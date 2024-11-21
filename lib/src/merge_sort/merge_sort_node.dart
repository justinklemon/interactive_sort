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
    
    if (leftChild.isSorted && rightChild.isSorted){
      int leftChildOptions = leftChild._sortedIndicesList.length;
      int rightChildOptions = rightChild._sortedIndicesList.length;
      return leftChildOptions + rightChildOptions - 1;
    }
    int maxOptionsAtThisNode = endIndex - startIndex;
    return maxOptionsAtThisNode + leftChild.maxChoicesLeft + rightChild.maxChoicesLeft;
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
