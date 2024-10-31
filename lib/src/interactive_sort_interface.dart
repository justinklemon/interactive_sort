import 'dart:async';

import 'choice_pair.dart';
import 'merge_sort/interactive_merge_sort.dart';

typedef ToJson<T> = Map<String, dynamic> Function(T item);
typedef FromJson<T> = T Function(Map<String, dynamic> json);
typedef ChoiceResult<T> = Map<ChoicePair<T>, T>;

abstract interface class InteractiveSort<T> {
  Stream<ChoicePair<T>> get choicePairStream;
  Future<List<T>> get sortedList;
  bool get isSorted;
  bool get isNotSorted;
  Map<ChoicePair<T>, T> get choiceHistory;

  void onItemSelected(T item);

  void dispose();

  bool get isDisposed;

  factory InteractiveSort.mergeSort(List<T> list, {Map<ChoicePair<T>, T>? choiceHistory}) {
    return InteractiveMergeSort<T>(list, choiceHistory: choiceHistory);
  }
}
