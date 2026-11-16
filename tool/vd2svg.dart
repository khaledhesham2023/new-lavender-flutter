// Converts the Android vector drawables into SVG files and generates
// lib/core/theme/app_assets.dart.
// Run from the lavender-flutter folder: dart run tool/vd2svg.dart
import 'dart:io';

import 'package:xml/xml.dart';

import 'strings2arb.dart' show toCamelCase;

const colorsXmlPath = '../lavenderk/app/src/main/res/values/colors.xml';
const drawableDir = '../lavenderk/app/src/main/res/drawable';
const svgDir = 'assets/svg';
const imagesDir = 'assets/images';
const imagesArDir = 'assets/images/ar';
const gifsDir = 'assets/gifs';
const lottieDir = 'assets/lottie';
const appAssetsPath = 'lib/core/theme/app_assets.dart';
const nonVectorListPath = 'tool/non_vector_drawables.txt';

/// Used for `@color/colorGray` and any other reference that cannot be resolved
/// (owner decision: `colorGray` is not defined in this project).
const fallbackHex = '#888888';

const _androidColors = <String, String>{
  'white': '#FFFFFFFF',
  'black': '#FF000000',
  'transparent': '#00000000',
};

/// A color split the way SVG wants it: `#RRGGBB` plus a separate opacity.
class SvgColor {
  const SvgColor(this.hex, this.opacity);
  final String hex;
  final double opacity;
}

/// Reads `<color name="x">value</color>` entries (name -> raw value).
Map<String, String> parseColorsXml(String xml) {
  final doc = XmlDocument.parse(xml);
  final colors = <String, String>{};
  for (final e in doc.findAllElements('color')) {
    final name = e.getAttribute('name');
    if (name != null) colors[name] = e.innerText.trim();
  }
  return colors;
}

/// Resolves an Android color value (`#AARRGGBB`, `#RGB`, `@color/x`,
/// `@android:color/white`, ...). Unknown references go to [fallbackHex] and are
/// added to [warnings].
SvgColor resolveColor(
  String raw,
  Map<String, String> colors,
  Set<String> warnings, [
  int depth = 0,
]) {
  final value = raw.trim();
  SvgColor fallback() {
    warnings.add(value);
    return const SvgColor(fallbackHex, 1);
  }

  if (value.startsWith('@android:color/')) {
    final known = _androidColors[value.substring('@android:color/'.length)];
    return known == null ? fallback() : resolveColor(known, colors, warnings, depth + 1);
  }
  if (value.startsWith('@color/')) {
    final target = colors[value.substring('@color/'.length)];
    if (target == null || depth > 8) return fallback();
    return resolveColor(target, colors, warnings, depth + 1);
  }
  if (!value.startsWith('#')) return fallback();

  var hex = value.substring(1);
  if (hex.length == 3 || hex.length == 4) {
    hex = hex.split('').map((c) => '$c$c').join();
  }
  if ((hex.length != 6 && hex.length != 8) || int.tryParse(hex, radix: 16) == null) {
    return fallback();
  }
  var opacity = 1.0;
  if (hex.length == 8) {
    opacity = int.parse(hex.substring(0, 2), radix: 16) / 255;
    hex = hex.substring(2);
  }
  return SvgColor('#${hex.toUpperCase()}', opacity);
}

/// `0.5019608` -> `0.502`, `1.0` -> `1`.
String fmt(num n) {
  var s = n.toStringAsFixed(3);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
  return s;
}

String _dimension(String? v) => (v ?? '0').replaceAll(RegExp(r'[a-zA-Z]+$'), '');

String? _attr(XmlElement e, String local) {
  for (final a in e.attributes) {
    if (a.name.local == local) return a.value;
  }
  return null;
}

String _esc(String s) => s.replaceAll('&', '&amp;').replaceAll('"', '&quot;').replaceAll('<', '&lt;');

class VectorResult {
  const VectorResult(this.svg, {required this.autoMirrored});
  final String svg;
  final bool autoMirrored;
}

class _Converter {
  _Converter(this.colors, this.warnings);

  final Map<String, String> colors;
  final Set<String> warnings;
  final defs = StringBuffer();
  var _gradientCount = 0;
  var _clipCount = 0;

  /// Returns the paint (`#RRGGBB` or `url(#gN)`) and its own opacity, or null for "none".
  ({String paint, double opacity})? _paint(XmlElement path, String attrName) {
    for (final child in path.childElements) {
      if (child.name.qualified != 'aapt:attr' || child.getAttribute('name') != 'android:$attrName') continue;
      final gradient = child.childElements.where((e) => e.name.local == 'gradient').firstOrNull;
      if (gradient != null) return (paint: _gradient(gradient), opacity: 1);
    }
    final raw = _attr(path, attrName);
    if (raw == null) return null;
    final c = resolveColor(raw, colors, warnings);
    if (c.opacity == 0) return null;
    return (paint: c.hex, opacity: c.opacity);
  }

  String _gradient(XmlElement g) {
    final id = 'g${_gradientCount++}';
    final type = _attr(g, 'type') ?? 'linear';
    final stops = StringBuffer();
    final items = g.childElements.where((e) => e.name.local == 'item').toList();
    void stop(String offset, String color) {
      final c = resolveColor(color, colors, warnings);
      final op = c.opacity == 1 ? '' : ' stop-opacity="${fmt(c.opacity)}"';
      stops.write('<stop offset="$offset" stop-color="${c.hex}"$op/>');
    }

    if (items.isEmpty) {
      final start = _attr(g, 'startColor');
      final center = _attr(g, 'centerColor');
      final end = _attr(g, 'endColor');
      if (start != null) stop('0', start);
      if (center != null) stop('0.5', center);
      if (end != null) stop('1', end);
    } else {
      for (final i in items) {
        stop(_attr(i, 'offset') ?? '0', _attr(i, 'color') ?? '#00000000');
      }
    }

    if (type == 'radial') {
      defs.write('<radialGradient id="$id" gradientUnits="userSpaceOnUse" '
          'cx="${_attr(g, 'centerX') ?? '0'}" cy="${_attr(g, 'centerY') ?? '0'}" '
          'r="${_attr(g, 'gradientRadius') ?? '0'}">$stops</radialGradient>');
    } else {
      if (type != 'linear') warnings.add('unsupported gradient type "$type" (drawn as linear)');
      defs.write('<linearGradient id="$id" gradientUnits="userSpaceOnUse" '
          'x1="${_attr(g, 'startX') ?? '0'}" y1="${_attr(g, 'startY') ?? '0'}" '
          'x2="${_attr(g, 'endX') ?? '0'}" y2="${_attr(g, 'endY') ?? '0'}">$stops</linearGradient>');
    }
    return 'url(#$id)';
  }

  void path(XmlElement p, StringBuffer out) {
    final d = _attr(p, 'pathData');
    if (d == null) return;
    final a = StringBuffer('<path d="${_esc(d)}"');

    final fill = _paint(p, 'fillColor');
    final fillAlpha = double.tryParse(_attr(p, 'fillAlpha') ?? '') ?? 1;
    if (fill == null) {
      a.write(' fill="none"');
    } else {
      a.write(' fill="${fill.paint}"');
      final o = fill.opacity * fillAlpha;
      if (o != 1) a.write(' fill-opacity="${fmt(o)}"');
    }
    if (_attr(p, 'fillType') == 'evenOdd') a.write(' fill-rule="evenodd"');

    final stroke = _paint(p, 'strokeColor');
    final strokeWidth = double.tryParse(_attr(p, 'strokeWidth') ?? '') ?? 0;
    if (stroke != null && strokeWidth > 0) {
      a.write(' stroke="${stroke.paint}" stroke-width="${fmt(strokeWidth)}"');
      final o = stroke.opacity * (double.tryParse(_attr(p, 'strokeAlpha') ?? '') ?? 1);
      if (o != 1) a.write(' stroke-opacity="${fmt(o)}"');
      final cap = _attr(p, 'strokeLineCap');
      if (cap != null) a.write(' stroke-linecap="$cap"');
      final join = _attr(p, 'strokeLineJoin');
      if (join != null) a.write(' stroke-linejoin="$join"');
      final miter = _attr(p, 'strokeMiterLimit');
      if (miter != null) a.write(' stroke-miterlimit="$miter"');
    }
    a.write('/>');
    out.write(a);
  }

  /// Android group transform: translate, then rotate/scale around the pivot.
  String? _transform(XmlElement g) {
    double n(String name, double def) => double.tryParse(_attr(g, name) ?? '') ?? def;
    final tx = n('translateX', 0), ty = n('translateY', 0);
    final sx = n('scaleX', 1), sy = n('scaleY', 1);
    final rot = n('rotation', 0);
    final px = n('pivotX', 0), py = n('pivotY', 0);
    final parts = <String>[];
    if (tx != 0 || ty != 0) parts.add('translate(${fmt(tx)} ${fmt(ty)})');
    if (rot != 0 || sx != 1 || sy != 1) {
      final pivot = px != 0 || py != 0;
      if (pivot) parts.add('translate(${fmt(px)} ${fmt(py)})');
      if (rot != 0) parts.add('rotate(${fmt(rot)})');
      if (sx != 1 || sy != 1) parts.add('scale(${fmt(sx)} ${fmt(sy)})');
      if (pivot) parts.add('translate(${fmt(-px)} ${fmt(-py)})');
    }
    return parts.isEmpty ? null : parts.join(' ');
  }

  /// Writes the children in order. A `<clip-path>` clips everything after it
  /// in the same group, so the rest is nested in a clipped `<g>`.
  void children(XmlElement parent, StringBuffer out) {
    var openedClips = 0;
    for (final c in parent.childElements) {
      switch (c.name.qualified) {
        case 'path':
          path(c, out);
        case 'group':
          group(c, out);
        case 'clip-path':
          final d = _attr(c, 'pathData');
          if (d == null) break;
          final id = 'c${_clipCount++}';
          defs.write('<clipPath id="$id"><path d="${_esc(d)}"/></clipPath>');
          out.write('<g clip-path="url(#$id)">');
          openedClips++;
        case 'aapt:attr':
          break;
        default:
          warnings.add('unsupported element <${c.name.qualified}>');
      }
    }
    for (var i = 0; i < openedClips; i++) {
      out.write('</g>');
    }
  }

  void group(XmlElement g, StringBuffer out) {
    final t = _transform(g);
    out.write(t == null ? '<g>' : '<g transform="$t">');
    children(g, out);
    out.write('</g>');
  }
}

/// Converts one `<vector>` drawable. [warnings] collects unresolved colors.
VectorResult convertVector(String xml, Map<String, String> colors, Set<String> warnings) {
  final root = XmlDocument.parse(xml).rootElement;
  final conv = _Converter(colors, warnings);
  final body = StringBuffer();
  conv.children(root, body);

  final w = _dimension(_attr(root, 'width'));
  final h = _dimension(_attr(root, 'height'));
  final vw = _attr(root, 'viewportWidth') ?? w;
  final vh = _attr(root, 'viewportHeight') ?? h;
  final svg = StringBuffer()
    ..write('<svg xmlns="http://www.w3.org/2000/svg" width="$w" height="$h" viewBox="0 0 $vw $vh">');
  if (conv.defs.isNotEmpty) svg.write('<defs>${conv.defs}</defs>');
  svg
    ..write(body)
    ..write('</svg>\n');
  return VectorResult(svg.toString(), autoMirrored: _attr(root, 'autoMirrored') == 'true');
}

String _baseName(String path) {
  final file = path.split(RegExp(r'[\\/]')).last;
  final dot = file.lastIndexOf('.');
  return dot < 0 ? file : file.substring(0, dot);
}

List<File> _files(String dir, List<String> extensions) {
  final d = Directory(dir);
  if (!d.existsSync()) return [];
  final list = d
      .listSync()
      .whereType<File>()
      .where((f) => extensions.contains(f.path.split('.').last.toLowerCase()))
      .toList()
    ..sort((a, b) => _baseName(a.path).compareTo(_baseName(b.path)));
  return list;
}

class AssetEntry {
  AssetEntry(this.name, this.path);
  final String name;
  final String path;
}

String buildAppAssets({
  required List<AssetEntry> svgs,
  required List<AssetEntry> images,
  required List<AssetEntry> gifs,
  required List<AssetEntry> lottie,
  required List<String> autoMirroredPaths,
}) {
  final seen = <String, String>{};
  final out = StringBuffer()
    ..writeln('// GENERATED by tool/vd2svg.dart (run: dart run tool/vd2svg.dart). Do not edit by hand.')
    ..writeln()
    ..writeln('abstract final class AppAssets {');
  void section(String title, List<AssetEntry> entries) {
    out.writeln('  // $title');
    for (final e in entries) {
      final previous = seen[e.name];
      if (previous != null) {
        throw StateError('Duplicate asset constant "${e.name}": $previous and ${e.path}');
      }
      seen[e.name] = e.path;
      out.writeln("  static const ${e.name} = '${e.path}';");
    }
    out.writeln();
  }

  section('SVG (converted Android vector drawables)', svgs);
  section('Images', images);
  section('GIFs', gifs);
  section('Lottie', lottie);
  out
    ..writeln('}')
    ..writeln()
    ..writeln('/// SVGs whose Android vector has `autoMirrored="true"`: flip them in RTL.')
    ..writeln('const Set<String> autoMirroredSvgs = {');
  for (final p in autoMirroredPaths) {
    final name = seen.entries.firstWhere((e) => e.value == p).key;
    out.writeln('  AppAssets.$name,');
  }
  out.writeln('};');
  return out.toString();
}

void main() {
  final colors = parseColorsXml(File(colorsXmlPath).readAsStringSync());
  final warnings = <String>{};

  Directory(svgDir).createSync(recursive: true);
  final written = <String>{};
  final nonVector = <String>[];
  final autoMirrored = <String>[];

  for (final f in _files(drawableDir, ['xml'])) {
    final name = _baseName(f.path);
    final xml = f.readAsStringSync();
    final root = XmlDocument.parse(xml).rootElement;
    if (root.name.local != 'vector') {
      nonVector.add(name);
      continue;
    }
    final result = convertVector(xml, colors, warnings);
    File('$svgDir/$name.svg').writeAsStringSync(result.svg);
    written.add('$name.svg');
    if (result.autoMirrored) autoMirrored.add('assets/svg/$name.svg');
  }

  // Remove SVGs whose Android vector no longer exists.
  for (final f in _files(svgDir, ['svg'])) {
    if (!written.contains(f.path.split(RegExp(r'[\\/]')).last)) f.deleteSync();
  }

  nonVector.sort();
  File(nonVectorListPath).writeAsStringSync('${nonVector.join('\n')}\n');

  List<AssetEntry> entries(String dir, List<String> ext, {String suffix = ''}) => [
        for (final f in _files(dir, ext))
          AssetEntry(
            '${toCamelCase(_baseName(f.path))}$suffix',
            '$dir/${f.path.split(RegExp(r'[\\/]')).last}',
          ),
      ];

  final svgs = entries(svgDir, ['svg']);
  final images = [
    ...entries(imagesDir, ['png', 'jpg', 'jpeg']),
    ...entries(imagesArDir, ['png', 'jpg', 'jpeg'], suffix: 'Ar'),
  ];
  autoMirrored.sort();
  File(appAssetsPath).writeAsStringSync(buildAppAssets(
    svgs: svgs,
    images: images,
    gifs: entries(gifsDir, ['gif']),
    lottie: entries(lottieDir, ['json']),
    autoMirroredPaths: autoMirrored,
  ));

  stdout.writeln('SVGs written: ${written.length}');
  stdout.writeln('Non-vector drawables (see $nonVectorListPath): ${nonVector.length}');
  stdout.writeln('Auto-mirrored: ${autoMirrored.length}');
  if (warnings.isNotEmpty) {
    stdout.writeln('Warnings (fell back to $fallbackHex or unsupported):');
    for (final w in warnings.toList()..sort()) {
      stdout.writeln('  $w');
    }
  }
}
