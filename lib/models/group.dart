class BlockStatus {
  static const noBlocked = BlockStatus._(0);
  static const allBlocked = BlockStatus._(1);
  static const someBlocked = BlockStatus._(2);

  final int value;
  const BlockStatus._(this.value);
}

class Group {
  String name;
  BlockStatus status = BlockStatus.noBlocked;

  Group({required this.name});

  void block() {
    status = BlockStatus.allBlocked;
  }

  void unBlock() {
    status = BlockStatus.noBlocked;
  }

  double todaysWaterUsage() {
    return 16;
  }

  double yesterdayWaterUsage() {
    return 32;
  }

  double actWaterUsage() {
    return 2.5;
  }
}
