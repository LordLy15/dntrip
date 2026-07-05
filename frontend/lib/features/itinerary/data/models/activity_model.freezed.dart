// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ActivityModel {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  int get estimatedCost => throw _privateConstructorUsedError;
  int? get actualCost => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  bool get isUnplanned => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ActivityModelCopyWith<ActivityModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityModelCopyWith<$Res> {
  factory $ActivityModelCopyWith(
          ActivityModel value, $Res Function(ActivityModel) then) =
      _$ActivityModelCopyWithImpl<$Res, ActivityModel>;
  @useResult
  $Res call(
      {int id,
      String title,
      String? description,
      String category,
      int estimatedCost,
      int? actualCost,
      String status,
      bool isUnplanned});
}

/// @nodoc
class _$ActivityModelCopyWithImpl<$Res, $Val extends ActivityModel>
    implements $ActivityModelCopyWith<$Res> {
  _$ActivityModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? category = null,
    Object? estimatedCost = null,
    Object? actualCost = freezed,
    Object? status = null,
    Object? isUnplanned = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      estimatedCost: null == estimatedCost
          ? _value.estimatedCost
          : estimatedCost // ignore: cast_nullable_to_non_nullable
              as int,
      actualCost: freezed == actualCost
          ? _value.actualCost
          : actualCost // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isUnplanned: null == isUnplanned
          ? _value.isUnplanned
          : isUnplanned // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActivityModelImplCopyWith<$Res>
    implements $ActivityModelCopyWith<$Res> {
  factory _$$ActivityModelImplCopyWith(
          _$ActivityModelImpl value, $Res Function(_$ActivityModelImpl) then) =
      __$$ActivityModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      String? description,
      String category,
      int estimatedCost,
      int? actualCost,
      String status,
      bool isUnplanned});
}

/// @nodoc
class __$$ActivityModelImplCopyWithImpl<$Res>
    extends _$ActivityModelCopyWithImpl<$Res, _$ActivityModelImpl>
    implements _$$ActivityModelImplCopyWith<$Res> {
  __$$ActivityModelImplCopyWithImpl(
      _$ActivityModelImpl _value, $Res Function(_$ActivityModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? category = null,
    Object? estimatedCost = null,
    Object? actualCost = freezed,
    Object? status = null,
    Object? isUnplanned = null,
  }) {
    return _then(_$ActivityModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      estimatedCost: null == estimatedCost
          ? _value.estimatedCost
          : estimatedCost // ignore: cast_nullable_to_non_nullable
              as int,
      actualCost: freezed == actualCost
          ? _value.actualCost
          : actualCost // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isUnplanned: null == isUnplanned
          ? _value.isUnplanned
          : isUnplanned // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ActivityModelImpl extends _ActivityModel {
  const _$ActivityModelImpl(
      {required this.id,
      required this.title,
      this.description,
      required this.category,
      required this.estimatedCost,
      this.actualCost,
      required this.status,
      required this.isUnplanned})
      : super._();

  factory _$ActivityModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityModelImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String category;
  @override
  final int estimatedCost;
  @override
  final int? actualCost;
  @override
  final String status;
  @override
  final bool isUnplanned;

  @override
  String toString() {
    return 'ActivityModel(id: $id, title: $title, description: $description, category: $category, estimatedCost: $estimatedCost, actualCost: $actualCost, status: $status, isUnplanned: $isUnplanned)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.estimatedCost, estimatedCost) ||
                other.estimatedCost == estimatedCost) &&
            (identical(other.actualCost, actualCost) ||
                other.actualCost == actualCost) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isUnplanned, isUnplanned) ||
                other.isUnplanned == isUnplanned));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, category,
      estimatedCost, actualCost, status, isUnplanned);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityModelImplCopyWith<_$ActivityModelImpl> get copyWith =>
      __$$ActivityModelImplCopyWithImpl<_$ActivityModelImpl>(this, _$identity);
}

abstract class _ActivityModel extends ActivityModel {
  const factory _ActivityModel(
      {required final int id,
      required final String title,
      final String? description,
      required final String category,
      required final int estimatedCost,
      final int? actualCost,
      required final String status,
      required final bool isUnplanned}) = _$ActivityModelImpl;
  const _ActivityModel._() : super._();

  factory _ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelImpl.fromJson(json);

  @override
  int get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  String get category;
  @override
  int get estimatedCost;
  @override
  int? get actualCost;
  @override
  String get status;
  @override
  bool get isUnplanned;
  @override
  @JsonKey(ignore: true)
  _$$ActivityModelImplCopyWith<_$ActivityModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
