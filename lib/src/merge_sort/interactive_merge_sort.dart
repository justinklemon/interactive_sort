import 'dart:async';

import '../choice_pair.dart';
import '../interactive_sort_interface.dart';
import 'merge_sort_node.dart';
class InteractiveMergeSort<T> implements InteractiveSort<T> {
  final List<T> _list;
  final Map<ChoicePair<T>, T> _choiceHistory;
  final MergeSortNode _root;
  final StreamController<ChoicePair<T>> _choiceController =
      StreamController<ChoicePair<T>>();
  final Completer<List<T>> _sortCompleter = Completer<List<T>>();
  bool _disposed = false;

  InteractiveMergeSort._(List<T> list, this._root,
      {Map<ChoicePair<T>, T>? choiceHistory})
      : _list = List.unmodifiable(list),
        _choiceHistory = Map.from(choiceHistory ?? {}) {
    if (_root.isSorted) {
      _sortCompleter.complete(
          _root.sortedIndicesList.map((index) => _list[index]).toList());
      dispose();
    } else {
      _addItemsToStreams();
    }
  }

  factory InteractiveMergeSort(List<T> list,
      {Map<ChoicePair<T>, T>? choiceHistory}) {
    MergeSortNode root = MergeSortNode.buildMergeSortTree(list);
    return InteractiveMergeSort._(list, root, choiceHistory: choiceHistory);
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
    ChoicePair<int>? currChoiceIndices = _root.getChoicePair();
    if (currChoiceIndices == null) {
      throw StateError('No more choices to make');
    }
    T leftItem = _list[currChoiceIndices.left];
    T rightItem = _list[currChoiceIndices.right];
    if (selectedItem != leftItem && selectedItem != rightItem) {
      throw ArgumentError('Item $selectedItem is not a valid choice');
    }
    ChoicePair<T> choicePair = ChoicePair(leftItem, rightItem);
    _root.selectIndex(selectedItem == leftItem ? currChoiceIndices.left : currChoiceIndices.right);
    _choiceHistory[choicePair] = selectedItem;

    if (_root.isSorted) {
      _sortCompleter.complete(
          _root.sortedIndicesList.map((index) => _list[index]).toList());
      dispose();
    } else {
      _addItemsToStreams();
    }
  }

  void _addItemsToStreams() {
    ChoicePair<int>? currChoiceIndices = _root.getChoicePair();
    if (currChoiceIndices == null) {
      throw StateError('No more choices to make');
    }
    T leftItem = _list[currChoiceIndices.left];
    T rightItem = _list[currChoiceIndices.right];
    ChoicePair<T> choicePair = ChoicePair(leftItem, rightItem);
    T? previousChoice = _choiceHistory[choicePair];
    if (previousChoice != null) {
      onItemSelected(previousChoice);
      return;
    }
    // Only add items to the stream if they haven't been selected before
    _choiceController.add(choicePair);
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
