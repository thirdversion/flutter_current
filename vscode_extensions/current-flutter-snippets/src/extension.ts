import * as vscode from "vscode";
import * as path from "path";

// --- 1. String Formatter ---
function toPascalCase(str: string): string {
  return str
    .split("_")
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
    .join("");
}

// --- 2. Pubspec Detective ---
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

// --- 3. Main Command Extension ---
export function activate(context: vscode.ExtensionContext) {
  let disposable = vscode.commands.registerCommand(
    "current-flutter-snippets.generateCurrentFiles",
    async (uri: vscode.Uri) => {
      let defaultUri: vscode.Uri | undefined;

      if (uri) {
        // If command invoked from context menu on a folder
        defaultUri = uri;
      } else if (vscode.window.activeTextEditor) {
        // Default to the directory of the active file
        defaultUri = vscode.Uri.file(
          path.dirname(vscode.window.activeTextEditor.document.uri.fsPath),
        );
      } else if (vscode.workspace.workspaceFolders) {
        // Default to the first workspace folder
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

class _${widgetClassName}State extends CurrentState<${widgetClassName}, ${viewModelClassName}>${isTextFields ? " with CurrentTextControllersLifecycleMixin" : ""} {
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

  context.subscriptions.push(disposable);
}

export function deactivate() {}
