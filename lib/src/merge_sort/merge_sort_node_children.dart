import 'package:flutter/foundation.dart';

import 'merge_sort_node.dart';

@immutable
class MergeSortNodeChildren {
  final MergeSortNode left;
  final MergeSortNode right;

  const MergeSortNodeChildren({required this.left, required this.right});
}