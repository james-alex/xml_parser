import 'package:meta/meta.dart';
import '../helpers/delimiters.dart';
import '../helpers/helpers.dart' as helpers;
import '../helpers/node_with_children.dart';
import './xml_attribute.dart';
import '../xml_node.dart';

/// A XML element.
///
/// For the purposes of this package, an element can either
/// be an XML element (a tag) or a nested plain text value, in
/// which case only the [text] value is supplied.
///
/// See: https://www.w3.org/TR/xml/#sec-logical-struct
class XmlElement extends NodeWithChildren implements XmlNode {
  /// A XML element.
  ///
  /// [name] must not be empty and must be `> 0` in length.
  ///
  /// [attributes] must not be `null` but may be empty.
  ///
  /// If the [text] value is supplied, [children] must be `null`.
  const XmlElement({
    @required this.name,
    this.attributes,
    this.children,
  }) : assert(name != null && name.length > 0);

  /// The name of this element.
  final String name;

  /// The `id` attribute of this element.
  String get id {
    return attributes
        ?.firstWhere(
          (XmlAttribute attribute) => attribute.name.toLowerCase() == 'id',
          orElse: () => null,
        )
        ?.value
        ?.toLowerCase();
  }

  /// This element's declared attributes.
  final List<XmlAttribute> attributes;

  /// Returns true if this element has an attribute named [attributeName].
  ///
  /// [attributeName] must not be `null` or empty.
  bool hasAttribute(String attributeName) {
    assert(attributeName != null && attributeName.isNotEmpty);

    attributeName = attributeName.toLowerCase();

    for (XmlAttribute attribute in attributes) {
      if (attribute.name.toLowerCase() == attributeName) {
        return true;
      }
    }

    return false;
  }

  /// Returns true if this element has an attribute named
  /// [attributeName] and a value of [attributeValue].
  ///
  /// [attributeName] must not be `null` or empty.
  bool hasAttributeWhere(String attributeName, String attributeValue) {
    assert(attributeName != null && attributeName.isNotEmpty);

    attributeName = attributeName.toLowerCase();

    for (XmlAttribute attribute in attributes) {
      if (attribute.name.toLowerCase() == attributeName &&
          attribute.value == attributeValue) {
        return true;
      }
    }

    return false;
  }

  /// Returns the value of the first attribute named [attributeName]
  /// if it exists, otherwise returns `null`.
  String getAttribute(String attributeName) {
    assert(attributeName != null && attributeName.trim().isNotEmpty);

    if (attributes == null) return null;

    attributeName = attributeName.toLowerCase();

    for (XmlAttribute attribute in attributes) {
      if (attribute.name.toLowerCase() == attributeName) {
        return attribute.value;
      }
    }

    return null;
  }

  /// A list of the elements nested within this one.
  @override
  final List<XmlNode> children;

  /// Returns all of the top-level text nodes found in [children]
  /// and returns them combined into a string.
  ///
  /// Returns `null` if no text nodes exist.
  String get text {
    String text = '';

    children?.forEach((XmlNode child) {
      if (child is XmlText) {
        text += ((text.isEmpty) ? '' : ' ') + child.value;
      }
    });

    if (text.isEmpty) return null;

    return text;
  }

  /// Compares this element to [element] and returns `true` if this element
  /// posesses all of [element]'s values, otherwise returns `false`.
  ///
  /// The element's [name] value is case insensitive.
  ///
  /// If [matchAllAttributes] is `true`, an element must possess every
  /// attribute contained in [returnElementsWithAttributes], if `false`,
  /// the element only needs to possess a single attribute contained in
  /// [returnElementsWithAttributes].
  ///
  /// If [attributesMustBeIdentical] is true, this elements's attributes
  /// must match [element]'s attributes exactly, it may not have any
  /// attributes in addition to those possessed by [element].
  ///
  /// If [childrenMustBeIdentical] is true, [children] will be compared
  /// with the `==` operator and must be identical to return true,
  /// otherwise they will be compared with this method, `compareTo()`,
  /// in which case this element's children must possess the same values
  /// as [element]'s children, but don't need to be identical. If
  /// [childrenMustBeIdentical] is false, this element is allowed to have
  /// children in addition to [element]'s.
  ///
  /// This element can have values in addition to those of [element].
  /// Use the `==` operator if this element and [element] should be identical.
  bool compareTo(
    XmlNode element, {
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    bool childrenMustBeIdentical = false,
  }) {
    assert(element != null);
    assert(matchAllAttributes != null);
    assert(attributesMustBeIdentical != null);
    assert(childrenMustBeIdentical != null);

    if (element is XmlElement) {
      if (NodeWithChildren.compareValues(
        this,
        name: element.name,
        id: element.id,
        attributes: element.attributes,
        matchAllAttributes: matchAllAttributes,
        attributesMustBeIdentical: attributesMustBeIdentical,
        children: element.children,
        matchAllChildren: true,
        childrenMustBeIdentical: childrenMustBeIdentical,
      )) {
        return true;
      }
    }

    return false;
  }

  /// Copies this element with the provided values.
  ///
  /// [name] must be `> 0` in length if not `null`.
  ///
  /// If [copyNull] is `true`, [id], [attributes], and [children] will
  /// be copied with a value of `null` if they're not provided with another
  /// value, otherwise they will default to this element's values.
  XmlElement copyWith({
    String name,
    List<XmlAttribute> attributes,
    List<XmlNode> children,
    bool copyNull = false,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(copyNull != null);

    if (!copyNull) {
      attributes ??= this.attributes;
      children ??= this.children;
    }

    return XmlElement(
      name: name ?? this.name,
      attributes: attributes,
      children: children,
    );
  }

  /// Attempts to load all external DTD references contained within
  /// any nested [XmlDoctype]s and [XmlEntity]s, load the pages
  /// they reference, and parse the DTD elements contained within.
  ///
  /// In a valid XML document [XmlDoctype]s and [XmlEntity]s shouldn't be
  /// contained within an element, this method only exists for good measure.
  Future<void> loadExternalDtd() async {
    if (children == null || children.isEmpty) return;

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

  /// Returns this element as an unformatted XML string.
  ///
  /// If [doubleQuotes] is `true`, double-quotes will be used to wrap
  /// all attribute values, otherwise single-quotes will be used.
  ///
  /// If [encodeCharacterEntities] is `true`, text and attribute values
  /// will be parsed and have the characters included in [encodeCharacters]
  /// encoded as character entities.
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

    String element = _buildTag(
      doubleQuotes: doubleQuotes,
      encodeCharacterEntities: encodeCharacterEntities,
      encodeCharacters: encodeCharacters,
    );

    if (children != null) {
      element += helpers.childrenToString(
        children: children,
        encodeCharacterEntities: encodeCharacterEntities,
        encodeCharacters: encodeCharacters,
        doubleQuotes: doubleQuotes,
      );

      element += '</$name>';
    }

    return element;
  }

  @override
  String toFormattedString({
    int nestingLevel = 0,
    String indent = '\t',
    // TODO: int lineLength = 80,
    bool encodeCharacterEntities = true,
    String encodeCharacters,
    bool doubleQuotes = true,
  }) {
    assert(nestingLevel != null && nestingLevel >= 0);
    assert(indent != null);
    // TODO: assert(lineLength == null || lineLength > 0);
    assert(encodeCharacterEntities != null);
    assert(doubleQuotes != null);

    final String tag = _buildTag(
      doubleQuotes: doubleQuotes,
      encodeCharacterEntities: encodeCharacterEntities,
      encodeCharacters: encodeCharacters,
    );

    String element = helpers.formatLine(tag, nestingLevel, indent);

    if (children != null) {
      element += helpers.formatChildren(
        children: children,
        nestingLevel: nestingLevel,
        indent: indent,
        encodeCharacterEntities: encodeCharacterEntities,
        encodeCharacters: encodeCharacters,
        doubleQuotes: doubleQuotes,
      );

      element += helpers.formatLine('</$name>', nestingLevel, indent);
    }

    // TODO: Handle lineLength

    return element;
  }

  String _buildTag({
    bool doubleQuotes = true,
    bool encodeCharacterEntities = true,
    String encodeCharacters,
  }) {
    assert(doubleQuotes != null);
    assert(encodeCharacterEntities != null);

    String tag = '<' + name;

    if (id != null) {
      final String quotationMark = (doubleQuotes) ? '"' : '\'';

      tag += ' id=$quotationMark$id$quotationMark';
    }

    attributes?.forEach((XmlAttribute attribute) {
      if (id != null && attribute.name.toLowerCase() == 'id') return;

      tag += ' ' +
          attribute.toString(
            doubleQuotes: doubleQuotes,
            encodeCharacterEntities: encodeCharacterEntities,
            encodeCharacters: encodeCharacters ?? '&<>"\'',
          );
    });

    if (children != null) {
      tag += '>';
    } else {
      tag += ' />';
    }

    return tag;
  }

  /// Returns the first element found in [string].
  /// [string] must not be `null`.
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
  /// If [returnElementsNamed] is not `null`, only elements with a name
  /// contained in [returnElementsNamed] will be returned.
  ///
  /// If [returnElementsWithId] is not `null`, only elements with an ID
  /// contained in [returnElementsWithId] will be returned.
  ///
  /// If [returnElementsWithAttributesNamed] is not `null`,
  /// only elements posessing an attribute with a name contained in
  /// [returnElementsWithAttributesNamed] will be returned.
  /// If [matchAllAttributes] is `true`, an element must possess
  /// every attribute contained in [returnElementsWithAttributesNamed]
  /// to be returned, if `false`, the element only needs to posess a
  /// single attribute contained in [returnElementsWithAttributesNamed].
  ///
  /// If [returnElementsWithAttributes] is not `null`, only elements
  /// possessing attributes with an identical name and value as those
  /// contained in [returnElemtnsWithAttribute] will be returned.
  /// If [matchAllAttributes] is `true`, an element must possess every
  /// attribute contained in [returnElementsWithAttributes], if `false`,
  /// the element only needs to possess a single attribute contained in
  /// [returnElementsWithAttributes].
  ///
  /// Returns `null` if no elements were found.
  static XmlElement fromString(
    String string, {
    bool parseCharacterEntities = true,
    bool parseComments = false,
    bool trimWhitespace = true,
    bool parseCdataAsText = true,
    List<String> returnElementsNamed,
    List<String> returnElementsWithId,
    List<String> returnElementsWithAttributesNamed,
    List<XmlAttribute> returnElementsWithAttributes,
    bool matchAllAttributes = true,
  }) {
    assert(string != null);
    assert(parseCharacterEntities != null);
    assert(parseComments != null);
    assert(trimWhitespace != null);
    assert(parseCdataAsText != null);
    assert(matchAllAttributes != null ||
        (returnElementsWithAttributesNamed == null &&
            returnElementsWithAttributes == null));

    return parseString(
      string,
      parseCharacterEntities: parseCharacterEntities,
      parseComments: parseComments,
      trimWhitespace: trimWhitespace,
      parseCdataAsText: parseCdataAsText,
      returnElementsNamed: returnElementsNamed,
      returnElementsWithId: returnElementsWithId,
      returnElementsWithAttributesNamed: returnElementsWithAttributesNamed,
      returnElementsWithAttributes: returnElementsWithAttributes,
      matchAllAttributes: matchAllAttributes,
      stop: 0,
    )?.first;
  }

  /// Returns a list of every element found in [string].
  /// [string] must not be `null`.
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
  /// If [global] is `true`, all elements will be returned regardless
  /// of whether they're nested within other elements. If `false`, only
  /// the root level elements will be returned.
  ///
  /// If [returnElementsNamed] is not `null`, only elements with a name
  /// contained in [returnElementsNamed] will be returned.
  ///
  /// If [returnElementsWithId] is not `null`, only elements with an ID
  /// contained in [returnElementsWithId] will be returned.
  ///
  /// If [returnElementsWithAttributesNamed] is not `null`,
  /// only elements posessing an attribute with a name contained in
  /// [returnElementsWithAttributesNamed] will be returned.
  /// If [matchAllAttributes] is `true`, an element must possess
  /// every attribute contained in [returnElementsWithAttributesNamed]
  /// to be returned, if `false`, the element only needs to posess a
  /// single attribute contained in [returnElementsWithAttributesNamed].
  ///
  /// If [returnElementsWithAttributes] is not `null`, only elements
  /// possessing attributes with an identical name and value as those
  /// contained in [returnElemtnsWithAttribute] will be returned.
  /// If [matchAllAttributes] is `true`, an element must possess every
  /// attribute contained in [returnElementsWithAttributes], if `false`,
  /// the element only needs to possess a single attribute contained in
  /// [returnElementsWithAttributes].
  ///
  /// [start] and [stop] refer to the indexes of the identified elements.
  /// Only matches found between [start] and [stop] will be returned.
  /// [start] must not be `null` and must be `>= 0`. [stop] may be `null`,
  /// but must be `>= start` if provided.
  ///
  /// Returns `null` if no elements were found.
  static List<XmlElement> parseString(
    String string, {
    bool parseCharacterEntities = true,
    bool parseComments = false,
    bool trimWhitespace = true,
    bool parseCdataAsText = true,
    bool global = false,
    List<String> returnElementsNamed,
    List<String> returnElementsWithId,
    List<String> returnElementsWithAttributesNamed,
    List<XmlAttribute> returnElementsWithAttributes,
    bool matchAllAttributes = true,
    // TODO: returnElementsWithChildren
    int start = 0,
    int stop,
  }) {
    assert(string != null);
    assert(parseCharacterEntities != null);
    assert(parseComments != null);
    assert(trimWhitespace != null);
    assert(parseCdataAsText != null);
    assert(global != null);
    assert(matchAllAttributes != null ||
        (returnElementsWithAttributesNamed == null &&
            returnElementsWithAttributes == null));
    assert(start != null && start >= 0);
    assert(stop == null || stop >= start);

    if (!parseComments) string = helpers.removeComments(string);

    if (trimWhitespace) string = helpers.trimWhitespace(string);

    final List<XmlElement> elements = List<XmlElement>();

    int elementCount = 0;

    while (string.contains(Delimiters.elementTag)) {
      RegExpMatch tag = Delimiters.elementTag.firstMatch(string);

      final String name = tag.namedGroup('tagName');

      if (!name.startsWith('/')) {
        if (returnElementsNamed == null || returnElementsNamed.contains(name)) {
          List<XmlNode> children;

          final String attributeData = tag.namedGroup('attributes').trim();

          if (tag.namedGroup('isEmpty') != '/') {
            tag = Delimiters.element(name, global).firstMatch(string);

            children = XmlNode.parseString(
              tag.namedGroup('children'),
              parseCharacterEntities: parseCharacterEntities,
              parseComments: true,
              trimWhitespace: false,
              parseCdataAsText: true,
            );
          }

          List<XmlAttribute> attributes;

          bool attriubtesAreValid = true;

          if (attributeData.isNotEmpty) {
            attributes = XmlAttribute.parseString(
              attributeData,
              parseCharacterEntities: parseCharacterEntities,
              trimWhitespace: false,
            );

            if (returnElementsWithAttributesNamed != null ||
                returnElementsWithAttributes != null) {
              int attributeNamesToValidate =
                  (returnElementsWithAttributesNamed != null)
                      ? (matchAllAttributes)
                          ? returnElementsWithAttributesNamed.length
                          : 1
                      : 0;

              int attributesToValidate = (returnElementsWithAttributes != null)
                  ? (matchAllAttributes)
                      ? returnElementsWithAttributes.length
                      : 1
                  : 0;

              for (XmlAttribute attribute in attributes) {
                if (attributeNamesToValidate > 0 &&
                    returnElementsWithAttributesNamed
                        .contains(attribute.name)) {
                  attributeNamesToValidate--;
                }

                if (attributesToValidate > 0 &&
                    returnElementsWithAttributes.contains(attribute)) {
                  attributesToValidate--;
                }

                if (attributeNamesToValidate <= 0 && attributesToValidate <= 0) {
                  break;
                }
              }

              if (attributeNamesToValidate > 0 || attributesToValidate > 0) {
                attriubtesAreValid = false;
              }
            }
          } else if (returnElementsWithAttributes != null &&
              returnElementsWithAttributes.isNotEmpty) {
            attriubtesAreValid = false;
          }

          if (attriubtesAreValid) {
            final String id = attributes
                ?.firstWhere(
                  (XmlAttribute attribute) => attribute.name == 'id',
                  orElse: () => null,
                )
                ?.value;

            if (elementCount >= start &&
                (returnElementsWithId == null ||
                    returnElementsWithId.contains(id))) {
              elements.add(
                XmlElement(
                  name: name,
                  attributes: attributes,
                  children: children,
                ),
              );

              if (stop != null && elementCount > stop) break;
            }

            elementCount++;
          }
        }
      }

      string = string.substring(tag.end);
    }

    if (elements.isEmpty) return null;

    return elements;
  }

  @override
  bool operator ==(o) {
    // Compare types
    if (o.runtimeType != XmlElement) return false;

    // Compare names
    if (name.toLowerCase() != o.name.toLowerCase()) return false;

    if ((id != null && o.id != null) && (id != o.id)) return false;

    // Compare attributes
    if (attributes == null && o.attributes != null) return false;

    if (attributes != null && o.attributes == null) return false;

    if (attributes != null && o.attributes != null) {
      if (attributes.length != o.attributes.length) {
        return false;
      } else {
        for (XmlAttribute attribute in attributes) {
          if (attribute.value != o.getAttribute(attribute.name)) {
            return false;
          }
        }
      }
    }

    // Compare children
    if (children == null && o.children != null) return false;

    if (children != null && o.children == null) return false;

    if (children != null && o.children != null) {
      if (children.length != o.children.length) {
        return false;
      } else {
        for (int i = 0; i < children.length; i++) {
          if (children[i] != o.children[i]) {
            return false;
          }
        }
      }
    }

    return true;
  }

  @override
  int get hashCode => name.hashCode ^ attributes.hashCode ^ children.hashCode;
}
