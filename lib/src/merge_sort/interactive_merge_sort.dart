import 'dart:convert';
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
  final Map<int, MergeSortStep> _steps;
  MergeSortStep _currentStep;
  @override
  ToJson<T>? listItemToJson;
  final StreamController<ChoicePair<T>> _choiceController =
      StreamController<ChoicePair<T>>();
  final Completer<List<T>> _sortCompleter = Completer<List<T>>();
  bool _disposed = false;

  InteractiveMergeSort._(List<T> list, this._steps, this._currentStep,
      {this.listItemToJson})
      : _list = List.unmodifiable(list) {
    if (_currentStep.isSorted) {
      _sortCompleter.complete(
          _currentStep.sortedIndicesList.map((index) => _list[index]).toList());
      _choiceController.close();
    } else {
      _addItemsToStreams();
    }
  }

  factory InteractiveMergeSort(List<T> list, {ToJson<T>? listItemToJson}) {
    Map<int, MergeSortStep> steps = MergeSortStep.generateTree(list: list);
    int currentStepIndex = steps.keys.reduce((a, b) => a > b ? a : b);
    MergeSortStep currentStep = steps[currentStepIndex]!;
    return InteractiveMergeSort._(list, steps, currentStep,
        listItemToJson: listItemToJson);
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
  void onItemSelected(T selectedItem) {
    if (_disposed) {
      throw StateError('InteractiveMergeSort has been disposed');
    }
    if (_sortCompleter.isCompleted) {
      throw StateError('Sorting is already complete');
    }
    T leftItem = _list[_currentStep.leftItemIndex];
    T rightItem = _list[_currentStep.rightItemIndex];
    if (selectedItem == leftItem) {
      _currentStep.selectLeftItem();
    } else if (selectedItem == rightItem) {
      _currentStep.selectRightItem();
    } else {
      throw ArgumentError('Invalid item selected');
    }
    if (_currentStep.isSorted && _currentStep.nodeType != NodeType.root) {
      _steps[_currentStep.parentStepIndex!]!.receiveChildResult(
          _currentStep.sortedIndicesList, _currentStep.nodeType);
      _steps.remove(_currentStep.stepIndex);
      _updateCurrentStep();
    }

    if (_currentStep.isSorted && _currentStep.nodeType == NodeType.root) {
      _sortCompleter.complete(
          _currentStep.sortedIndicesList.map((index) => _list[index]).toList());
      _choiceController.close();
    } else {
      _addItemsToStreams();
    }
  }

  void _addItemsToStreams() {
    T leftItem = _list[_currentStep.leftItemIndex];
    T rightItem = _list[_currentStep.rightItemIndex];
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
  Map<String, dynamic> toJson() {
    List<dynamic> listJson;
    if (listItemToJson != null) {
      listJson = _list.map((item) => listItemToJson!(item)).toList();
    } else {
      try {
        jsonEncode(_list);
      } catch (e) {
        throw StateError(
            'List could not be converted to JSON. Try providing a custom listItemToJson function for the list items.');
      }
      listJson = _list;
    }
    final steps =
        _steps.map((key, value) => MapEntry(key.toString(), value.toJson()));
    return {
      listKey: listJson,
      stepsKey: steps,
      currentStepIndexKey: _currentStep.stepIndex,
    };
  }

  @override
  String toJsonString() {
    return jsonEncode(toJson());
  }

  @override
  void dispose() {
    if (_disposed) {
      throw StateError('InteractiveMergeSort has already been disposed');
    }
    _choiceController.close();
    _disposed = true;
  }

  factory InteractiveMergeSort.fromJson(Map<String, dynamic> json,
      {FromJson<T>? listItemFromJson}) {
    List<T> list;
    if (listItemFromJson != null) {
      List<Map<String, dynamic>> jsonList =
          json[listKey].cast<Map<String, dynamic>>();
      list = jsonList.map((item) => listItemFromJson(item)).toList();
    } else {
      try {
        list = json[listKey] as List<T>;
      } catch (e) {
        throw StateError(
            'List could not be converted from JSON. Try providing a custom listItemFromJson function for the list items.');
      }
    }
    Map<String, dynamic> stepsJson = json[stepsKey].cast<String, dynamic>();
    Map<int, MergeSortStep> steps = stepsJson.map((key, value) =>
        MapEntry(int.parse(key), MergeSortStep.fromJson(value)));
    int currentStepIndex = json[currentStepIndexKey];
    MergeSortStep currentStep = steps[currentStepIndex]!;

    return InteractiveMergeSort._(list, steps, currentStep);
  }

  factory InteractiveMergeSort.fromJsonString(String jsonString,
      {FromJson<T>? listItemFromJson}) {
    return InteractiveMergeSort.fromJson(jsonDecode(jsonString),
        listItemFromJson: listItemFromJson);
  }
}
