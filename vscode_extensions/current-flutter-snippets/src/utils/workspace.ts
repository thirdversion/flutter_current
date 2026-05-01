import * as vscode from "vscode";

// Since the new Current Text Fields and validation features are only in 3.0.0+
// Don't want to give devs the option to generate code that won't even work for them.
// If this returns false, it will just generate the regular Current Widget and no option to select with Text Fields.
export async function isCurrentV3Plus(
  workspaceUri: vscode.Uri,
): Promise<boolean> {
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
