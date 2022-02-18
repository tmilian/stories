extension IntExt on int {
  int min(int value) {
    return this < value ? value : this;
  }

  int max(int value) {
    return this > value ? value : this;
  }
}

extension NumExt on num {
  bool between(num start, num end) {
    return start <= this && this <= end;
  }
}
