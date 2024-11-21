import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:interactive_sort/interactive_sort.dart';

void main() {
  group('InteractiveMergeSort Tests', () {
    group('Constructor tests', () {
      test('InteractiveSort.mergeSort() creates a valid instance', () {
        final list = [3, 1, 4, 2];
        final sorter = InteractiveSort.mergeSort(list);

        // Can't access private members but we can check public facing properties
        expect(sorter.isSorted, false);
        expect(sorter.choiceHistory, isEmpty);
      });

      test('InteractiveSort.mergeSort() with a choice history works', () {
        final list = [3, 1, 4, 2];
        final choiceHistory = {
          const ChoicePair(1, 2): 1,
          const ChoicePair(3, 4): 3,
        };
        final sorter =
            InteractiveSort.mergeSort(list, choiceHistory: choiceHistory);

        expect(sorter.choiceHistory, equals(choiceHistory));
      });
    });

    group('Choice history', () {
      test('Choice history is updated correctly', () async {
        final list = [3, 1, 4, 2];
        final sorter = InteractiveSort.mergeSort(list);

        Map<ChoicePair<int>, int> history = {};
        sorter.choicePairStream.listen((pair) {
          int chosen = pair.left < pair.right ? pair.left : pair.right;
          history[pair] = chosen;
          sorter.onItemSelected(chosen);
          expect(sorter.choiceHistory, equals(history));
        });
        await sorter.sortedList;
        expect(sorter.choiceHistory, equals(history));
      });

      test('Choice history is used, 2 items', () async {
        final list = [3, 1];
        final choiceHistory = {
          const ChoicePair(1, 3): 1,
        };
        final sorter =
            InteractiveSort.mergeSort(list, choiceHistory: choiceHistory);

        expect(sorter.isSorted, true);
        expectLater(sorter.sortedList, completion(equals([1, 3])));
      });

      test('Choice history is used, 3 items', () async {
        final list = [3, 1, 4];
        final choiceHistory = {
          const ChoicePair(1, 3): 1,
          const ChoicePair(1, 4): 1,
        };
        final sorter =
            InteractiveSort.mergeSort(list, choiceHistory: choiceHistory);
        sorter.choicePairStream.listen((pair) {
          int chosen = pair.left < pair.right ? pair.left : pair.right;
          // Expect that the choiceHistory does not contain this pair
          expect(sorter.choiceHistory.containsKey(pair), false);
          sorter.onItemSelected(chosen);
        });
        await sorter.sortedList;
        expect(sorter.isSorted, true);
        expectLater(sorter.sortedList, completion(equals([1, 3, 4])));
      });

      test('Choice history is used, 4 items', () async {
        final list = [3, 1, 4, 2];
        final choiceHistory = {
          const ChoicePair(1, 3): 1,
          const ChoicePair(1, 4): 1,
          const ChoicePair(1, 2): 1,
        };
        final sorter =
            InteractiveSort.mergeSort(list, choiceHistory: choiceHistory);
        sorter.choicePairStream.listen((pair) {
          int chosen = pair.left < pair.right ? pair.left : pair.right;
          // Expect that the choiceHistory does not contain this pair
          expect(sorter.choiceHistory.containsKey(pair), false);
          sorter.onItemSelected(chosen);
        });
        await sorter.sortedList;
        expect(sorter.isSorted, true);
        expectLater(sorter.sortedList, completion(equals([1, 2, 3, 4])));
      });
    });

    // Sorting logic
    test('onItemSelected() progresses through the sort correctly', () {
      testSorting([3, 1, 4, 2], [1, 2, 3, 4], (a, b) => a.compareTo(b));
    });

    test('Duplicate items', () {
      testSorting(
          [2, 3, 3, 1, 4, 2], [1, 2, 2, 3, 3, 4], (a, b) => a.compareTo(b));
    });

    /// Handling StateError in onItemSelected
    test('onItemSelected() throws StateError when list is already sorted', () {
      final sorter = InteractiveSort.mergeSort([1]); // Already sorted
      expect(sorter.isSorted, true);
      expect(() => sorter.onItemSelected(1), throwsStateError);
    });

    /// Handling ArgumentError in onItemSelected
    test('onItemSelected() throws ArgumentError with invalid item', () {
      final list = [2, 1];
      final sorter = InteractiveSort.mergeSort(list);
      expect(() => sorter.onItemSelected(3), throwsArgumentError);
    });

    // Edge cases
    test('Empty list', () {
      final sorter = InteractiveSort.mergeSort([]);
      expect(sorter.isSorted, true);
      expectLater(sorter.sortedList, completion(equals([])));

      // Should throw a StateError as the list is already sorted
      expect(() => sorter.onItemSelected(0), throwsStateError);
    });

    test('List with one item', () {
      final sorter = InteractiveSort.mergeSort([5]);
      expect(sorter.isSorted, true);
      expectLater(sorter.sortedList, completion(equals([5])));

      // Should throw a StateError as the list is already sorted
      expect(() => sorter.onItemSelected(5), throwsStateError);
    });

    group('List with 2 items', () {
      test('List with 2 items, pick left', () {
        final sorter = InteractiveSort.mergeSort([1, 2]);
        expect(sorter.isSorted, false);
        sorter.onItemSelected(1);
        expect(sorter.isSorted, true);
        expectLater(sorter.sortedList, completion(equals([1, 2])));
      });

      test('List with 2 items, pick right', () {
        final sorter = InteractiveSort.mergeSort([1, 2]);
        expect(sorter.isSorted, false);
        sorter.choicePairStream.listen((pair) {
          print(pair);
        });
        sorter.onItemSelected(2);
        expect(sorter.isSorted, true);
        expectLater(sorter.sortedList, completion(equals([2, 1])));
      });
    });

    test('Very large list sorts correctly and efficiently', () {
      final largeList = List.generate(10000, (i) => Random().nextInt(100000));
      testSorting(largeList, largeList..sort(), (a, b) => a.compareTo(b));
    });

    test('Sorting custom objects', () {
      final people = [
        _TestPerson('Alice', 30),
        _TestPerson('Zoe', 25),
        _TestPerson('Bob', 40),
      ];
      testSorting(
          people,
          [
            _TestPerson('Zoe', 25),
            _TestPerson('Alice', 30),
            _TestPerson('Bob', 40),
          ],
          (a, b) => a.age.compareTo(b.age));
    });
  });

  group('disposal tests', () {
    test('dispose() cancels the stream', () {
      final sorter = InteractiveSort.mergeSort([3, 1, 4, 2]);
      sorter.dispose();
      expect(sorter.isDisposed, true);
      // Expect that the future completes with an error
      expectLater(sorter.sortedList, throwsStateError);
      expect(() => sorter.onItemSelected(1), throwsStateError);
    });

    test('dispose() cancels the stream even if sorting is complete', () {
      final sorter = InteractiveSort.mergeSort([1]);
      expect(sorter.isSorted, true);
      expect(sorter.isDisposed, true);
      sorter.dispose();
      expect(sorter.isDisposed, true);
    });
  });

  group('maxChoiceLeft stream', () {
    test('maxChoicesLeftStream emits nothing for empty stream', () {
      final sorter = InteractiveSort.mergeSort([]);
      expectLater(sorter.maxChoicesLeftStream, neverEmits(anything));
    });
    test('maxChoicesLeftStream emits nothing for single item', () {
      final sorter = InteractiveSort.mergeSort([1]);
      expectLater(sorter.maxChoicesLeftStream, neverEmits(anything));
    });
    test('maxChoicesLeftStream emits correct values for 2 items', () {
      final sorter = InteractiveSort.mergeSort([1, 2]);
      expectLater(sorter.maxChoicesLeftStream, emitsInOrder([1, emitsDone]));
      sorter.choicePairStream.listen((pair) {
        sorter.onItemSelected(pair.left);
      });
    });

    test('maxChoicesLeftStream emits correct values for 3 items - pick left',
        () {
      final sorter = InteractiveSort.mergeSort([1, 2, 3]);
      expectLater(
          sorter.maxChoicesLeftStream, emitsInOrder([3, 2, 1, emitsDone]));
      sorter.choicePairStream.listen((pair) {
        sorter.onItemSelected(pair.left);
      });
    });

    test('maxChoicesLeftStream emits correct values for 3 items - pick right',
        () {
      final sorter = InteractiveSort.mergeSort([1, 2, 3]);
      expectLater(sorter.maxChoicesLeftStream, emitsInOrder([3, 2, emitsDone]));
      sorter.choicePairStream.listen((pair) {
        sorter.onItemSelected(pair.right);
      });
    });

    test('maxChoicesLeftStream emits correct values for 4 items - pick left',
        () {
      final sorter = InteractiveSort.mergeSort([1, 2, 3, 4]);
      expectLater(
          sorter.maxChoicesLeftStream, emitsInOrder([5, 4, 3, 2, emitsDone]));
      sorter.choicePairStream.listen((pair) {
        sorter.onItemSelected(pair.left);
      });
    });

    test(
        'maxChoicesLeftStream emits correct values for 4 items - pick less efficient path',
        () {
      final sorter = InteractiveSort.mergeSort([1, 2, 3, 4]);
      expectLater(sorter.maxChoicesLeftStream,
          emitsInOrder([5, 4, 3, 2, 1, emitsDone]));
      sorter.onItemSelected(1);
      sorter.onItemSelected(3);
      sorter.onItemSelected(1);
      sorter.onItemSelected(3);
      sorter.onItemSelected(4);
      expect(sorter.isSorted, true);
      expectLater(sorter.sortedList, completion(equals([1, 3, 4, 2])));
    });

    test(
        'maxChoicesLeftStream emits correct values for 5 items - pick less efficient path',
        () {
      final sorter = InteractiveSort.mergeSort([1, 2, 3, 4, 5]);
      expectLater(sorter.maxChoicesLeftStream,
          emitsInOrder([8, 7, 6, 5, 4, 3, 2, 1, emitsDone]));
      sorter.onItemSelected(1);
      sorter.onItemSelected(1);
      sorter.onItemSelected(2);
      sorter.onItemSelected(4);
      sorter.onItemSelected(4);
      sorter.onItemSelected(1);
      sorter.onItemSelected(2);
      sorter.onItemSelected(5);
      expect(sorter.isSorted, true);
      expectLater(sorter.sortedList, completion(equals([4, 1, 2, 5, 3])));
    });
  });
}

void testSorting<T>(List<T> list, List<T> expected, Comparator<T> comparator) {
  final sorter = InteractiveSort.mergeSort(list);
  final comparisonsFuture = countComparisons(sorter, comparator);
  final expectedComparisons = list.length * log(list.length);
  expectLater(sorter.sortedList, completion(expected));
  expectLater(
      comparisonsFuture,
      completion(
          lessThanOrEqualTo(expectedComparisons + 1 + list.length / 10)));
}

Future<int> countComparisons<T>(
    InteractiveSort<T> sorter, Comparator<T> comparator) {
  final completer = Completer<int>();
  int comparisons = 0;
  sorter.choicePairStream.listen(
    (pair) {
      comparisons++;
      sorter.onItemSelected(
          comparator(pair.left, pair.right) <= 0 ? pair.left : pair.right);
    },
    onDone: () => completer.complete(comparisons),
  );
  return completer.future;
}

class _TestPerson {
  final String name;
  final int age;

  _TestPerson(this.name, this.age);

  @override
  String toString() => '$name ($age)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TestPerson &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          age == other.age;

  @override
  int get hashCode => name.hashCode ^ age.hashCode;
}
