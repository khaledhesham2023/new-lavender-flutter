// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginationMeta _$PaginationMetaFromJson(Map<String, dynamic> json) =>
    PaginationMeta(
      currentPage: const IntConv().fromJson(json['current_page']),
      from: const IntConv().fromJson(json['from']),
      lastPage: const IntConv().fromJson(json['last_page']),
      path: const StrConv().fromJson(json['path']),
      perPage: const IntConv().fromJson(json['per_page']),
      to: const IntConv().fromJson(json['to']),
      total: const IntConv().fromJson(json['total']),
    );

PaginationLinks _$PaginationLinksFromJson(Map<String, dynamic> json) =>
    PaginationLinks(
      first: const StrConv().fromJson(json['first']),
      last: const StrConv().fromJson(json['last']),
      prev: const StrConv().fromJson(json['prev']),
      next: const StrConv().fromJson(json['next']),
    );
