import 'dart:async';

import 'choice_pair.dart';
import 'merge_sort/interactive_merge_sort.dart';

typedef ToJson<T> = Map<String, dynamic> Function(T item);
typedef FromJson<T> = T Function(Map<String, dynamic> json);

abstract interface class InteractiveSort<T> {
  Stream<ChoicePair<T>> get choicePairStream;
  Future<List<T>> get sortedList;
  ToJson<T>? get listItemToJson;
  bool get isSorted;
  bool get isNotSorted;
  set listItemToJson(ToJson<T>? value);

  void onItemSelected(T item);

  Map<String, dynamic> toJson();
  String toJsonString();

  void dispose();

  factory InteractiveSort.mergeSort(List<T> list, {ToJson<T>? listItemToJson}) {
    return InteractiveMergeSort<T>(list, listItemToJson: listItemToJson);
  }

  factory InteractiveSort.mergeSortFromJson(Map<String, dynamic> json,
      {FromJson<T>? listItemFromJson}) {
    return InteractiveMergeSort<T>.fromJson(json,
        listItemFromJson: listItemFromJson);
  }

  factory InteractiveSort.mergeSortFromJsonString(String jsonString,
      {FromJson<T>? listItemFromJson}) {
    return InteractiveMergeSort<T>.fromJsonString(jsonString,
        listItemFromJson: listItemFromJson);
  }
}
