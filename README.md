Have you ever wished you could easily sort through a list of objects based on how you feel? Then this is the package for you!

## Features

- This package allows you to sort through a list of objects based on user preference.
- Currently, it uses the merge sort algorithim although others may be implemented later.
- Simply provide the sorter with a list of items, then it will provide you with two options at a time until the list has been sorted.

## Getting started

Add this line to your pubspec.yaml:

```yaml
dependencies:
  interactive_sort: 
    git: https://github.com/justinklemon/interactive_sort.git
```

Then run this command:

```bash
flutter pub get
```

Then add this import:

```dart
import 'package:interactive_sort:interactive_sort.dart
```

## Usage

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

If your items can be sorted as easily as this example, then this package is not for you. Use this when you need to decide between complex preferences, like your favorite movie or the best pizza place in town.

Go forth and sort!
