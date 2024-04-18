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
