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

  group('maxChoicesLeft after constructing', () {
    test('Empty node', () {
      MergeSortNode node = MergeSortNode.empty();
      expect(node.maxChoicesLeft, 0);
    });
    test('Single item node', () {
      MergeSortNode node = MergeSortNode.single(0);
      expect(node.maxChoicesLeft, 0);
    });
    test('Two item node', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1, 2]);
      expect(node.maxChoicesLeft, 1);
    });
    test('Three item node', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1, 2, 3]);
      expect(node.maxChoicesLeft, 3);
    });
    test('Four item node', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1, 2, 3, 4]);
      expect(node.maxChoicesLeft, 5);
    });
    test('Five item node', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1, 2, 3, 4, 5]);
      expect(node.maxChoicesLeft, 8);
    });
    test('Six item node', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1, 2, 3, 4, 5, 6]);
      expect(node.maxChoicesLeft, 11);
    });
    test('Seven item node', () {
      MergeSortNode node =
          MergeSortNode.buildMergeSortTree([1, 2, 3, 4, 5, 6, 7]);
      expect(node.maxChoicesLeft, 14);
    });
  });

  group('maxChoicesLeft updates as choices are made', () {
    test('Two item node', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1, 2]);
      expect(node.maxChoicesLeft, 1);
      node.selectIndex(0);
      expect(node.maxChoicesLeft, 0);
    });
    test('Three item node, pick left, then right', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1, 2, 3]);
      expect(node.maxChoicesLeft, 3);
      node.selectIndex(0);
      expect(node.maxChoicesLeft, 2);
      node.selectIndex(2);
      expect(node.maxChoicesLeft, 0);
    });

    test('Three item node, pick left every time', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1, 2, 3]);
      expect(node.maxChoicesLeft, 3);
      node.selectIndex(0);
      expect(node.maxChoicesLeft, 2);
      node.selectIndex(0);
      expect(node.maxChoicesLeft, 1);
      node.selectIndex(1);
      expect(node.maxChoicesLeft, 0);
    });
    test('Four item node, pick left every time', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1, 2, 3, 4]);
      expect(node.maxChoicesLeft, 5);
      node.selectIndex(0);
      expect(node.maxChoicesLeft, 4);
      node.selectIndex(2);
      expect(node.maxChoicesLeft, 3);
      node.selectIndex(0);
      expect(node.maxChoicesLeft, 2);
      node.selectIndex(1);
      expect(node.maxChoicesLeft, 0);
    });
    test('Four item node, pick longest path', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1, 2, 3, 4]);
      expect(node.maxChoicesLeft, 5);
      node.selectIndex(0);
      expect(node.maxChoicesLeft, 4);
      node.selectIndex(2);
      expect(node.maxChoicesLeft, 3);
      node.selectIndex(0);
      expect(node.maxChoicesLeft, 2);
      node.selectIndex(2);
      expect(node.maxChoicesLeft, 1);
      node.selectIndex(1);
      expect(node.maxChoicesLeft, 0);
    });
    test('Five item node with more efficient choices', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1, 2, 3, 4, 5]);
      expect(node.maxChoicesLeft, 8);
      node.selectIndex(0);
      expect(node.maxChoicesLeft, 7);
      node.selectIndex(4);
      expect(node.maxChoicesLeft, 6);
      node.selectIndex(2);
      expect(node.maxChoicesLeft, 4);
      node.selectIndex(4);
      expect(node.maxChoicesLeft, 3);
      node.selectIndex(3);
      expect(node.maxChoicesLeft, 0);
    });
    test('Five item node with less efficient choices', () {
      MergeSortNode node = MergeSortNode.buildMergeSortTree([1, 2, 3, 4, 5]);
      expect(node.maxChoicesLeft, 8);
      node.selectIndex(0);
      expect(node.maxChoicesLeft, 7);
      node.selectIndex(0);
      expect(node.maxChoicesLeft, 6);
      node.selectIndex(4);
      expect(node.maxChoicesLeft, 5);
      node.selectIndex(1);
      expect(node.maxChoicesLeft, 4);
      node.selectIndex(0);
      expect(node.maxChoicesLeft, 3);
      node.selectIndex(1);
      expect(node.maxChoicesLeft, 2);
      node.selectIndex(4);
      expect(node.maxChoicesLeft, 1);
      node.selectIndex(3);
      expect(node.maxChoicesLeft, 0);
    });
  });


  group('MergeSortNode.alreadySorted', () {
    test('creates a valid sorted node with correct indices', () {
      final node = MergeSortNode.alreadySorted(
        startIndex: 2,
        endIndex: 4,
        sortedIndicesList: [2, 3, 4],
      );

      expect(node.startIndex, 2);
      expect(node.endIndex, 4);
      expect(node.isSorted, true);
      expect(node.children, null);
      expect(node.sortedIndicesList, [2, 3, 4]);
    });

    test('throws ArgumentError for invalid startIndex and endIndex', () {
      expect(
        () => MergeSortNode.alreadySorted(
          startIndex: 4,
          endIndex: 2,
          sortedIndicesList: [2, 3, 4],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for incorrect sortedIndicesList length', () {
      expect(
        () => MergeSortNode.alreadySorted(
          startIndex: 2,
          endIndex: 4,
          sortedIndicesList: [2, 3],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for out-of-range indices in sortedIndicesList',
        () {
      expect(
        () => MergeSortNode.alreadySorted(
          startIndex: 2,
          endIndex: 4,
          sortedIndicesList: [1, 2, 3],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('works with single element', () {
      final node = MergeSortNode.alreadySorted(
        startIndex: 5,
        endIndex: 5,
        sortedIndicesList: [5],
      );

      expect(node.startIndex, 5);
      expect(node.endIndex, 5);
      expect(node.isSorted, true);
      expect(node.children, null);
      expect(node.sortedIndicesList, [5]);
    });

    test('toString works correctly for already sorted node', () {
      final node = MergeSortNode.alreadySorted(
        startIndex: 2,
        endIndex: 4,
        sortedIndicesList: [2, 3, 4],
      );

      expect(node.toString(), ' [2, 3, 4]\n');
    });
  });
}
