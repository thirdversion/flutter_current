export function extractBuildMethodBody(text: string): string | undefined {
  const range = getBuildMethodRange(text);
  if (!range) {
    return undefined;
  }

  const headerMatch = text
    .substring(range.start, range.end)
    .match(/Widget\s+build\s*\(\s*BuildContext\s+context\s*\)\s*\{/);
  if (!headerMatch) {
    return undefined;
  }

  const startIndex = range.start + headerMatch.index! + headerMatch[0].length;
  // The range.end is the closing brace of the build method
  return text.substring(startIndex, range.end - 1).trim();
}

export function getBuildMethodRange(
  text: string,
): { start: number; end: number } | undefined {
  // Try to include the @override annotation if present
  const buildMatch = text.match(
    /(@override\s+)?Widget\s+build\s*\(\s*BuildContext\s+context\s*\)\s*\{/,
  );
  if (!buildMatch) {
    return undefined;
  }

  const startIndex = buildMatch.index!;
  const bodyStartIndex = startIndex + buildMatch[0].length;
  let openBraces = 1;
  let i = bodyStartIndex;

  while (i < text.length && openBraces > 0) {
    if (text[i] === "{") {
      openBraces++;
    } else if (text[i] === "}") {
      openBraces--;
    }
    i++;
  }

  if (openBraces === 0) {
    return { start: startIndex, end: i };
  }
  return undefined;
}

export function extractOtherMembers(text: string, className: string): string {
  let result = text;

  // Figure out the range of the class body
  const firstBrace = result.indexOf("{");
  const lastBrace = result.lastIndexOf("}");
  if (firstBrace === -1 || lastBrace === -1) {
    return "";
  }

  result = result.substring(firstBrace + 1, lastBrace).trim();

  // tmp remove the build method (will put it back later)
  const buildRange = getBuildMethodRange(result);
  if (buildRange) {
    result =
      result.substring(0, buildRange.start) + result.substring(buildRange.end);
  }

  // remove the constructor (handles both named and unnamed constructors, with or without 'const')
  const constructorRegex = new RegExp(
    `(const\\s+)?${className}\\s*\\([\\s\\S]*?\\)\\s*(\\{[\\s\\S]*?\\}|;)?`,
    "g",
  );
  result = result.replace(constructorRegex, "");

  // for StatefulWidgets, also remove the createState method. Current has it's own special way of handling state creation.
  const createStateRegex =
    /(@override\s+)?State<.*>\s+createState\(\)\s*=>\s*.*;/g;
  result = result.replace(createStateRegex, "");

  return result.trim();
}
