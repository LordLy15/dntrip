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
String _$tripsNotifierHash() => r'32df6448bb400ad82962707bb4bb0d05b920891f';

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
    r'6b3a48e091914f4b591a5569804b4a376784c5a1';

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
String _$membersNotifierHash() => r'2f4928a276caf19fbfaaafbe3a10a112eb8a2b8a';

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
