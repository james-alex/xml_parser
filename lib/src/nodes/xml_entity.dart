import 'package:meta/meta.dart';
import '../helpers/delimiters.dart';
import '../helpers/formatters.dart';
import '../helpers/string_parser.dart';
import '../xml_node.dart';

/// A DTD Entity Declaration.
///
/// See: https://www.w3.org/TR/xml/#sec-entity-decl
@immutable
class XmlEntity extends XmlNodeWithAttributes {
  /// A DTD Entity Declaration.
  ///
  /// [name] must not be `null` and must be `> 0` in length.
  ///
  /// [value] must not be `null`.
  ///
  /// [isSystem] and [isPublic] must not be `null`, and only
  /// one of them may be `true`.
  const XmlEntity(
    this.name,
    this.value, {
    this.isParameter = false,
    this.isSystem = false,
    this.isPublic = false,
    this.externalEntities,
    this.ndata,
  })  : assert(name.length > 0),
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
  final List<XmlEntity>? externalEntities;

  /// NDATA defines type of data the external
  /// entity should be treated as.
  final String? ndata;

  /// Attempts to load the external entity if there is one and
  /// if [ndata] is `null`. If [ndata] is provided, the file is
  /// assumed to be of another data type that can't be parsed by
  /// this library.
  ///
  /// If the URI couldn't be reached or no DTD elements could be identified,
  /// Returns `null`.
  Future<XmlEntity?> loadExternalEntities() async {
    if ((!isSystem && !isPublic) || ndata != null) return null;
    final externalEntities =
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
    String? name,
    String? value,
    bool? isSystem,
    bool? isPublic,
    List<XmlEntity>? externalEntities,
    String? ndata,
    bool copyNull = false,
  }) {
    assert(name == null || name.isNotEmpty);
    assert(isPublic == null || isSystem == null || !(isPublic && isSystem));

    if (!copyNull) {
      value ??= this.value;
      externalEntities ??= this.externalEntities;
      ndata ??= this.ndata;
    }

    return XmlEntity(
      name ?? this.name,
      value!,
      isSystem: isSystem ?? (isPublic == true ? false : this.isSystem),
      isPublic: isPublic ?? (isSystem == true ? false : this.isPublic),
      externalEntities: externalEntities,
      ndata: ndata,
    );
  }

  @override
  String toString({bool doubleQuotes = true}) {
    final quotationMark = doubleQuotes ? '"' : '\'';
    final identifier = isSystem
        ? ' SYSTEM'
        : isPublic
            ? ' PUBLIC'
            : '';
    final value = ' $quotationMark${this.value}$quotationMark';
    final ndata = (this.ndata != null) ? ' NDATA ${this.ndata}' : '';
    return '<!ENTITY $name$identifier$value$ndata>';
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
  static XmlEntity? from(
    String string, {
    bool trimWhitespace = true,
  }) {
    return StringParser.from<XmlEntity>(
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
  static List<XmlEntity>? parseString(
    String string, {
    bool trimWhitespace = true,
    int start = 0,
    int? stop,
  }) {
    assert(start >= 0);
    assert(stop == null || stop >= start);
    return StringParser.parse<XmlEntity>(
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
  static XmlEntity? _getEntity(RegExpMatch entity) {
    final isParameter = entity.namedGroup('parameter') == '%';

    final name = entity.namedGroup('name');
    if (name == null) return null;

    final identifier = entity.namedGroup('identifier')?.toUpperCase();

    final isPublic = identifier == 'PUBLIC';
    final isSystem = identifier == 'SYSTEM';

    var value = entity.namedGroup('value');
    if (value == null) return null;
    value = value.stripDelimiters();

    String? ndata;
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

  @override
  bool operator ==(Object o) =>
      o is XmlEntity &&
      name == o.name &&
      value == o.value &&
      isSystem == o.isSystem;

  @override
  int get hashCode => name.hashCode ^ value.hashCode ^ isSystem.hashCode;
}
