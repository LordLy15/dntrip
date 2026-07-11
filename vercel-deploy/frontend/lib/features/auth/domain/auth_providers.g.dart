// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hiveStorageHash() => r'a81059bd29f3c2b34085efff71542dcdee1c4714';

/// See also [hiveStorage].
@ProviderFor(hiveStorage)
final hiveStorageProvider = AutoDisposeProvider<HiveStorage>.internal(
  hiveStorage,
  name: r'hiveStorageProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$hiveStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HiveStorageRef = AutoDisposeProviderRef<HiveStorage>;
String _$apiClientHash() => r'16d00b98a98f4904b4fe7cbeb4c028461ec67542';

/// See also [apiClient].
@ProviderFor(apiClient)
final apiClientProvider = AutoDisposeProvider<ApiClient>.internal(
  apiClient,
  name: r'apiClientProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$apiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ApiClientRef = AutoDisposeProviderRef<ApiClient>;
String _$authRemoteDatasourceHash() =>
    r'49f05ede9d4731860af9277d149e37f3c2fe2ce4';

/// See also [authRemoteDatasource].
@ProviderFor(authRemoteDatasource)
final authRemoteDatasourceProvider =
    AutoDisposeProvider<AuthRemoteDatasource>.internal(
  authRemoteDatasource,
  name: r'authRemoteDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRemoteDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthRemoteDatasourceRef = AutoDisposeProviderRef<AuthRemoteDatasource>;
String _$authRepositoryHash() => r'e9374abfa64d5c17b5ab2fede5aba94e70b51412';

/// See also [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$authNotifierHash() => r'cf8a4a775c41e2af8d6d3cd3d7d5c61787bd51e6';

/// See also [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AuthNotifier, AuthState>.internal(
  AuthNotifier.new,
  name: r'authNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthNotifier = AutoDisposeAsyncNotifier<AuthState>;
String _$loginNotifierHash() => r'2ba1beeda2dca5993245daf5d05868f15021b666';

/// See also [LoginNotifier].
@ProviderFor(LoginNotifier)
final loginNotifierProvider =
    AutoDisposeNotifierProvider<LoginNotifier, LoginState>.internal(
  LoginNotifier.new,
  name: r'loginNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$loginNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LoginNotifier = AutoDisposeNotifier<LoginState>;
String _$registerNotifierHash() => r'a23b1137905347e2cca2987db4eb08f4f9dea649';

/// See also [RegisterNotifier].
@ProviderFor(RegisterNotifier)
final registerNotifierProvider =
    AutoDisposeNotifierProvider<RegisterNotifier, RegisterState>.internal(
  RegisterNotifier.new,
  name: r'registerNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$registerNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RegisterNotifier = AutoDisposeNotifier<RegisterState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
