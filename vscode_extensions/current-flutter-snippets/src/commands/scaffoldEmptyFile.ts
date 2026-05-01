import * as vscode from "vscode";
import * as path from "path";
import { isCurrentV3Plus } from "../utils/workspace";
import { toPascalCase } from "../utils/string";

export function registerScaffoldEmptyFileCommand(
  context: vscode.ExtensionContext,
) {
  context.subscriptions.push(
    vscode.commands.registerCommand(
      "current-flutter-snippets.scaffoldEmptyFile",
      async (document: vscode.TextDocument) => {
        const workspaceFolder = vscode.workspace.getWorkspaceFolder(
          document.uri,
        );
        const isV3 = workspaceFolder
          ? await isCurrentV3Plus(workspaceFolder.uri)
          : false;

        const fileName = path.basename(document.uri.fsPath, ".dart");
        const defaultFeatureName = fileName.replace(/_widget$/, "");

        const featureName = await vscode.window.showInputBox({
          prompt: "Enter the feature name in snake_case (e.g., 'user_profile')",
          value: defaultFeatureName,
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

        const isTextFields =
          widgetType === "Current Widget + CurrentTextFields";

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

        const viewModelFileName = `${featureName}_view_model.dart`;
        const targetDirectory = vscode.Uri.file(
          path.dirname(document.uri.fsPath),
        );
        const viewModelUri = vscode.Uri.joinPath(
          targetDirectory,
          viewModelFileName,
        );

        const viewModelContent = `import 'package:current/current.dart';\n\nclass ${viewModelClassName} extends CurrentViewModel {\n  // TODO: add Current Properties\n\n  @override\n  Iterable<CurrentProperty> get currentProps => []; // TODO: add Current Properties to this list\n}\n`;

        const widgetContent = `import 'package:current/current.dart';\n${flutterImport}\n\nimport '${viewModelFileName}';\n\nclass ${widgetClassName} extends CurrentWidget<${viewModelClassName}> {\n  const ${widgetClassName}({\n    required super.viewModel,\n    super.key,\n  });\n\n  @override\n  CurrentState<CurrentWidget<CurrentViewModel>, ${viewModelClassName}> createCurrent() =>\n      _${widgetClassName}State(viewModel);\n}\n\nclass _${widgetClassName}State extends CurrentState<${widgetClassName}, ${viewModelClassName}>${
          isTextFields ? " with CurrentTextControllersLifecycleMixin" : ""
        } {\n  _${widgetClassName}State(super.viewModel);${
          isTextFields
            ? "\n\n  @override\n  void bindCurrentControllers() {}"
            : ""
        }\n\n  @override\n  Widget build(BuildContext context) {\n    return const Placeholder();\n  }\n}\n`;

        const edit = new vscode.WorkspaceEdit();
        // Replace current empty file content with widget content
        const fullRange = new vscode.Range(0, 0, document.lineCount, 0);
        edit.replace(document.uri, fullRange, widgetContent);
        // Create view model file
        edit.createFile(viewModelUri, { ignoreIfExists: true });

        try {
          await vscode.workspace.applyEdit(edit);

          const encoder = new TextEncoder();
          await vscode.workspace.fs.writeFile(
            viewModelUri,
            encoder.encode(viewModelContent),
          );

          vscode.window.showInformationMessage(
            `Successfully scaffolded CurrentWidget and ${viewModelFileName}!`,
          );

          // Instead of taking the user to the viewmodel after running this action like the Command Palette action,
          // open the viewmodel in a split view. It's less jarring
          const doc = await vscode.workspace.openTextDocument(viewModelUri);
          await vscode.window.showTextDocument(doc, {
            preview: false,
            viewColumn: vscode.ViewColumn.Beside,
          });
        } catch (error) {
          vscode.window.showErrorMessage(`Failed to scaffold files: ${error}`);
        }
      },
    ),
  );
}
