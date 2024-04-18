import 'dart:convert';
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
        expect(sorter.listItemToJson, isNull);
      });
      test('listItemToJson', () {
        final sorter = InteractiveSort.mergeSort([], listItemToJson: (_) => {});

        expect(sorter.listItemToJson, isNotNull);
      });
    });

    group('Serialization tests', () {
      test(
          'InteractiveSort.mergeSortFromJson() recreates a valid instance (List<int>)',
          () {
        // Serialize then deserialize, then check a known property
        final list = [3, 1, 4, 2];
        final sorter = InteractiveSort.mergeSort(list);
        final json = sorter.toJson();
        final sorterFromJson = InteractiveSort.mergeSortFromJson(json);

        expect(sorterFromJson.isSorted, false);
      });
      test(
          'InteractiveSort.mergeSortFromJson() recreates a valid instance (List<String>)',
          () {
        final list = ['c', 'a', 'd', 'b'];
        final sorter = InteractiveSort.mergeSort(list);
        final json = sorter.toJson();
        final sorterFromJson = InteractiveSort.mergeSortFromJson(json);

        expect(sorterFromJson.isSorted, false);
      });
      test(
          'InteractiveSort.mergeSortFromJson() recreates a valid instance (List<CustomObject>)',
          () {
        final people = [
          _TestPerson('Alice', 30),
          _TestPerson('Zoe', 25),
          _TestPerson('Bob', 40),
        ];
        final sorter = InteractiveSort.mergeSort(people);
        expect(() => sorter.toJson(), throwsStateError);

        sorter.listItemToJson =
            (person) => {'name': person.name, 'age': person.age};
        final json = sorter.toJson();
        expect(() => InteractiveSort<_TestPerson>.mergeSortFromJson(json),
            throwsStateError);

        final sorterFromJson = InteractiveSort<_TestPerson>.mergeSortFromJson(json,
            listItemFromJson: (json) => _TestPerson(json['name'], json['age']));
        expect(sorterFromJson.isSorted, false);
      });
      test('InteractiveSort.mergeSortFromJsonString() recreates a valid instance',
          () {
        final list = [3, 1, 4, 2];
        final sorter = InteractiveSort.mergeSort(list);
        final jsonString = sorter.toJsonString();
        final sorterFromJson = InteractiveSort.mergeSortFromJsonString(jsonString);

        expect(sorterFromJson.isSorted, false);
      });
      test(
          'InteractiveSort.mergeSortFromJsonString() recreates a valid instance (List<String>)',
          () {
        final list = ['c', 'a', 'd', 'b'];
        final sorter = InteractiveSort.mergeSort(list);
        final jsonString = jsonEncode(sorter.toJson());
        final sorterFromJson = InteractiveSort.mergeSortFromJsonString(jsonString);

        expect(sorterFromJson.isSorted, false);
      });

      test(
          'InteractiveSort.mergeSortFromJsonString() recreates a valid instance (List<CustomObject>)',
          () {
        final people = [
          _TestPerson('Alice', 30),
          _TestPerson('Zoe', 25),
          _TestPerson('Bob', 40),
        ];
        final sorter = InteractiveSort.mergeSort(people);
        expect(() => sorter.toJsonString(), throwsStateError);

        sorter.listItemToJson =
            (person) => {'name': person.name, 'age': person.age};
        final jsonString = sorter.toJsonString();
        expect(
            () => InteractiveSort<_TestPerson>.mergeSortFromJsonString(jsonString),
            throwsStateError);

        final sorterFromJson = InteractiveSort<_TestPerson>.mergeSortFromJsonString(jsonString,
            listItemFromJson: (json) => _TestPerson(json['name'], json['age']));
        expect(sorterFromJson.isSorted, false);
      });

      test('Invalid JSON input', () {
        const invalidJson =
            '{ "list": [1, 2, 3], "steps": { "1": { ... } } "missingClosingBracket }';

        expect(() => InteractiveSort.mergeSortFromJson(jsonDecode(invalidJson)),
            throwsA(isA<FormatException>()));
      });
    });

    // Sorting logic
    test('onItemSelected() progresses through the sort correctly', () {
      final list = [3, 1, 4, 2];
      final sorter = InteractiveSort.mergeSort(list);

      while (!sorter.isSorted) {
        sorter.onItemSelected(sorter.leftItem <= sorter.rightItem
            ? sorter.leftItem
            : sorter.rightItem);
      }

      expect(sorter.sortedList, [1, 2, 3, 4]);
      expect(() => sorter.onItemSelected(0), throwsStateError);
    });

    test('Duplicate items', () {
      final sorter = InteractiveSort.mergeSort([2, 3, 3, 1, 4, 2]);
      while (!sorter.isSorted) {
        sorter.onItemSelected(sorter.leftItem <= sorter.rightItem
            ? sorter.leftItem
            : sorter.rightItem);
      }

      expect(sorter.sortedList, [1, 2, 2, 3, 3, 4]);
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

    /// Handling StateError in sortedList Getter Throughout the Sorting Process
    test('sortedList throws StateError before the list is sorted', () {
      final list = [3, 1, 4, 2];
      final sorter = InteractiveSort.mergeSort(list);

      // Should throw an error at the beginning since it is not sorted.
      expect(() => sorter.sortedList, throwsStateError);

      // Sort the list partially - it should still throw an error as we are not done
      sorter.onItemSelected(sorter.leftItem <= sorter.rightItem
          ? sorter.leftItem
          : sorter.rightItem);
      expect(() => sorter.sortedList, throwsStateError);

      // Finish sorting the list and verify the getter works
      while (!sorter.isSorted) {
        sorter.onItemSelected(sorter.leftItem <= sorter.rightItem
            ? sorter.leftItem
            : sorter.rightItem);
      }
      expect(sorter.sortedList, [1, 2, 3, 4]);
    });
    // Edge cases
    test('Empty list', () {
      final sorter = InteractiveSort.mergeSort([]);
      expect(sorter.isSorted, true);
      expect(sorter.sortedList, []);

      // Should throw a StateError as the list is already sorted
      expect(() => sorter.onItemSelected(0), throwsStateError);
    });

    test('List with one item', () {
      final sorter = InteractiveSort.mergeSort([5]);
      expect(sorter.isSorted, true);
      expect(sorter.sortedList, [5]);

      // Should throw a StateError as the list is already sorted
      expect(() => sorter.onItemSelected(5), throwsStateError);
    });

    test('Very large list sorts correctly and efficiently', () {
      final largeList = List.generate(10000, (i) => Random().nextInt(100000));
      final sorter = InteractiveSort.mergeSort(largeList);
      final stopwatch = Stopwatch()..start();

      while (!sorter.isSorted) {
        sorter.onItemSelected(sorter.leftItem <= sorter.rightItem
            ? sorter.leftItem
            : sorter.rightItem);
      }

      expect(
          sorter.sortedList,
          largeList
            ..sort()); // Using the isSorted matcher from the test package
      print(
          'Sorting took ${stopwatch.elapsed}'); // Optional for performance analysis.
    });

    test('Sorting custom objects', () {
      final people = [
        _TestPerson('Alice', 30),
        _TestPerson('Zoe', 25),
        _TestPerson('Bob', 40),
      ];

      final sorter = InteractiveSort.mergeSort(people);

      // Assuming comparison is based on age
      while (!sorter.isSorted) {
        sorter.onItemSelected(sorter.leftItem.age <= sorter.rightItem.age
            ? sorter.leftItem
            : sorter.rightItem);
      }

      expect(sorter.sortedList, [
        _TestPerson('Zoe', 25),
        _TestPerson('Alice', 30),
        _TestPerson('Bob', 40),
      ]);
    });
  });
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
