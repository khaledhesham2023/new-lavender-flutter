import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'json_converters.dart';

part 'base_response.g.dart';

/// Laravel pagination `meta` (notifications only).
@JsonSerializable(createToJson: false)
@IntConv()
@StrConv()
class PaginationMeta extends Equatable {
  final int? currentPage;
  final int? from;
  final int? lastPage;
  final String? path;
  final int? perPage;
  final int? to;
  final int? total;

  const PaginationMeta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);

  @override
  List<Object?> get props =>
      [currentPage, from, lastPage, path, perPage, to, total];
}

/// Laravel pagination `links` (notifications only).
@JsonSerializable(createToJson: false)
@StrConv()
class PaginationLinks extends Equatable {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  const PaginationLinks({this.first, this.last, this.prev, this.next});

  factory PaginationLinks.fromJson(Map<String, dynamic> json) =>
      _$PaginationLinksFromJson(json);

  @override
  List<Object?> get props => [first, last, prev, next];
}
