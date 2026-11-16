import 'package:flutter_test/flutter_test.dart';

import '../../tool/vd2svg.dart';

const _head = '<vector xmlns:android="http://schemas.android.com/apk/res/android" '
    'xmlns:aapt="http://schemas.android.com/aapt" '
    'android:width="24dp" android:height="20dp" '
    'android:viewportWidth="48" android:viewportHeight="40"';

String _convert(String body, {Set<String>? warnings}) => convertVector(
      '$_head>$body</vector>',
      {'colorPrimary': '#6A449A', 'transparent': '@android:color/transparent'},
      warnings ?? <String>{},
    ).svg;

void main() {
  group('resolveColor', () {
    test('#AARRGGBB splits into #RRGGBB and opacity', () {
      final c = resolveColor('#80FF0000', {}, <String>{});
      expect(c.hex, '#FF0000');
      expect(c.opacity, closeTo(0.502, 0.001));
    });
    test('short forms are expanded', () {
      expect(resolveColor('#F0A', {}, <String>{}).hex, '#FF00AA');
      final c = resolveColor('#8F00', {}, <String>{});
      expect(c.hex, '#FF0000');
      expect(c.opacity, closeTo(0.533, 0.001));
    });
    test('references and android colors', () {
      final colors = {'colorPrimary': '#6A449A', 'transparent': '@android:color/transparent'};
      expect(resolveColor('@color/colorPrimary', colors, <String>{}).hex, '#6A449A');
      expect(resolveColor('@android:color/white', colors, <String>{}).hex, '#FFFFFF');
      expect(resolveColor('@color/transparent', colors, <String>{}).opacity, 0);
    });
    test('unknown reference falls back to #888888 and is reported', () {
      final warnings = <String>{};
      final c = resolveColor('@color/colorGray', {}, warnings);
      expect(c.hex, '#888888');
      expect(c.opacity, 1);
      expect(warnings, {'@color/colorGray'});
    });
  });

  group('convertVector', () {
    test('header: size without dp and viewBox', () {
      expect(_convert(''), contains('width="24" height="20" viewBox="0 0 48 40"'));
    });

    test('fill color, fillAlpha multiplies and evenOdd', () {
      final svg = _convert('<path android:pathData="M0,0L1,1Z" android:fillColor="#80FF0000" '
          'android:fillAlpha="0.5" android:fillType="evenOdd"/>');
      expect(svg, contains('fill="#FF0000"'));
      expect(svg, contains('fill-opacity="0.251"'));
      expect(svg, contains('fill-rule="evenodd"'));
    });

    test('no fillColor means fill none', () {
      expect(_convert('<path android:pathData="M0,0L1,1Z"/>'), contains('fill="none"'));
    });

    test('path with stroke', () {
      final svg = _convert('<path android:pathData="M0,0L1,1" android:strokeColor="@color/colorPrimary" '
          'android:strokeWidth="1.5" android:strokeAlpha="0.4" android:strokeLineCap="round" '
          'android:strokeLineJoin="round"/>');
      expect(svg, contains('fill="none"'));
      expect(svg, contains('stroke="#6A449A"'));
      expect(svg, contains('stroke-width="1.5"'));
      expect(svg, contains('stroke-opacity="0.4"'));
      expect(svg, contains('stroke-linecap="round"'));
      expect(svg, contains('stroke-linejoin="round"'));
    });

    test('stroke with width 0 is dropped', () {
      expect(_convert('<path android:pathData="M0,0" android:strokeColor="#FF0000"/>'), isNot(contains('stroke=')));
    });

    test('group transform', () {
      final svg = _convert('<group android:translateX="2" android:translateY="3" android:scaleX="-1" '
          'android:pivotX="10" android:pivotY="5">'
          '<path android:pathData="M0,0" android:fillColor="#000"/></group>');
      expect(svg, contains('<g transform="translate(2 3) translate(10 5) scale(-1 1) translate(-10 -5)">'));
    });

    test('clip-path goes to defs and clips the rest of the group', () {
      final svg = _convert('<group><clip-path android:pathData="M0,0h10v10z"/>'
          '<path android:pathData="M1,1" android:fillColor="#000"/></group>');
      expect(svg, contains('<clipPath id="c0"><path d="M0,0h10v10z"/></clipPath>'));
      expect(svg, contains('<g clip-path="url(#c0)"><path'));
    });

    test('linear gradient becomes a linearGradient referenced by fill', () {
      final svg = _convert('<path android:pathData="M0,0L1,1Z"><aapt:attr name="android:fillColor">'
          '<gradient android:startX="1" android:startY="2" android:endX="3" android:endY="4" android:type="linear">'
          '<item android:offset="0" android:color="#FFFF0000"/>'
          '<item android:offset="1" android:color="#80000000"/>'
          '</gradient></aapt:attr></path>');
      expect(svg, contains('<linearGradient id="g0" gradientUnits="userSpaceOnUse" x1="1" y1="2" x2="3" y2="4">'));
      expect(svg, contains('<stop offset="0" stop-color="#FF0000"/>'));
      expect(svg, contains('stop-color="#000000" stop-opacity="0.502"'));
      expect(svg, contains('fill="url(#g0)"'));
    });

    test('radial gradient', () {
      final svg = _convert('<path android:pathData="M0,0"><aapt:attr name="android:fillColor">'
          '<gradient android:centerX="5" android:centerY="6" android:gradientRadius="7" android:type="radial">'
          '<item android:offset="0" android:color="#FF000000"/></gradient></aapt:attr></path>');
      expect(svg, contains('<radialGradient id="g0" gradientUnits="userSpaceOnUse" cx="5" cy="6" r="7">'));
    });

    test('unknown color reference gives #888888 and a warning', () {
      final warnings = <String>{};
      final svg = _convert('<path android:pathData="M0,0" android:fillColor="@color/colorGray"/>', warnings: warnings);
      expect(svg, contains('fill="#888888"'));
      expect(warnings, contains('@color/colorGray'));
    });

    test('autoMirrored flag is reported', () {
      expect(convertVector('$_head android:autoMirrored="true"/>', {}, <String>{}).autoMirrored, isTrue);
      expect(convertVector('$_head/>', {}, <String>{}).autoMirrored, isFalse);
    });
  });
}
