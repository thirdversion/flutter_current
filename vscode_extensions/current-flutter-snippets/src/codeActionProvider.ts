import * as vscode from "vscode";
import { isCurrentV3Plus } from "./utils/workspace";

export class CurrentCodeActionProvider implements vscode.CodeActionProvider {
  public static readonly providedCodeActionKinds = [
    vscode.CodeActionKind.RefactorRewrite,
  ];

  public async provideCodeActions(
    document: vscode.TextDocument,
    range: vscode.Range | vscode.Selection,
  ): Promise<vscode.CodeAction[] | undefined> {
    const line = document.lineAt(range.start.line);
    const actions: vscode.CodeAction[] = [];

    // 1. Detect Widget Conversion
    const match = line.text.match(
      /class\s+(\w+)\s+extends\s+(StatelessWidget|StatefulWidget)/,
    );

    if (match) {
      const className = match[1];
      const isStateful = match[2] === "StatefulWidget";

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
      actions.push(action);
    }

    // 2. Detect CurrentProperty (check current line and 2 lines above to handle multi-line declarations)
    let propertyMatch: RegExpMatchArray | null = null;
    let propertyName: string | undefined;

    for (let i = 0; i <= 2; i++) {
      const lineIndex = range.start.line - i;
      if (lineIndex < 0) {
        break;
      }
      const checkLine = document.lineAt(lineIndex).text;
      propertyMatch = checkLine.match(
        /(?:final|var|late)?\s+(\w+)\s*(?::\s*[^=]+)?\s*=\s*(?:const\s+)?(?:Current(?:Nullable)?(?:Int|Double|String|Bool|DateTime|List|Map)?Property(?:\.\w+)?|create(?:Null)?Property)\s*[<(]/,
      );
      if (propertyMatch) {
        propertyName = propertyMatch[1];
        break;
      }
    }

    if (propertyName) {
      // Find currentProps getter
      const fullText = document.getText();
      const currentPropsMatch = fullText.match(
        /get\s+currentProps\s*=>\s*\[([\s\S]*?)\]/,
      );

      if (currentPropsMatch) {
        const currentPropsText = currentPropsMatch[1];
        const isAlreadyAdded = new RegExp(`\\b${propertyName}\\b`).test(
          currentPropsText,
        );

        if (!isAlreadyAdded) {
          const action = new vscode.CodeAction(
            `Add '${propertyName}' to currentProps`,
            vscode.CodeActionKind.RefactorRewrite,
          );
          action.command = {
            command: "current-flutter-snippets.addToCurrentProps",
            title: "Add to currentProps",
            arguments: [document, propertyName],
          };
          actions.push(action);
        }
      }
    }

    // Find currentProps
    const isCurrentPropsLine = line.text.match(/currentProps/);
    if (isCurrentPropsLine) {
      const fullText = document.getText();
      const currentPropsMatch = fullText.match(
        /get\s+currentProps\s*=>\s*\[([\s\S]*?)\]/,
      );

      if (currentPropsMatch) {
        const currentPropsText = currentPropsMatch[1];

        // Find all CurrentProperty definitions in the file
        const propertyRegex =
          /(?:final|var|late)?\s+(\w+)\s*(?::\s*[^=]+)?\s*=\s*(?:const\s+)?(?:Current(?:Nullable)?(?:Int|Double|String|Bool|DateTime|List|Map)?Property(?:\.\w+)?|create(?:Null)?Property)\s*[<(]/g;

        const missingProperties: string[] = [];
        let match;
        while ((match = propertyRegex.exec(fullText)) !== null) {
          const propertyNameMatch = match[1];
          const isAlreadyAdded = new RegExp(`\\b${propertyNameMatch}\\b`).test(
            currentPropsText,
          );
          if (!isAlreadyAdded) {
            missingProperties.push(propertyNameMatch);
          }
        }

        if (missingProperties.length > 0) {
          const action = new vscode.CodeAction(
            `Add all missing properties to currentProps`,
            vscode.CodeActionKind.RefactorRewrite,
          );
          action.command = {
            command: "current-flutter-snippets.addAllMissingToCurrentProps",
            title: "Add all missing properties to currentProps",
            arguments: [document, missingProperties],
          };
          actions.push(action);
        }
      }
    }

    // Find CurrentTextController
    const controllerMatch = line.text.match(
      /(?:final|var|late)?\s+(\w+)\s*(?::\s*[^=]+)?\s*=\s*Current(?:[A-Za-z]+)?TextController(?:\.\w+)?(?:\s*<[^>]+>)?\s*\(/,
    );

    if (controllerMatch) {
      const controllerName = controllerMatch[1];
      const fullText = document.getText();
      const isAlreadyBound = new RegExp(`\\b${controllerName}\\.bind\\b`).test(
        fullText,
      );

      if (!isAlreadyBound) {
        const action = new vscode.CodeAction(
          `Bind '${controllerName}' to a property`,
          vscode.CodeActionKind.RefactorRewrite,
        );
        action.command = {
          command: "current-flutter-snippets.bindCurrentController",
          title: "Bind Controller",
          arguments: [document, controllerName],
        };
        actions.push(action);
      }
    }

    // Find CurrentState without CurrentTextControllersLifecycleMixin
    const stateMatch = line.text.match(
      /class\s+(\w+)\s+extends\s+CurrentState\s*</,
    );

    if (stateMatch) {
      const stateClassName = stateMatch[1];
      const fullText = document.getText();

      // Find the class declaration line(s) to check for the mixin
      // We need to look from the start of the class to the opening brace
      const classStartIdx = fullText.indexOf(`class ${stateClassName}`);
      const braceIdx = fullText.indexOf("{", classStartIdx);
      const classDeclaration = fullText.substring(classStartIdx, braceIdx);

      const hasMixin = classDeclaration.includes(
        "CurrentTextControllersLifecycleMixin",
      );

      if (!hasMixin) {
        const workspaceFolder = vscode.workspace.getWorkspaceFolder(
          document.uri,
        );
        const isV3 = workspaceFolder
          ? await isCurrentV3Plus(workspaceFolder.uri)
          : false;

        if (isV3) {
          const action = new vscode.CodeAction(
            `Add CurrentTextController support to '${stateClassName}'`,
            vscode.CodeActionKind.RefactorRewrite,
          );
          action.command = {
            command: "current-flutter-snippets.addTextControllerSupport",
            title: "Add TextController Support",
            arguments: [document, stateClassName, range.start.line],
          };
          actions.push(action);
        }
      }
    }

    // Check if the file is empty to scaffold CurrentWidget and ViewModel
    const documentText = document.getText().trim();
    if (documentText === "") {
      const action = new vscode.CodeAction(
        "Scaffold CurrentWidget and ViewModel",
        vscode.CodeActionKind.RefactorRewrite,
      );
      action.command = {
        command: "current-flutter-snippets.scaffoldEmptyFile",
        title: "Scaffold CurrentWidget and ViewModel",
        arguments: [document],
      };
      actions.push(action);
    }

    return actions.length > 0 ? actions : undefined;
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
