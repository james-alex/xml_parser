import 'package:meta/meta.dart';
import '../helpers/delimiters.dart';
import '../helpers/helpers.dart' as helpers;
import '../helpers/string_parser.dart';
import '../xml_node.dart';

/// A DTD Entity Declaration.
///
/// See: https://www.w3.org/TR/xml/#sec-entity-decl
@immutable
class XmlEntity implements XmlNode {
  /// A DTD Entity Declaration.
  ///
  /// [name] must not be `null` and must be `> 0` in length.
  ///
  /// [value] must not be `null`.
  ///
  /// [isSystem] and [isPublic] must not be `null`, and only
  /// one of them may be `true`.
  XmlEntity(
    this.name,
    this.value, {
    this.isParameter = false,
    this.isSystem = false,
    this.isPublic = false,
    this.externalEntities,
    this.ndata,
  })  : assert(name != null && name.isNotEmpty),
        assert(value != null),
        assert(isParameter != null),
        assert(isSystem != null),
        assert(isPublic != null),
        assert(!(isPublic && isSystem));

  /// The name of the entity.
  ///
  /// It can be referenced in text values as `&name;`.
  final String name;

  /// The unparsed text value of the entity.
  final String value;

  /// Whether this entity is a parameter entity.
  ///
  /// Parameter entities are only used within DTD documents.
  final bool isParameter;

  /// `true` if the `SYSTEM` flag is declared.
  final bool isSystem;

  /// `true` if the `PUBLIC` flag is declared.
  final bool isPublic;

  /// The parsed external DTD elements, if they were loaded.
  final List<XmlEntity> externalEntities;

  /// NDATA defines type of data the external
  /// entity should be treated as.
  final String ndata;

  /// Attempts to load the external entity if there is one and
  /// if [ndata] is `null`. If [ndata] is provided, the file is
  /// assumed to be of another data type that can't be parsed by
  /// this library.
  ///
  /// If the URI couldn't be reached or no DTD elements could be identified,
  /// Returns `null`.
  Future<XmlEntity> loadExternalEntities() async {
    if ((!isSystem && !isPublic) || ndata != null) return null;

    final List<XmlNode> externalEntities =
        await XmlNode.fromUri(value, returnNodesOfType: [XmlEntity]);

    if (externalEntities == null) return null;

    return copyWith(externalEntities: externalEntities);
  }

  /// Copies this entity with the provided values.
  ///
  /// [name] must be `> 0` in length if not `null`.
  ///
  /// Either [isSystem] or [isPublic] may be `true`, not both.
  ///
  /// If [copyNull] is `true`, [value], [externalEntities], and [ndata]
  /// will be copied with a value of `null` if they're not provided with
  /// another value, otherwise they will default to this element's values.
  XmlEntity copyWith({
    String name,
    String value,
    bool isSystem,
    bool isPublic,
    List<XmlEntity> externalEntities,
    String ndata,
    bool copyNull = false,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(!(isPublic && isSystem));
    assert(copyNull != null);

    if (!copyNull) {
      value ??= this.value;
      externalEntities ??= this.externalEntities;
      ndata ??= this.ndata;
    }

    return XmlEntity(
      name ?? this.name,
      value,
      isSystem: isSystem ?? (isPublic != null)
          ? !isPublic
          : (this.isPublic != null) ? !this.isPublic : false,
      isPublic: isPublic ?? (isSystem != null)
          ? !isSystem
          : (this.isSystem != null) ? !this.isSystem : false,
      externalEntities: externalEntities,
      ndata: ndata,
    );
  }

  @override
  String toString([bool doubleQuotes = true]) {
    assert(doubleQuotes != null);

    final quotationMark = doubleQuotes ? '"' : '\'';

    final identifier = isSystem ? ' SYSTEM' : isPublic ? ' PUBLIC' : '';

    final value = ' $quotationMark${this.value}$quotationMark';

    final ndata = (this.ndata != null) ? ' NDATA ${this.ndata}' : '';

    return '<!ENTITY $name$identifier$value$ndata>';
  }

  @override
  String toFormattedString({
    int nestingLevel = 0,
    String indent = '\t',
    // TODO: int lineLength = 80,
    bool doubleQuotes = true,
  }) {
    assert(nestingLevel != null && nestingLevel >= 0);
    assert(indent != null);
    // TODO: assert(lineLength == null || lineLength > 0);
    assert(doubleQuotes != null);

    var entity =
        helpers.formatLine(toString(doubleQuotes), nestingLevel, indent);

    // TODO: Handle lineLength

    return entity;
  }

  /// Returns the first DTD Entity found in [string].
  ///
  /// [string] must not be `null`.
  ///
  /// If [trimWhitespace] is `true`, unnecessary whitespace between nodes
  /// will be removed and all remaining whitespace will be replaced with
  /// a single space. [trimWhitespace] must not be `null`.
  ///
  /// Returns `null` if no valid DTD entities are found.
  static XmlEntity fromString(
    String string, {
    bool trimWhitespace = true,
  }) {
    assert(string != null);
    assert(trimWhitespace != null);

    return _parser.fromString(
      input: string,
      delimiter: Delimiters.entity,
      getNode: _getEntity,
      trimWhitespace: trimWhitespace,
    );
  }

  /// Returns all DTD Entities found in [string].
  ///
  /// [string] must not be `null`.
  ///
  /// [start] and [stop] refer to the indexes of the identified DTD Entities.
  /// Only matches found between [start] and [stop] will be returned.
  /// [start] must not be `null` and must be `>= 0`. [stop] may be `null`,
  /// but must be `>= start` if provided.
  ///
  /// Returns `null` if no valid DTD entities are found.
  static List<XmlEntity> parseString(
    String string, {
    bool trimWhitespace = true,
    int start = 0,
    int stop,
  }) {
    assert(string != null);
    assert(trimWhitespace != null);
    assert(start != null && start >= 0);
    assert(stop == null || stop >= start);

    return _parser.parseString(
      input: string,
      delimiter: Delimiters.entity,
      getNode: _getEntity,
      trimWhitespace: trimWhitespace,
      start: start,
      stop: stop,
    );
  }

  /// Builds a [XmlEntity] node from a [RegExpMatch] if the captured
  /// values are valid, otherwise returns `null`.
  static XmlEntity _getEntity(RegExpMatch entity) {
    assert(entity != null);

    final isParameter = entity.namedGroup('parameter') == '%';

    final name = entity.namedGroup('name');

    if (name == null) return null;

    final identifier = entity.namedGroup('identifier')?.toUpperCase();

    final isPublic = identifier == 'PUBLIC';
    final isSystem = identifier == 'SYSTEM';

    var value = entity.namedGroup('value');
    value = helpers.stripDelimiters(value);

    String ndata;

    if (entity.namedGroup('ndataFlag') == 'NDATA') {
      ndata = entity.namedGroup('ndata');
    }

    return XmlEntity(
      name,
      value,
      isParameter: isParameter,
      isPublic: isPublic,
      isSystem: isSystem,
      ndata: ndata,
    );
  }

  /// Contains methods to parse strings for [XmlEntity] nodes.
  static final StringParser<XmlEntity> _parser = StringParser<XmlEntity>();

  @override
  bool operator ==(Object o) =>
      o is XmlEntity &&
      name == o.name &&
      value == o.value &&
      isSystem == o.isSystem;

  @override
  int get hashCode => name.hashCode ^ value.hashCode ^ isSystem.hashCode;
}
