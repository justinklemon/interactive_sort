## 0.0.1

Allows you to sort a list of items based on user preference. You can use `leftItem` and `rightItem` getters to determine what two objects need to be compared, then use `onItemSelected` when the user makes their preference. The sorter will automatically update the left and right items based on your choice, so you can continue sorting.

If sorting is complete, the `leftItem` and `rightItem` getters will throw `StateError`, so to prevent that you can use the `isSorted` or `isNotSorted` getters to determine the state of the sorting job, you can usethe `sortedList` getter to retrieve the sorted list. Make sure that you don't call `sortedList` before sorting is complete, as it will throw a `StateError`.

Currently, only the merge sort algorithm is implemented, but others may be added later.


Example:

```dart
// Create sorter
final List<int> list = [3, 1, 4, 2];
final sorter = InteractiveSort<int>.mergeSort(list);

// Here is where you would actually present the items to the user and let them pick.
while(list.isNotSorted){
    sorter.onItemSelected(sorter.leftItem <= sorter.rightItem
        ? sorter.leftItem
        : sorter.rightItem);
}

print(sorter.sortedList)    // Prints: [1, 2, 3, 4]
```
If you need to preserve the sorting state at any point, you can do so using either the `toJson` or `toJsonString` functions. 

There are also associated constructors to resume sorting: `mergeSortFromJson` and `mergeSortFromJsonString`.

## 0.0.2
Refactored the InteractiveSort class to use a stream of `ChoicePair` objects instead of leftItem/rightItem getters. 
The `sortedList` function now returns a future and will not throw an error.
Calling `onItemSelected` with an item that is not from the most recent `ChoicePair` or after the sorting is complete will still throw a `StateError`.

Example: 
```dart
// Create sorter
final List<int> list = [3, 1, 4, 2];
final sorter = InteractiveSort<int>.mergeSort(list);

// Here is where you would actually present the items to the user and let them pick.
sorter.choicePairStream.listen(
    (pair) {
      comparisons++;
      sorter.onItemSelected(
          comparator(pair.left, pair.right) <= 0 ? pair.left : pair.right);
    },
  );

sorter.sortedList.then((list) => print(list));   // Prints: [1, 2, 3, 4]
```
