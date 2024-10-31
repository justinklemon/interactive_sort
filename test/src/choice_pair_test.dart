import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_sort/src/choice_pair.dart';

void main() {
  test('ChoicePair equality', () {
    const pair1 = ChoicePair(1, 2);
    const pair2 = ChoicePair(1, 2);
    const pair3 = ChoicePair(2, 1);

    expect(pair1, pair2);
    expect(pair1, pair3);
  });

  group('ChoicePair hashcode', () {
    test('ChoicePair hashcode with integers', () {
      const pair1 = ChoicePair(3, 7);
      const pair2 = ChoicePair(3, 7);
      const pair3 = ChoicePair(7, 3);

      expect(pair1.hashCode, pair2.hashCode);
      expect(pair1.hashCode, pair3.hashCode);
    });

    test('ChoicePair hashcode with strings', () {
      const pair1 = ChoicePair('a', 'b');
      const pair2 = ChoicePair('a', 'b');
      const pair3 = ChoicePair('b', 'a');

      expect(pair1.hashCode, pair2.hashCode);
      expect(pair1.hashCode, pair3.hashCode);
    });
  });
}