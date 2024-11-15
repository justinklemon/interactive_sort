import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_sort/src/choice_pair.dart';
import 'package:interactive_sort/src/merge_sort/merge_sort_node.dart';

void main() {
  group("Build merge sort tree", () {
    test('Empty list', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([]);
      expect(node.isSorted, true);
      expect(node.sortedIndicesList, []);
      expect(node.currentChoicePair, null);
      expect(node.children, null);
    });

    test('Single item list', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1]);
      expect(node.isSorted, true);
      expect(node.sortedIndicesList, [0]);
      expect(node.currentChoicePair, null);
      expect(node.children, null);
    });

    test('Two item list', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1, 2]);
      expect(node.isSorted, false);
      expect(() => node.sortedIndicesList, throwsStateError);
      expect(node.currentChoicePair, const ChoicePair(0, 1));
      expect(node.children, isNotNull);
      expect(node.children!.left.isSorted, true);
      expect(node.children!.left.sortedIndicesList, [0]);
      expect(node.children!.right.isSorted, true);
      expect(node.children!.right.sortedIndicesList, [1]);
    });
  });

  group('Select index', () {
    test('Select index on empty node', () {
      MergeSortNode node = MergeSortNode.empty();
      expect(() => node.selectIndex(0), throwsArgumentError);
    });

    test('Select index on single item node', () {
      MergeSortNode node = MergeSortNode.single(0);
      expect(() => node.selectIndex(0), throwsStateError);
    });

    test('Select index on two item node', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1, 2]);
      expect(node.isSorted, false);
      expect(node.currentChoicePair, const ChoicePair(0, 1));
      node.selectIndex(0);
      expect(node.isSorted, true);
      expect(node.sortedIndicesList, [0, 1]);
      expect(node.currentChoicePair, null);
      expect(node.children, isNotNull);
      expect(node.children!.left.isSorted, true);
      expect(node.children!.left.sortedIndicesList, isEmpty);
      expect(node.children!.right.isSorted, true);
      expect(node.children!.right.sortedIndicesList, isEmpty);
    });

    test('Select index on three item node', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1, 2, 3]);
      expect(node.isSorted, false);
      expect(node.currentChoicePair, const ChoicePair(0, 1));
      node.selectIndex(0);
      expect(node.isSorted, false);
      expect(node.currentChoicePair, const ChoicePair(0, 2));
      expect(() => node.selectIndex(1), throwsStateError);
      expect(() => node.sortedIndicesList, throwsStateError);
      expect(node.children!.left.isSorted, true);
      expect(node.children!.left.sortedIndicesList, [0, 1]);
      expect(node.children!.left.children, isNotNull);
      expect(node.children!.left.children!.left.isSorted, true);
      expect(node.children!.left.children!.left.sortedIndicesList, isEmpty);
      expect(node.children!.left.children!.right.isSorted, true);
      expect(node.children!.left.children!.right.sortedIndicesList, isEmpty);
      expect(node.children!.right.isSorted, true);
      expect(node.children!.right.sortedIndicesList, [2]);
    });
  });

  group('getChoicePair', () {
    test('Empty node', () {
      MergeSortNode node = MergeSortNode.empty();
      expect(node.currentChoicePair, null);
    });
    test('Single item node', () {
      MergeSortNode node = MergeSortNode.single(0);
      expect(node.currentChoicePair, null);
    });
    test('Two item node', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1, 2]);
      expect(node.currentChoicePair, const ChoicePair(0, 1));
      node.selectIndex(0);
      expect(node.currentChoicePair, null);
    });
    test('Three item node', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1, 2, 3]);
      expect(node.currentChoicePair, const ChoicePair(0, 1));
      expect(node.currentChoicePair, const ChoicePair(0, 1));
      node.selectIndex(0);
      expect(node.currentChoicePair, const ChoicePair(0, 2));
      node.selectIndex(2);
      expect(node.currentChoicePair, null);
    });
  });

  group('isSorted', () {
    test('Empty node', () {
      MergeSortNode node = MergeSortNode.empty();
      expect(node.isSorted, true);
    });
    test('Single item node', () {
      MergeSortNode node = MergeSortNode.single(0);
      expect(node.isSorted, true);
    });
    test('Two item node', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1, 2]);
      expect(node.isSorted, false);
      node.selectIndex(0);
      expect(node.isSorted, true);
    });
    test('Three item node', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1, 2, 3]);
      expect(node.isSorted, false);
      node.selectIndex(0);
      expect(node.isSorted, false);
      node.selectIndex(2);
      expect(node.isSorted, true);
    });
  });

  group('sortedIndicesList', () {
    test('Empty node', () {
      MergeSortNode node = MergeSortNode.empty();
      expect(node.sortedIndicesList, []);
    });
    test('Single item node', () {
      MergeSortNode node = MergeSortNode.single(0);
      expect(node.sortedIndicesList, [0]);
    });
    test('Two item node', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1, 2]);
      expect(() => node.sortedIndicesList, throwsStateError);
      node.selectIndex(0);
      expect(node.sortedIndicesList, [0, 1]);
    });
    test('Three item node', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1, 2, 3]);
      expect(() => node.sortedIndicesList, throwsStateError);
      node.selectIndex(0);
      expect(() => node.sortedIndicesList, throwsStateError);
      node.selectIndex(2);
      expect(node.sortedIndicesList, [2, 0, 1]);
    });
  });
}
