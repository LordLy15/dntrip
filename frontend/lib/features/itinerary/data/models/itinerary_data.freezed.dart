// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'itinerary_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ItineraryData _$ItineraryDataFromJson(Map<String, dynamic> json) {
  return _ItineraryData.fromJson(json);
}

/// @nodoc
mixin _$ItineraryData {
  int get tripId => throw _privateConstructorUsedError;
  BudgetSummaryModel get budgetSummary => throw _privateConstructorUsedError;
  List<TripDayModel> get days => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ItineraryDataCopyWith<ItineraryData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItineraryDataCopyWith<$Res> {
  factory $ItineraryDataCopyWith(
          ItineraryData value, $Res Function(ItineraryData) then) =
      _$ItineraryDataCopyWithImpl<$Res, ItineraryData>;
  @useResult
  $Res call(
      {int tripId, BudgetSummaryModel budgetSummary, List<TripDayModel> days});

  $BudgetSummaryModelCopyWith<$Res> get budgetSummary;
}

/// @nodoc
class _$ItineraryDataCopyWithImpl<$Res, $Val extends ItineraryData>
    implements $ItineraryDataCopyWith<$Res> {
  _$ItineraryDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tripId = null,
    Object? budgetSummary = null,
    Object? days = null,
  }) {
    return _then(_value.copyWith(
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as int,
      budgetSummary: null == budgetSummary
          ? _value.budgetSummary
          : budgetSummary // ignore: cast_nullable_to_non_nullable
              as BudgetSummaryModel,
      days: null == days
          ? _value.days
          : days // ignore: cast_nullable_to_non_nullable
              as List<TripDayModel>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BudgetSummaryModelCopyWith<$Res> get budgetSummary {
    return $BudgetSummaryModelCopyWith<$Res>(_value.budgetSummary, (value) {
      return _then(_value.copyWith(budgetSummary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ItineraryDataImplCopyWith<$Res>
    implements $ItineraryDataCopyWith<$Res> {
  factory _$$ItineraryDataImplCopyWith(
          _$ItineraryDataImpl value, $Res Function(_$ItineraryDataImpl) then) =
      __$$ItineraryDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int tripId, BudgetSummaryModel budgetSummary, List<TripDayModel> days});

  @override
  $BudgetSummaryModelCopyWith<$Res> get budgetSummary;
}

/// @nodoc
class __$$ItineraryDataImplCopyWithImpl<$Res>
    extends _$ItineraryDataCopyWithImpl<$Res, _$ItineraryDataImpl>
    implements _$$ItineraryDataImplCopyWith<$Res> {
  __$$ItineraryDataImplCopyWithImpl(
      _$ItineraryDataImpl _value, $Res Function(_$ItineraryDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tripId = null,
    Object? budgetSummary = null,
    Object? days = null,
  }) {
    return _then(_$ItineraryDataImpl(
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as int,
      budgetSummary: null == budgetSummary
          ? _value.budgetSummary
          : budgetSummary // ignore: cast_nullable_to_non_nullable
              as BudgetSummaryModel,
      days: null == days
          ? _value._days
          : days // ignore: cast_nullable_to_non_nullable
              as List<TripDayModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ItineraryDataImpl implements _ItineraryData {
  const _$ItineraryDataImpl(
      {required this.tripId,
      required this.budgetSummary,
      final List<TripDayModel> days = const []})
      : _days = days;

  factory _$ItineraryDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItineraryDataImplFromJson(json);

  @override
  final int tripId;
  @override
  final BudgetSummaryModel budgetSummary;
  final List<TripDayModel> _days;
  @override
  @JsonKey()
  List<TripDayModel> get days {
    if (_days is EqualUnmodifiableListView) return _days;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_days);
  }

  @override
  String toString() {
    return 'ItineraryData(tripId: $tripId, budgetSummary: $budgetSummary, days: $days)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItineraryDataImpl &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.budgetSummary, budgetSummary) ||
                other.budgetSummary == budgetSummary) &&
            const DeepCollectionEquality().equals(other._days, _days));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, tripId, budgetSummary,
      const DeepCollectionEquality().hash(_days));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ItineraryDataImplCopyWith<_$ItineraryDataImpl> get copyWith =>
      __$$ItineraryDataImplCopyWithImpl<_$ItineraryDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItineraryDataImplToJson(
      this,
    );
  }
}

abstract class _ItineraryData implements ItineraryData {
  const factory _ItineraryData(
      {required final int tripId,
      required final BudgetSummaryModel budgetSummary,
      final List<TripDayModel> days}) = _$ItineraryDataImpl;

  factory _ItineraryData.fromJson(Map<String, dynamic> json) =
      _$ItineraryDataImpl.fromJson;

  @override
  int get tripId;
  @override
  BudgetSummaryModel get budgetSummary;
  @override
  List<TripDayModel> get days;
  @override
  @JsonKey(ignore: true)
  _$$ItineraryDataImplCopyWith<_$ItineraryDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
