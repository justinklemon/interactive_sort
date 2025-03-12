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

## 0.0.3
Refactored the dispose method to not throw an error if it is already disposed, instead it just does nothing.
When disposed, the future now completes with an error if it is not already completed.
The interface now also exposes an `isDisposed` getter.

## 0.0.4
Refactored to remove the toJson/fromJson methods as they were needlessly complex. Instead, the sorter now
accepts a map of `ChoicePair` objects to the choice. It also tracks each choice the user makes and allows 
you to retrieve the full map at any point. This will allow you to save the choice history when you stop
sorting for any reason.

## 0.0.5
Refactored the merge sort method to use recursive nodes instead of a map. Also added a stream for the maximum number of choices left if the user sorts inefficiently.

## 0.0.6
Added a 'partiallySorted' constructor that allows you to add a list of unsorted items and a list of sorted lists. 
The contents of a sorted list will not be compared against each other. 
## 0.0.7
Removed unecessary print statements
