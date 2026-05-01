import * as vscode from "vscode";
import { CurrentCodeActionProvider } from "./codeActionProvider";

// Import Command Registrations
import { registerExecuteConvertCommand } from "./commands/executeConvert";
import { registerAddToCurrentPropsCommand } from "./commands/addToCurrentProps";
import { registerAddAllMissingToCurrentPropsCommand } from "./commands/addAllMissingToCurrentProps";
import { registerBindCurrentControllerCommand } from "./commands/bindCurrentController";
import { registerAddTextControllerSupportCommand } from "./commands/addTextControllerSupport";
import { registerGenerateCurrentFilesCommand } from "./commands/generateCurrentFiles";
import { registerScaffoldEmptyFileCommand } from "./commands/scaffoldEmptyFile";

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

  // Register all Commands
  registerExecuteConvertCommand(context);
  registerAddToCurrentPropsCommand(context);
  registerAddAllMissingToCurrentPropsCommand(context);
  registerBindCurrentControllerCommand(context);
  registerAddTextControllerSupportCommand(context);
  registerGenerateCurrentFilesCommand(context);
  registerScaffoldEmptyFileCommand(context);
}

export function deactivate() {}
