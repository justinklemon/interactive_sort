import 'dart:async';

import 'choice_pair.dart';
import 'merge_sort/interactive_merge_sort.dart';

typedef ToJson<T> = Map<String, dynamic> Function(T item);
typedef FromJson<T> = T Function(Map<String, dynamic> json);
typedef ChoiceResult<T> = Map<ChoicePair<T>, T>;

abstract interface class InteractiveSort<T> {
  Stream<ChoicePair<T>> get choicePairStream;
  Stream<int> get maxChoicesLeftStream;
  Future<List<T>> get sortedList;
  bool get isSorted;
  bool get isNotSorted;
  Map<ChoicePair<T>, T> get choiceHistory;

  void onItemSelected(T item);

  void dispose();

  bool get isDisposed;

  factory InteractiveSort.mergeSort(List<T> list,
      {Map<ChoicePair<T>, T>? choiceHistory}) {
    return InteractiveMergeSort<T>(list, choiceHistory: choiceHistory);
  }
  /// Constructor for partially sorted lists.
  /// Accepts a list of unsorted items and a list of sorted item lists.
  factory InteractiveSort.partiallySortedMergeSort(
      List<T> unsortedItems, List<List<T>> sortedItemsLists,
      {Map<ChoicePair<T>, T>? choiceHistory}) {
    return InteractiveMergeSort.partiallySorted(unsortedItems, sortedItemsLists,
        choiceHistory: choiceHistory);
  }
}
