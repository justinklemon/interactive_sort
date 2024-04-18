import 'dart:collection';
import 'dart:convert';

import 'node_type.dart';

const stepIndexKey = 'stepIndex';
const parentStepIndexKey = 'parentStepIndex';
const nodeTypeKey = 'nodeType';
const startIndexKey = '_startIndex';
const endIndexKey = '_endIndex';
const sortedIndicesListKey = '_sortedList';
const leftItemIndicesKey = '_leftItemIndices';
const rightItemIndicesKey = '_rightItemIndices';

class MergeSortStep {
  final int stepIndex;
  final int? parentStepIndex;
  final int _startIndex;
  final int _endIndex;
  final List<int> _sortedIndicesList = [];
  final NodeType nodeType;
  List<int>? _leftItemIndices;
  List<int>? _rightItemIndices;

  MergeSortStep({
    required this.stepIndex,
    required this.parentStepIndex,
    required this.nodeType,
    required int startIndex,
    required int endIndex,
  })  : _startIndex = startIndex,
        _endIndex = endIndex {
    if (startIndex > endIndex) {
      _leftItemIndices = [];
      _rightItemIndices = [];
    } else if (startIndex == endIndex) {
      _leftItemIndices = [];
      _rightItemIndices = [];
      _sortedIndicesList.add(startIndex);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      stepIndexKey: stepIndex,
      parentStepIndexKey: parentStepIndex,
      nodeTypeKey:
          nodeType.toString(), // Convert nodeType to a string representation
      startIndexKey: _startIndex,
      endIndexKey: _endIndex,
      sortedIndicesListKey: _sortedIndicesList,
      leftItemIndicesKey: _leftItemIndices,
      rightItemIndicesKey: _rightItemIndices
    };
  }

  MergeSortStep.fromJson(Map<String, dynamic> json)
      : stepIndex = json[stepIndexKey],
        parentStepIndex = json[parentStepIndexKey],
        nodeType = NodeType.values
            .firstWhere((e) => e.toString() == json[nodeTypeKey]),
        _startIndex = json[startIndexKey],
        _endIndex = json[endIndexKey],
        _leftItemIndices = json[leftItemIndicesKey]?.cast<int>(),
        _rightItemIndices = json[rightItemIndicesKey]?.cast<int>() {
    _sortedIndicesList.addAll(json[sortedIndicesListKey].cast<int>());
  }

  static Map<int, MergeSortStep> generateTree<T>({required List<T> list}) {
    int stepIndex = 0;
    final Map<int, MergeSortStep> steps = {};
    final queue = Queue<MergeSortStep>();

    void addStep(MergeSortStep step) {
      steps[step.stepIndex] = step;
      queue.add(step);
    }

    final root = MergeSortStep(
      stepIndex: stepIndex,
      parentStepIndex: null,
      nodeType: NodeType.root,
      startIndex: 0,
      endIndex: list.length - 1,
    );
    addStep(root);

    while (queue.isNotEmpty) {
      final currentStep = queue.removeFirst();
      if (currentStep.isSorted) {
        if (currentStep.parentStepIndex != null) {
          final parentStep = steps[currentStep.parentStepIndex!];
          parentStep!.receiveChildResult(
              currentStep._sortedIndicesList, currentStep.nodeType);
          steps.remove(currentStep.stepIndex);
        }
        continue;
      }

      final middleIndex =
          (currentStep._startIndex + currentStep._endIndex) ~/ 2;
      final leftChild = currentStep._createLeftChild(++stepIndex, middleIndex);
      final rightChild =
          currentStep._createRightChild(++stepIndex, middleIndex);

      addStep(leftChild);
      addStep(rightChild);
    }
    return steps;
  }

  MergeSortStep _createLeftChild(int leftChildStepIndex, int midIndex) {
    return MergeSortStep(
      stepIndex: leftChildStepIndex,
      parentStepIndex: stepIndex,
      nodeType: NodeType.leftBranch,
      startIndex: _startIndex,
      endIndex: midIndex,
    );
  }

  MergeSortStep _createRightChild(int rightChildStepIndex, int midIndex) {
    return MergeSortStep(
      stepIndex: rightChildStepIndex,
      parentStepIndex: stepIndex,
      nodeType: NodeType.rightBranch,
      startIndex: midIndex + 1,
      endIndex: _endIndex,
    );
  }

  void receiveChildResult(List<int> childrenSortedIndices, NodeType childType) {
    if (childType == NodeType.leftBranch) {
      _leftItemIndices = childrenSortedIndices;
    } else if (childType == NodeType.rightBranch) {
      _rightItemIndices = childrenSortedIndices;
    } else {
      throw ArgumentError('Invalid child type');
    }
  }

  bool get isSorted {
    return (_leftItemIndices?.isEmpty ?? false) &&
        (_rightItemIndices?.isEmpty ?? false);
  }

  List<int> get sortedIndicesList {
    if (!isSorted) {
      throw StateError('Step is not sorted');
    }
    return _sortedIndicesList;
  }

  int get leftItemIndex {
    if (_leftItemIndices == null) {
      throw StateError('Left child has not been sorted yet');
    } else if (_leftItemIndices!.isEmpty) {
      throw StateError('Left child is empty');
    }
    return _leftItemIndices![0];
  }

  int get rightItemIndex {
    if (_rightItemIndices == null) {
      throw StateError('Right child has not been sorted yet');
    } else if (_rightItemIndices!.isEmpty) {
      throw StateError('Right child is empty');
    }
    return _rightItemIndices![0];
  }

  void selectLeftItem() {
    if (_leftItemIndices == null) {
      throw StateError('Left child has not been sorted yet');
    } else if (_leftItemIndices!.isEmpty) {
      throw StateError('Left child is empty');
    }
    _sortedIndicesList.add(_leftItemIndices!.removeAt(0));
    if (_leftItemIndices!.isEmpty) {
      _sortedIndicesList.addAll(_rightItemIndices!);
      _rightItemIndices!.clear();
    }
  }

  void selectRightItem() {
    if (_rightItemIndices == null) {
      throw StateError('Right child has not been sorted yet');
    } else if (_rightItemIndices!.isEmpty) {
      throw StateError('Right child is empty');
    }
    _sortedIndicesList.add(_rightItemIndices!.removeAt(0));
    if (_rightItemIndices!.isEmpty) {
      _sortedIndicesList.addAll(_leftItemIndices!);
      _leftItemIndices!.clear();
    }
  }

  @override
  String toString() {
    return 'MergeSortStep${const JsonEncoder.withIndent('  ').convert(toJson())}';
  }
}
