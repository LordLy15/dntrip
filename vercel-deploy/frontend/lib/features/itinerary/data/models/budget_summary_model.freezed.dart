// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_summary_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BudgetSummaryModel _$BudgetSummaryModelFromJson(Map<String, dynamic> json) {
  return _BudgetSummaryModel.fromJson(json);
}

/// @nodoc
mixin _$BudgetSummaryModel {
  int get totalEstimated => throw _privateConstructorUsedError;
  int get totalActual => throw _privateConstructorUsedError;
  int get variance => throw _privateConstructorUsedError;
  bool get isOverbudget => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BudgetSummaryModelCopyWith<BudgetSummaryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BudgetSummaryModelCopyWith<$Res> {
  factory $BudgetSummaryModelCopyWith(
          BudgetSummaryModel value, $Res Function(BudgetSummaryModel) then) =
      _$BudgetSummaryModelCopyWithImpl<$Res, BudgetSummaryModel>;
  @useResult
  $Res call(
      {int totalEstimated, int totalActual, int variance, bool isOverbudget});
}

/// @nodoc
class _$BudgetSummaryModelCopyWithImpl<$Res, $Val extends BudgetSummaryModel>
    implements $BudgetSummaryModelCopyWith<$Res> {
  _$BudgetSummaryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalEstimated = null,
    Object? totalActual = null,
    Object? variance = null,
    Object? isOverbudget = null,
  }) {
    return _then(_value.copyWith(
      totalEstimated: null == totalEstimated
          ? _value.totalEstimated
          : totalEstimated // ignore: cast_nullable_to_non_nullable
              as int,
      totalActual: null == totalActual
          ? _value.totalActual
          : totalActual // ignore: cast_nullable_to_non_nullable
              as int,
      variance: null == variance
          ? _value.variance
          : variance // ignore: cast_nullable_to_non_nullable
              as int,
      isOverbudget: null == isOverbudget
          ? _value.isOverbudget
          : isOverbudget // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BudgetSummaryModelImplCopyWith<$Res>
    implements $BudgetSummaryModelCopyWith<$Res> {
  factory _$$BudgetSummaryModelImplCopyWith(_$BudgetSummaryModelImpl value,
          $Res Function(_$BudgetSummaryModelImpl) then) =
      __$$BudgetSummaryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalEstimated, int totalActual, int variance, bool isOverbudget});
}

/// @nodoc
class __$$BudgetSummaryModelImplCopyWithImpl<$Res>
    extends _$BudgetSummaryModelCopyWithImpl<$Res, _$BudgetSummaryModelImpl>
    implements _$$BudgetSummaryModelImplCopyWith<$Res> {
  __$$BudgetSummaryModelImplCopyWithImpl(_$BudgetSummaryModelImpl _value,
      $Res Function(_$BudgetSummaryModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalEstimated = null,
    Object? totalActual = null,
    Object? variance = null,
    Object? isOverbudget = null,
  }) {
    return _then(_$BudgetSummaryModelImpl(
      totalEstimated: null == totalEstimated
          ? _value.totalEstimated
          : totalEstimated // ignore: cast_nullable_to_non_nullable
              as int,
      totalActual: null == totalActual
          ? _value.totalActual
          : totalActual // ignore: cast_nullable_to_non_nullable
              as int,
      variance: null == variance
          ? _value.variance
          : variance // ignore: cast_nullable_to_non_nullable
              as int,
      isOverbudget: null == isOverbudget
          ? _value.isOverbudget
          : isOverbudget // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BudgetSummaryModelImpl implements _BudgetSummaryModel {
  const _$BudgetSummaryModelImpl(
      {required this.totalEstimated,
      required this.totalActual,
      required this.variance,
      required this.isOverbudget});

  factory _$BudgetSummaryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BudgetSummaryModelImplFromJson(json);

  @override
  final int totalEstimated;
  @override
  final int totalActual;
  @override
  final int variance;
  @override
  final bool isOverbudget;

  @override
  String toString() {
    return 'BudgetSummaryModel(totalEstimated: $totalEstimated, totalActual: $totalActual, variance: $variance, isOverbudget: $isOverbudget)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BudgetSummaryModelImpl &&
            (identical(other.totalEstimated, totalEstimated) ||
                other.totalEstimated == totalEstimated) &&
            (identical(other.totalActual, totalActual) ||
                other.totalActual == totalActual) &&
            (identical(other.variance, variance) ||
                other.variance == variance) &&
            (identical(other.isOverbudget, isOverbudget) ||
                other.isOverbudget == isOverbudget));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, totalEstimated, totalActual, variance, isOverbudget);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BudgetSummaryModelImplCopyWith<_$BudgetSummaryModelImpl> get copyWith =>
      __$$BudgetSummaryModelImplCopyWithImpl<_$BudgetSummaryModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BudgetSummaryModelImplToJson(
      this,
    );
  }
}

abstract class _BudgetSummaryModel implements BudgetSummaryModel {
  const factory _BudgetSummaryModel(
      {required final int totalEstimated,
      required final int totalActual,
      required final int variance,
      required final bool isOverbudget}) = _$BudgetSummaryModelImpl;

  factory _BudgetSummaryModel.fromJson(Map<String, dynamic> json) =
      _$BudgetSummaryModelImpl.fromJson;

  @override
  int get totalEstimated;
  @override
  int get totalActual;
  @override
  int get variance;
  @override
  bool get isOverbudget;
  @override
  @JsonKey(ignore: true)
  _$$BudgetSummaryModelImplCopyWith<_$BudgetSummaryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
