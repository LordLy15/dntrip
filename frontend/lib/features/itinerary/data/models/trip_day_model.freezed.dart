// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_day_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TripDayModel _$TripDayModelFromJson(Map<String, dynamic> json) {
  return _TripDayModel.fromJson(json);
}

/// @nodoc
mixin _$TripDayModel {
  int get id => throw _privateConstructorUsedError;
  int get dayNumber => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  List<ActivityModel> get activities => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TripDayModelCopyWith<TripDayModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripDayModelCopyWith<$Res> {
  factory $TripDayModelCopyWith(
          TripDayModel value, $Res Function(TripDayModel) then) =
      _$TripDayModelCopyWithImpl<$Res, TripDayModel>;
  @useResult
  $Res call(
      {int id,
      int dayNumber,
      String date,
      String? notes,
      List<ActivityModel> activities});
}

/// @nodoc
class _$TripDayModelCopyWithImpl<$Res, $Val extends TripDayModel>
    implements $TripDayModelCopyWith<$Res> {
  _$TripDayModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dayNumber = null,
    Object? date = null,
    Object? notes = freezed,
    Object? activities = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      dayNumber: null == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      activities: null == activities
          ? _value.activities
          : activities // ignore: cast_nullable_to_non_nullable
              as List<ActivityModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TripDayModelImplCopyWith<$Res>
    implements $TripDayModelCopyWith<$Res> {
  factory _$$TripDayModelImplCopyWith(
          _$TripDayModelImpl value, $Res Function(_$TripDayModelImpl) then) =
      __$$TripDayModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int dayNumber,
      String date,
      String? notes,
      List<ActivityModel> activities});
}

/// @nodoc
class __$$TripDayModelImplCopyWithImpl<$Res>
    extends _$TripDayModelCopyWithImpl<$Res, _$TripDayModelImpl>
    implements _$$TripDayModelImplCopyWith<$Res> {
  __$$TripDayModelImplCopyWithImpl(
      _$TripDayModelImpl _value, $Res Function(_$TripDayModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dayNumber = null,
    Object? date = null,
    Object? notes = freezed,
    Object? activities = null,
  }) {
    return _then(_$TripDayModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      dayNumber: null == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      activities: null == activities
          ? _value._activities
          : activities // ignore: cast_nullable_to_non_nullable
              as List<ActivityModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TripDayModelImpl implements _TripDayModel {
  const _$TripDayModelImpl(
      {required this.id,
      required this.dayNumber,
      required this.date,
      this.notes,
      final List<ActivityModel> activities = const []})
      : _activities = activities;

  factory _$TripDayModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripDayModelImplFromJson(json);

  @override
  final int id;
  @override
  final int dayNumber;
  @override
  final String date;
  @override
  final String? notes;
  final List<ActivityModel> _activities;
  @override
  @JsonKey()
  List<ActivityModel> get activities {
    if (_activities is EqualUnmodifiableListView) return _activities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activities);
  }

  @override
  String toString() {
    return 'TripDayModel(id: $id, dayNumber: $dayNumber, date: $date, notes: $notes, activities: $activities)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripDayModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dayNumber, dayNumber) ||
                other.dayNumber == dayNumber) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality()
                .equals(other._activities, _activities));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, dayNumber, date, notes,
      const DeepCollectionEquality().hash(_activities));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TripDayModelImplCopyWith<_$TripDayModelImpl> get copyWith =>
      __$$TripDayModelImplCopyWithImpl<_$TripDayModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripDayModelImplToJson(
      this,
    );
  }
}

abstract class _TripDayModel implements TripDayModel {
  const factory _TripDayModel(
      {required final int id,
      required final int dayNumber,
      required final String date,
      final String? notes,
      final List<ActivityModel> activities}) = _$TripDayModelImpl;

  factory _TripDayModel.fromJson(Map<String, dynamic> json) =
      _$TripDayModelImpl.fromJson;

  @override
  int get id;
  @override
  int get dayNumber;
  @override
  String get date;
  @override
  String? get notes;
  @override
  List<ActivityModel> get activities;
  @override
  @JsonKey(ignore: true)
  _$$TripDayModelImplCopyWith<_$TripDayModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
