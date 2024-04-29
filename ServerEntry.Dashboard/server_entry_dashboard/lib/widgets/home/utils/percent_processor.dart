extension PercentProcessor on double {
  String toProgressString() {
    var actual = this * 100;
    var closeIn = (actual - 100).abs() < 0.05;
    var display = closeIn ? '100' : actual.toStringAsFixed(1);

    return '$display %';
  }
}
