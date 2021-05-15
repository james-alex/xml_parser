import 'package:xml_parser/xml_parser.dart';

bool validateChildren(List<XmlNode> nodes) {
  if (nodes.length != children.length) {
    print('[validateChildren] nodes.length != children.length');
    print('EXPECTED: ${children.length}');
    print('ACTUAL: ${nodes.length}');
    return false;
  }

  for (var i = 0; i < nodes.length; i++) {
    if (!_validateNode(nodes[i], children[i])) return false;
  }

  return true;
}

bool _validateNode(XmlNode node, Map<Type, dynamic> values) {
  // Check if the node is of the expected type.
  final type = values.keys.first;

  if (node.runtimeType != type) {
    print('$node: ${values.keys}\n');
    print('[_validateNode] node.runtimeType != type');
    print('EXPECTED: $type');
    print('ACTUAL: ${node.runtimeType}');
    return false;
  }

  final value = values.values.first;

  if (node is XmlCdata) {
    if (node.value != value) {
      print('[_validateNode] XmlCdata: node.value != value');
      print('EXPECTED: $value');
      print('ACTUAL: ${node.value}');
      return false;
    }
  } else if (node is XmlComment) {
    if (node.value != value) {
      print('[_validateNode] XmlComment: node.value != value');
      print('EXPECTED: $value');
      print('ACTUAL: ${node.value}');
      return false;
    }
  } else if (node is XmlConditional) {
    if (node.condition != value['condition']) {
      print('[_validateNode] XmlConditional: node.condition != '
          'value[\'condition\']');
      print('EXPECTED: ${value['condition']}');
      print('ACTUAL: ${node.condition}');
      return false;
    }

    if (node.children.length != value['value'].length) {
      print('[_validateNode] XmlConditional: node.children.length '
          '!= value[\'condition\'].length');
      print('EXPECTED: ${value['value'].length}');
      print('ACTUAL: ${node.children.length}');
      return false;
    }

    for (var i = 0; i < node.children.length; i++) {
      if (!_validateNode(node.children[i], value['value'][i])) return false;
    }
  } else if (node is XmlElement) {
    if (node.name != value['name']) {
      print('[_validateNode] XmlElement: node.name != value[\'name\']');
      print('EXPECTED: ${value['name']}');
      print('ACTUAL: ${node.name}');
      return false;
    }

    if (value.containsKey('text') && node.text != value['text']) {
      print('[_validateNode] XmlElement: node.text != value[\'text\']');
      print('EXPECTED: ${value['text']}');
      print('ACTUAL: ${node.text}');
      return false;
    }

    if (value.containsKey('attributes')) {
      var attributesAreValid = true;

      value['attributes'].forEach((name, value) {
        if (!node.hasAttributeWhere(name, value)) {
          print('[_validateNode] XmlElement: '
              '!node.hasAttributeWhere($name, $value)');
          print('EXPECTED: true');
          print('ACTUAL: false');
          attributesAreValid = false;
        }
      });

      if (!attributesAreValid) return false;
    }
    if (value.containsKey('children')) {
      if (node.children!.length != value['children'].length) {
        print('[_validateNodde] XmlElement: node.children.length '
            '!= value[\'children\'].length');
        print('EXPECTED: ${value['children'].length}');
        print('ACTUAL: ${node.children!.length}');
        return false;
      }

      for (var i = 0; i < node.children!.length; i++) {
        if (!_validateNode(node.children![i], value['children'][i])) {
          return false;
        }
      }
    }
  } else if (node is XmlText) {
    if (node.value != value) {
      print('EXPECTED: $value');
      print('ACTUAL: ${node.value}');
      return false;
    }
  }

  return true;
}

final String xmlDeclaration = '<?xml version="1.0" encoding="UTF-8" ?>';

final String processingInstruction = '<?pi foo="bar" ?>';

final List<String> internalDtd = <String>[
  '<!ENTITY author "j.alex@email.com">',
  '<!ELEMENT text (#PCDATA)>',
  '<!ELEMENT image EMPTY>',
  '<!ATTLIST image alt CDATA #IMPLIED>',
  '<!ATTLIST image width CDATA #REQUIRED>',
  '<!ATTLIST image height CDATA #REQUIRED>',
  '<!ATTLIST image src CDATA #REQUIRED>',
  '<!ENTITY condition "INCLUDE">',
  '<!NOTATION test2 SYSTEM "tests/test2">',
  '<!ATTLIST text test2 NOTATION (test2) #FIXED "test">',
  '<!NOTATION test1 PUBLIC "notation test1" "https://test.com/notation1">',
  '<!ATTLIST text test1 NOTATION (test1) #IMPLIED>',
];

final List<Type> internalDtdTypes = <Type>[
  XmlEntity,
  XmlEtd,
  XmlEtd,
  XmlAttlist,
  XmlAttlist,
  XmlAttlist,
  XmlAttlist,
  XmlEntity,
  XmlNotation,
  XmlAttlist,
  XmlNotation,
  XmlAttlist,
];

final List<String> textValues = <String>[
  'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
  'Proin in lectus vel ipsum sagittis cursus.',
  'Aliquam efficitur, nibh sed tincidunt congue, turpis leo egestas '
      'odio, fermentum vulputate elit erat ut ex.',
  'Suspendisse et sollicitudin est, ut gravida sapien.',
];

final List<String> imageElements = <String>[
  '<image width="50" height="80" src="test1.gif" />',
  '<image width="250" height="300" src="test2.gif" />',
  '<image width="500" height="800" src="test3.png" alt="Test 3" />',
];

final List<String> comments = <String>[
  '<!-- Start of content -->',
  '<!--<text>Nullam lobortis eros eget egestas finibus.</text>-->',
];

final List<String> commentValues = <String>[
  ' Start of content ',
  '<text>Nullam lobortis eros eget egestas finibus.</text>',
];

final List<String> conditionalSections = <String>[
  '<![ IGNORE [Donec id augue hendrerit dui rhoncus '
      'elementum vel sit amet sapien.]]>',
  '<![ INCLUDE [<text test2="test">Aliquam efficitur, '
      'nibh sed tincidunt congue, turpis leo egestas odio, '
      'fermentum vulputate elit erat ut ex.<![ IGNORE [Donec '
      'id augue hendrerit dui rhoncus elementum vel sit amet '
      'sapien.]]></text>]]>',
  '<![ IGNORE [<image width="250" height="300" src="test2.gif" />]]>',
  '<![ &condition; [<image width="50" height="80" src="test1.gif" />'
      '<text>Proin in lectus vel ipsum sagittis cursus.</text><![ INCLUDE '
      '[<text test2="test">Aliquam efficitur, nibh sed tincidunt congue, '
      'turpis leo egestas odio, fermentum vulputate elit erat ut ex.<![ IGNORE '
      '[Donec id augue hendrerit dui rhoncus elementum vel sit amet sapien.]]>'
      '</text>]]><![ IGNORE [<image width="250" height="300" src="test2.gif" '
      '/>]]>]]>',
];

final List<String> entities = <String>[
  '<!ENTITY author "j.alex@email.com">',
  '<!ENTITY condition "INCLUDE">',
];

final List<String> etds = <String>[
  '<!ELEMENT text (#PCDATA)>',
  '<!ELEMENT image EMPTY>',
];

final List<String> attlists = <String>[
  '<!ATTLIST image alt CDATA #IMPLIED>',
  '<!ATTLIST image width CDATA #REQUIRED>',
  '<!ATTLIST image height CDATA #REQUIRED>',
  '<!ATTLIST image src CDATA #REQUIRED>',
  '<!ATTLIST text test2 NOTATION (test2) #FIXED "test">',
  '<!ATTLIST text test1 NOTATION (test1) #IMPLIED>',
];

final List<String> notations = <String>[
  '<!NOTATION test2 SYSTEM "tests/test2">',
  '<!NOTATION test1 PUBLIC "notation test1" "https://test.com/notation1">',
];

final List<Map<Type, dynamic>> children = [
  {
    XmlElement: {
      'name': 'text',
      'text': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    },
  },
  {
    XmlConditional: {
      'condition': '&condition;',
      'value': [
        {
          XmlElement: {
            'name': 'image',
            'attributes': {
              'width': '50',
              'height': '80',
              'src': 'test1.gif',
            },
          },
        },
        {
          XmlElement: {
            'name': 'text',
            'text': 'Proin in lectus vel ipsum sagittis cursus.',
          },
        },
        {
          XmlConditional: {
            'condition': 'INCLUDE',
            'value': [
              {
                XmlElement: {
                  'name': 'text',
                  'attributes': {
                    'test2': 'test',
                  },
                  'children': [
                    {
                      XmlText: 'Aliquam efficitur, nibh sed tincidunt '
                          'congue, turpis leo egestas odio, fermentum '
                          'vulputate elit erat ut ex.',
                    },
                    {
                      XmlConditional: {
                        'condition': 'IGNORE',
                        'value': [
                          {
                            XmlText: 'Donec id augue hendrerit dui rhoncus '
                                'elementum vel sit amet sapien.',
                          },
                        ],
                      },
                    },
                  ],
                },
              },
            ],
          },
        },
        {
          XmlConditional: {
            'condition': 'IGNORE',
            'value': [
              {
                XmlElement: {
                  'name': 'image',
                  'attributes': {
                    'width': '250',
                    'height': '300',
                    'src': 'test2.gif',
                  },
                },
              },
            ],
          },
        },
      ],
    },
  },
  {
    XmlElement: {
      'name': 'text',
      'attributes': {
        'bold': 'true',
      },
      'text': 'Suspendisse et sollicitudin est, ut gravida sapien.',
    },
  },
  {
    XmlElement: {
      'name': 'cdata',
      'children': [
        {
          XmlCdata: '<markup bool="false">liquam venenatis lobortis '
              'tellus non lobortis.</markup>',
        }
      ],
    },
  },
  {
    XmlComment: '<text>Nullam lobortis eros eget egestas finibus.</text>',
  },
  {
    XmlElement: {
      'name': 'image',
      'attributes': {
        'width': '500',
        'height': '800',
        'src': 'test3.png',
        'alt': 'Test 3',
      },
    },
  },
  {
    XmlElement: {
      'name': 'link',
      'id': 'google',
      'children': [
        {
          XmlCdata: '<a href="https://google.com">Google</a>',
        },
      ],
    }
  }
];
