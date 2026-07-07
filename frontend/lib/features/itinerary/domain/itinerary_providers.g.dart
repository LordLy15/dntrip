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
String _$suddenExpenseRemoteDatasourceHash() =>
    r'2b2bf9e622a441c9b63afbb0cc5e088fd58644ec';

/// See also [suddenExpenseRemoteDatasource].
@ProviderFor(suddenExpenseRemoteDatasource)
final suddenExpenseRemoteDatasourceProvider =
    AutoDisposeProvider<SuddenExpenseRemoteDatasource>.internal(
  suddenExpenseRemoteDatasource,
  name: r'suddenExpenseRemoteDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$suddenExpenseRemoteDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SuddenExpenseRemoteDatasourceRef
    = AutoDisposeProviderRef<SuddenExpenseRemoteDatasource>;
String _$itineraryRepositoryHash() =>
    r'8f4402a569cfb94b9fc326809a20c72dfe35c07c';

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
String _$suddenExpensesHash() => r'2f200dc5b624bc47971eaa4563659fa042f6ef7d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [suddenExpenses].
@ProviderFor(suddenExpenses)
const suddenExpensesProvider = SuddenExpensesFamily();

/// See also [suddenExpenses].
class SuddenExpensesFamily
    extends Family<AsyncValue<List<SuddenExpenseModel>>> {
  /// See also [suddenExpenses].
  const SuddenExpensesFamily();

  /// See also [suddenExpenses].
  SuddenExpensesProvider call(
    int tripId,
  ) {
    return SuddenExpensesProvider(
      tripId,
    );
  }

  @override
  SuddenExpensesProvider getProviderOverride(
    covariant SuddenExpensesProvider provider,
  ) {
    return call(
      provider.tripId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'suddenExpensesProvider';
}

/// See also [suddenExpenses].
class SuddenExpensesProvider
    extends AutoDisposeFutureProvider<List<SuddenExpenseModel>> {
  /// See also [suddenExpenses].
  SuddenExpensesProvider(
    int tripId,
  ) : this._internal(
          (ref) => suddenExpenses(
            ref as SuddenExpensesRef,
            tripId,
          ),
          from: suddenExpensesProvider,
          name: r'suddenExpensesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$suddenExpensesHash,
          dependencies: SuddenExpensesFamily._dependencies,
          allTransitiveDependencies:
              SuddenExpensesFamily._allTransitiveDependencies,
          tripId: tripId,
        );

  SuddenExpensesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tripId,
  }) : super.internal();

  final int tripId;

  @override
  Override overrideWith(
    FutureOr<List<SuddenExpenseModel>> Function(SuddenExpensesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SuddenExpensesProvider._internal(
        (ref) => create(ref as SuddenExpensesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tripId: tripId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SuddenExpenseModel>> createElement() {
    return _SuddenExpensesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SuddenExpensesProvider && other.tripId == tripId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tripId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SuddenExpensesRef
    on AutoDisposeFutureProviderRef<List<SuddenExpenseModel>> {
  /// The parameter `tripId` of this provider.
  int get tripId;
}

class _SuddenExpensesProviderElement
    extends AutoDisposeFutureProviderElement<List<SuddenExpenseModel>>
    with SuddenExpensesRef {
  _SuddenExpensesProviderElement(super.provider);

  @override
  int get tripId => (origin as SuddenExpensesProvider).tripId;
}

String _$expenseCategoriesHash() => r'f15bbc6f1be6d370bb5f8bd3171045a496425a93';

/// See also [expenseCategories].
@ProviderFor(expenseCategories)
final expenseCategoriesProvider =
    AutoDisposeFutureProvider<List<ExpenseCategory>>.internal(
  expenseCategories,
  name: r'expenseCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expenseCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ExpenseCategoriesRef
    = AutoDisposeFutureProviderRef<List<ExpenseCategory>>;
String _$customCategoryHash() => r'bbd2bcc4e51bd7877700324bab81456d712291bf';

/// See also [customCategory].
@ProviderFor(customCategory)
const customCategoryProvider = CustomCategoryFamily();

/// See also [customCategory].
class CustomCategoryFamily extends Family<AsyncValue<ExpenseCategory>> {
  /// See also [customCategory].
  const CustomCategoryFamily();

  /// See also [customCategory].
  CustomCategoryProvider call({
    required String categoryName,
    String icon = 'category',
    String? description,
  }) {
    return CustomCategoryProvider(
      categoryName: categoryName,
      icon: icon,
      description: description,
    );
  }

  @override
  CustomCategoryProvider getProviderOverride(
    covariant CustomCategoryProvider provider,
  ) {
    return call(
      categoryName: provider.categoryName,
      icon: provider.icon,
      description: provider.description,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'customCategoryProvider';
}

/// See also [customCategory].
class CustomCategoryProvider
    extends AutoDisposeFutureProvider<ExpenseCategory> {
  /// See also [customCategory].
  CustomCategoryProvider({
    required String categoryName,
    String icon = 'category',
    String? description,
  }) : this._internal(
          (ref) => customCategory(
            ref as CustomCategoryRef,
            categoryName: categoryName,
            icon: icon,
            description: description,
          ),
          from: customCategoryProvider,
          name: r'customCategoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$customCategoryHash,
          dependencies: CustomCategoryFamily._dependencies,
          allTransitiveDependencies:
              CustomCategoryFamily._allTransitiveDependencies,
          categoryName: categoryName,
          icon: icon,
          description: description,
        );

  CustomCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryName,
    required this.icon,
    required this.description,
  }) : super.internal();

  final String categoryName;
  final String icon;
  final String? description;

  @override
  Override overrideWith(
    FutureOr<ExpenseCategory> Function(CustomCategoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomCategoryProvider._internal(
        (ref) => create(ref as CustomCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryName: categoryName,
        icon: icon,
        description: description,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ExpenseCategory> createElement() {
    return _CustomCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomCategoryProvider &&
        other.categoryName == categoryName &&
        other.icon == icon &&
        other.description == description;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryName.hashCode);
    hash = _SystemHash.combine(hash, icon.hashCode);
    hash = _SystemHash.combine(hash, description.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CustomCategoryRef on AutoDisposeFutureProviderRef<ExpenseCategory> {
  /// The parameter `categoryName` of this provider.
  String get categoryName;

  /// The parameter `icon` of this provider.
  String get icon;

  /// The parameter `description` of this provider.
  String? get description;
}

class _CustomCategoryProviderElement
    extends AutoDisposeFutureProviderElement<ExpenseCategory>
    with CustomCategoryRef {
  _CustomCategoryProviderElement(super.provider);

  @override
  String get categoryName => (origin as CustomCategoryProvider).categoryName;
  @override
  String get icon => (origin as CustomCategoryProvider).icon;
  @override
  String? get description => (origin as CustomCategoryProvider).description;
}

String _$budgetSummaryHash() => r'4e41baa4df14d7b5ec1f1b616d5aaff13cec3e7b';

/// See also [budgetSummary].
@ProviderFor(budgetSummary)
const budgetSummaryProvider = BudgetSummaryFamily();

/// See also [budgetSummary].
class BudgetSummaryFamily extends Family<AsyncValue<BudgetSummaryModel>> {
  /// See also [budgetSummary].
  const BudgetSummaryFamily();

  /// See also [budgetSummary].
  BudgetSummaryProvider call(
    int tripId,
  ) {
    return BudgetSummaryProvider(
      tripId,
    );
  }

  @override
  BudgetSummaryProvider getProviderOverride(
    covariant BudgetSummaryProvider provider,
  ) {
    return call(
      provider.tripId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'budgetSummaryProvider';
}

/// See also [budgetSummary].
class BudgetSummaryProvider
    extends AutoDisposeFutureProvider<BudgetSummaryModel> {
  /// See also [budgetSummary].
  BudgetSummaryProvider(
    int tripId,
  ) : this._internal(
          (ref) => budgetSummary(
            ref as BudgetSummaryRef,
            tripId,
          ),
          from: budgetSummaryProvider,
          name: r'budgetSummaryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$budgetSummaryHash,
          dependencies: BudgetSummaryFamily._dependencies,
          allTransitiveDependencies:
              BudgetSummaryFamily._allTransitiveDependencies,
          tripId: tripId,
        );

  BudgetSummaryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tripId,
  }) : super.internal();

  final int tripId;

  @override
  Override overrideWith(
    FutureOr<BudgetSummaryModel> Function(BudgetSummaryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BudgetSummaryProvider._internal(
        (ref) => create(ref as BudgetSummaryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tripId: tripId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<BudgetSummaryModel> createElement() {
    return _BudgetSummaryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetSummaryProvider && other.tripId == tripId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tripId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BudgetSummaryRef on AutoDisposeFutureProviderRef<BudgetSummaryModel> {
  /// The parameter `tripId` of this provider.
  int get tripId;
}

class _BudgetSummaryProviderElement
    extends AutoDisposeFutureProviderElement<BudgetSummaryModel>
    with BudgetSummaryRef {
  _BudgetSummaryProviderElement(super.provider);

  @override
  int get tripId => (origin as BudgetSummaryProvider).tripId;
}

String _$activityTimeStatsHash() => r'3e3e31ae67ec07e5037afa78270fd549b5ed68db';

/// See also [activityTimeStats].
@ProviderFor(activityTimeStats)
const activityTimeStatsProvider = ActivityTimeStatsFamily();

/// See also [activityTimeStats].
class ActivityTimeStatsFamily extends Family<AsyncValue<Map<String, int>>> {
  /// See also [activityTimeStats].
  const ActivityTimeStatsFamily();

  /// See also [activityTimeStats].
  ActivityTimeStatsProvider call(
    int tripId,
  ) {
    return ActivityTimeStatsProvider(
      tripId,
    );
  }

  @override
  ActivityTimeStatsProvider getProviderOverride(
    covariant ActivityTimeStatsProvider provider,
  ) {
    return call(
      provider.tripId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'activityTimeStatsProvider';
}

/// See also [activityTimeStats].
class ActivityTimeStatsProvider
    extends AutoDisposeFutureProvider<Map<String, int>> {
  /// See also [activityTimeStats].
  ActivityTimeStatsProvider(
    int tripId,
  ) : this._internal(
          (ref) => activityTimeStats(
            ref as ActivityTimeStatsRef,
            tripId,
          ),
          from: activityTimeStatsProvider,
          name: r'activityTimeStatsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$activityTimeStatsHash,
          dependencies: ActivityTimeStatsFamily._dependencies,
          allTransitiveDependencies:
              ActivityTimeStatsFamily._allTransitiveDependencies,
          tripId: tripId,
        );

  ActivityTimeStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tripId,
  }) : super.internal();

  final int tripId;

  @override
  Override overrideWith(
    FutureOr<Map<String, int>> Function(ActivityTimeStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ActivityTimeStatsProvider._internal(
        (ref) => create(ref as ActivityTimeStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tripId: tripId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, int>> createElement() {
    return _ActivityTimeStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActivityTimeStatsProvider && other.tripId == tripId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tripId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ActivityTimeStatsRef on AutoDisposeFutureProviderRef<Map<String, int>> {
  /// The parameter `tripId` of this provider.
  int get tripId;
}

class _ActivityTimeStatsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, int>>
    with ActivityTimeStatsRef {
  _ActivityTimeStatsProviderElement(super.provider);

  @override
  int get tripId => (origin as ActivityTimeStatsProvider).tripId;
}

String _$itineraryNotifierHash() => r'f00629ed3d2b66530e98a2066c0b8074740f580f';

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
String _$suddenExpenseNotifierHash() =>
    r'6e323a84834c1d9d3f9e42c44f325f7d5821c4e4';

abstract class _$SuddenExpenseNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<SuddenExpenseModel>> {
  late final int tripId;

  FutureOr<List<SuddenExpenseModel>> build(
    int tripId,
  );
}

/// See also [SuddenExpenseNotifier].
@ProviderFor(SuddenExpenseNotifier)
const suddenExpenseNotifierProvider = SuddenExpenseNotifierFamily();

/// See also [SuddenExpenseNotifier].
class SuddenExpenseNotifierFamily
    extends Family<AsyncValue<List<SuddenExpenseModel>>> {
  /// See also [SuddenExpenseNotifier].
  const SuddenExpenseNotifierFamily();

  /// See also [SuddenExpenseNotifier].
  SuddenExpenseNotifierProvider call(
    int tripId,
  ) {
    return SuddenExpenseNotifierProvider(
      tripId,
    );
  }

  @override
  SuddenExpenseNotifierProvider getProviderOverride(
    covariant SuddenExpenseNotifierProvider provider,
  ) {
    return call(
      provider.tripId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'suddenExpenseNotifierProvider';
}

/// See also [SuddenExpenseNotifier].
class SuddenExpenseNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<SuddenExpenseNotifier,
        List<SuddenExpenseModel>> {
  /// See also [SuddenExpenseNotifier].
  SuddenExpenseNotifierProvider(
    int tripId,
  ) : this._internal(
          () => SuddenExpenseNotifier()..tripId = tripId,
          from: suddenExpenseNotifierProvider,
          name: r'suddenExpenseNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$suddenExpenseNotifierHash,
          dependencies: SuddenExpenseNotifierFamily._dependencies,
          allTransitiveDependencies:
              SuddenExpenseNotifierFamily._allTransitiveDependencies,
          tripId: tripId,
        );

  SuddenExpenseNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tripId,
  }) : super.internal();

  final int tripId;

  @override
  FutureOr<List<SuddenExpenseModel>> runNotifierBuild(
    covariant SuddenExpenseNotifier notifier,
  ) {
    return notifier.build(
      tripId,
    );
  }

  @override
  Override overrideWith(SuddenExpenseNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: SuddenExpenseNotifierProvider._internal(
        () => create()..tripId = tripId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tripId: tripId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<SuddenExpenseNotifier,
      List<SuddenExpenseModel>> createElement() {
    return _SuddenExpenseNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SuddenExpenseNotifierProvider && other.tripId == tripId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tripId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SuddenExpenseNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<SuddenExpenseModel>> {
  /// The parameter `tripId` of this provider.
  int get tripId;
}

class _SuddenExpenseNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<SuddenExpenseNotifier,
        List<SuddenExpenseModel>> with SuddenExpenseNotifierRef {
  _SuddenExpenseNotifierProviderElement(super.provider);

  @override
  int get tripId => (origin as SuddenExpenseNotifierProvider).tripId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
