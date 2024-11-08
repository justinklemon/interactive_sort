import 'dart:async';

import '../choice_pair.dart';
import '../interactive_sort_interface.dart';
import 'merge_sort_step.dart';
import 'node_type.dart';

const String listKey = 'list';
const String stepsKey = 'steps';
const String currentStepIndexKey = 'currentStepIndex';

class InteractiveMergeSort<T> implements InteractiveSort<T> {
  final List<T> _list;
  final Map<ChoicePair<T>, T> _choiceHistory;
  final Map<int, MergeSortStep> _steps;
  final StreamController<ChoicePair<T>> _choiceController =
      StreamController<ChoicePair<T>>();
  final Completer<List<T>> _sortCompleter = Completer<List<T>>();
  MergeSortStep _currentStep;
  bool _disposed = false;

  InteractiveMergeSort._(List<T> list, this._steps, this._currentStep,
      {Map<ChoicePair<T>, T>? choiceHistory})
      : _list = List.unmodifiable(list),
        _choiceHistory = Map.from(choiceHistory ?? {}) {
    if (_currentStep.isSorted) {
      _sortCompleter.complete(
          _currentStep.sortedIndicesList.map((index) => _list[index]).toList());
      dispose();
    } else {
      _addItemsToStreams();
    }
  }

  factory InteractiveMergeSort(List<T> list,
      {Map<ChoicePair<T>, T>? choiceHistory}) {
    Map<int, MergeSortStep> steps = MergeSortStep.generateTree(list: list);
    int currentStepIndex = steps.keys.reduce((a, b) => a > b ? a : b);
    MergeSortStep currentStep = steps[currentStepIndex]!;
    return InteractiveMergeSort._(list, steps, currentStep,
        choiceHistory: choiceHistory);
  }

  @override
  Stream<ChoicePair<T>> get choicePairStream => _choiceController.stream;
  @override
  Future<List<T>> get sortedList => _sortCompleter.future;
  @override
  bool get isSorted => _sortCompleter.isCompleted;
  @override
  bool get isNotSorted => !_sortCompleter.isCompleted;
  @override
  Map<ChoicePair<T>, T> get choiceHistory => Map.from(_choiceHistory);

  @override
  void onItemSelected(T selectedItem) {
    if (_disposed) {
      throw StateError('InteractiveMergeSort has been disposed');
    }
    if (_sortCompleter.isCompleted) {
      throw StateError('Sorting is already complete');
    }
    T leftItem = _list[_currentStep.leftItemIndex];
    T rightItem = _list[_currentStep.rightItemIndex];
    ChoicePair<T> choicePair = ChoicePair(leftItem, rightItem);
    if (selectedItem == leftItem) {
      _currentStep.selectLeftItem();
      _choiceHistory[choicePair] = leftItem;
    } else if (selectedItem == rightItem) {
      _currentStep.selectRightItem();
      _choiceHistory[choicePair] = rightItem;
    } else {
      throw ArgumentError('Invalid item selected');
    }
    if (_currentStep.isSorted && _currentStep.nodeType != NodeType.root) {
      _steps[_currentStep.parentStepIndex!]!.receiveChildResult(_currentStep);
      _steps.remove(_currentStep.stepIndex);
      _updateCurrentStep();
    }

    if (_currentStep.isSorted && _currentStep.nodeType == NodeType.root) {
      _sortCompleter.complete(
          _currentStep.sortedIndicesList.map((index) => _list[index]).toList());
      dispose();
    } else {
      _addItemsToStreams();
    }
  }

  void _addItemsToStreams() {
    T leftItem = _list[_currentStep.leftItemIndex];
    T rightItem = _list[_currentStep.rightItemIndex];
    T? previousChoice = _choiceHistory[ChoicePair(leftItem, rightItem)];
    if (previousChoice != null) {
      onItemSelected(previousChoice);
      return;
    }
    // Only add items to the stream if they haven't been selected before
    _choiceController.add(ChoicePair(leftItem, rightItem));
  }

  void _updateCurrentStep() {
    int stepIndex = _currentStep.stepIndex;
    while (_steps[stepIndex] == null && stepIndex > 0) {
      stepIndex--;
    }
    _currentStep = _steps[stepIndex]!;
  }

  @override
  void dispose() {
    if (_disposed) return;

    _choiceController.close();
    if (!_sortCompleter.isCompleted) {
      _sortCompleter.completeError(StateError(
          'InteractiveMergeSort disposed before sorting was completed'));
    }
    _disposed = true;
  }

  @override
  bool get isDisposed => _disposed;
}
