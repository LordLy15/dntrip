// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TripModel _$TripModelFromJson(Map<String, dynamic> json) {
  return _TripModel.fromJson(json);
}

/// @nodoc
mixin _$TripModel {
  int get id => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get destination => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get startDate => throw _privateConstructorUsedError;
  String? get endDate => throw _privateConstructorUsedError;
  String? get shareCode => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  TripOwner get owner => throw _privateConstructorUsedError;
  List<TripMemberModel> get members => throw _privateConstructorUsedError;
  int? get membersCount => throw _privateConstructorUsedError;
  int? get planBudget => throw _privateConstructorUsedError;
  String? get latitude => throw _privateConstructorUsedError;
  String? get longitude => throw _privateConstructorUsedError;
  String? get actualStartTime => throw _privateConstructorUsedError;
  String? get actualEndTime => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TripModelCopyWith<TripModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripModelCopyWith<$Res> {
  factory $TripModelCopyWith(TripModel value, $Res Function(TripModel) then) =
      _$TripModelCopyWithImpl<$Res, TripModel>;
  @useResult
  $Res call(
      {int id,
      String? title,
      String? destination,
      String? description,
      String? startDate,
      String? endDate,
      String? shareCode,
      String? status,
      TripOwner owner,
      List<TripMemberModel> members,
      int? membersCount,
      int? planBudget,
      String? latitude,
      String? longitude,
      String? actualStartTime,
      String? actualEndTime});

  $TripOwnerCopyWith<$Res> get owner;
}

/// @nodoc
class _$TripModelCopyWithImpl<$Res, $Val extends TripModel>
    implements $TripModelCopyWith<$Res> {
  _$TripModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = freezed,
    Object? destination = freezed,
    Object? description = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? shareCode = freezed,
    Object? status = freezed,
    Object? owner = null,
    Object? members = null,
    Object? membersCount = freezed,
    Object? planBudget = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? actualStartTime = freezed,
    Object? actualEndTime = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
      shareCode: freezed == shareCode
          ? _value.shareCode
          : shareCode // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      owner: null == owner
          ? _value.owner
          : owner // ignore: cast_nullable_to_non_nullable
              as TripOwner,
      members: null == members
          ? _value.members
          : members // ignore: cast_nullable_to_non_nullable
              as List<TripMemberModel>,
      membersCount: freezed == membersCount
          ? _value.membersCount
          : membersCount // ignore: cast_nullable_to_non_nullable
              as int?,
      planBudget: freezed == planBudget
          ? _value.planBudget
          : planBudget // ignore: cast_nullable_to_non_nullable
              as int?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as String?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as String?,
      actualStartTime: freezed == actualStartTime
          ? _value.actualStartTime
          : actualStartTime // ignore: cast_nullable_to_non_nullable
              as String?,
      actualEndTime: freezed == actualEndTime
          ? _value.actualEndTime
          : actualEndTime // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TripOwnerCopyWith<$Res> get owner {
    return $TripOwnerCopyWith<$Res>(_value.owner, (value) {
      return _then(_value.copyWith(owner: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TripModelImplCopyWith<$Res>
    implements $TripModelCopyWith<$Res> {
  factory _$$TripModelImplCopyWith(
          _$TripModelImpl value, $Res Function(_$TripModelImpl) then) =
      __$$TripModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String? title,
      String? destination,
      String? description,
      String? startDate,
      String? endDate,
      String? shareCode,
      String? status,
      TripOwner owner,
      List<TripMemberModel> members,
      int? membersCount,
      int? planBudget,
      String? latitude,
      String? longitude,
      String? actualStartTime,
      String? actualEndTime});

  @override
  $TripOwnerCopyWith<$Res> get owner;
}

/// @nodoc
class __$$TripModelImplCopyWithImpl<$Res>
    extends _$TripModelCopyWithImpl<$Res, _$TripModelImpl>
    implements _$$TripModelImplCopyWith<$Res> {
  __$$TripModelImplCopyWithImpl(
      _$TripModelImpl _value, $Res Function(_$TripModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = freezed,
    Object? destination = freezed,
    Object? description = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? shareCode = freezed,
    Object? status = freezed,
    Object? owner = null,
    Object? members = null,
    Object? membersCount = freezed,
    Object? planBudget = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? actualStartTime = freezed,
    Object? actualEndTime = freezed,
  }) {
    return _then(_$TripModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
      shareCode: freezed == shareCode
          ? _value.shareCode
          : shareCode // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      owner: null == owner
          ? _value.owner
          : owner // ignore: cast_nullable_to_non_nullable
              as TripOwner,
      members: null == members
          ? _value._members
          : members // ignore: cast_nullable_to_non_nullable
              as List<TripMemberModel>,
      membersCount: freezed == membersCount
          ? _value.membersCount
          : membersCount // ignore: cast_nullable_to_non_nullable
              as int?,
      planBudget: freezed == planBudget
          ? _value.planBudget
          : planBudget // ignore: cast_nullable_to_non_nullable
              as int?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as String?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as String?,
      actualStartTime: freezed == actualStartTime
          ? _value.actualStartTime
          : actualStartTime // ignore: cast_nullable_to_non_nullable
              as String?,
      actualEndTime: freezed == actualEndTime
          ? _value.actualEndTime
          : actualEndTime // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TripModelImpl extends _TripModel {
  const _$TripModelImpl(
      {required this.id,
      this.title,
      this.destination,
      this.description,
      this.startDate,
      this.endDate,
      this.shareCode,
      this.status,
      required this.owner,
      final List<TripMemberModel> members = const [],
      this.membersCount,
      this.planBudget,
      this.latitude,
      this.longitude,
      this.actualStartTime,
      this.actualEndTime})
      : _members = members,
        super._();

  factory _$TripModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripModelImplFromJson(json);

  @override
  final int id;
  @override
  final String? title;
  @override
  final String? destination;
  @override
  final String? description;
  @override
  final String? startDate;
  @override
  final String? endDate;
  @override
  final String? shareCode;
  @override
  final String? status;
  @override
  final TripOwner owner;
  final List<TripMemberModel> _members;
  @override
  @JsonKey()
  List<TripMemberModel> get members {
    if (_members is EqualUnmodifiableListView) return _members;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_members);
  }

  @override
  final int? membersCount;
  @override
  final int? planBudget;
  @override
  final String? latitude;
  @override
  final String? longitude;
  @override
  final String? actualStartTime;
  @override
  final String? actualEndTime;

  @override
  String toString() {
    return 'TripModel(id: $id, title: $title, destination: $destination, description: $description, startDate: $startDate, endDate: $endDate, shareCode: $shareCode, status: $status, owner: $owner, members: $members, membersCount: $membersCount, planBudget: $planBudget, latitude: $latitude, longitude: $longitude, actualStartTime: $actualStartTime, actualEndTime: $actualEndTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.shareCode, shareCode) ||
                other.shareCode == shareCode) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.owner, owner) || other.owner == owner) &&
            const DeepCollectionEquality().equals(other._members, _members) &&
            (identical(other.membersCount, membersCount) ||
                other.membersCount == membersCount) &&
            (identical(other.planBudget, planBudget) ||
                other.planBudget == planBudget) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.actualStartTime, actualStartTime) ||
                other.actualStartTime == actualStartTime) &&
            (identical(other.actualEndTime, actualEndTime) ||
                other.actualEndTime == actualEndTime));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      destination,
      description,
      startDate,
      endDate,
      shareCode,
      status,
      owner,
      const DeepCollectionEquality().hash(_members),
      membersCount,
      planBudget,
      latitude,
      longitude,
      actualStartTime,
      actualEndTime);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TripModelImplCopyWith<_$TripModelImpl> get copyWith =>
      __$$TripModelImplCopyWithImpl<_$TripModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripModelImplToJson(
      this,
    );
  }
}

abstract class _TripModel extends TripModel {
  const factory _TripModel(
      {required final int id,
      final String? title,
      final String? destination,
      final String? description,
      final String? startDate,
      final String? endDate,
      final String? shareCode,
      final String? status,
      required final TripOwner owner,
      final List<TripMemberModel> members,
      final int? membersCount,
      final int? planBudget,
      final String? latitude,
      final String? longitude,
      final String? actualStartTime,
      final String? actualEndTime}) = _$TripModelImpl;
  const _TripModel._() : super._();

  factory _TripModel.fromJson(Map<String, dynamic> json) =
      _$TripModelImpl.fromJson;

  @override
  int get id;
  @override
  String? get title;
  @override
  String? get destination;
  @override
  String? get description;
  @override
  String? get startDate;
  @override
  String? get endDate;
  @override
  String? get shareCode;
  @override
  String? get status;
  @override
  TripOwner get owner;
  @override
  List<TripMemberModel> get members;
  @override
  int? get membersCount;
  @override
  int? get planBudget;
  @override
  String? get latitude;
  @override
  String? get longitude;
  @override
  String? get actualStartTime;
  @override
  String? get actualEndTime;
  @override
  @JsonKey(ignore: true)
  _$$TripModelImplCopyWith<_$TripModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TripOwner _$TripOwnerFromJson(Map<String, dynamic> json) {
  return _TripOwner.fromJson(json);
}

/// @nodoc
mixin _$TripOwner {
  int get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TripOwnerCopyWith<TripOwner> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripOwnerCopyWith<$Res> {
  factory $TripOwnerCopyWith(TripOwner value, $Res Function(TripOwner) then) =
      _$TripOwnerCopyWithImpl<$Res, TripOwner>;
  @useResult
  $Res call({int id, String? name, String? avatar});
}

/// @nodoc
class _$TripOwnerCopyWithImpl<$Res, $Val extends TripOwner>
    implements $TripOwnerCopyWith<$Res> {
  _$TripOwnerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? avatar = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TripOwnerImplCopyWith<$Res>
    implements $TripOwnerCopyWith<$Res> {
  factory _$$TripOwnerImplCopyWith(
          _$TripOwnerImpl value, $Res Function(_$TripOwnerImpl) then) =
      __$$TripOwnerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String? name, String? avatar});
}

/// @nodoc
class __$$TripOwnerImplCopyWithImpl<$Res>
    extends _$TripOwnerCopyWithImpl<$Res, _$TripOwnerImpl>
    implements _$$TripOwnerImplCopyWith<$Res> {
  __$$TripOwnerImplCopyWithImpl(
      _$TripOwnerImpl _value, $Res Function(_$TripOwnerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? avatar = freezed,
  }) {
    return _then(_$TripOwnerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TripOwnerImpl implements _TripOwner {
  const _$TripOwnerImpl({required this.id, this.name, this.avatar});

  factory _$TripOwnerImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripOwnerImplFromJson(json);

  @override
  final int id;
  @override
  final String? name;
  @override
  final String? avatar;

  @override
  String toString() {
    return 'TripOwner(id: $id, name: $name, avatar: $avatar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripOwnerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatar, avatar) || other.avatar == avatar));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, avatar);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TripOwnerImplCopyWith<_$TripOwnerImpl> get copyWith =>
      __$$TripOwnerImplCopyWithImpl<_$TripOwnerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripOwnerImplToJson(
      this,
    );
  }
}

abstract class _TripOwner implements TripOwner {
  const factory _TripOwner(
      {required final int id,
      final String? name,
      final String? avatar}) = _$TripOwnerImpl;

  factory _TripOwner.fromJson(Map<String, dynamic> json) =
      _$TripOwnerImpl.fromJson;

  @override
  int get id;
  @override
  String? get name;
  @override
  String? get avatar;
  @override
  @JsonKey(ignore: true)
  _$$TripOwnerImplCopyWith<_$TripOwnerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
