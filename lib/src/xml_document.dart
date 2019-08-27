import './helpers/node_with_children.dart';
import './helpers/helpers.dart' as helpers;
import './xml_node.dart';

/// A XML document.
///
/// It contains optional XML Declaration and Document Type Declarations,
/// and a root element that contains every other element nested within it.
class XmlDocument extends NodeWithChildren {
  /// A XML document.
  ///
  /// [nodes] must not be null.
  const XmlDocument(this.children) : assert(children != null);

  /// The list of root level nodes in this document.
  ///
  /// A valid XML document should have at most one [XmlDeclaration],
  /// [XmlDoctype], and [XmlElement] at its root.
  ///
  /// [XmlDeclration] and [XmlDoctype], if provided, should
  /// be the first and second nodes in the list.
  @override
  final List<XmlNode> children;

  /// The raw value of the XML document declaration.
  XmlDeclaration get xmlDeclaration => children.firstWhere(
        (XmlNode child) => child.runtimeType == XmlDeclaration,
        orElse: () => null,
      );

  /// The XML document type definition.
  XmlDoctype get doctype => children.firstWhere(
        (XmlNode child) => child.runtimeType == XmlDoctype,
        orElse: () => null,
      );

  /// The root level element.
  ///
  /// In a valid XML document, all elements besides the
  /// root element are nested within the root element.
  XmlElement get root => children.firstWhere(
        (XmlNode node) => node.runtimeType == XmlElement,
        orElse: () => null,
      );

  /// Attempts to load all external DTD references contained
  /// within the [XmlDoctype] and nested [XmlEntity]s, load the pages
  /// they reference, and parse the DTD elements contained within.
  ///
  /// External DTD will not be loaded if this document's XML
  /// declaration's `standalone` attribute is set to `yes`.
  Future<void> loadExternalDtd() async {
    // Don't attempt to load DTDs if the document is flagged as standalone.
    if ((xmlDeclaration.standalone != null && xmlDeclaration.standalone) ||
        children.isEmpty) return;

    for (int i = 0; i < children.length; i++) {
      final XmlNode child = children[i];

      if (child is XmlConditional) {
        await child.loadExternalDtd();
      } else if (child is XmlDoctype) {
        children[i] = await child.loadExternalDtd();
      } else if (child is XmlElement) {
        await child.loadExternalDtd();
      } else if (child is XmlEntity) {
        children[i] = await child.loadExternalEntities();
      }
    }

    return;
  }

  /// Returns this document as a single-line XML string.
  ///
  /// If [doubleQuotes] is `true`, double-quotes will be used to wrap
  /// all attribute values, otherwise single-quotes will be used.
  ///
  /// If [encodeCharacterEntities] is `true`, text and attribute
  /// values will be parsed and will encode the characters included
  /// in [encodeCharacters] as character entities.
  ///
  /// If [encodeCharacters] is `null`, attribute values will be parsed
  /// for less-than (`<`), greater-than (`>`), ampersand (`&`), apostrophe
  /// or single quote (`'`) and double-quote (`"`). And, [XmlText] nodes will
  /// be encoded for less-than (`<`), greater-than (`>`), and ampersand (`&`).
  ///
  /// __Note:__ If an element's [id] isn't null and possess an ID
  /// attribute, the value for [id] will be used over the attribute.
  @override
  String toString({
    bool doubleQuotes = true,
    bool encodeCharacterEntities = true,
    String encodeCharacters,
  }) {
    assert(doubleQuotes != null);
    assert(encodeCharacterEntities != null);

    return helpers.childrenToString(
      children: children,
      encodeCharacterEntities: encodeCharacterEntities,
      encodeCharacters: encodeCharacters,
      doubleQuotes: doubleQuotes,
    );
  }

  /// Returns this document as a formatted XML string.
  ///
  /// New lines will be added after each tag, and all nested
  /// elements will be padded by [indent] multipled by the
  /// current nesting level. [indent] defaults to 2 spaces.
  String toFormattedString({
    int nestingLevel = 0,
    String indent = '\t',
  }) {
    assert(indent != null);

    String document = '';

    children.forEach((XmlNode node) {
      document += node.toFormattedString(
        nestingLevel: nestingLevel,
        indent: indent,
      );
    });

    return document;
  }

  /// Parses a XML string for its XML document declaration,
  /// DocType declaration, and its root element.
  ///
  /// If the [document] isn't valid XML and contains multiple
  /// top-level elements, only the first parsed element will be
  /// returned as the root element. If you have to work with such
  /// a document, consider using [XmlElement]'s `fromString()`
  /// method instead.
  ///
  /// If [parseCharacterEntities] is `true`, [text] and attribute values
  /// will be parsed for character entities and replaced with their
  /// corresponding characters.
  ///
  /// If [parseComments] is `true`, commments will be scrubbed
  /// from [string] before parsing.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// Returns `null` if the document is empty.
  static XmlDocument fromString(
    String document, {
    bool parseCharacterEntities = true,
    bool parseComments = false,
    bool trimWhitespace = true,
  }) {
    assert(document != null);
    assert(parseCharacterEntities != null);
    assert(parseComments != null);
    assert(trimWhitespace != null);

    if (!parseComments) document = helpers.removeComments(document);

    if (trimWhitespace) document = helpers.trimWhitespace(document);

    document = document.trim();

    if (document.isEmpty) return null;

    final List<XmlNode> nodes = XmlNode.parseString(
      document,
      parseCharacterEntities: parseCharacterEntities,
      parseComments: true,
      trimWhitespace: false,
    );

    if (nodes == null) return null;

    return XmlDocument(nodes);
  }

  /// Attempts to load and parse a XML document from a URI.
  ///
  /// If [parseCharacterEntities] is `true`, [text] and attribute values
  /// will be parsed for character entities and replaced with their
  /// corresponding characters.
  ///
  /// If [parseComments] is `true`, commments will be scrubbed
  /// from [string] before parsing.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// Returns `null` if the document couldn't be reached or is empty.
  static Future<XmlDocument> fromUri(
    String uri, {
    bool parseCharacterEntities = true,
    bool parseComments = false,
    bool trimWhitespace = true,
  }) async {
    assert(uri != null);
    assert(parseComments != null);
    assert(trimWhitespace != null);

    final XmlDocument document = await XmlNode.fromUri(uri,
        parseCharacterEntities: parseCharacterEntities,
        parseComments: parseComments,
        trimWhitespace: trimWhitespace,
        returnNodesOfType: [XmlDocument]);

    return document;
  }

  @override
  bool operator ==(o) {
    if (o is! XmlDocument) return false;

    if (children.length != o.children.length) return false;

    for (int i = 0; i < children.length; i++) {
      if (children[i] != o.nodes[i]) return false;
    }

    return true;
  }

  @override
  int get hashCode =>
      xmlDeclaration.hashCode ^ doctype.hashCode ^ root.hashCode;
}
