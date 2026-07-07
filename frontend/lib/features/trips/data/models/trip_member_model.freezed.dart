// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_member_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TripMemberModel _$TripMemberModelFromJson(Map<String, dynamic> json) {
  return _TripMemberModel.fromJson(json);
}

/// @nodoc
mixin _$TripMemberModel {
  int get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;
  String? get role => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TripMemberModelCopyWith<TripMemberModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripMemberModelCopyWith<$Res> {
  factory $TripMemberModelCopyWith(
          TripMemberModel value, $Res Function(TripMemberModel) then) =
      _$TripMemberModelCopyWithImpl<$Res, TripMemberModel>;
  @useResult
  $Res call(
      {int id, String? name, String? email, String? avatar, String? role});
}

/// @nodoc
class _$TripMemberModelCopyWithImpl<$Res, $Val extends TripMemberModel>
    implements $TripMemberModelCopyWith<$Res> {
  _$TripMemberModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? email = freezed,
    Object? avatar = freezed,
    Object? role = freezed,
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
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      role: freezed == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TripMemberModelImplCopyWith<$Res>
    implements $TripMemberModelCopyWith<$Res> {
  factory _$$TripMemberModelImplCopyWith(_$TripMemberModelImpl value,
          $Res Function(_$TripMemberModelImpl) then) =
      __$$TripMemberModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id, String? name, String? email, String? avatar, String? role});
}

/// @nodoc
class __$$TripMemberModelImplCopyWithImpl<$Res>
    extends _$TripMemberModelCopyWithImpl<$Res, _$TripMemberModelImpl>
    implements _$$TripMemberModelImplCopyWith<$Res> {
  __$$TripMemberModelImplCopyWithImpl(
      _$TripMemberModelImpl _value, $Res Function(_$TripMemberModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? email = freezed,
    Object? avatar = freezed,
    Object? role = freezed,
  }) {
    return _then(_$TripMemberModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      role: freezed == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TripMemberModelImpl extends _TripMemberModel {
  const _$TripMemberModelImpl(
      {required this.id, this.name, this.email, this.avatar, this.role})
      : super._();

  factory _$TripMemberModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripMemberModelImplFromJson(json);

  @override
  final int id;
  @override
  final String? name;
  @override
  final String? email;
  @override
  final String? avatar;
  @override
  final String? role;

  @override
  String toString() {
    return 'TripMemberModel(id: $id, name: $name, email: $email, avatar: $avatar, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripMemberModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, email, avatar, role);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TripMemberModelImplCopyWith<_$TripMemberModelImpl> get copyWith =>
      __$$TripMemberModelImplCopyWithImpl<_$TripMemberModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripMemberModelImplToJson(
      this,
    );
  }
}

abstract class _TripMemberModel extends TripMemberModel {
  const factory _TripMemberModel(
      {required final int id,
      final String? name,
      final String? email,
      final String? avatar,
      final String? role}) = _$TripMemberModelImpl;
  const _TripMemberModel._() : super._();

  factory _TripMemberModel.fromJson(Map<String, dynamic> json) =
      _$TripMemberModelImpl.fromJson;

  @override
  int get id;
  @override
  String? get name;
  @override
  String? get email;
  @override
  String? get avatar;
  @override
  String? get role;
  @override
  @JsonKey(ignore: true)
  _$$TripMemberModelImplCopyWith<_$TripMemberModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
