// Safe JSON readers. The backend (Laravel) is inconsistent: numbers arrive as
// strings, bools as 0/1, fields are missing or null. Never cast JSON directly.

int? asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.isFinite ? v.toInt() : null;
  if (v is String) {
    final s = v.trim();
    return int.tryParse(s) ?? double.tryParse(s)?.toInt();
  }
  if (v is bool) return v ? 1 : 0;
  return null;
}

double? asDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.trim());
  return null;
}

String? asString(dynamic v) {
  if (v == null) return null;
  if (v is String) return v;
  if (v is Map || v is List) return null;
  return v.toString();
}

bool asBool(dynamic v, {bool fallback = false}) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    switch (v.trim().toLowerCase()) {
      case '1':
      case 'true':
        return true;
      case '0':
      case 'false':
        return false;
    }
  }
  return fallback;
}

/// Nullable variant of [asBool]: null stays null (Kotlin `Boolean?`).
bool? asBoolOrNull(dynamic v) => v == null ? null : asBool(v);

/// Returns [v] as a JSON object, or null when it is not one.
Map<String, dynamic>? asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
  return null;
}

/// Parses a JSON array of objects. Anything that is not a list gives `[]`;
/// elements that are not objects are skipped.
List<T> asList<T>(dynamic v, T Function(Map<String, dynamic>) parse) {
  if (v is! List) return const [];
  final out = <T>[];
  for (final e in v) {
    final m = asMap(e);
    if (m != null) out.add(parse(m));
  }
  return out;
}

/// Parses a JSON array of scalars as strings.
List<String> asStringList(dynamic v) {
  if (v is! List) return const [];
  return [
    for (final e in v)
      if (asString(e) != null) asString(e)!,
  ];
}

/// Parses a nested object with [parse], or null.
T? asObject<T>(dynamic v, T Function(Map<String, dynamic>) parse) {
  final m = asMap(v);
  return m == null ? null : parse(m);
}

/// Request bodies omit null fields (Gson default).
Map<String, dynamic> withoutNulls(Map<String, dynamic> m) =>
    {...m}..removeWhere((_, v) => v == null);
