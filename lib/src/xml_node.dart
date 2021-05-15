import 'package:http/http.dart';
import 'package:meta/meta.dart';
import './helpers/delimiters.dart';
import 'helpers/formatters.dart' as helpers;
import './nodes/dtd/xml_attlist.dart';
import './nodes/dtd/xml_etd.dart';
import './nodes/xml_attribute.dart';
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
import './xml_document.dart';

export './nodes/dtd/xml_attlist.dart';
export './nodes/dtd/xml_etd.dart';
export './nodes/xml_attribute.dart';
export './nodes/xml_cdata.dart';
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
@immutable
abstract class XmlNode {
  const XmlNode();

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
  }) {
    assert(nestingLevel >= 0);
    return toString().formatLine(nestingLevel, indent);
  }

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
  static XmlNode? from(
    String string, {
    bool parseCharacterEntities = true,
    bool parseComments = false,
    bool trimWhitespace = true,
    bool parseCdataAsText = true,
    List<Type>? returnNodesOfType,
  }) {
    return parseString(
      string,
      parseCharacterEntities: parseCharacterEntities,
      parseComments: parseComments,
      trimWhitespace: trimWhitespace,
      parseCdataAsText: parseCdataAsText,
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
  static List<XmlNode>? parseString(
    String string, {
    bool parseCharacterEntities = true,
    bool parseComments = false,
    bool trimWhitespace = true,
    bool parseCdataAsText = true,
    List<Type>? returnNodesOfType,
    int start = 0,
    int? stop,
  }) {
    assert(start >= 0);
    assert(stop == null || stop >= start);

    if (!parseComments) string = string.removeComments();
    if (trimWhitespace) string = string.trimWhitespace();
    string = string.trim();

    final nodes = <XmlNode>[];
    var nodeCount = 0;

    while (string.contains(_delimiter)) {
      RegExpMatch? delimiter;
      String? node;

      void setNode(RegExp regExp) {
        delimiter = regExp.firstMatch(string);
        node = (delimiter != null)
            ? string.substring(delimiter!.start, delimiter!.end)
            : null;
      }

      setNode(_delimiter);

      if (delimiter!.start > 0) {
        final text = string.substring(0, delimiter!.start).trimRight();

        if (text.isNotEmpty) {
          nodes.add(XmlText(text));
          string = string.substring(delimiter!.start);
          setNode(_delimiter);
        }
      }

      XmlNode? xmlNode;

      if (node!.startsWith('<?')) {
        if (node!.startsWith('<?xml')) {
          // If it's a XML declaration...
          setNode(Delimiters.xmlDeclaration);
          if (node != null) {
            xmlNode = XmlDeclaration.from(node!, trimWhitespace: false);
          }
        } else {
          // If it's a processing instruction declaration...
          setNode(Delimiters.processingInstruction);
          if (node != null) {
            xmlNode =
                XmlProcessingInstruction.from(node!, trimWhitespace: false);
          }
        }
      } else if (node!.startsWith('<!')) {
        // If it's a comment...
        if (node!.startsWith('<!--')) {
          // If the delimiter wasn't closed by a comment delimiter...
          if (!node!.endsWith('-->')) {
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
          xmlNode = XmlComment.from(node!, trimWhitespace: false);
        } else {
          // If it's a markup delimiter...
          final type = _markupStartDelimiter
              .firstMatch(node!)
              ?.namedGroup('type')
              ?.toUpperCase();

          if (type == 'ATTLIST') {
            setNode(Delimiters.attlist);
            if (node != null) {
              xmlNode = XmlAttlist.from(node!, trimWhitespace: false);
            }
          } else if (type == 'CDATA') {
            setNode(Delimiters.cdata);
            if (node != null) {
              if (parseCdataAsText) {
                xmlNode =
                    XmlText.from(node!, trimWhitespace: false, isMarkup: true);
              } else {
                xmlNode = XmlCdata.from(node!, trimWhitespace: false);
              }
            }
          } else if (type == 'DOCTYPE') {
            setNode(Delimiters.doctype);
            if (node != null) {
              xmlNode = XmlDoctype.from(
                node!,
                parseCharacterEntities: parseCharacterEntities,
                parseComments: true,
                trimWhitespace: false,
                parseCdataAsText: parseCdataAsText,
              );
            }
          } else if (type == 'ELEMENT') {
            setNode(Delimiters.etd);
            if (node != null) {
              xmlNode = XmlEtd.from(
                node!,
                trimWhitespace: false,
              );
            }
          } else if (type == 'ENTITY') {
            setNode(Delimiters.entity);
            if (node != null) {
              xmlNode = XmlEntity.from(
                node!,
                trimWhitespace: trimWhitespace,
              );
            }
          } else if (type == 'INCLUDE' ||
              type == 'IGNORE' ||
              ((type!.startsWith('&') || type.startsWith('%')) &&
                  type.endsWith(';'))) {
            setNode(Delimiters.conditional);
            if (node != null) {
              xmlNode = XmlConditional.from(node!,
                  parseCharacterEntities: parseCharacterEntities,
                  parseComments: true,
                  trimWhitespace: false,
                  parseCdataAsText: parseCdataAsText);
            }
          } else if (type == 'NOTATION') {
            setNode(Delimiters.notation);
            if (node != null) {
              xmlNode = XmlNotation.from(
                node!,
                trimWhitespace: false,
              );
            }
          } else {
            xmlNode = XmlText.from(
              node!,
              isMarkup: true,
              parseCharacterEntities: parseCharacterEntities,
              trimWhitespace: false,
            );
          }
        }
      } else {
        // If it's an element...
        // If the tag was closed by a comment delimiter, remove the comment.
        while (node!.contains(Delimiters.comment)) {
          string = string.replaceFirst(Delimiters.comment, '');
          setNode(_delimiter);
        }

        // Capture the element's tag.
        final tag = Delimiters.elementTag.firstMatch(node!);
        final tagName = tag?.namedGroup('tagName');

        // Only parse opening tags. If a closing tag was found, it was found
        // without a corresponding opening tag and shouldn't be parsed.
        if (tagName?.isNotEmpty == true && !tagName!.startsWith('/')) {
          // If it's not an empty element, capture the whole element.
          if (tag!.namedGroup('isEmpty') != '/') {
            final RegExp element = Delimiters.element(tagName);
            setNode(element);
          }

          if (node != null) {
            xmlNode = XmlElement.from(node!,
                parseCharacterEntities: parseCharacterEntities,
                parseComments: true,
                trimWhitespace: false,
                parseCdataAsText: parseCdataAsText);
          }
        }
      }

      if (xmlNode == null) {
        setNode(_delimiter);
        xmlNode = XmlText.from(
          node!,
          parseCharacterEntities: parseCharacterEntities,
          trimWhitespace: false,
        );
      }

      if (returnNodesOfType == null ||
          returnNodesOfType.contains(xmlNode.runtimeType)) {
        if (nodeCount >= start) nodes.add(xmlNode);
        nodeCount++;
        if (stop != null && nodeCount > stop) break;
      }

      string = string.substring(delimiter!.end).trimLeft();
    }

    if (string.isNotEmpty &&
        (returnNodesOfType == null || returnNodesOfType.contains(XmlText))) {
      nodes.add(XmlText.from(
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
  ///
  /// Returns `null` if the [uri] can't be reached or no valid XML nodes
  /// are found in the returned document.
  static Future<dynamic?> fromUri(
    String uri, {
    bool parseCharacterEntities = true,
    bool parseComments = false,
    bool trimWhitespace = true,
    bool parseCdataAsText = true,
    List<Type>? returnNodesOfType,
    int start = 0,
    int? stop,
  }) async {
    assert(start >= 0);
    assert(stop == null || stop >= start);

    final response = await get(Uri.parse(uri));
    if (response.statusCode != 200) {
      return null;
    }

    final document = response.body;

    if (returnNodesOfType != null) {
      if (returnNodesOfType.length == 1) {
        final nodeType = returnNodesOfType.first;

        if (nodeType == XmlDocument) {
          return XmlDocument.from(
            document,
            parseCharacterEntities: parseCharacterEntities,
            parseComments: parseComments,
            trimWhitespace: trimWhitespace,
            parseCdataAsText: parseCdataAsText,
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
            parseCdataAsText: parseCdataAsText,
            start: start,
            stop: stop,
          );
        } else if (nodeType == XmlDoctype) {
          return XmlDoctype.parseString(
            document,
            parseCharacterEntities: parseCharacterEntities,
            parseComments: parseComments,
            trimWhitespace: trimWhitespace,
            parseCdataAsText: parseCdataAsText,
            start: start,
            stop: stop,
          );
        } else if (nodeType == XmlElement) {
          return XmlElement.parseString(
            document,
            parseCharacterEntities: parseCharacterEntities,
            parseComments: parseComments,
            trimWhitespace: trimWhitespace,
            parseCdataAsText: parseCdataAsText,
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
      parseCdataAsText: parseCdataAsText,
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

@immutable
abstract class XmlNodeWithAttributes extends XmlNode {
  const XmlNodeWithAttributes();

  @override
  String toString({bool doubleQuotes = true});

  @override
  String toFormattedString({
    int nestingLevel = 0,
    String indent = '\t',
    bool doubleQuotes = true,
  }) {
    assert(nestingLevel >= 0);
    return toString(doubleQuotes: doubleQuotes)
        .formatLine(nestingLevel, indent);
  }
}

/// Base class for nodes with children that can contain [XmlElement]s.
@immutable
abstract class XmlNodeWithChildren extends XmlNode {
  const XmlNodeWithChildren({this.children});

  /// The list of [children] each getter and method references.
  final List<XmlNode>? children;

  /// Returns `true` if [children] isn't null or empty.
  bool get hasChildren => children?.isNotEmpty == true;

  /// Returns the first [XmlElement] found in [children].
  ///
  /// Returns `null` if one isn't found.
  XmlElement? get firstChild {
    if (children == null) return null;
    for (var child in children!) {
      if (child is XmlElement) return child;
    }
    return null;
  }

  /// Returns the nth [XmlElement] found in [children].
  ///
  /// [index] must not be `null` and must be `>= 0`.
  ///
  /// Returns `null` if one isn't found.
  XmlElement? nthChild(int index) {
    assert(index >= 0);
    if (children == null) return null;
    var childCount = 0;
    for (var child in children!) {
      if (child is XmlElement) {
        if (index == childCount) {
          return child;
        } else {
          childCount++;
        }
      }
    }
    return null;
  }

  /// Returns the last [XmlElement] found in [children].
  ///
  /// Returns `null` if one isn't found.
  XmlElement? get lastChild {
    if (children == null) return null;
    for (var child in children!.reversed) {
      if (child is XmlElement) return child;
    }
    return null;
  }

  /// Returns the first direct child named [elementName].
  ///
  /// Returns `null` if no element can be found.
  XmlElement? getChild(String elementName) {
    assert(elementName.isNotEmpty);
    if (children == null) return null;
    elementName = elementName.toLowerCase();
    return children!.cast<XmlNode?>().firstWhere(
          (child) =>
              child is XmlElement && child.name.toLowerCase() == elementName,
          orElse: () => null,
        ) as XmlElement?;
  }

  /// Returns the nth direct child named [elementName].
  ///
  /// [index] must not be `null` and must be `>= 0`.
  ///
  /// Returns `null` if no element can be found.
  XmlElement? getNthChild(int index, String elementName) {
    assert(index >= 0);
    assert(elementName.isNotEmpty);
    return getChildren(elementName, start: index, stop: index)?.first;
  }

  /// Returns the last direct child named [elementName].
  ///
  /// Returns `null` if no element can be found.
  XmlElement? getLastChild(String elementName) {
    assert(elementName.isNotEmpty);
    if (children == null) return null;
    elementName = elementName.toLowerCase();
    return children!.cast<XmlNode?>().lastWhere(
          (child) =>
              child is XmlElement && child.name.toLowerCase() == elementName,
          orElse: () => null,
        ) as XmlElement?;
  }

  /// Returns all direct children named [elementName].
  ///
  /// [start] and [stop] refer to the indexes of the identified elements.
  /// Only matches found between [start] and [stop] will be returned.
  /// [start] must not be `null` and must be `>= 0`. [stop] may be `null`,
  /// but must be `>= start` if provided.
  ///
  /// Returns `null` if no element can be found.
  List<XmlElement>? getChildren(
    String elementName, {
    int start = 0,
    int? stop,
  }) {
    assert(elementName.isNotEmpty);
    assert(start >= 0);
    assert(stop == null || stop >= start);
    return getElementsWhere(
        name: elementName, start: start, stop: stop, global: false);
  }

  /// Returns all direct children with properties matching those specified.
  ///
  /// [name] and [id] must not be empty if they are provided.
  ///
  /// If [attributeNames] is not `null`, only elements posessing an attribute
  /// with a name contained in [attributeNames] will be returned. If
  /// [matchAllAttributes] is `true`, an element must possess every attribute
  /// contained in [attributeNames] to be returned, if `false`, the element
  /// only needs to posess a single attribute contained in [attributeNames].
  ///
  /// If [attributes] isn't `null`, only elements possessing attributes
  /// with an identical name and value as those contained in [attributes]
  /// will be returned. If [matchAllAttributes] is `true`, an element must
  /// possess every attribute contained in [attributes], if `false`,
  /// the element only needs to possess a single attribute contained in
  /// [attributes].
  ///
  /// If [children] isn't `null`, only elements possessing children matching
  /// those in [children] will be returned. If [matchAllChildren] is `true`,
  /// an element must posess every [child] found in [children], if `false`,
  /// the element only needs to posess a single child found in [children].
  /// If [childrenMustBeIdentical] is `true`, the element's children must be
  /// in the same order and possess the same number of children as those in
  /// [children], children will also be compared with the `==` operator,
  /// rather than the [compareValues] method.
  ///
  /// Returns `null` if no element can be found.
  XmlElement? getChildWhere({
    String? name,
    String? id,
    List<String>? attributeNames,
    List<XmlAttribute>? attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    List<XmlNode>? children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical = false,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);
    return getElementsWhere(
      name: name,
      id: id,
      attributeNames: attributeNames,
      matchAllAttributes: matchAllAttributes,
      attributesMustBeIdentical: attributesMustBeIdentical,
      children: children,
      matchAllChildren: matchAllChildren,
      childrenMustBeIdentical: childrenMustBeIdentical,
      start: 0,
      stop: 0,
      global: false,
    )?.first;
  }

  /// Returns the nth direct child with properties matching those specified.
  ///
  /// [index] must not be `null` and must be `>= 0`.
  ///
  /// [name] and [id] must not be empty if they are provided.
  ///
  /// If [attributeNames] is not `null`, only elements posessing an attribute
  /// with a name contained in [attributeNames] will be returned. If
  /// [matchAllAttributes] is `true`, an element must possess every attribute
  /// contained in [attributeNames] to be returned, if `false`, the element
  /// only needs to posess a single attribute contained in [attributeNames].
  ///
  /// If [attributes] isn't `null`, only elements possessing attributes
  /// with an identical name and value as those contained in [attributes]
  /// will be returned. If [matchAllAttributes] is `true`, an element must
  /// possess every attribute contained in [attributes], if `false`,
  /// the element only needs to possess a single attribute contained in
  /// [attributes].
  ///
  /// If [children] isn't `null`, only elements possessing children matching
  /// those in [children] will be returned. If [matchAllChildren] is `true`,
  /// an element must posess every [child] found in [children], if `false`,
  /// the element only needs to posess a single child found in [children].
  /// If [childrenMustBeIdentical] is `true`, the element's children must be
  /// in the same order and possess the same number of children as those in
  /// [children], children will also be compared with the `==` operator,
  /// rather than the [compareValues] method.
  ///
  /// Returns `null` if no element can be found.
  XmlElement? getNthChildWhere(
    int index, {
    String? name,
    String? id,
    List<String>? attributeNames,
    List<XmlAttribute>? attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    List<XmlNode>? children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical = false,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);
    return getElementsWhere(
      name: name,
      id: id,
      attributeNames: attributeNames,
      attributes: attributes,
      matchAllAttributes: matchAllAttributes,
      attributesMustBeIdentical: attributesMustBeIdentical,
      children: children,
      matchAllChildren: matchAllChildren,
      childrenMustBeIdentical: childrenMustBeIdentical,
      start: index,
      stop: index,
      global: false,
    )?.first;
  }

  /// Returns the last direct child with properties matching those specified.
  ///
  /// [name] and [id] must not be empty if they are provided.
  ///
  /// If [attributeNames] is not `null`, only elements posessing an attribute
  /// with a name contained in [attributeNames] will be returned. If
  /// [matchAllAttributes] is `true`, an element must possess every attribute
  /// contained in [attributeNames] to be returned, if `false`, the element
  /// only needs to posess a single attribute contained in [attributeNames].
  ///
  /// If [attributes] isn't `null`, only elements possessing attributes
  /// with an identical name and value as those contained in [attributes]
  /// will be returned. If [matchAllAttributes] is `true`, an element must
  /// possess every attribute contained in [attributes], if `false`,
  /// the element only needs to possess a single attribute contained in
  /// [attributes].
  ///
  /// If [children] isn't `null`, only elements possessing children matching
  /// those in [children] will be returned. If [matchAllChildren] is `true`,
  /// an element must posess every [child] found in [children], if `false`,
  /// the element only needs to posess a single child found in [children].
  /// If [childrenMustBeIdentical] is `true`, the element's children must be
  /// in the same order and possess the same number of children as those in
  /// [children], children will also be compared with the `==` operator,
  /// rather than the [compareValues] method.
  ///
  /// Returns `null` if no element can be found.
  XmlElement? getLastChildWhere({
    String? name,
    String? id,
    List<String>? attributeNames,
    List<XmlAttribute>? attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    List<XmlNode>? children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical = false,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);
    return getElementsWhere(
      name: name,
      id: id,
      attributeNames: attributeNames,
      attributes: attributes,
      matchAllAttributes: matchAllAttributes,
      attributesMustBeIdentical: attributesMustBeIdentical,
      children: children,
      matchAllChildren: matchAllChildren,
      childrenMustBeIdentical: childrenMustBeIdentical,
      global: false,
      reversed: true,
    )?.first;
  }

  /// Returns all direct children with properties matching those specified.
  ///
  /// [name] and [id] must not be empty if they are provided.
  ///
  /// If [attributeNames] is not `null`, only elements posessing an attribute
  /// with a name contained in [attributeNames] will be returned. If
  /// [matchAllAttributes] is `true`, an element must possess every attribute
  /// contained in [attributeNames] to be returned, if `false`, the element
  /// only needs to posess a single attribute contained in [attributeNames].
  ///
  /// If [attributes] isn't `null`, only elements possessing attributes
  /// with an identical name and value as those contained in [attributes]
  /// will be returned. If [matchAllAttributes] is `true`, an element must
  /// possess every attribute contained in [attributes], if `false`,
  /// the element only needs to possess a single attribute contained in
  /// [attributes].
  ///
  /// If [children] isn't `null`, only elements possessing children matching
  /// those in [children] will be returned. If [matchAllChildren] is `true`,
  /// an element must posess every [child] found in [children], if `false`,
  /// the element only needs to posess a single child found in [children].
  /// If [childrenMustBeIdentical] is `true`, the element's children must be
  /// in the same order and possess the same number of children as those in
  /// [children], children will also be compared with the `==` operator,
  /// rather than the [compareValues] method.
  ///
  /// [start] and [stop] refer to the indexes of the identified elements.
  /// Only matches found between [start] and [stop] will be returned.
  /// [start] must not be `null` and must be `>= 0`. [stop] may be `null`,
  /// but must be `>= start` if provided.
  ///
  /// Returns `null` if no element can be found.
  List<XmlElement>? getChildrenWhere({
    String? name,
    String? id,
    List<String>? attributeNames,
    List<XmlAttribute>? attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    List<XmlNode>? children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical = false,
    int start = 0,
    int? stop,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);
    return getElementsWhere(
      name: name,
      id: id,
      attributeNames: attributeNames,
      attributes: attributes,
      matchAllAttributes: matchAllAttributes,
      attributesMustBeIdentical: attributesMustBeIdentical,
      children: children,
      matchAllChildren: matchAllChildren,
      childrenMustBeIdentical: childrenMustBeIdentical,
      global: false,
    );
  }

  /// Returns `true` if this element contains a direct
  /// child named [elementName].
  ///
  /// [elementName] must not be `null` or empty.
  bool hasChild(String elementName) {
    assert(elementName.isNotEmpty);
    if (children == null) return false;
    elementName = elementName.toLowerCase();
    for (var child in children!) {
      if (child is XmlElement && child.name.toLowerCase() == elementName) {
        return true;
      }
    }
    return false;
  }

  /// Returns `true` if [children] contains a direct child with
  /// properties matching those specified.
  ///
  /// [name] and [id] must not be empty if they are provided.
  ///
  /// If [attributeNames] is not `null`, only elements posessing an attribute
  /// with a name contained in [attributeNames] will be returned. If
  /// [matchAllAttributes] is `true`, an element must possess every attribute
  /// contained in [attributeNames] to be returned, if `false`, the element
  /// only needs to posess a single attribute contained in [attributeNames].
  ///
  /// If [attributes] isn't `null`, only elements possessing attributes
  /// with an identical name and value as those contained in [attributes]
  /// will be returned. If [matchAllAttributes] is `true`, an element must
  /// possess every attribute contained in [attributes], if `false`,
  /// the element only needs to possess a single attribute contained in
  /// [attributes].
  ///
  /// If [children] isn't `null`, only elements possessing children matching
  /// those in [children] will be returned. If [matchAllChildren] is `true`,
  /// an element must posess every [child] found in [children], if `false`,
  /// the element only needs to posess a single child found in [children].
  /// If [childrenMustBeIdentical] is `true`, the element's children must be
  /// in the same order and possess the same number of children as those in
  /// [children], children will also be compared with the `==` operator,
  /// rather than the [compareValues] method.
  bool hasChildWhere({
    String? name,
    String? id,
    List<String>? attributeNames,
    List<XmlAttribute>? attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    List<XmlNode>? children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical = false,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);
    assert(attributeNames != null || attributeNames!.isNotEmpty);

    if (children == null) return false;

    return hasElementWhere(
      name: name,
      id: id,
      attributeNames: attributeNames,
      attributes: attributes,
      matchAllAttributes: matchAllAttributes,
      attributesMustBeIdentical: attributesMustBeIdentical,
      children: children,
      matchAllChildren: matchAllChildren,
      childrenMustBeIdentical: childrenMustBeIdentical,
      global: false,
    );
  }

  /// Recursively checks all elements within this node tree and
  /// returns the first element found named [elementName].
  ///
  /// Returns `null` if no element can be found named [elementName].
  XmlElement? getElement(String elementName) {
    assert(elementName.isNotEmpty);
    return getElementsWhere(
      name: elementName,
      start: 0,
      stop: 0,
    )?.first;
  }

  /// Recursively checks all elements within this node tree and
  /// returns the nth element found named [elementName].
  ///
  /// [index] must not be `null` and must be `>= 0`.
  ///
  /// [elementName] must not be `null` or empty.
  ///
  /// If [ignoreNestedMatches] is `true`, matching elements that are
  /// nested within matching elements will not be returned, only the highest
  /// level matching elements will be returned. If `false`, all matching
  /// elements will be returned.
  ///
  /// Returns `null` if no element can be found.
  XmlElement? getNthElement(int index, String elementName,
      {bool ignoreNestedMatches = true}) {
    assert(index >= 0);
    assert(elementName.isNotEmpty);
    return getElementsWhere(
      name: elementName,
      ignoreNestedMatches: ignoreNestedMatches,
      start: index,
      stop: index,
    )?.first;
  }

  /// Recursively checks all elements within this node tree and
  /// returns the last element found named [elementName].
  ///
  /// Returns `null` if no element can be found named [elementName].
  XmlElement? getLastElement(String elementName) {
    assert(elementName.isNotEmpty);
    return getElementsWhere(
      name: elementName,
      start: 0,
      stop: 0,
      reversed: true,
    )?.first;
  }

  /// Recursively checks all elements within this node tree and
  /// returns any elements found named [elementName].
  ///
  /// If [ignoredNestedMatches] is `true`, the children of any
  /// matching element will be ignored. If `false`, elements named
  /// [elementName] nested within elements named [elementName]
  /// will be returned in additional to their parent.
  ///
  /// [start] and [stop] refer to the indexes of the identified elements.
  /// Only matches found between [start] and [stop] will be returned.
  /// [start] must not be `null` and must be `>= 0`. [stop] may be `null`,
  /// but must be `>= start` if provided.
  ///
  /// Returns `null` if no elements can be found named [elementName].
  List<XmlElement>? getElements(
    String elementName, {
    bool ignoreNestedMatches = true,
    int start = 0,
    int? stop,
  }) {
    assert(elementName.isNotEmpty);
    assert(start >= 0);
    assert(stop == null || stop >= start);

    return getElementsWhere(
      name: elementName,
      ignoreNestedMatches: ignoreNestedMatches,
      start: start,
      stop: stop,
    );
  }

  /// Recursively checks all elements within the node tree and returns
  /// the first element found with properties matching those specified.
  ///
  /// [name] and [id] must not be empty if they are provided.
  ///
  /// If [attributeNames] is not `null`, only elements posessing an attribute
  /// with a name contained in [attributeNames] will be returned. If
  /// [matchAllAttributes] is `true`, an element must possess every attribute
  /// contained in [attributeNames] to be returned, if `false`, the element
  /// only needs to posess a single attribute contained in [attributeNames].
  ///
  /// If [attributes] isn't `null`, only elements possessing attributes
  /// with an identical name and value as those contained in [attributes]
  /// will be returned. If [matchAllAttributes] is `true`, an element must
  /// possess every attribute contained in [attributes], if `false`,
  /// the element only needs to possess a single attribute contained in
  /// [attributes].
  ///
  /// If [children] isn't `null`, only elements possessing children matching
  /// those in [children] will be returned. If [matchAllChildren] is `true`,
  /// an element must posess every [child] found in [children], if `false`,
  /// the element only needs to posess a single child found in [children].
  /// If [childrenMustBeIdentical] is `true`, the element's children must be
  /// in the same order and possess the same number of children as those in
  /// [children], children will also be compared with the `==` operator,
  /// rather than the [compareValues] method.
  ///
  /// [start] and [stop] refer to the indexes of the identified elements.
  /// Only matches found between [start] and [stop] will be returned.
  /// [start] must not be `null` and must be `>= 0`. [stop] may be `null`,
  /// but must be `>= start` if provided.
  ///
  /// Returns `null` if no element can be found.
  XmlElement? getElementWhere({
    String? name,
    String? id,
    List<String>? attributeNames,
    List<XmlAttribute>? attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    List<XmlNode>? children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical = false,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);

    return getElementsWhere(
      name: name,
      id: id,
      attributeNames: attributeNames,
      matchAllAttributes: matchAllAttributes,
      attributesMustBeIdentical: attributesMustBeIdentical,
      children: children,
      matchAllChildren: matchAllChildren,
      childrenMustBeIdentical: childrenMustBeIdentical,
      start: 0,
      stop: 0,
    )?.first;
  }

  /// Recursively checks all elements within the node tree and returns
  /// the nth element found with properties matching those specified.
  ///
  /// [index] must not be `null` and must be `>= 0`.
  ///
  /// [name] and [id] must not be empty if they are provided.
  ///
  /// If [attributeNames] is not `null`, only elements posessing an attribute
  /// with a name contained in [attributeNames] will be returned. If
  /// [matchAllAttributes] is `true`, an element must possess every attribute
  /// contained in [attributeNames] to be returned, if `false`, the element
  /// only needs to posess a single attribute contained in [attributeNames].
  ///
  /// If [attributes] isn't `null`, only elements possessing attributes
  /// with an identical name and value as those contained in [attributes]
  /// will be returned. If [matchAllAttributes] is `true`, an element must
  /// possess every attribute contained in [attributes], if `false`,
  /// the element only needs to possess a single attribute contained in
  /// [attributes].
  ///
  /// If [children] isn't `null`, only elements possessing children matching
  /// those in [children] will be returned. If [matchAllChildren] is `true`,
  /// an element must posess every [child] found in [children], if `false`,
  /// the element only needs to posess a single child found in [children].
  /// If [childrenMustBeIdentical] is `true`, the element's children must be
  /// in the same order and possess the same number of children as those in
  /// [children], children will also be compared with the `==` operator,
  /// rather than the [compareValues] method.
  ///
  /// [start] and [stop] refer to the indexes of the identified elements.
  /// Only matches found between [start] and [stop] will be returned.
  /// [start] must not be `null` and must be `>= 0`. [stop] may be `null`,
  /// but must be `>= start` if provided.
  ///
  /// Returns `null` if no element can be found.
  XmlElement? getNthElementWhere(
    int index, {
    String? name,
    String? id,
    List<String>? attributeNames,
    List<XmlAttribute>? attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    List<XmlNode>? children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical = false,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);

    return getElementsWhere(
      name: name,
      id: id,
      attributeNames: attributeNames,
      attributes: attributes,
      matchAllAttributes: matchAllAttributes,
      attributesMustBeIdentical: attributesMustBeIdentical,
      children: children,
      matchAllChildren: matchAllChildren,
      childrenMustBeIdentical: childrenMustBeIdentical,
      start: index,
      stop: index,
    )?.first;
  }

  /// Recursively checks all elements within the node tree and returns
  /// the last element found with properties matching those specified.
  ///
  /// [name] and [id] must not be empty if they are provided.
  ///
  /// If [attributeNames] is not `null`, only elements posessing an attribute
  /// with a name contained in [attributeNames] will be returned. If
  /// [matchAllAttributes] is `true`, an element must possess every attribute
  /// contained in [attributeNames] to be returned, if `false`, the element
  /// only needs to posess a single attribute contained in [attributeNames].
  ///
  /// If [attributes] isn't `null`, only elements possessing attributes
  /// with an identical name and value as those contained in [attributes]
  /// will be returned. If [matchAllAttributes] is `true`, an element must
  /// possess every attribute contained in [attributes], if `false`,
  /// the element only needs to possess a single attribute contained in
  /// [attributes].
  ///
  /// If [children] isn't `null`, only elements possessing children matching
  /// those in [children] will be returned. If [matchAllChildren] is `true`,
  /// an element must posess every [child] found in [children], if `false`,
  /// the element only needs to posess a single child found in [children].
  /// If [childrenMustBeIdentical] is `true`, the element's children must be
  /// in the same order and possess the same number of children as those in
  /// [children], children will also be compared with the `==` operator,
  /// rather than the [compareValues] method.
  ///
  /// Returns `null` if no element can be found.
  XmlElement? getLastElementWhere({
    String? name,
    String? id,
    List<String>? attributeNames,
    List<XmlAttribute>? attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    List<XmlNode>? children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical = false,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);
    return getElementsWhere(
      name: name,
      id: id,
      attributeNames: attributeNames,
      attributes: attributes,
      matchAllAttributes: matchAllAttributes,
      attributesMustBeIdentical: attributesMustBeIdentical,
      children: children,
      matchAllChildren: matchAllChildren,
      childrenMustBeIdentical: childrenMustBeIdentical,
      reversed: true,
    )?.first;
  }

  /// Recursively checks all elements within the node tree and returns
  /// any elements found with properties matching those specified.
  ///
  /// [name] and [id] must not be empty if they are provided.
  ///
  /// If [attributeNames] is not `null`, only elements posessing an attribute
  /// with a name contained in [attributeNames] will be returned. If
  /// [matchAllAttributes] is `true`, an element must possess every attribute
  /// contained in [attributeNames] to be returned, if `false`, the element
  /// only needs to posess a single attribute contained in [attributeNames].
  ///
  /// If [attributes] isn't `null`, only elements possessing attributes
  /// with an identical name and value as those contained in [attributes]
  /// will be returned. If [matchAllAttributes] is `true`, an element must
  /// possess every attribute contained in [attributes], if `false`,
  /// the element only needs to possess a single attribute contained in
  /// [attributes].
  ///
  /// If [children] isn't `null`, only elements possessing children matching
  /// those in [children] will be returned. If [matchAllChildren] is `true`,
  /// an element must posess every [child] found in [children], if `false`,
  /// the element only needs to posess a single child found in [children].
  /// If [childrenMustBeIdentical] is `true`, the element's children must be
  /// in the same order and possess the same number of children as those in
  /// [children], children will also be compared with the `==` operator,
  /// rather than the [compareValues] method.
  ///
  /// If [ignoreNestedMatches] is `true`, matching elements that are
  /// nested within matching elements will not be returned, only the highest
  /// level matching elements will be returned. If `false`, all matching
  /// elements will be returned.
  ///
  /// [start] and [stop] refer to the indexes of the identified elements.
  /// Only matches found between [start] and [stop] will be returned.
  /// [start] must not be `null` and must be `>= 0`. [stop] may be `null`,
  /// but must be `>= start` if provided.
  ///
  /// Returns `null` if no element can be found.
  List<XmlElement>? getElementsWhere({
    String? name,
    String? id,
    List<String>? attributeNames,
    List<XmlAttribute>? attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    List<XmlNode>? children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical = false,
    bool ignoreNestedMatches = true,
    int start = 0,
    int? stop,
    bool global = true,
    bool reversed = false,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);
    assert(start >= 0);
    assert(stop == null || stop >= start);

    if (this.children == null || start >= this.children!.length) return null;

    name = name?.toLowerCase();

    final elements = <XmlElement>[];
    var elementCount = 0;

    for (var child in reversed ? this.children!.reversed : this.children!) {
      if (child is XmlElement) {
        if (compareValues(
          child,
          name: name,
          id: id,
          attributes: attributes,
          attributeNames: attributeNames,
          matchAllAttributes: matchAllAttributes,
          attributesMustBeIdentical: attributesMustBeIdentical,
          children: children,
          matchAllChildren: matchAllChildren,
          childrenMustBeIdentical: childrenMustBeIdentical,
        )) {
          if (elementCount >= start) elements.add(child);

          elementCount++;

          if (stop != null && elementCount > stop) break;

          if (ignoreNestedMatches) continue;
        }

        if (!global) continue;

        if (child.children?.isNotEmpty == true) {
          final nestedChildren = child.getElementsWhere(
            name: name,
            id: id,
            attributeNames: attributeNames,
            attributes: attributes,
            matchAllAttributes: matchAllAttributes,
            attributesMustBeIdentical: attributesMustBeIdentical,
            children: children,
            matchAllChildren: matchAllChildren,
            childrenMustBeIdentical: childrenMustBeIdentical,
            ignoreNestedMatches: ignoreNestedMatches,
            start: 0,
            stop: (stop != null) ? stop - elementCount : null,
          );

          if (nestedChildren != null) {
            for (var nestedChild in nestedChildren) {
              if (elementCount >= start) elements.add(nestedChild);

              elementCount++;

              if (stop != null && elementCount > stop) break;
            }
          }
        }

        if (stop != null && elementCount > stop) break;
      }
    }

    if (elements.isEmpty) return null;

    return elements;
  }

  /// Recursively checks all nested elements and returns `true` if one
  /// is found named [elementName].
  ///
  /// [elementName] must not be `null` or empty.
  bool hasElement(String elementName) {
    assert(elementName.isNotEmpty);
    return hasElementWhere(name: elementName);
  }

  /// Recursively checks all nested elements and returns `true` if one
  /// is found with properties matching those specified.
  ///
  /// [name] and [id] must not be empty if they are provided.
  ///
  /// If [attributeNames] is not `null`, only elements posessing an attribute
  /// with a name contained in [attributeNames] will be returned. If
  /// [matchAllAttributes] is `true`, an element must possess every attribute
  /// contained in [attributeNames] to be returned, if `false`, the element
  /// only needs to posess a single attribute contained in [attributeNames].
  ///
  /// If [attributes] isn't `null`, only elements possessing attributes
  /// with an identical name and value as those contained in [attributes]
  /// will be returned. If [matchAllAttributes] is `true`, an element must
  /// possess every attribute contained in [attributes], if `false`,
  /// the element only needs to possess a single attribute contained in
  /// [attributes].
  ///
  /// If [children] isn't `null`, only elements possessing children matching
  /// those in [children] will be returned. If [matchAllChildren] is `true`,
  /// an element must posess every [child] found in [children], if `false`,
  /// the element only needs to posess a single child found in [children].
  /// If [childrenMustBeIdentical] is `true`, the element's children must be
  /// in the same order and possess the same number of children as those in
  /// [children], children will also be compared with the `==` operator,
  /// rather than the [compareValues] method.
  ///
  /// If [global] is `true`, only top-level elements will be returned,
  /// making this method identical to [hasChildWhere].
  bool hasElementWhere({
    String? name,
    String? id,
    List<String>? attributeNames,
    List<XmlAttribute>? attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    List<XmlNode>? children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical = false,
    bool global = false,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);

    if (this.children == null) return false;

    name = name?.toLowerCase();

    for (var child in children!) {
      if (child is XmlElement) {
        if (compareValues(
          child,
          name: name,
          id: id,
          attributeNames: attributeNames,
          attributes: attributes,
          matchAllAttributes: matchAllAttributes,
          attributesMustBeIdentical: attributesMustBeIdentical,
          children: children,
          matchAllChildren: matchAllChildren,
          childrenMustBeIdentical: childrenMustBeIdentical,
        )) {
          return true;
        }

        if (!global) continue;

        final elementIsNested = child.hasElementWhere(
          name: name,
          id: id,
          attributeNames: attributeNames,
          attributes: attributes,
          matchAllAttributes: matchAllAttributes,
          attributesMustBeIdentical: attributesMustBeIdentical,
          children: children,
          matchAllChildren: matchAllChildren,
          childrenMustBeIdentical: childrenMustBeIdentical,
        );

        if (elementIsNested) return true;
      }
    }

    return false;
  }

  /// Compares [element]'s values with the supplied values and returns
  /// `true` if they match, or `false` if they don't.
  ///
  /// [name] and [id] must not be empty if they are provided.
  ///
  /// If [attributeNames] is not `null`, only elements posessing an attribute
  /// with a name contained in [attributeNames] will be returned. If
  /// [matchAllAttributes] is `true`, an element must possess every attribute
  /// contained in [attributeNames] to be returned, if `false`, the element
  /// only needs to posess a single attribute contained in [attributeNames].
  ///
  /// If [attributes] isn't `null`, only elements possessing attributes
  /// with an identical name and value as those contained in [attributes]
  /// will be returned. If [matchAllAttributes] is `true`, an element must
  /// possess every attribute contained in [attributes], if `false`,
  /// the element only needs to possess a single attribute contained in
  /// [attributes].
  ///
  /// If [children] isn't `null`, only elements possessing children matching
  /// those in [children] will be returned. If [matchAllChildren] is `true`,
  /// an element must posess every [child] found in [children], if `false`,
  /// the element only needs to posess a single child found in [children].
  /// If [childrenMustBeIdentical] is `true`, the element's children must be
  /// in the same order and possess the same number of children as those in
  /// [children], children will also be compared with the `==` operator,
  /// rather than the [compareValues] method.
  static bool compareValues(
    XmlNode element, {
    String? name,
    String? id,
    List<String>? attributeNames,
    List<XmlAttribute>? attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    List<XmlNode>? children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical = false,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);
    assert(attributeNames == null || attributeNames.isNotEmpty);

    if (element is XmlElement) {
      // Compare the names
      if (name != null && element.name.toLowerCase() != name.toLowerCase()) {
        return false;
      }

      // Compare the IDs
      if (id != null && element.id != id) {
        return false;
      }

      // Compare the attributes
      if (attributeNames != null || attributes != null) {
        if (element.attributes == null) return false;

        if (attributesMustBeIdentical &&
            attributes!.length != element.attributes!.length) {
          return false;
        }

        if (attributeNames != null && attributeNames.isNotEmpty) {
          var hasAttributes = (matchAllAttributes) ? attributeNames.length : 1;
          for (var attributeName in attributeNames) {
            if (element.hasAttribute(attributeName)) {
              hasAttributes--;
            }
            if (hasAttributes <= 0) break;
          }
          if (hasAttributes > 0) return false;
        }

        if (attributes != null) {
          var hasAttributes = (matchAllAttributes) ? attributes.length : 1;

          for (var attribute in attributes) {
            if (element.hasAttributeWhere(attribute.name, attribute.value)) {
              hasAttributes--;
            }
          }

          if (hasAttributes > 0) return false;
        }
      }

      // Compare the children
      if (children != null) {
        if (element.children == null) return false;

        if (childrenMustBeIdentical &&
            element.children!.length != children.length) {
          return false;
        }

        var hasChildren =
            (matchAllChildren || childrenMustBeIdentical) ? children.length : 1;

        for (var i = 0; i < children.length; i++) {
          final child = children[i];

          if (child is XmlElement) {
            if (childrenMustBeIdentical) {
              if (child != element.children![i]) {
                return false;
              } else {
                hasChildren--;
              }
            } else {
              if (element.hasChildWhere(
                name: child.name,
                id: child.id,
                attributes: child.attributes,
                matchAllAttributes: matchAllAttributes,
                attributesMustBeIdentical: attributesMustBeIdentical,
                children: child.children,
                matchAllChildren: matchAllChildren,
                childrenMustBeIdentical: childrenMustBeIdentical,
              )) {
                hasChildren--;
              }
            }
          }

          if (hasChildren <= 0) break;
        }

        if (hasChildren > 0) return false;
      }
    } else {
      return false;
    }

    return true;
  }
}
