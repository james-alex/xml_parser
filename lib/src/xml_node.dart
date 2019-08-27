import 'package:http/http.dart';
import './helpers/delimiters.dart';
import './helpers/helpers.dart' as helpers;
import './xml_document.dart';
import './nodes/dtd/xml_attlist.dart';
import './nodes/dtd/xml_etd.dart';
import './nodes/xml_cdata.dart';
import './nodes/xml_comment.dart';
import './nodes/xml_conditional.dart';
import './nodes/xml_declaration.dart';
import './nodes/xml_doctype.dart';
import './nodes/xml_element.dart';
import './nodes/xml_entity.dart';
import './nodes/xml_notation.dart';
import './nodes/xml_processing_instruction.dart';
import './nodes/xml_text.dart';

export './nodes/dtd/xml_attlist.dart';
export './nodes/dtd/xml_etd.dart';
export './nodes/xml_cdata.dart';
export './nodes/xml_attribute.dart';
export './nodes/xml_comment.dart';
export './nodes/xml_conditional.dart';
export './nodes/xml_declaration.dart';
export './nodes/xml_doctype.dart';
export './nodes/xml_element.dart';
export './nodes/xml_entity.dart';
export './nodes/xml_notation.dart';
export './nodes/xml_processing_instruction.dart';
export './nodes/xml_text.dart';

/// The base class for all XML nodes.
abstract class XmlNode {
  const XmlNode._();

  /// Returns this node as a formatted string.
  ///
  /// Each child is returned further indented by [indent] with
  /// each [nestingLevel].
  ///
  /// If [lineLength] isn't `null`, lines will be broken when they
  /// reach [lineLength] in length. Some lines may not be broken
  /// by [lineLength] if a clean way to break them can't be detected.
  ///
  /// [nestingLevel] must not be `null` and must be `>= 0`.
  ///
  /// [indent] defaults to `\t` (tab) and must not be `null`.
  ///
  /// [lineLength] must not be `null` and must be `> 0`.
  String toFormattedString({
    int nestingLevel = 0,
    String indent = '\t',
    // TODO: int lineLength = 80,
  });

  /// Returns the first node found in [string]. [string] must not be `null`.
  ///
  /// If [parseCharacterEntities] is `true`, text values will be parsed
  /// and replace all encoded character entities with their corresponding
  /// character. [parseCharacterEntities] must not be `null`.
  ///
  /// If [parseComments] is `true`, commments will be scrubbed
  /// from [string] before parsing. [parseComments] must not be `null`.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// If [returnNodesOfType] is not `null`, only the nodes of the types
  /// contained in [returnNodesOfType] will be returned, otherwise, all
  /// nodes, regardless of type, will be returned.
  ///
  /// Returns `null` if [string] is empty.
  static XmlNode fromString(
    String string, {
    bool parseCharacterEntities = true,
    bool parseComments = false,
    bool trimWhitespace = true,
    List<Type> returnNodesOfType,
  }) {
    assert(string != null);
    assert(parseCharacterEntities != null);
    assert(parseComments != null);
    assert(trimWhitespace != null);

    return parseString(
      string,
      parseCharacterEntities: parseCharacterEntities,
      parseComments: parseComments,
      trimWhitespace: trimWhitespace,
      stop: 0,
    )?.first;
  }

  /// Returns a list of every root level node found in [string].
  /// [string] must not be `null`.
  ///
  /// If [parseCharacterEntities] is `true`, text values will be parsed
  /// and replace all encoded character entities with their corresponding
  /// character. [parseCharacterEntities] must not be `null`.
  ///
  /// If [parseComments] is `true`, commments will be scrubbed
  /// from [string] before parsing. [parseComments] must not be `null`.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// If [returnNodesOfType] is not `null`, only the nodes of the types
  /// contained in [returnNodesOfType] will be returned, otherwise, all
  /// nodes, regardless of type, will be returned.
  ///
  /// [start] and [stop] refer to the indexes of the identified nodes.
  /// Only matches found between [start] and [stop] will be returned.
  /// [start] must not be `null` and must be `>= 0`. [stop] may be `null`,
  /// but must be `>= start` if provided.
  ///
  /// Returns `null` if no nodes were found.
  static List<XmlNode> parseString(
    String string, {
    bool parseCharacterEntities = true,
    bool parseComments = false,
    bool trimWhitespace = true,
    List<Type> returnNodesOfType,
    // TODO: global
    int start = 0,
    int stop,
  }) {
    assert(string != null);
    assert(parseCharacterEntities != null);
    assert(parseComments != null);
    assert(trimWhitespace != null);
    assert(start != null && start >= 0);
    assert(stop == null || stop >= start);

    if (!parseComments) string = helpers.removeComments(string);

    if (trimWhitespace) string = helpers.trimWhitespace(string);

    string = string.trim();

    final List<XmlNode> nodes = List<XmlNode>();

    int nodeCount = 0;

    while (string.contains(_delimiter)) {
      RegExpMatch delimiter;
      String node;

      void setNode(RegExp regExp) {
        delimiter = regExp.firstMatch(string);

        node = (delimiter != null)
            ? string.substring(delimiter.start, delimiter.end)
            : null;
      }

      setNode(_delimiter);

      if (delimiter.start > 0) {
        final String text = string.substring(0, delimiter.start).trimRight();

        if (text.isNotEmpty) {
          nodes.add(XmlText(text));
          string = string.substring(delimiter.start);
          setNode(_delimiter);
        }
      }

      XmlNode xmlNode;

      if (node.startsWith('<?')) {
        if (node.startsWith('<?xml')) {
          // If it's a XML declaration...
          setNode(Delimiters.xmlDeclaration);
          if (node != null) {
            xmlNode = XmlDeclaration.fromString(
              node,
              trimWhitespace: false,
            );
          }
        } else {
          // If it's a processing instruction declaration...
          setNode(Delimiters.processingInstruction);
          if (node != null) {
            xmlNode = XmlProcessingInstruction.fromString(
              node,
              trimWhitespace: false,
            );
          }
        }
      } else if (node.startsWith('<!')) {
        // If it's a comment...
        if (node.startsWith('<!--')) {
          // If the delimiter wasn't closed by a comment delimiter...
          if (!node.endsWith('-->')) {
            // Try to find the actual comment delimiter
            setNode(Delimiters.comment);

            // If the comment wasn't closed...
            if (delimiter == null) {
              // The entirety of the remaining string is commented.
              string += '-->';
              setNode(Delimiters.comment);
            }
          }

          // Parse the node as a comment.
          xmlNode = XmlComment.fromString(node, trimWhitespace: false);
        } else {
          // If it's a markup delimiter...
          final String type = _markupStartDelimiter
              .firstMatch(node)
              .namedGroup('type')
              .toUpperCase();

          if (type == 'ATTLIST') {
            setNode(Delimiters.attlist);
            if (node != null) {
              xmlNode = XmlAttlist.fromString(
                node,
                trimWhitespace: false,
              );
            }
          } else if (type == 'CDATA') {
            setNode(Delimiters.cdata);
            if (node != null) {
              xmlNode = XmlCdata.fromString(
                node,
                trimWhitespace: false,
              );
            }
          } else if (type == 'DOCTYPE') {
            setNode(Delimiters.doctype);
            if (node != null) {
              xmlNode = XmlDoctype.fromString(
                node,
                parseCharacterEntities: parseCharacterEntities,
                parseComments: true,
                trimWhitespace: false,
              );
            }
          } else if (type == 'ELEMENT') {
            setNode(Delimiters.etd);
            if (node != null) {
              xmlNode = XmlEtd.fromString(
                node,
                trimWhitespace: false,
              );
            }
          } else if (type == 'ENTITY') {
            setNode(Delimiters.entity);
            if (node != null) {
              xmlNode = XmlEntity.fromString(
                node,
                trimWhitespace: trimWhitespace,
              );
            }
          } else if (type == 'INCLUDE' ||
              type == 'IGNORE' ||
              ((type.startsWith('&') || type.startsWith('%')) &&
                  type.endsWith(';'))) {
            setNode(Delimiters.conditional);
            if (node != null) {
              xmlNode = XmlConditional.fromString(
                node,
                parseCharacterEntities: parseCharacterEntities,
                parseComments: true,
                trimWhitespace: false,
              );
            }
          } else if (type == 'NOTATION') {
            setNode(Delimiters.notation);
            if (node != null) {
              xmlNode = XmlNotation.fromString(
                node,
                trimWhitespace: false,
              );
            }
          } else {
            xmlNode = XmlText.fromString(
              node,
              isMarkup: true,
              parseCharacterEntities: parseCharacterEntities,
              trimWhitespace: false,
            );
          }
        }
      } else {
        // If it's an element...
        // If the tag was closed by a comment delimiter, remove the comment.
        while (node.contains(Delimiters.comment)) {
          string = string.replaceFirst(Delimiters.comment, '');
          setNode(_delimiter);
        }

        // Capture the element's tag.
        final RegExpMatch tag = Delimiters.elementTag.firstMatch(node);

        final String tagName = tag.namedGroup('tagName');

        // Only parse opening tags. If a closing tag was found, it was found
        // without a corresponding opening tag and shouldn't be parsed.
        if (tagName.isNotEmpty && !tagName.startsWith('/')) {
          // If it's not an empty element, capture the whole element.
          if (tag.namedGroup('isEmpty') != '/') {
            final RegExp element = Delimiters.element(tagName);
            setNode(element);
          }

          if (node != null) {
            xmlNode = XmlElement.fromString(
              node,
              parseCharacterEntities: parseCharacterEntities,
              parseComments: true,
              trimWhitespace: false,
            );
          }
        }
      }

      if (xmlNode == null) {
        setNode(_delimiter);

        xmlNode = XmlText.fromString(
          node,
          parseCharacterEntities: parseCharacterEntities,
          trimWhitespace: false,
        );
      }

      if (xmlNode != null &&
          (returnNodesOfType == null ||
              returnNodesOfType.contains(xmlNode.runtimeType))) {
        if (nodeCount >= start) nodes.add(xmlNode);

        nodeCount++;

        if (stop != null && nodeCount > stop) break;
      }

      string = string.substring(delimiter.end).trimLeft();
    }

    if (string.isNotEmpty &&
        (returnNodesOfType == null || returnNodesOfType.contains(XmlText))) {
      nodes.add(XmlText.fromString(
        string,
        parseCharacterEntities: parseCharacterEntities,
        trimWhitespace: false,
      ));
    }

    if (nodes.isEmpty) return null;

    return nodes;
  }

  /// Retrieves a document from [uri], parses it, and
  /// returns all identified XML nodes in a list.
  ///
  /// If [parseCharacterEntities] is `true`, text values will be parsed
  /// and replace all encoded character entities with their corresponding
  /// character. [parseCharacterEntities] must not be `null`.
  ///
  /// If [parseComments] is `true`, commments will be scrubbed
  /// from [string] before parsing.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// If [returnNodesOfType] is not `null`, only the nodes of the types
  /// contained in [returnNodesOfType] will be returned, otherwise, all
  /// nodes, regardless of type, will be returned.
  ///
  /// [start] and [stop] refer to the indexes of the identified nodes.
  /// Only matches found between [start] and [stop] will be returned.
  /// [start] must not be `null` and must be `>= 0`. [stop] may be `null`,
  /// but must be `>= start` if provided.
  static Future<dynamic> fromUri(
    String uri, {
    bool parseCharacterEntities = true,
    bool parseComments = false,
    bool trimWhitespace = true,
    List<Type> returnNodesOfType,
    int start = 0,
    int stop,
  }) async {
    assert(uri != null);
    assert(parseCharacterEntities != null);
    assert(parseComments != null);
    assert(trimWhitespace != null);
    assert(start != null && start >= 0);
    assert(stop == null || stop >= start);

    final Response response = await get(uri);

    if (response.statusCode != 200) {
      return null;
    }

    final String document = response.body;

    if (returnNodesOfType != null) {
      if (returnNodesOfType.length == 1) {
        final Type nodeType = returnNodesOfType.first;

        if (nodeType == XmlDocument) {
          return XmlDocument.fromString(
            document,
            parseCharacterEntities: parseCharacterEntities,
            parseComments: parseComments,
            trimWhitespace: trimWhitespace,
          );
        } else if (nodeType == XmlAttlist) {
          return XmlAttlist.parseString(
            document,
            trimWhitespace: trimWhitespace,
            start: start,
            stop: stop,
          );
        } else if (nodeType == XmlEtd) {
          return XmlEtd.parseString(
            document,
            trimWhitespace: trimWhitespace,
            start: start,
            stop: stop,
          );
        } else if (nodeType == XmlComment) {
          return XmlComment.parseString(
            document,
            parseCharacterEntities: parseCharacterEntities,
            trimWhitespace: trimWhitespace,
            start: start,
            stop: stop,
          );
        } else if (nodeType == XmlConditional) {
          return XmlConditional.parseString(
            document,
            parseCharacterEntities: parseCharacterEntities,
            parseComments: parseComments,
            trimWhitespace: trimWhitespace,
            start: start,
            stop: stop,
          );
        } else if (nodeType == XmlDoctype) {
          return XmlDoctype.parseString(
            document,
            parseCharacterEntities: parseCharacterEntities,
            parseComments: parseComments,
            trimWhitespace: trimWhitespace,
            start: start,
            stop: stop,
          );
        } else if (nodeType == XmlElement) {
          return XmlElement.parseString(
            document,
            parseCharacterEntities: parseCharacterEntities,
            parseComments: parseComments,
            trimWhitespace: trimWhitespace,
            start: start,
            stop: stop,
          );
        } else if (nodeType == XmlEntity) {
          return XmlEntity.parseString(
            document,
            trimWhitespace: trimWhitespace,
            start: start,
            stop: stop,
          );
        } else if (nodeType == XmlNotation) {
          return XmlNotation.parseString(
            document,
            trimWhitespace: trimWhitespace,
            start: start,
            stop: stop,
          );
        } else if (nodeType == XmlProcessingInstruction) {
          return XmlProcessingInstruction.parseString(
            document,
            trimWhitespace: trimWhitespace,
            start: start,
            stop: stop,
          );
        } else if (nodeType == XmlText) {
          return XmlText.parseString(
            document,
            trimWhitespace: trimWhitespace,
            start: start,
            stop: stop,
          );
        }
      }
    }

    return XmlNode.parseString(
      document,
      parseCharacterEntities: parseCharacterEntities,
      parseComments: parseComments,
      trimWhitespace: trimWhitespace,
      returnNodesOfType: returnNodesOfType,
      start: start,
      stop: stop,
    );
  }

  /// Matches any tag or markup delimiter.
  static final RegExp _delimiter = RegExp(r'<.*?>', dotAll: true);

  /// Matches the start of markup declarations and captures their type.
  static final RegExp _markupStartDelimiter =
      RegExp(r'<!\s*(?:\[)?\s*(?<type>[^>\s\[]*)');
}
