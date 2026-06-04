import '../choice_pair.dart';
import 'merge_sort_node_children.dart';

class MergeSortNode {
  final int startIndex;
  final int endIndex;
  final List<int> _sortedIndicesList = [];
  MergeSortNodeChildren? children;
  bool _isSorted = false;

  MergeSortNode({
    required this.startIndex,
    required this.endIndex,
    required this.children,
  });

  MergeSortNode.empty()
      : startIndex = -1,
        endIndex = -1,
        children = null,
        _isSorted = true;

  MergeSortNode.single(int index)
      : startIndex = index,
        endIndex = index,
        children = null,
        _isSorted = true {
    _sortedIndicesList.add(index);
  }

  /// Named constructor for a node that is already sorted.
  /// Accepts the start and end indices and the sorted indices list.
  /// Validates that the sorted indices list is of the correct size.
  MergeSortNode.alreadySorted({
    required this.startIndex,
    required this.endIndex,
    required List<int> sortedIndicesList,
  })  : children = null,
        _isSorted = true {
    // Validate input
    if (startIndex > endIndex) {
      throw ArgumentError('startIndex must be less than or equal to endIndex');
    }
    if (sortedIndicesList.length != endIndex - startIndex + 1) {
      throw ArgumentError(
          'sortedIndicesList must have length equal to endIndex - startIndex + 1');
    }
    if (!sortedIndicesList
        .every((index) => index >= startIndex && index <= endIndex)) {
      throw ArgumentError(
          'All indices in sortedIndicesList must be within [startIndex, endIndex]');
    }

    // Add sorted indices to the internal list
    _sortedIndicesList.addAll(sortedIndicesList);
  }

  bool get isSorted => _isSorted;

  List<int> get sortedIndicesList {
    if (!isSorted) {
      throw StateError('Node is not sorted');
    }
    return List.from(_sortedIndicesList);
  }

  /// Traverse the tree to find the pair of indices that need to be compared next
  /// Returns the pair of indices if found, otherwise returns null
  ChoicePair<int>? get currentChoicePair {
    if (children == null || isSorted) {
      return null;
    }

    final MergeSortNode leftChild = children!.left;
    final MergeSortNode rightChild = children!.right;
    if (leftChild.isSorted && rightChild.isSorted) {
      final int leftIndex = leftChild._sortedIndicesList.first;
      final int rightIndex = rightChild._sortedIndicesList.first;
      return ChoicePair(leftIndex, rightIndex);
    }

    ChoicePair<int>? leftChoice = leftChild.currentChoicePair;
    if (leftChoice != null) {
      return leftChoice;
    }
    return rightChild.currentChoicePair;
  }

  int get maxChoicesLeft {
    if (children == null || isSorted) {
      return 0;
    }

    final MergeSortNode leftChild = children!.left;
    final MergeSortNode rightChild = children!.right;

    if (leftChild.isSorted && rightChild.isSorted) {
      int leftChildOptions = leftChild._sortedIndicesList.length;
      int rightChildOptions = rightChild._sortedIndicesList.length;
      return leftChildOptions + rightChildOptions - 1;
    }
    int maxOptionsAtThisNode = endIndex - startIndex;
    return maxOptionsAtThisNode +
        leftChild.maxChoicesLeft +
        rightChild.maxChoicesLeft;
  }

  /// Select an index to be added to the sorted list
  /// Recursively traverses the tree to find the index in the appropriate child
  /// If the index is found in one of the children, it is removed from the child and added to the sorted list
  /// If one of the children is empty, the sorted indices from the other child are added to the sorted list
  /// If the children are not sorted, the index is selected in the appropriate child
  void selectIndex(int index) {
    if (index < startIndex || index > endIndex) {
      throw ArgumentError('Index out of range');
    }
    if (_sortedIndicesList.contains(index)) {
      throw StateError('Index $index has already been sorted');
    }
    if (children == null) {
      throw StateError(
          'Cannot select index $index from a node with no children');
    }
    final MergeSortNode leftChild = children!.left;
    final MergeSortNode rightChild = children!.right;

    if (leftChild.isSorted && rightChild.isSorted) {
      final leftIndex = leftChild._sortedIndicesList.first;
      final rightIndex = rightChild._sortedIndicesList.first;
      // If the index is found in one of the children, remove it from the child and add it to the sorted list
      if (leftIndex == index) {
        leftChild._sortedIndicesList.removeAt(0);
      } else if (rightIndex == index) {
        rightChild._sortedIndicesList.removeAt(0);
      } else {
        throw StateError('Index not found in children');
      }
      _sortedIndicesList.add(index);
      // If one of the children is empty, add the sorted indices from the other child
      if (leftChild._sortedIndicesList.isEmpty) {
        _sortedIndicesList.addAll(rightChild._sortedIndicesList);
        rightChild._sortedIndicesList.clear();
        _isSorted = true;
      } else if (rightChild._sortedIndicesList.isEmpty) {
        _sortedIndicesList.addAll(leftChild._sortedIndicesList);
        leftChild._sortedIndicesList.clear();
        _isSorted = true;
      }
    }
    // If the children are not sorted, recursively select the index in the appropriate child
    else if (index <= (startIndex + endIndex) ~/ 2) {
      leftChild.selectIndex(index);
    } else {
      rightChild.selectIndex(index);
    }
  }

  /// Returns indices that are already known to be less preferred than [index]
  /// based on choices made so far in this node's merge process.
  ///
  /// This method only returns relationships that can be inferred from the
  /// current partial state of the merge tree. If [index] has not participated
  /// in enough comparisons yet, the returned list may be incomplete. 
  ///
  /// Important:
  /// - The returned collection is not sorted and does not imply any ordering
  ///   among the returned indices.
  /// - The result should be treated as a set of known-lower indices.
  ///
  /// Behavior by state:
  /// - If [index] is already in this node's `_sortedIndicesList`, all later
  ///   indices in that list are considered known less-than.
  /// - If this node still has children with remaining candidates, those
  ///   candidates are included as known less-than for indices already placed in
  ///   this node's sorted list.
  /// - If [index] is not in this node's sorted list, the lookup recurses into
  ///   the child subtree that contains [index].
  ///
  /// Throws an [ArgumentError] if [index] is outside this node's
  /// `[startIndex, endIndex]` range.
  Iterable<int> getIndicesOfKnownLowerItems(int index) {
    // If the index is out of range, throw an error
    if (index < startIndex || index > endIndex) {
      throw ArgumentError('Index out of range');
    }

    // If the index is already in our sorted list, then we can assume that
    // a) all indices that come after it in the sorted list are less than it, and
    // b) all indicies that remain in either child node are also less than it.
    List<int> knownLowerIndices = [];
    final int indexPosition = _sortedIndicesList.indexOf(index);
    if (indexPosition != -1) {
      knownLowerIndices
          .addAll(_sortedIndicesList.sublist(indexPosition + 1));
      if (children != null) {
        knownLowerIndices.addAll(children!.left._sortedIndicesList);
        knownLowerIndices.addAll(children!.right._sortedIndicesList);
      }
    } else if (children != null) {
      // If the index is not in our sorted list, then we determine which child node it will be in and recursively call getKnownLessThanIndices on that child node
      if (index <= (startIndex + endIndex) ~/ 2) {
        knownLowerIndices
            .addAll(children!.left.getIndicesOfKnownLowerItems(index));
      } else {
        knownLowerIndices
            .addAll(children!.right.getIndicesOfKnownLowerItems(index));
      }
    }

    return knownLowerIndices;
  }

  static MergeSortNode buildMergeSortTree(List<dynamic> list) {
    return _buildMergeSortTree(0, list.length - 1);
  }

  static MergeSortNode _buildMergeSortTree(int startIndex, int endIndex) {
    if (endIndex < startIndex) {
      return MergeSortNode.empty();
    } else if (startIndex == endIndex) {
      return MergeSortNode.single(startIndex);
    } else {
      final int midIndex = (startIndex + endIndex) ~/ 2;
      final MergeSortNode leftChild = _buildMergeSortTree(startIndex, midIndex);
      final MergeSortNode rightChild =
          _buildMergeSortTree(midIndex + 1, endIndex);
      return MergeSortNode(
        startIndex: startIndex,
        endIndex: endIndex,
        children: MergeSortNodeChildren(left: leftChild, right: rightChild),
      );
    }
  }

  static MergeSortNode buildPartiallySortedTree(
      int unsortedLength, List<MergeSortNode> sortedNodes) {
    if (sortedNodes.isEmpty) {
      return _buildMergeSortTree(0, unsortedLength - 1);
    }

    int previousEndIndex = -1;
    for (MergeSortNode node in sortedNodes) {
      if (node.startIndex <= previousEndIndex) {
        throw ArgumentError('Sorted nodes must not overlap');
      }
      if (previousEndIndex != -1 && node.startIndex != previousEndIndex + 1) {
        throw ArgumentError('Sorted nodes must be contiguous');
      }
      previousEndIndex = node.endIndex;
    }

    List<MergeSortNode> allNodes = [
      if (unsortedLength > 0) _buildMergeSortTree(0, unsortedLength - 1),
      ...sortedNodes,
    ];

    while (allNodes.length > 1) {
      List<MergeSortNode> newNodes = [];
      for (int i = 0; i < allNodes.length; i += 2) {
        if (i + 1 < allNodes.length) {
          newNodes.add(MergeSortNode(
            startIndex: allNodes[i].startIndex,
            endIndex: allNodes[i + 1].endIndex,
            children: MergeSortNodeChildren(
                left: allNodes[i], right: allNodes[i + 1]),
          ));
        } else {
          newNodes.add(allNodes[i]);
        }
      }
      allNodes = newNodes;
    }

    return allNodes[0];
  }

  static String prettyPrint(MergeSortNode? node,
      [String top = '', String root = '', String bottom = '']) {
    if (node == null) {
      return '$root null\n';
    }
    if (node.isSorted) {
      return '$root ${node._sortedIndicesList}\n';
    }
    final right =
        prettyPrint(node.children?.right, '$top ', '$top┌──', '$top│ ');
    final left =
        prettyPrint(node.children?.left, '$bottom│ ', '$bottom└──', '$bottom ');
    String nodeString =
        "(${node.startIndex} - ${node.endIndex}) => ${node._sortedIndicesList}";
    if (node.isSorted) {
      nodeString = node._sortedIndicesList.toString();
    }

    return '$right$root$nodeString\n$left';
  }

  @override
  String toString() {
    return prettyPrint(this);
  }
}
