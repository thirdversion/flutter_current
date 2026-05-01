import * as vscode from "vscode";
import * as path from "path";
import { isCurrentV3Plus } from "../utils/workspace";
import { toSnakeCase, toPascalCase } from "../utils/string";
import { extractOtherMembers, extractBuildMethodBody } from "../utils/dart";

export function registerExecuteConvertCommand(context: vscode.ExtensionContext) {
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

        const usesCupertino = fileText.includes(
          "package:flutter/cupertino.dart",
        );
        const flutterImport = usesCupertino
          ? "import 'package:flutter/cupertino.dart';"
          : "import 'package:flutter/material.dart';";

        const currentImport = "import 'package:current/current.dart';";
        const viewModelImport = `import '${viewModelFileName}';`;

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
            `Current: Successfully converted ${className} to CurrentWidget!`,
          );
        } catch (error) {
          vscode.window.showErrorMessage(`Failed to convert: ${error}`);
        }
      },
    ),
  );
}
