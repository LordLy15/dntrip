// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sudden_expense_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SuddenExpenseModel _$SuddenExpenseModelFromJson(Map<String, dynamic> json) {
  return _SuddenExpenseModel.fromJson(json);
}

/// @nodoc
mixin _$SuddenExpenseModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'trip_id')
  int get tripId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'expense_category_id')
  int? get categoryId => throw _privateConstructorUsedError;
  String? get categoryName => throw _privateConstructorUsedError;
  String? get categoryIcon => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SuddenExpenseModelCopyWith<SuddenExpenseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SuddenExpenseModelCopyWith<$Res> {
  factory $SuddenExpenseModelCopyWith(
          SuddenExpenseModel value, $Res Function(SuddenExpenseModel) then) =
      _$SuddenExpenseModelCopyWithImpl<$Res, SuddenExpenseModel>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'trip_id') int tripId,
      String name,
      @JsonKey(name: 'expense_category_id') int? categoryId,
      String? categoryName,
      String? categoryIcon,
      double amount,
      String? description,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class _$SuddenExpenseModelCopyWithImpl<$Res, $Val extends SuddenExpenseModel>
    implements $SuddenExpenseModelCopyWith<$Res> {
  _$SuddenExpenseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? name = null,
    Object? categoryId = freezed,
    Object? categoryName = freezed,
    Object? categoryIcon = freezed,
    Object? amount = null,
    Object? description = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryIcon: freezed == categoryIcon
          ? _value.categoryIcon
          : categoryIcon // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SuddenExpenseModelImplCopyWith<$Res>
    implements $SuddenExpenseModelCopyWith<$Res> {
  factory _$$SuddenExpenseModelImplCopyWith(_$SuddenExpenseModelImpl value,
          $Res Function(_$SuddenExpenseModelImpl) then) =
      __$$SuddenExpenseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'trip_id') int tripId,
      String name,
      @JsonKey(name: 'expense_category_id') int? categoryId,
      String? categoryName,
      String? categoryIcon,
      double amount,
      String? description,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class __$$SuddenExpenseModelImplCopyWithImpl<$Res>
    extends _$SuddenExpenseModelCopyWithImpl<$Res, _$SuddenExpenseModelImpl>
    implements _$$SuddenExpenseModelImplCopyWith<$Res> {
  __$$SuddenExpenseModelImplCopyWithImpl(_$SuddenExpenseModelImpl _value,
      $Res Function(_$SuddenExpenseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? name = null,
    Object? categoryId = freezed,
    Object? categoryName = freezed,
    Object? categoryIcon = freezed,
    Object? amount = null,
    Object? description = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$SuddenExpenseModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryIcon: freezed == categoryIcon
          ? _value.categoryIcon
          : categoryIcon // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SuddenExpenseModelImpl implements _SuddenExpenseModel {
  const _$SuddenExpenseModelImpl(
      {required this.id,
      @JsonKey(name: 'trip_id') required this.tripId,
      required this.name,
      @JsonKey(name: 'expense_category_id') this.categoryId,
      this.categoryName,
      this.categoryIcon,
      required this.amount,
      this.description,
      @JsonKey(name: 'created_at') this.createdAt});

  factory _$SuddenExpenseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SuddenExpenseModelImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'trip_id')
  final int tripId;
  @override
  final String name;
  @override
  @JsonKey(name: 'expense_category_id')
  final int? categoryId;
  @override
  final String? categoryName;
  @override
  final String? categoryIcon;
  @override
  final double amount;
  @override
  final String? description;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'SuddenExpenseModel(id: $id, tripId: $tripId, name: $name, categoryId: $categoryId, categoryName: $categoryName, categoryIcon: $categoryIcon, amount: $amount, description: $description, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuddenExpenseModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.categoryIcon, categoryIcon) ||
                other.categoryIcon == categoryIcon) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, tripId, name, categoryId,
      categoryName, categoryIcon, amount, description, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SuddenExpenseModelImplCopyWith<_$SuddenExpenseModelImpl> get copyWith =>
      __$$SuddenExpenseModelImplCopyWithImpl<_$SuddenExpenseModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SuddenExpenseModelImplToJson(
      this,
    );
  }
}

abstract class _SuddenExpenseModel implements SuddenExpenseModel {
  const factory _SuddenExpenseModel(
          {required final int id,
          @JsonKey(name: 'trip_id') required final int tripId,
          required final String name,
          @JsonKey(name: 'expense_category_id') final int? categoryId,
          final String? categoryName,
          final String? categoryIcon,
          required final double amount,
          final String? description,
          @JsonKey(name: 'created_at') final DateTime? createdAt}) =
      _$SuddenExpenseModelImpl;

  factory _SuddenExpenseModel.fromJson(Map<String, dynamic> json) =
      _$SuddenExpenseModelImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'trip_id')
  int get tripId;
  @override
  String get name;
  @override
  @JsonKey(name: 'expense_category_id')
  int? get categoryId;
  @override
  String? get categoryName;
  @override
  String? get categoryIcon;
  @override
  double get amount;
  @override
  String? get description;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$SuddenExpenseModelImplCopyWith<_$SuddenExpenseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
