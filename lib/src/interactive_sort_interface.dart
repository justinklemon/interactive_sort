import 'merge_sort/interactive_merge_sort.dart';

/// This function is used to convert a list item to a JSON object.
typedef ToJson<T> = Map<String, dynamic> Function(T item);

/// This function is used to convert a JSON object to a list item.
typedef FromJson<T> = T Function(Map<String, dynamic> json);

abstract interface class InteractiveSort<T> {
  bool get isSorted;
  bool get isNotSorted;

  /// Throws a [StateError] if [isSorted] is [false], otherwise returns the current 'left' item.
  T get leftItem;

  /// Throws a [StateError] if [isSorted] is [false], otherwise returns the current 'right' item.
  T get rightItem;

  /// Throws a [StateError] if [isSorted] is [false], otherwise returns the current 'left' item index.
  List<T> get sortedList;
  ToJson<T>? get listItemToJson;
  set listItemToJson(ToJson<T>? value);

  /// Calling this method will advance the sort order by one step.
  void onItemSelected(T item);

  Map<String, dynamic> toJson();
  String toJsonString();

  /// Factory constructors
  factory InteractiveSort.mergeSort(List<T> list, {ToJson<T>? listItemToJson}) {
    return InteractiveMergeSort<T>(list, listItemToJson: listItemToJson);
  }

  factory InteractiveSort.mergeSortFromJson(Map<String, dynamic> json, {FromJson<T>? listItemFromJson}) {
    return InteractiveMergeSort<T>.fromJson(json, listItemFromJson: listItemFromJson);
  }

  factory InteractiveSort.mergeSortFromJsonString(String jsonString, {FromJson<T>? listItemFromJson}) {
    return InteractiveMergeSort<T>.fromJsonString(jsonString, listItemFromJson: listItemFromJson);
  }
}
