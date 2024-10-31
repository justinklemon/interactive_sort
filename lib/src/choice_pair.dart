import 'package:flutter/foundation.dart';

@immutable
class ChoicePair<T> {
  final T left;
  final T right;

  const ChoicePair(this.left, this.right);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChoicePair &&
          runtimeType == other.runtimeType &&
          // if this.left and other.left are equal AND this.right and other.right are equal
          // OR if this.left and other.right are equal AND this.right and other.left are equal
          ((left == other.left && right == other.right) ||
          (left == other.right && right == other.left));

  @override
  int get hashCode => left.hashCode ^ right.hashCode;

  @override
  String toString() => 'ChoicePair($left, $right)';
}