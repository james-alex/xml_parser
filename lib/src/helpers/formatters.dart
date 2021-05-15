import '../xml_node.dart';

extension StringFormatters on String {
  /// Removes every block of text delimited with
  /// XML comment delimiters from `this` string.
  String removeComments() {
    var input = this;

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
  String stripDelimiters() {
    final first = substring(0, 1);
    final last = substring(length - 1);

    if ((first == '\'' && last == '\'') ||
        (first == '"' && last == '"') ||
        (first == '<' && last == '>') ||
        (first == '(' && last == ')') ||
        (first == '[' && last == ']') ||
        (first == '{' && last == '}')) {
      return substring(1, length - 1);
    }

    return this;
  }

  /// Replaces all whitespace in [input] with a single space
  /// and removes unnecessary whitespace between nodes.
  String trimWhitespace() => replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'(?<=>) (?=\S)|(?<=\S) (?=<)'), '')
      .trim();

  /// Prepends a string with `indent * nestingLevel` and
  /// appends it with a newline.
  String formatLine(int nestingLevel, String indent) {
    assert(nestingLevel >= 0);
    final lineIndent = indent * nestingLevel;
    return '$lineIndent$this\n';
  }
}

extension ChildFormatters on List<XmlNode> {
  /// Writes all [children] as a string with thier
  /// respective `toString()` methods.
  String write({
    bool encodeCharacterEntities = true,
    String? encodeCharacters,
    bool doubleQuotes = true,
  }) {
    var string = '';

    for (var child in this) {
      late String node;

      if (child is XmlAttlist) {
        node = child.toString(doubleQuotes: doubleQuotes);
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
        node = child.toString(doubleQuotes: doubleQuotes);
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
        node = child.toString(doubleQuotes: doubleQuotes);
      } else if (child is XmlNotation) {
        node = child.toString(doubleQuotes: doubleQuotes);
      } else if (child is XmlProcessingInstruction) {
        node = child.toString();
      } else if (child is XmlText) {
        node = child.toString(
          encodeCharacterEntities: encodeCharacterEntities,
          encodeCharacters: encodeCharacters ?? '&<>',
        );
      }

      string += node;
    }

    return string;
  }

  /// Returns each node in [children] as a new line in a string
  /// using the node's `toFormattedString()` method.
  ///
  /// `1` is added to [nestingLevel] automatically.
  String format({
    int nestingLevel = 0,
    String indent = '\t',
    bool encodeCharacterEntities = true,
    String? encodeCharacters,
    bool doubleQuotes = true,
  }) {
    assert(nestingLevel >= 0);

    nestingLevel += 1;

    var formattedChildren = '';

    for (var child in this) {
      if (child is XmlAttlist) {
        formattedChildren += child.toFormattedString(
          nestingLevel: nestingLevel,
          indent: indent,
          doubleQuotes: doubleQuotes,
        );
      } else if (child is XmlEtd) {
        formattedChildren += child.toFormattedString(
          nestingLevel: nestingLevel,
          indent: indent,
        );
      } else if (child is XmlCdata) {
        formattedChildren += child.toFormattedString(
          nestingLevel: nestingLevel,
          indent: indent,
        );
      } else if (child is XmlComment) {
        formattedChildren += child.toFormattedString(
          nestingLevel: nestingLevel,
          indent: indent,
        );
      } else if (child is XmlConditional) {
        formattedChildren += child.toFormattedString(
          nestingLevel: nestingLevel,
          indent: indent,
          encodeCharacterEntities: encodeCharacterEntities,
          encodeCharacters: encodeCharacters,
          doubleQuotes: doubleQuotes,
        );
      } else if (child is XmlDoctype) {
        formattedChildren += child.toFormattedString(
          nestingLevel: nestingLevel,
          indent: indent,
          encodeCharacterEntities: encodeCharacterEntities,
          encodeCharacters: encodeCharacters,
          doubleQuotes: doubleQuotes,
        );
      } else if (child is XmlDeclaration) {
        formattedChildren += child.toFormattedString(
          nestingLevel: nestingLevel,
          indent: indent,
          doubleQuotes: doubleQuotes,
        );
      } else if (child is XmlElement) {
        formattedChildren += child.toFormattedString(
          nestingLevel: nestingLevel,
          indent: indent,
          encodeCharacterEntities: encodeCharacterEntities,
          encodeCharacters: encodeCharacters,
          doubleQuotes: doubleQuotes,
        );
      } else if (child is XmlEntity) {
        formattedChildren += child.toFormattedString(
          nestingLevel: nestingLevel,
          indent: indent,
          doubleQuotes: doubleQuotes,
        );
      } else if (child is XmlNotation) {
        formattedChildren += child.toFormattedString(
          nestingLevel: nestingLevel,
          indent: indent,
          doubleQuotes: doubleQuotes,
        );
      } else if (child is XmlProcessingInstruction) {
        formattedChildren += child.toFormattedString(
          nestingLevel: nestingLevel,
          indent: indent,
        );
      } else if (child is XmlText) {
        formattedChildren += child.toFormattedString(
          nestingLevel: nestingLevel,
          indent: indent,
          encodeCharacterEntities: encodeCharacterEntities,
          encodeCharacters: encodeCharacters ?? '&<>',
        );
      }
    }

    return formattedChildren;
  }
}
