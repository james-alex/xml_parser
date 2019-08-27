import 'package:meta/meta.dart';
import '../xml_node.dart';

/// Removes all blocks of text delimited with XML comment delimiters.
String removeComments(String input) {
  assert(input != null);

  while (input.contains('<!--') && input.contains('-->')) {
    input = input.replaceRange(
      input.indexOf('<!--'),
      input.indexOf('-->') + 3,
      '',
    );
  }

  return input;
}

/// Removes the first and last character from a string,
/// if they match one of the common pairs of delimiters.
String stripDelimiters(String input) {
  assert(input != null);

  final String first = input.substring(0, 1);
  final String last = input.substring(input.length - 1);

  if ((first == '\'' && last == '\'') ||
      (first == '"' && last == '"') ||
      (first == '<' && last == '>') ||
      (first == '(' && last == ')') ||
      (first == '[' && last == ']') ||
      (first == '{' && last == '}')) {
    return input.substring(1, input.length - 1);
  }

  return input;
}

/// Replaces all whitespace in [input] with a single space
/// and removes unnecessary whitespace between nodes.
String trimWhitespace(String input) {
  assert(input != null);

  return input
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'(?<=>) (?=\S)|(?<=\S) (?=<)'), '')
      .trim();
}

/// Prepends a string with `indent * nestingLevel` and
/// appends it with a newline.
String formatLine(String input, int nestingLevel, String indent) {
  assert(input != null);
  assert(nestingLevel != null && nestingLevel >= 0);
  assert(indent != null);

  final String lineIndent = indent * nestingLevel;

  return lineIndent + input + '\r\n';
}

String childrenToString({
  @required List<XmlNode> children,
  bool encodeCharacterEntities = true,
  String encodeCharacters,
  bool doubleQuotes = true,
}) {
  assert(children != null);
  assert(encodeCharacterEntities != null);
  assert(doubleQuotes != null);

  String string = '';

  children.forEach((XmlNode child) {
    String node;

    if (child is XmlAttlist) {
      node = child.toString(doubleQuotes);
    } else if (child is XmlEtd) {
      node = child.toString();
    } else if (child is XmlCdata) {
      node = child.toString();
    } else if (child is XmlComment) {
      node = child.toString();
    } else if (child is XmlConditional) {
      node = child.toString(
        doubleQuotes: doubleQuotes,
        encodeCharacterEntities: encodeCharacterEntities,
        encodeCharacters: encodeCharacters,
      );
    } else if (child is XmlDeclaration) {
      node = child.toString(doubleQuotes);
    } else if (child is XmlDoctype) {
      node = child.toString(
        doubleQuotes: doubleQuotes,
        encodeCharacterEntities: encodeCharacterEntities,
        encodeCharacters: encodeCharacters,
      );
    } else if (child is XmlElement) {
      node = child.toString(
        doubleQuotes: doubleQuotes,
        encodeCharacterEntities: encodeCharacterEntities,
        encodeCharacters: encodeCharacters,
      );
    } else if (child is XmlEntity) {
      node = child.toString(doubleQuotes);
    } else if (child is XmlNotation) {
      node = child.toString(doubleQuotes);
    } else if (child is XmlProcessingInstruction) {
      node = child.toString();
    } else if (child is XmlText) {
      node = child.toString(
        encodeCharacterEntities: encodeCharacterEntities,
        encodeCharacters: encodeCharacters ?? '&<>',
      );
    }

    string += node;
  });

  return string;
}

/// Returns each node in [children] as a new line in a string
/// using the node's `toFormattedString()` method.
///
/// `1` is added to [nestingLevel] automatically.
String formatChildren({
  @required List<XmlNode> children,
  int nestingLevel = 0,
  String indent = '\t',
  // TODO: int lineLength = 80,
  bool encodeCharacterEntities = true,
  String encodeCharacters,
  bool doubleQuotes = true,
}) {
  assert(children != null);
  assert(nestingLevel != null && nestingLevel >= 0);
  assert(indent != null);
  // TODO: assert(lineLength == null || lineLength > 0);
  assert(encodeCharacterEntities != null);
  assert(doubleQuotes != null);

  nestingLevel += 1;

  String formattedChildren = '';

  children.forEach((XmlNode child) {
    if (child is XmlAttlist) {
      formattedChildren += child.toFormattedString(
        nestingLevel: nestingLevel,
        indent: indent,
        // TODO: lineLenght: lineLength,
        doubleQuotes: doubleQuotes,
      );
    } else if (child is XmlEtd) {
      formattedChildren += child.toFormattedString(
        nestingLevel: nestingLevel,
        indent: indent,
        // TODO: lineLenght: lineLength,
      );
    } else if (child is XmlCdata) {
      formattedChildren += child.toFormattedString(
        nestingLevel: nestingLevel,
        indent: indent,
        // TODO: lineLenght: lineLength,
      );
    } else if (child is XmlComment) {
      formattedChildren += child.toFormattedString(
        nestingLevel: nestingLevel,
        indent: indent,
        // TODO: lineLenght: lineLength,
      );
    } else if (child is XmlConditional) {
      formattedChildren += child.toFormattedString(
        nestingLevel: nestingLevel,
        indent: indent,
        // TODO: lineLenght: lineLength,
        encodeCharacterEntities: encodeCharacterEntities,
        encodeCharacters: encodeCharacters,
        doubleQuotes: doubleQuotes,
      );
    } else if (child is XmlDoctype) {
      formattedChildren += child.toFormattedString(
        nestingLevel: nestingLevel,
        indent: indent,
        // TODO: lineLenght: lineLength,
        encodeCharacterEntities: encodeCharacterEntities,
        encodeCharacters: encodeCharacters,
        doubleQuotes: doubleQuotes,
      );
    } else if (child is XmlDeclaration) {
      formattedChildren += child.toFormattedString(
        nestingLevel: nestingLevel,
        indent: indent,
        // TODO: lineLenght: lineLength,
        doubleQuotes: doubleQuotes,
      );
    } else if (child is XmlElement) {
      formattedChildren += child.toFormattedString(
        nestingLevel: nestingLevel,
        indent: indent,
        // TODO: lineLenght: lineLength,
        encodeCharacterEntities: encodeCharacterEntities,
        encodeCharacters: encodeCharacters,
        doubleQuotes: doubleQuotes,
      );
    } else if (child is XmlEntity) {
      formattedChildren += child.toFormattedString(
        nestingLevel: nestingLevel,
        indent: indent,
        // TODO: lineLenght: lineLength,
        doubleQuotes: doubleQuotes,
      );
    } else if (child is XmlNotation) {
      formattedChildren += child.toFormattedString(
        nestingLevel: nestingLevel,
        indent: indent,
        // TODO: lineLenght: lineLength,
        doubleQuotes: doubleQuotes,
      );
    } else if (child is XmlProcessingInstruction) {
      formattedChildren += child.toFormattedString(
        nestingLevel: nestingLevel,
        indent: indent,
        // TODO: lineLenght: lineLength,
      );
    } else if (child is XmlText) {
      formattedChildren += child.toFormattedString(
        nestingLevel: nestingLevel,
        indent: indent,
        // TODO: lineLenght: lineLength,
        encodeCharacterEntities: encodeCharacterEntities,
        encodeCharacters: encodeCharacters ?? '&<>',
      );
    }
  });

  return formattedChildren;
}
