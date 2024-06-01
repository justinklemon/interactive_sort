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
          left == other.left &&
          right == other.right;

  @override
  int get hashCode => left.hashCode ^ right.hashCode;
}