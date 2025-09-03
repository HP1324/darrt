// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'date_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$datesHash() => r'4c06aeb786da8f8a5a006cc45a7da93c318ae2a7';

/// See also [dates].
@ProviderFor(dates)
final datesProvider = AutoDisposeProvider<List<DateTime>>.internal(
  dates,
  name: r'datesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$datesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatesRef = AutoDisposeProviderRef<List<DateTime>>;
String _$selectedDateNotifierHash() =>
    r'5f5ab6987b513b8e42c2bfd3b40cfade201bb28a';

/// See also [SelectedDateNotifier].
@ProviderFor(SelectedDateNotifier)
final selectedDateNotifierProvider =
    AutoDisposeNotifierProvider<SelectedDateNotifier, CalendarState>.internal(
      SelectedDateNotifier.new,
      name: r'selectedDateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedDateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedDateNotifier = AutoDisposeNotifier<CalendarState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
