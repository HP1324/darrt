// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_state_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskStateNotifierHash() => r'd720a004ce3138b26d925cf14927f9f655f8f6e7';

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

abstract class _$TaskStateNotifier
    extends BuildlessAutoDisposeNotifier<TaskState> {
  late final bool edit;
  late final Task? task;
  late final TaskCategory? category;

  TaskState build(bool edit, [Task? task, TaskCategory? category]);
}

/// See also [TaskStateNotifier].
@ProviderFor(TaskStateNotifier)
const taskStateNotifierProvider = TaskStateNotifierFamily();

/// See also [TaskStateNotifier].
class TaskStateNotifierFamily extends Family<TaskState> {
  /// See also [TaskStateNotifier].
  const TaskStateNotifierFamily();

  /// See also [TaskStateNotifier].
  TaskStateNotifierProvider call(
    bool edit, [
    Task? task,
    TaskCategory? category,
  ]) {
    return TaskStateNotifierProvider(edit, task, category);
  }

  @override
  TaskStateNotifierProvider getProviderOverride(
    covariant TaskStateNotifierProvider provider,
  ) {
    return call(provider.edit, provider.task, provider.category);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'taskStateNotifierProvider';
}

/// See also [TaskStateNotifier].
class TaskStateNotifierProvider
    extends AutoDisposeNotifierProviderImpl<TaskStateNotifier, TaskState> {
  /// See also [TaskStateNotifier].
  TaskStateNotifierProvider(bool edit, [Task? task, TaskCategory? category])
    : this._internal(
        () => TaskStateNotifier()
          ..edit = edit
          ..task = task
          ..category = category,
        from: taskStateNotifierProvider,
        name: r'taskStateNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$taskStateNotifierHash,
        dependencies: TaskStateNotifierFamily._dependencies,
        allTransitiveDependencies:
            TaskStateNotifierFamily._allTransitiveDependencies,
        edit: edit,
        task: task,
        category: category,
      );

  TaskStateNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.edit,
    required this.task,
    required this.category,
  }) : super.internal();

  final bool edit;
  final Task? task;
  final TaskCategory? category;

  @override
  TaskState runNotifierBuild(covariant TaskStateNotifier notifier) {
    return notifier.build(edit, task, category);
  }

  @override
  Override overrideWith(TaskStateNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TaskStateNotifierProvider._internal(
        () => create()
          ..edit = edit
          ..task = task
          ..category = category,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        edit: edit,
        task: task,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<TaskStateNotifier, TaskState>
  createElement() {
    return _TaskStateNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskStateNotifierProvider &&
        other.edit == edit &&
        other.task == task &&
        other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, edit.hashCode);
    hash = _SystemHash.combine(hash, task.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TaskStateNotifierRef on AutoDisposeNotifierProviderRef<TaskState> {
  /// The parameter `edit` of this provider.
  bool get edit;

  /// The parameter `task` of this provider.
  Task? get task;

  /// The parameter `category` of this provider.
  TaskCategory? get category;
}

class _TaskStateNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<TaskStateNotifier, TaskState>
    with TaskStateNotifierRef {
  _TaskStateNotifierProviderElement(super.provider);

  @override
  bool get edit => (origin as TaskStateNotifierProvider).edit;
  @override
  Task? get task => (origin as TaskStateNotifierProvider).task;
  @override
  TaskCategory? get category => (origin as TaskStateNotifierProvider).category;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
