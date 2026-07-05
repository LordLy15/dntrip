// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itineraryRemoteDatasourceHash() =>
    r'905a11bdf7d693123d89807dfeff931e4fde7afd';

/// See also [itineraryRemoteDatasource].
@ProviderFor(itineraryRemoteDatasource)
final itineraryRemoteDatasourceProvider =
    AutoDisposeProvider<ItineraryRemoteDatasource>.internal(
  itineraryRemoteDatasource,
  name: r'itineraryRemoteDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$itineraryRemoteDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ItineraryRemoteDatasourceRef
    = AutoDisposeProviderRef<ItineraryRemoteDatasource>;
String _$itineraryRepositoryHash() =>
    r'2345a00cc64bba4abbbe4570fc93d8b07a7b8ad0';

/// See also [itineraryRepository].
@ProviderFor(itineraryRepository)
final itineraryRepositoryProvider =
    AutoDisposeProvider<ItineraryRepository>.internal(
  itineraryRepository,
  name: r'itineraryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$itineraryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ItineraryRepositoryRef = AutoDisposeProviderRef<ItineraryRepository>;
String _$itineraryNotifierHash() => r'c01e6a9d90dee3b8fc46a9cf7ee7479f0de46550';

/// See also [ItineraryNotifier].
@ProviderFor(ItineraryNotifier)
final itineraryNotifierProvider =
    AutoDisposeNotifierProvider<ItineraryNotifier, ItineraryData?>.internal(
  ItineraryNotifier.new,
  name: r'itineraryNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$itineraryNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ItineraryNotifier = AutoDisposeNotifier<ItineraryData?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
