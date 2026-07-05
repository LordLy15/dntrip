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
  String get title => throw _privateConstructorUsedError;
  String? get destination => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get startDate => throw _privateConstructorUsedError;
  String? get endDate => throw _privateConstructorUsedError;
  String get shareCode => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  UserModel get owner => throw _privateConstructorUsedError;
  List<TripMemberModel> get members => throw _privateConstructorUsedError;
  int? get membersCount => throw _privateConstructorUsedError;

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
      String title,
      String? destination,
      String? description,
      String? startDate,
      String? endDate,
      String shareCode,
      String status,
      UserModel owner,
      List<TripMemberModel> members,
      int? membersCount});

  $UserModelCopyWith<$Res> get owner;
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
    Object? title = null,
    Object? destination = freezed,
    Object? description = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? shareCode = null,
    Object? status = null,
    Object? owner = null,
    Object? members = null,
    Object? membersCount = freezed,
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
      shareCode: null == shareCode
          ? _value.shareCode
          : shareCode // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      owner: null == owner
          ? _value.owner
          : owner // ignore: cast_nullable_to_non_nullable
              as UserModel,
      members: null == members
          ? _value.members
          : members // ignore: cast_nullable_to_non_nullable
              as List<TripMemberModel>,
      membersCount: freezed == membersCount
          ? _value.membersCount
          : membersCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res> get owner {
    return $UserModelCopyWith<$Res>(_value.owner, (value) {
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
      String title,
      String? destination,
      String? description,
      String? startDate,
      String? endDate,
      String shareCode,
      String status,
      UserModel owner,
      List<TripMemberModel> members,
      int? membersCount});

  @override
  $UserModelCopyWith<$Res> get owner;
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
    Object? title = null,
    Object? destination = freezed,
    Object? description = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? shareCode = null,
    Object? status = null,
    Object? owner = null,
    Object? members = null,
    Object? membersCount = freezed,
  }) {
    return _then(_$TripModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
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
      shareCode: null == shareCode
          ? _value.shareCode
          : shareCode // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      owner: null == owner
          ? _value.owner
          : owner // ignore: cast_nullable_to_non_nullable
              as UserModel,
      members: null == members
          ? _value._members
          : members // ignore: cast_nullable_to_non_nullable
              as List<TripMemberModel>,
      membersCount: freezed == membersCount
          ? _value.membersCount
          : membersCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TripModelImpl extends _TripModel {
  const _$TripModelImpl(
      {required this.id,
      required this.title,
      this.destination,
      this.description,
      this.startDate,
      this.endDate,
      required this.shareCode,
      required this.status,
      required this.owner,
      final List<TripMemberModel> members = const [],
      this.membersCount})
      : _members = members,
        super._();

  factory _$TripModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripModelImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String? destination;
  @override
  final String? description;
  @override
  final String? startDate;
  @override
  final String? endDate;
  @override
  final String shareCode;
  @override
  final String status;
  @override
  final UserModel owner;
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
  String toString() {
    return 'TripModel(id: $id, title: $title, destination: $destination, description: $description, startDate: $startDate, endDate: $endDate, shareCode: $shareCode, status: $status, owner: $owner, members: $members, membersCount: $membersCount)';
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
                other.membersCount == membersCount));
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
      membersCount);

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
      required final String title,
      final String? destination,
      final String? description,
      final String? startDate,
      final String? endDate,
      required final String shareCode,
      required final String status,
      required final UserModel owner,
      final List<TripMemberModel> members,
      final int? membersCount}) = _$TripModelImpl;
  const _TripModel._() : super._();

  factory _TripModel.fromJson(Map<String, dynamic> json) =
      _$TripModelImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String? get destination;
  @override
  String? get description;
  @override
  String? get startDate;
  @override
  String? get endDate;
  @override
  String get shareCode;
  @override
  String get status;
  @override
  UserModel get owner;
  @override
  List<TripMemberModel> get members;
  @override
  int? get membersCount;
  @override
  @JsonKey(ignore: true)
  _$$TripModelImplCopyWith<_$TripModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({int id, String name});
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
          _$UserModelImpl value, $Res Function(_$UserModelImpl) then) =
      __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name});
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
      _$UserModelImpl _value, $Res Function(_$UserModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_$UserModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl({required this.id, required this.name});

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final int id;
  @override
  final String name;

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(
      this,
    );
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel(
      {required final int id, required final String name}) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  @JsonKey(ignore: true)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
