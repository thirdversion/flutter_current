import * as vscode from "vscode";

export function registerAddTextControllerSupportCommand(context: vscode.ExtensionContext) {
  context.subscriptions.push(
    vscode.commands.registerCommand(
      "current-flutter-snippets.addTextControllerSupport",
      async (
        document: vscode.TextDocument,
        className: string,
        startLine: number,
      ) => {
        const fullText = document.getText();
        const edit = new vscode.WorkspaceEdit();
        let editApplied = false;

        // Find the class declaration to add the mixin
        const classStartIdx = fullText.indexOf(`class ${className}`);
        if (classStartIdx !== -1) {
          const braceIdx = fullText.indexOf("{", classStartIdx);
          if (braceIdx !== -1) {
            const classDeclaration = fullText.substring(
              classStartIdx,
              braceIdx,
            );

            if (
              !classDeclaration.includes("CurrentTextControllersLifecycleMixin")
            ) {
              let mixinInsertText = "";
              if (classDeclaration.includes("with ")) {
                // If it already has mixins, append ours
                // But need to be careful about spacing. The safest is to just add it at the end of the existing 'with' list, right before the brace.
                mixinInsertText = ", CurrentTextControllersLifecycleMixin ";
              } else {
                mixinInsertText = " with CurrentTextControllersLifecycleMixin ";
              }

              // Insert just before the brace
              edit.insert(
                document.uri,
                document.positionAt(braceIdx),
                mixinInsertText,
              );
              editApplied = true;
            }
          }
        }

        // 2. Add bindCurrentControllers() if it doesn't exist
        if (!fullText.match(/void\s+bindCurrentControllers\s*\(\)\s*\{/)) {
          const buildMethodMatch = fullText.match(
            /@override\s+Widget\s+build\s*\(/,
          );
          if (buildMethodMatch && buildMethodMatch.index !== undefined) {
            const bindMethod = `  @override\n  void bindCurrentControllers() {}\n\n`;
            edit.insert(
              document.uri,
              document.positionAt(buildMethodMatch.index),
              bindMethod,
            );
            editApplied = true;
          }
        }

        if (editApplied) {
          try {
            await vscode.workspace.applyEdit(edit);
            vscode.window.showInformationMessage(
              `Current: Added CurrentTextController support to '${className}'.`,
            );
          } catch (error) {
            vscode.window.showErrorMessage(
              `Current: Failed to add CurrentTextController support: ${error}`,
            );
          }
        }
      },
    ),
  );
}
