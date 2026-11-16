// Converts the Android strings.xml (en + ar) into ARB files.
// Run from the lavender-flutter folder: dart run tool/strings2arb.dart
import 'dart:convert';
import 'dart:io';

import 'package:xml/xml.dart';

const enXmlPath = '../lavenderk/app/src/main/res/values/strings.xml';
const arXmlPath = '../lavenderk/app/src/main/res/values-ar/strings.xml';
const enArbPath = 'lib/l10n/app_en.arb';
const arArbPath = 'lib/l10n/app_ar.arb';

const dartReservedWords = <String>{
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'of',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'typedef',
  'var',
  'void',
  'while',
  'with',
  'yield',
};

/// `good_morning` -> `goodMorning`; `doctorM` stays; reserved word / leading
/// digit gets a `Text` suffix.
String toCamelCase(String name) {
  final parts = name.split('_').where((p) => p.isNotEmpty).toList();
  var result = '';
  for (var i = 0; i < parts.length; i++) {
    final p = parts[i];
    result += i == 0 ? p : p[0].toUpperCase() + p.substring(1);
  }
  if (result.isEmpty) result = 'text';
  // A leading digit can't be fixed by a suffix ("1Text" is still invalid), so prefix it.
  if (RegExp(r'^\d').hasMatch(result)) result = 'text$result';
  if (dartReservedWords.contains(result)) result += 'Text';
  return result;
}

/// Removes XML-indentation whitespace and Android escapes.
String unescapeAndroid(String raw) {
  return raw
      .trim()
      .replaceAll(r"\'", "'")
      .replaceAll(r'\"', '"')
      .replaceAll(r'\n', '\n')
      .replaceAll(r'\@', '@')
      .replaceAll(r'\?', '?');
}

class ConvertedValue {
  const ConvertedValue(this.text, this.placeholders);
  final String text;
  final List<String> placeholders; // e.g. [p1, p2]
}

final _tokenRegex = RegExp(r'%%|%(\d+\$)?(\d+)?([sd])');

/// Android format string -> ICU message with `{pN}` placeholders.
ConvertedValue convertPlaceholders(String value) {
  var next = 1;
  final names = <String>{};
  final text = value.replaceAllMapped(_tokenRegex, (m) {
    if (m[0] == '%%') return '%';
    final explicit = m[1];
    final index = explicit != null
        ? int.parse(explicit.substring(0, explicit.length - 1))
        : next++;
    names.add('p$index');
    return '{p$index}';
  });
  final sorted = names.toList()
    ..sort(
      (a, b) => int.parse(a.substring(1)).compareTo(int.parse(b.substring(1))),
    );
  return ConvertedValue(text, sorted);
}

/// Parses an Android strings.xml into name -> unescaped value (raw Android
/// format, placeholders not yet converted). Skips translatable="false".
Map<String, String> parseStringsXml(String xml) {
  final doc = XmlDocument.parse(xml);
  final result = <String, String>{};
  for (final e in doc.rootElement.findElements('string')) {
    if (e.getAttribute('translatable') == 'false') continue;
    final name = e.getAttribute('name');
    if (name == null) continue;
    result[name] = unescapeAndroid(e.innerText);
  }
  return result;
}

/// Builds the ARB map. [template] decides keys and metadata.
Map<String, Object> buildArb({
  required String locale,
  required Map<String, String> strings,
  required Map<String, String> nameToKey,
  required Map<String, Map<String, Object>> metadata,
  void Function(String)? warn,
}) {
  final entries = <String, Object>{};
  nameToKey.forEach((name, key) {
    final value = strings[name]!;
    if (value.contains('{') || value.contains('}')) {
      warn?.call(
        '[$locale] "$name" contains { or } before replacement: $value',
      );
    }
    final converted = convertPlaceholders(value);
    entries[key] = converted.text;
    if (metadata.containsKey(key)) entries['@$key'] = metadata[key]!;
  });
  final sortedKeys = entries.keys.where((k) => !k.startsWith('@')).toList()
    ..sort();
  final out = <String, Object>{'@@locale': locale};
  for (final k in sortedKeys) {
    out[k] = entries[k]!;
    if (entries.containsKey('@$k')) out['@$k'] = entries['@$k']!;
  }
  return out;
}

String encodeArb(Map<String, Object> arb) =>
    '${const JsonEncoder.withIndent('  ').convert(arb)}\n';

void main() {
  final en = parseStringsXml(File(enXmlPath).readAsStringSync());
  final ar = parseStringsXml(File(arXmlPath).readAsStringSync());

  final nameToKey = <String, String>{};
  final used = <String>{};
  final metadata = <String, Map<String, Object>>{};
  for (final name in en.keys) {
    var key = toCamelCase(name);
    if (!used.add(key)) {
      stderr.writeln(
        'WARNING: key collision for "$name" -> "$key", using "${key}2"',
      );
      key = '${key}2';
      used.add(key);
    }
    nameToKey[name] = key;
    final ph = convertPlaceholders(en[name]!).placeholders;
    if (ph.isNotEmpty) {
      metadata[key] = {
        'placeholders': {
          for (final p in ph) p: {'type': 'String'},
        },
      };
    }
  }

  final fallback = <String>[];
  final arValues = <String, String>{};
  for (final name in en.keys) {
    final v = ar[name];
    if (v == null) {
      fallback.add(name);
      arValues[name] = en[name]!;
    } else {
      arValues[name] = v;
    }
  }

  void warn(String m) => stderr.writeln('WARNING: $m');
  final enArb = buildArb(
    locale: 'en',
    strings: en,
    nameToKey: nameToKey,
    metadata: metadata,
    warn: warn,
  );
  final arArb = buildArb(
    locale: 'ar',
    strings: arValues,
    nameToKey: nameToKey,
    metadata: metadata,
    warn: warn,
  );

  File(enArbPath).writeAsStringSync(encodeArb(enArb));
  File(arArbPath).writeAsStringSync(encodeArb(arArb));
  stdout.writeln('Wrote ${nameToKey.length} keys to $enArbPath and $arArbPath');
  stdout.writeln(
    'Arabic fallback to English (${fallback.length}): ${fallback.join(', ')}',
  );
}
