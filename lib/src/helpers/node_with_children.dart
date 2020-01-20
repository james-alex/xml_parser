import 'package:meta/meta.dart';
import '../xml_node.dart';

/// Base class for nodes with children that can contain [XmlElement]s.
@immutable
abstract class NodeWithChildren {
  /// Base class for nodes with children that can contain [XmlElement]s.
  NodeWithChildren();

  /// The list of [children] each getter and method references.
  final List<XmlNode> children = null;

  /// Returns `true` if [children] isn't null or empty.
  bool get hasChildren => children != null && children.isNotEmpty;

  /// Returns the first [XmlElement] found in [children].
  ///
  /// Returns `null` if one isn't found.
  XmlElement get firstChild {
    if (children == null) return null;

    for (var child in children) {
      if (child is XmlElement) return child;
    }

    return null;
  }

  /// Returns the nth [XmlElement] found in [children].
  ///
  /// [index] must not be `null` and must be `>= 0`.
  ///
  /// Returns `null` if one isn't found.
  XmlElement nthChild(int index) {
    assert(index != null && index >= 0);

    if (children == null) return null;

    var childCount = 0;

    for (var child in children) {
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
  XmlElement get lastChild {
    if (children == null) return null;

    for (var child in children.reversed) {
      if (child is XmlElement) return child;
    }

    return null;
  }

  /// Returns the first direct child named [elementName].
  ///
  /// Returns `null` if no element can be found.
  XmlElement getChild(String elementName) {
    assert(elementName != null && elementName.isNotEmpty);

    if (children == null) return null;

    elementName = elementName.toLowerCase();

    return children.firstWhere(
      (child) => child is XmlElement && child.name.toLowerCase() == elementName,
      orElse: () => null,
    );
  }

  /// Returns the nth direct child named [elementName].
  ///
  /// [index] must not be `null` and must be `>= 0`.
  ///
  /// Returns `null` if no element can be found.
  XmlElement getNthChild(int index, String elementName) {
    assert(index != null && index >= 0);
    assert(elementName != null && elementName.isNotEmpty);

    return getChildren(elementName, start: index, stop: index)?.first;
  }

  /// Returns the last direct child named [elementName].
  ///
  /// Returns `null` if no element can be found.
  XmlElement getLastChild(String elementName) {
    assert(elementName != null && elementName.isNotEmpty);

    if (children == null) return null;

    elementName = elementName.toLowerCase();

    return children.lastWhere(
      (child) => child is XmlElement && child.name.toLowerCase() == elementName,
      orElse: () => null,
    );
  }

  /// Returns all direct children named [elementName].
  ///
  /// [start] and [stop] refer to the indexes of the identified elements.
  /// Only matches found between [start] and [stop] will be returned.
  /// [start] must not be `null` and must be `>= 0`. [stop] may be `null`,
  /// but must be `>= start` if provided.
  ///
  /// Returns `null` if no element can be found.
  List<XmlElement> getChildren(
    String elementName, {
    int start = 0,
    int stop,
  }) {
    assert(elementName != null && elementName.isNotEmpty);
    assert(start != null && start >= 0);
    assert(stop == null || stop >= start);

    return getElementsWhere(
      name: elementName,
      start: start,
      stop: stop,
      global: false,
    );
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
  XmlElement getChildWhere({
    String name,
    String id,
    List<String> attributeNames,
    List<XmlAttribute> attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    List<XmlNode> children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical = false,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);
    assert(matchAllAttributes != null);
    assert(attributesMustBeIdentical != null);
    assert(matchAllChildren != null);
    assert(childrenMustBeIdentical != null);

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
  XmlElement getNthChildWhere(
    int index, {
    String name,
    String id,
    List<String> attributeNames,
    List<XmlAttribute> attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    List<XmlNode> children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical = false,
  }) {
    assert(index != null);
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);
    assert(matchAllAttributes != null);
    assert(attributesMustBeIdentical != null);
    assert(matchAllChildren != null);
    assert(childrenMustBeIdentical != null);

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
  XmlElement getLastChildWhere({
    String name,
    String id,
    List<String> attributeNames,
    List<XmlAttribute> attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    List<XmlNode> children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical = false,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);
    assert(matchAllAttributes != null);
    assert(attributesMustBeIdentical != null);
    assert(matchAllChildren != null);
    assert(childrenMustBeIdentical != null);

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
  List<XmlElement> getChildrenWhere({
    String name,
    String id,
    List<String> attributeNames,
    List<XmlAttribute> attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    List<XmlNode> children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical = false,
    int start = 0,
    int stop,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);
    assert(matchAllAttributes != null);
    assert(attributesMustBeIdentical != null);
    assert(matchAllChildren != null);
    assert(childrenMustBeIdentical != null);

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
    assert(elementName != null && elementName.isNotEmpty);

    if (children == null) return false;

    elementName = elementName.toLowerCase();

    for (var child in children) {
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
    String name,
    String id,
    List<String> attributeNames,
    List<XmlAttribute> attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    List<XmlNode> children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical = false,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);
    assert(attributeNames != null || attributeNames.isNotEmpty);
    assert(matchAllAttributes != null);
    assert(attributesMustBeIdentical != null);
    assert(matchAllChildren != null);
    assert(childrenMustBeIdentical != null);

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
  XmlElement getElement(String elementName) {
    assert(elementName != null && elementName.isNotEmpty);

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
  XmlElement getNthElement(int index, String elementName,
      {bool ignoreNestedMatches = true}) {
    assert(index != null && index >= 0);
    assert(elementName != null && elementName.isNotEmpty);
    assert(ignoreNestedMatches != null);

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
  XmlElement getLastElement(String elementName) {
    assert(elementName != null && elementName.isNotEmpty);

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
  List<XmlElement> getElements(
    String elementName, {
    bool ignoreNestedMatches = true,
    int start = 0,
    int stop,
  }) {
    assert(elementName != null && elementName.isNotEmpty);
    assert(ignoreNestedMatches != null);
    assert(start != null && start >= 0);
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
  XmlElement getElementWhere({
    String name,
    String id,
    List<String> attributeNames,
    List<XmlAttribute> attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    List<XmlNode> children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical = false,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);
    assert(matchAllAttributes != null);
    assert(attributesMustBeIdentical != null);
    assert(matchAllChildren != null);
    assert(childrenMustBeIdentical != null);

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
  XmlElement getNthElementWhere(
    int index, {
    String name,
    String id,
    List<String> attributeNames,
    List<XmlAttribute> attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    List<XmlNode> children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical = false,
  }) {
    assert(index != null);
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);
    assert(matchAllAttributes != null);
    assert(attributesMustBeIdentical != null);
    assert(matchAllChildren != null);
    assert(childrenMustBeIdentical != null);

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
  XmlElement getLastElementWhere({
    String name,
    String id,
    List<String> attributeNames,
    List<XmlAttribute> attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    List<XmlNode> children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical = false,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);
    assert(matchAllAttributes != null);
    assert(attributesMustBeIdentical != null);
    assert(matchAllChildren != null);
    assert(childrenMustBeIdentical != null);

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
  List<XmlElement> getElementsWhere({
    String name,
    String id,
    List<String> attributeNames,
    List<XmlAttribute> attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    List<XmlNode> children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical = false,
    bool ignoreNestedMatches = true,
    int start = 0,
    int stop,
    bool global = true,
    bool reversed = false,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);
    assert(matchAllAttributes != null);
    assert(attributesMustBeIdentical != null);
    assert(matchAllChildren != null);
    assert(childrenMustBeIdentical != null);
    assert(ignoreNestedMatches != null);
    assert(start != null && start >= 0);
    assert(stop == null || stop >= start);
    assert(global != null);
    assert(reversed != null);

    if (this.children == null || start >= this.children.length) return null;

    name = name?.toLowerCase();

    final elements = <XmlElement>[];

    var elementCount = 0;

    for (var child in reversed ? this.children.reversed : this.children) {
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

        if (child.children != null && child.children.isNotEmpty) {
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
    assert(elementName != null && elementName.isNotEmpty);

    return hasElementWhere(
      name: elementName,
    );
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
    String name,
    String id,
    List<String> attributeNames,
    List<XmlAttribute> attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical = false,
    List<XmlNode> children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical = false,
    bool global = false,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);
    assert(matchAllAttributes != null);
    assert(attributesMustBeIdentical != null);
    assert(matchAllChildren != null);
    assert(childrenMustBeIdentical != null);
    assert(global != null);

    if (this.children == null) return false;

    name = name?.toLowerCase();

    for (var child in children) {
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
    String name,
    String id,
    List<String> attributeNames,
    List<XmlAttribute> attributes,
    bool matchAllAttributes = false,
    bool attributesMustBeIdentical,
    List<XmlNode> children,
    bool matchAllChildren = false,
    bool childrenMustBeIdentical,
  }) {
    assert(element != null);
    assert(name == null || name.isNotEmpty);
    assert(id == null || id.isNotEmpty);
    assert(attributeNames == null || attributeNames.isNotEmpty);
    assert(matchAllAttributes != null);
    assert(attributesMustBeIdentical != null);
    assert(matchAllChildren != null);
    assert(childrenMustBeIdentical != null);

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
            attributes.length != element.attributes.length) {
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
            element.children.length != children.length) {
          return false;
        }

        var hasChildren =
            (matchAllChildren || childrenMustBeIdentical) ? children.length : 1;

        for (var i = 0; i < children.length; i++) {
          final child = children[i];

          if (child is XmlElement) {
            if (childrenMustBeIdentical) {
              if (child != element.children[i]) {
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

  // TODO: getNode methods
}
