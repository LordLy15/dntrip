// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tripRemoteDatasourceHash() =>
    r'4ceb946256ce6d85b1825c8d6c7a9f051bde120d';

/// See also [tripRemoteDatasource].
@ProviderFor(tripRemoteDatasource)
final tripRemoteDatasourceProvider =
    AutoDisposeProvider<TripRemoteDatasource>.internal(
  tripRemoteDatasource,
  name: r'tripRemoteDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tripRemoteDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TripRemoteDatasourceRef = AutoDisposeProviderRef<TripRemoteDatasource>;
String _$tripRepositoryHash() => r'4ea03dfb6dfd64c90e24189ecf8ce228620759fd';

/// See also [tripRepository].
@ProviderFor(tripRepository)
final tripRepositoryProvider = AutoDisposeProvider<TripRepository>.internal(
  tripRepository,
  name: r'tripRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tripRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TripRepositoryRef = AutoDisposeProviderRef<TripRepository>;
String _$tripsNotifierHash() => r'2793ba8e65569cf05320e2426d08107048beec8f';

/// See also [TripsNotifier].
@ProviderFor(TripsNotifier)
final tripsNotifierProvider =
    AutoDisposeNotifierProvider<TripsNotifier, TripsState>.internal(
  TripsNotifier.new,
  name: r'tripsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tripsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TripsNotifier = AutoDisposeNotifier<TripsState>;
String _$tripDetailNotifierHash() =>
    r'67bce79a256b23a3283b69771b5c548d751686b4';

/// See also [TripDetailNotifier].
@ProviderFor(TripDetailNotifier)
final tripDetailNotifierProvider =
    AutoDisposeNotifierProvider<TripDetailNotifier, TripModel?>.internal(
  TripDetailNotifier.new,
  name: r'tripDetailNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tripDetailNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TripDetailNotifier = AutoDisposeNotifier<TripModel?>;
String _$membersNotifierHash() => r'b649eb2fa60c566d4ef573791da8baba0b32f38e';

/// See also [MembersNotifier].
@ProviderFor(MembersNotifier)
final membersNotifierProvider = AutoDisposeNotifierProvider<MembersNotifier,
    List<TripMemberModel>>.internal(
  MembersNotifier.new,
  name: r'membersNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$membersNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MembersNotifier = AutoDisposeNotifier<List<TripMemberModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
