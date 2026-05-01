import * as vscode from "vscode";

export function registerAddToCurrentPropsCommand(context: vscode.ExtensionContext) {
  context.subscriptions.push(
    vscode.commands.registerCommand(
      "current-flutter-snippets.addToCurrentProps",
      async (document: vscode.TextDocument, propertyName: string) => {
        const fullText = document.getText();
        const currentPropsMatch = fullText.match(
          /get\s+currentProps\s*=>\s*\[([\s\S]*?)\]/,
        );

        if (!currentPropsMatch) {
          vscode.window.showErrorMessage("Could not find currentProps list.");
          return;
        }

        const listContent = currentPropsMatch[1];
        const trimmedContent = listContent.trimEnd();
        let newListContent = "";

        if (listContent.trim() === "") {
          newListContent = propertyName;
        } else if (trimmedContent.endsWith(",")) {
          newListContent = `${trimmedContent} ${propertyName}`;
        } else {
          newListContent = `${trimmedContent}, ${propertyName}`;
        }

        // Find the index of the opening bracket '['
        const openBracketIndex = fullText.indexOf("[", currentPropsMatch.index);
        const startPos = document.positionAt(openBracketIndex + 1);

        // The end position is just before the closing bracket ']'
        const closeBracketIndex = fullText.indexOf("]", openBracketIndex);
        const endPos = document.positionAt(closeBracketIndex);

        const edit = new vscode.WorkspaceEdit();
        edit.replace(
          document.uri,
          new vscode.Range(startPos, endPos),
          newListContent,
        );

        try {
          await vscode.workspace.applyEdit(edit);
          vscode.window.showInformationMessage(
            `Current: Added '${propertyName}' to currentProps.`,
          );
        } catch (error) {
          vscode.window.showErrorMessage(
            `Current: Failed to add property: ${error}`,
          );
        }
      },
    ),
  );
}
