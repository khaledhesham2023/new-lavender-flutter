import 'package:json_annotation/json_annotation.dart';

import 'json_utils.dart';

// Lenient converters for json_serializable. Put them on a model class
// (e.g. `@IntConv()`): they apply to every field of the matching type.
// The backend (Laravel) sends numbers as strings, bools as 0/1, and nulls.

class IntConv implements JsonConverter<int?, Object?> {
  const IntConv();
  @override
  int? fromJson(Object? json) => asInt(json);
  @override
  Object? toJson(int? object) => object;
}

class DoubleConv implements JsonConverter<double?, Object?> {
  const DoubleConv();
  @override
  double? fromJson(Object? json) => asDouble(json);
  @override
  Object? toJson(double? object) => object;
}

class StrConv implements JsonConverter<String?, Object?> {
  const StrConv();
  @override
  String? fromJson(Object? json) => asString(json);
  @override
  Object? toJson(String? object) => object;
}

/// `bool?`: null stays null.
class BoolOrNullConv implements JsonConverter<bool?, Object?> {
  const BoolOrNullConv();
  @override
  bool? fromJson(Object? json) => asBoolOrNull(json);
  @override
  Object? toJson(bool? object) => object;
}

/// Non-null `bool`: missing/null/unknown is false.
class BoolConv implements JsonConverter<bool, Object?> {
  const BoolConv();
  @override
  bool fromJson(Object? json) => asBool(json);
  @override
  Object? toJson(bool object) => object;
}

// Field-level helpers (`@JsonKey(fromJson: ...)`) for non-null fields.
int asIntOrZero(Object? v) => asInt(v) ?? 0;
String asStringOrEmpty(Object? v) => asString(v) ?? '';
bool asBoolDefaultTrue(Object? v) => asBool(v, fallback: true);
List<String> asStringListOrEmpty(Object? v) => asStringList(v);
List<String> asPrefixOr5(Object? v) => v is List ? asStringList(v) : const ['5'];
