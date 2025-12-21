import 'dart:math';

T weightedPick<T>(
  List<T> items,
  int Function(T) weightFn,
  Random rng,
) {
  final total = items.fold<int>(0, (s, i) => s + weightFn(i));
  final roll = rng.nextInt(total);

  int acc = 0;
  for (final item in items) {
    acc += weightFn(item);
    if (roll < acc) return item;
  }
  return items.last;
}
