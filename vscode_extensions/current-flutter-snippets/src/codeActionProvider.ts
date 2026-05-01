import * as vscode from "vscode";

export class CurrentCodeActionProvider implements vscode.CodeActionProvider {
  public static readonly providedCodeActionKinds = [
    vscode.CodeActionKind.RefactorRewrite,
  ];

  public provideCodeActions(
    document: vscode.TextDocument,
    range: vscode.Range | vscode.Selection,
  ): vscode.CodeAction[] | undefined {
    const line = document.lineAt(range.start.line);
    const match = line.text.match(
      /class\s+(\w+)\s+extends\s+(StatelessWidget|StatefulWidget)/,
    );

    if (match) {
      const className = match[1];
      const isStateful = match[2] === "StatefulWidget";

      // This is everything that needs to be replace.
      // For now this is all or nothing.
      const fullRange = this.findFullWidgetRange(
        document,
        range.start.line,
        className,
        isStateful,
      );

      const action = new vscode.CodeAction(
        `Convert '${className}' to CurrentWidget`,
        vscode.CodeActionKind.RefactorRewrite,
      );
      action.command = {
        command: "current-flutter-snippets.executeConvert",
        title: "Convert to CurrentWidget",
        arguments: [document, fullRange, className, isStateful],
      };
      return [action];
    }

    return undefined;
  }

  // This is used to find everything we need to replace, including the StatefulWidget and its State class if it exists
  private findFullWidgetRange(
    document: vscode.TextDocument,
    startLine: number,
    className: string,
    isStateful: boolean,
  ): vscode.Range {
    let endLine = startLine;
    let openBraces = 0;
    let foundStart = false;

    // Find the end of the first class
    for (let i = startLine; i < document.lineCount; i++) {
      const text = document.lineAt(i).text;
      if (!foundStart && text.includes("{")) {
        foundStart = true;
      }

      openBraces += (text.match(/\{/g) || []).length;
      openBraces -= (text.match(/\}/g) || []).length;

      if (foundStart && openBraces <= 0) {
        endLine = i;
        break;
      }
    }

    // If it's a StatefulWidget, we also need to find and include the State class
    if (isStateful) {
      const stateClassName = `_${className}State`;
      for (let i = endLine + 1; i < document.lineCount; i++) {
        const text = document.lineAt(i).text;
        if (text.includes(`class ${stateClassName}`)) {
          let stateEndLine = i;
          let stateOpenBraces = 0;
          let stateFoundStart = false;

          for (let j = i; j < document.lineCount; j++) {
            const stateText = document.lineAt(j).text;
            if (!stateFoundStart && stateText.includes("{")) {
              stateFoundStart = true;
            }
            stateOpenBraces += (stateText.match(/\{/g) || []).length;
            stateOpenBraces -= (stateText.match(/\}/g) || []).length;

            if (stateFoundStart && stateOpenBraces <= 0) {
              stateEndLine = j;
              break;
            }
          }
          endLine = stateEndLine;
          break;
        }
      }
    }

    return new vscode.Range(
      new vscode.Position(startLine, 0),
      new vscode.Position(endLine, document.lineAt(endLine).text.length),
    );
  }
}
