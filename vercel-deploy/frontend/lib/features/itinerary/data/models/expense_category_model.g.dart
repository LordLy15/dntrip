// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseCategoryImpl _$$ExpenseCategoryImplFromJson(
        Map<String, dynamic> json) =>
    _$ExpenseCategoryImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String?,
      isCustom: json['isCustom'] as bool? ?? false,
    );

Map<String, dynamic> _$$ExpenseCategoryImplToJson(
        _$ExpenseCategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'icon': instance.icon,
      'description': instance.description,
      'isCustom': instance.isCustom,
    };
