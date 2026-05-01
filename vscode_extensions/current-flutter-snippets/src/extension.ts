import * as vscode from "vscode";
import * as path from "path";
import { CurrentCodeActionProvider } from "./codeActionProvider";

function toPascalCase(str: string): string {
  return str
    .split("_")
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
    .join("");
}

function toSnakeCase(str: string): string {
  return str.replace(/([a-z])([A-Z])/g, "$1_$2").toLowerCase();
}

function extractBuildMethodBody(text: string): string | undefined {
  const range = getBuildMethodRange(text);
  if (!range) {
    return undefined;
  }

  const headerMatch = text
    .substring(range.start, range.end)
    .match(/Widget\s+build\s*\(\s*BuildContext\s+context\s*\)\s*\{/);
  if (!headerMatch) {
    return undefined;
  }

  const startIndex = range.start + headerMatch.index! + headerMatch[0].length;
  // The range.end is the closing brace of the build method
  return text.substring(startIndex, range.end - 1).trim();
}

function getBuildMethodRange(
  text: string,
): { start: number; end: number } | undefined {
  // Try to include the @override annotation if present
  const buildMatch = text.match(
    /(@override\s+)?Widget\s+build\s*\(\s*BuildContext\s+context\s*\)\s*\{/,
  );
  if (!buildMatch) {
    return undefined;
  }

  const startIndex = buildMatch.index!;
  const bodyStartIndex = startIndex + buildMatch[0].length;
  let openBraces = 1;
  let i = bodyStartIndex;

  while (i < text.length && openBraces > 0) {
    if (text[i] === "{") {
      openBraces++;
    } else if (text[i] === "}") {
      openBraces--;
    }
    i++;
  }

  if (openBraces === 0) {
    return { start: startIndex, end: i };
  }
  return undefined;
}

function extractOtherMembers(text: string, className: string): string {
  let result = text;

  // Figure out the range of the class body
  const firstBrace = result.indexOf("{");
  const lastBrace = result.lastIndexOf("}");
  if (firstBrace === -1 || lastBrace === -1) {
    return "";
  }

  result = result.substring(firstBrace + 1, lastBrace).trim();

  // tmp remove the build method (will put it back later)
  const buildRange = getBuildMethodRange(result);
  if (buildRange) {
    result =
      result.substring(0, buildRange.start) + result.substring(buildRange.end);
  }

  // remove the constructor (handles both named and unnamed constructors, with or without 'const')
  const constructorRegex = new RegExp(
    `(const\\s+)?${className}\\s*\\([\\s\\S]*?\\)\\s*(\\{[\\s\\S]*?\\}|;)?`,
    "g",
  );
  result = result.replace(constructorRegex, "");

  // for StatefulWidgets, also remove the createState method. Current has it's own special way of handling state creation.
  const createStateRegex =
    /(@override\s+)?State<.*>\s+createState\(\)\s*=>\s*.*;/g;
  result = result.replace(createStateRegex, "");

  return result.trim();
}

// Since the new Current Text Fields and validation features are only in 3.0.0+
// Don't want to give devs the option to generate code that won't even work for them.
// If this returns false, it will just generate the regular Current Widget and no option to select with Text Fields.
async function isCurrentV3Plus(workspaceUri: vscode.Uri): Promise<boolean> {
  try {
    const pubspecUri = vscode.Uri.joinPath(workspaceUri, "pubspec.yaml");
    const fileData = await vscode.workspace.fs.readFile(pubspecUri);
    const pubspecContent = new TextDecoder().decode(fileData);

    const versionRegex = /current:\s*[<>=~^\s]*(\d+)\.\d+\.\d+/;
    const match = pubspecContent.match(versionRegex);

    let isV3 = false;
    if (match && match[1]) {
      const majorVersion = parseInt(match[1], 10);
      if (majorVersion >= 3) {
        isV3 = true;
      }
    }
    vscode.commands.executeCommand(
      "setContext",
      "current-flutter-snippets.isV3Plus",
      isV3,
    );
    return isV3;
  } catch (error) {
    return false;
  }
}

export function activate(context: vscode.ExtensionContext) {
  // Register Code Action Provider
  context.subscriptions.push(
    vscode.languages.registerCodeActionsProvider(
      "dart",
      new CurrentCodeActionProvider(),
      {
        providedCodeActionKinds:
          CurrentCodeActionProvider.providedCodeActionKinds,
      },
    ),
  );

  context.subscriptions.push(
    vscode.commands.registerCommand(
      "current-flutter-snippets.executeConvert",
      async (
        document: vscode.TextDocument,
        range: vscode.Range,
        className: string,
        isStateful: boolean,
      ) => {
        const workspaceFolder = vscode.workspace.getWorkspaceFolder(
          document.uri,
        );
        const isV3 = workspaceFolder
          ? await isCurrentV3Plus(workspaceFolder.uri)
          : false;

        const featureName = await vscode.window.showInputBox({
          prompt: "Enter the feature name in snake_case",
          value: toSnakeCase(className),
        });

        if (!featureName) {
          return;
        }

        let widgetType: string | undefined = "Current Widget";

        if (isV3) {
          widgetType = await vscode.window.showQuickPick(
            ["Current Widget", "Current Widget + CurrentTextFields"],
            { placeHolder: "Select the type of Current Widget to generate" },
          );
          if (!widgetType) {
            return;
          }
        }

        const isTextFields =
          widgetType === "Current Widget + CurrentTextFields";

        const originalText = document.getText(range);
        let widgetClassMembers = "";
        let stateClassMembers = "";
        let buildMethodBody = "";

        if (isStateful) {
          // Split into the two classes
          const secondClassStart = originalText.indexOf(
            "class",
            originalText.indexOf("{"),
          );
          if (secondClassStart !== -1) {
            const firstClassText = originalText.substring(0, secondClassStart);
            const secondClassText = originalText.substring(secondClassStart);

            widgetClassMembers = extractOtherMembers(firstClassText, className);
            stateClassMembers = extractOtherMembers(
              secondClassText,
              `_${className}State`,
            );
            buildMethodBody = extractBuildMethodBody(secondClassText) || "";
          }
        } else {
          widgetClassMembers = ""; // Usually nothing stays in the Stateless part except constructor
          stateClassMembers = extractOtherMembers(originalText, className);
          buildMethodBody = extractBuildMethodBody(originalText) || "";
        }

        const buildMethodContent = buildMethodBody
          ? `\n    ${buildMethodBody}`
          : "\n    return const Placeholder();";

        const viewModelClassName = `${toPascalCase(featureName)}ViewModel`;
        const viewModelFileName = `${featureName}_view_model.dart`;
        const targetDirectory = vscode.Uri.file(
          path.dirname(document.uri.fsPath),
        );
        const viewModelUri = vscode.Uri.joinPath(
          targetDirectory,
          viewModelFileName,
        );

        const viewModelContent = `import 'package:current/current.dart';

class ${viewModelClassName} extends CurrentViewModel {
  // TODO: add Current Properties

  @override
  Iterable<CurrentProperty> get currentProps => []; // TODO: add Current Properties to this list
}
`;

        const widgetClassName = className;
        const widgetContent = `class ${widgetClassName} extends CurrentWidget<${viewModelClassName}> {
  const ${widgetClassName}({
    required super.viewModel,
    super.key,
  });
  ${widgetClassMembers}

  @override
  CurrentState<CurrentWidget<CurrentViewModel>, ${viewModelClassName}> createCurrent() =>
      _${widgetClassName}State(viewModel);
}

class _${widgetClassName}State extends CurrentState<${widgetClassName}, ${viewModelClassName}>${
          isTextFields ? " with CurrentTextControllersLifecycleMixin" : ""
        } {
  _${widgetClassName}State(super.viewModel);
  ${stateClassMembers}${
    isTextFields
      ? `

  @override
  void bindCurrentControllers() {}`
      : ""
  }

  @override
  Widget build(BuildContext context) {${buildMethodContent}
  }
}
`;

        const edit = new vscode.WorkspaceEdit();

        edit.createFile(viewModelUri, { ignoreIfExists: true });

        const fileText = document.getText();

        // Ask the user Material or Cupertino. We used to not import anything
        // and had the user import manually, but that grew to be really annoying in practice.
        const usesCupertino = fileText.includes(
          "package:flutter/cupertino.dart",
        );
        const flutterImport = usesCupertino
          ? "import 'package:flutter/cupertino.dart';"
          : "import 'package:flutter/material.dart';";

        // We'll remove any existing instances of these specific imports to make sure they appear
        // at the top in the correct order without duplicates. Prevents an problem
        // showing up in the users vs code environment if they have alphabetical import ordering lints
        const currentImport = "import 'package:current/current.dart';";
        const viewModelImport = `import '${viewModelFileName}';`;

        // Regex to find and remove the imports if they exist (handling both single and double quotes)
        const importsToRemove = [
          /import\s+['"]package:current\/current\.dart['"];\s*\n?/g,
          /import\s+['"]package:flutter\/(material|cupertino)\.dart['"];\s*\n?/g,
          new RegExp(`import\\s+['"]${viewModelFileName}['"];\\s*\\n?`, "g"),
        ];

        for (const regex of importsToRemove) {
          let match;
          while ((match = regex.exec(fileText)) !== null) {
            const startPos = document.positionAt(match.index);
            const endPos = document.positionAt(match.index + match[0].length);
            edit.delete(document.uri, new vscode.Range(startPos, endPos));
          }
        }

        const newImportsBlock = `${currentImport}\n${flutterImport}\n${viewModelImport}\n\n`;
        edit.insert(document.uri, new vscode.Position(0, 0), newImportsBlock);

        // 3. Replace the Widget class(es)
        edit.replace(document.uri, range, widgetContent);

        try {
          await vscode.workspace.applyEdit(edit);

          const encoder = new TextEncoder();
          await vscode.workspace.fs.writeFile(
            viewModelUri,
            encoder.encode(viewModelContent),
          );

          vscode.window.showInformationMessage(
            `Successfully converted ${className} to CurrentWidget!`,
          );
        } catch (error) {
          vscode.window.showErrorMessage(`Failed to convert: ${error}`);
        }
      },
    ),
  );

  let generateDisposable = vscode.commands.registerCommand(
    "current-flutter-snippets.generateCurrentFiles",
    async (uri: vscode.Uri) => {
      let defaultUri: vscode.Uri | undefined;

      if (uri) {
        defaultUri = uri;
      } else if (vscode.window.activeTextEditor) {
        defaultUri = vscode.Uri.file(
          path.dirname(vscode.window.activeTextEditor.document.uri.fsPath),
        );
      } else if (vscode.workspace.workspaceFolders) {
        defaultUri = vscode.workspace.workspaceFolders[0].uri;
      }

      const selectedFolders = await vscode.window.showOpenDialog({
        canSelectFiles: false,
        canSelectFolders: true,
        canSelectMany: false,
        defaultUri: defaultUri,
        openLabel: "Select folder for Current files",
      });

      if (!selectedFolders || selectedFolders.length === 0) {
        return;
      }
      const targetDirectory = selectedFolders[0];

      const workspaceFolder =
        vscode.workspace.getWorkspaceFolder(targetDirectory);
      const workspaceUri = workspaceFolder
        ? workspaceFolder.uri
        : targetDirectory;
      const isV3 = await isCurrentV3Plus(workspaceUri);

      const featureName = await vscode.window.showInputBox({
        prompt: "Enter the feature name in snake_case (e.g., 'user_profile')",
        placeHolder: "feature_name",
      });

      if (!featureName) {
        return;
      }

      let widgetType: string | undefined = "Regular Current Widget";

      if (isV3) {
        widgetType = await vscode.window.showQuickPick(
          ["Current Widget", "Current Widget + CurrentTextFields"],
          { placeHolder: "Select the type of Current Widget to generate" },
        );
        if (!widgetType) {
          return;
        }
      }

      const designSystem =
        (await vscode.window.showQuickPick(["Material", "Cupertino"], {
          placeHolder: "Select the design system (Default: Material)",
        })) || "Material";

      const flutterImport =
        designSystem === "Material"
          ? "import 'package:flutter/material.dart';"
          : "import 'package:flutter/cupertino.dart';";

      const baseClassName = toPascalCase(featureName);
      const widgetClassName = `${baseClassName}Widget`;
      const viewModelClassName = `${baseClassName}ViewModel`;

      const widgetFileName = `${featureName}.dart`;
      const viewModelFileName = `${featureName}_view_model.dart`;
      const widgetUri = vscode.Uri.joinPath(targetDirectory, widgetFileName);
      const viewModelUri = vscode.Uri.joinPath(
        targetDirectory,
        viewModelFileName,
      );

      const viewModelContent = `import 'package:current/current.dart';

class ${viewModelClassName} extends CurrentViewModel {
  // TODO: add Current Properties

  @override
  Iterable<CurrentProperty> get currentProps => []; // TODO: add Current Properties to this list
}
`;

      const isTextFields = widgetType === "Current Widget + CurrentTextFields";

      const widgetContent = `import 'package:current/current.dart';
${flutterImport}

import '${viewModelFileName}';

class ${widgetClassName} extends CurrentWidget<${viewModelClassName}> {
  const ${widgetClassName}({
    required super.viewModel,
    super.key,
  });

  @override
  CurrentState<CurrentWidget<CurrentViewModel>, ${viewModelClassName}> createCurrent() =>
      _${widgetClassName}State(viewModel);
}

class _${widgetClassName}State extends CurrentState<${widgetClassName}, ${viewModelClassName}>${
        isTextFields ? " with CurrentTextControllersLifecycleMixin" : ""
      } {
  _${widgetClassName}State(super.viewModel);${
    isTextFields
      ? `

  @override
  void bindCurrentControllers() {}`
      : ""
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
`;

      try {
        const widgetExists = await vscode.workspace.fs.stat(widgetUri).then(
          () => true,
          () => false,
        );
        const viewModelExists = await vscode.workspace.fs
          .stat(viewModelUri)
          .then(
            () => true,
            () => false,
          );

        if (widgetExists || viewModelExists) {
          vscode.window.showErrorMessage(
            `Files for '${featureName}' already exist in this directory!`,
          );
          return;
        }

        const encoder = new TextEncoder();
        await vscode.workspace.fs.writeFile(
          widgetUri,
          encoder.encode(widgetContent),
        );
        await vscode.workspace.fs.writeFile(
          viewModelUri,
          encoder.encode(viewModelContent),
        );

        vscode.window.showInformationMessage(
          `Successfully generated ${widgetFileName} and ${viewModelFileName}!`,
        );

        const doc = await vscode.workspace.openTextDocument(viewModelUri);
        await vscode.window.showTextDocument(doc);
      } catch (error) {
        vscode.window.showErrorMessage(
          `Failed to create or open files: ${error}`,
        );
      }
    },
  );

  context.subscriptions.push(generateDisposable);
}

export function deactivate() {}
