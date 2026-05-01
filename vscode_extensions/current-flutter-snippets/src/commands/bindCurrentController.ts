import * as vscode from "vscode";

export function registerBindCurrentControllerCommand(context: vscode.ExtensionContext) {
  context.subscriptions.push(
    vscode.commands.registerCommand(
      "current-flutter-snippets.bindCurrentController",
      async (document: vscode.TextDocument, controllerName: string) => {
        const fullText = document.getText();

        let defaultPropertyName = controllerName.replace(/Controller$/i, "");
        if (defaultPropertyName === controllerName) {
          defaultPropertyName = "";
        }

        const propertyName = await vscode.window.showInputBox({
          prompt: `Enter the ViewModel property name to bind to '${controllerName}'`,
          value: defaultPropertyName,
        });

        if (!propertyName) {
          return;
        }

        const edit = new vscode.WorkspaceEdit();
        const bindStatement = `\n    ${controllerName}.bind(property: viewModel.${propertyName}, lifecycleProvider: this);`;

        const bindMethodMatch = fullText.match(
          /void\s+bindCurrentControllers\s*\(\)\s*\{/,
        );

        if (bindMethodMatch) {
          // Method exists, insert inside it
          const insertIndex =
            bindMethodMatch.index! + bindMethodMatch[0].length;
          edit.insert(
            document.uri,
            document.positionAt(insertIndex),
            bindStatement,
          );

          try {
            await vscode.workspace.applyEdit(edit);
            vscode.window.showInformationMessage(
              `Current: Bound '${controllerName}'.`,
            );
          } catch (error) {
            vscode.window.showErrorMessage(
              `Current: Failed to bind controller: ${error}`,
            );
          }
        } else {
          // Method doesn't exist, we should create it
          // Look for the build method or any place inside the state class
          const buildMethodMatch = fullText.match(
            /@override\s+Widget\s+build\s*\(/,
          );
          if (buildMethodMatch) {
            const insertIndex = buildMethodMatch.index!;
            const bindMethod = `  @override\n  void bindCurrentControllers() {${bindStatement}\n  }\n\n  `;
            edit.insert(
              document.uri,
              document.positionAt(insertIndex),
              bindMethod,
            );

            try {
              await vscode.workspace.applyEdit(edit);
              vscode.window.showInformationMessage(
                `Current: Bound '${controllerName}'. Note: Ensure you add 'with CurrentTextControllersLifecycleMixin' to your CurrentState class.`,
              );
            } catch (error) {
              vscode.window.showErrorMessage(
                `Current: Failed to bind controller: ${error}`,
              );
            }
          } else {
            vscode.window.showErrorMessage(
              "Current: Could not find a suitable place to insert 'bindCurrentControllers'. Please bind it manually.",
            );
          }
        }
      },
    ),
  );
}
