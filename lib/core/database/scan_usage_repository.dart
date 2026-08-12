import 'package:hive/hive.dart';

import 'box_names.dart';

/// Tracks the free-tier scan quota: [freeScanLimit] scans per rolling
/// [windowDuration]. A single window-start timestamp + used count is used
/// (rather than per-scan timestamps) — the whole quota resets together,
/// 48h after the first scan in the current window.
class ScanUsageRepository {
  static const int freeScanLimit = 2;
  static const Duration windowDuration = Duration(hours: 48);

  static const _windowStartKey = 'scan_usage_window_start';
  static const _usedCountKey = 'scan_usage_count';

  Box get _box => Hive.box(BoxNames.settings);

  DateTime? get _windowStart {
    final millis = _box.get(_windowStartKey) as int?;
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  int get _usedCount => _box.get(_usedCountKey, defaultValue: 0) as int;

  /// Clears the window if 48h have elapsed. Called before every read/write
  /// so callers always see fresh state without needing a background timer.
  void _syncWindow() {
    final start = _windowStart;
    if (start == null) return;
    if (DateTime.now().difference(start) >= windowDuration) {
      _box.delete(_windowStartKey);
      _box.put(_usedCountKey, 0);
    }
  }

  int remainingScans() {
    _syncWindow();
    return (freeScanLimit - _usedCount).clamp(0, freeScanLimit);
  }

  bool get canScan => remainingScans() > 0;

  /// Time until the quota fully resets, or null if a full quota is already
  /// available (no window currently open).
  Duration? timeUntilReset() {
    _syncWindow();
    final start = _windowStart;
    if (start == null) return null;
    final remaining = start.add(windowDuration).difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Records one used scan; opens a new window if none is active.
  Future<void> recordScan() async {
    _syncWindow();
    if (_windowStart == null) {
      await _box.put(_windowStartKey, DateTime.now().millisecondsSinceEpoch);
    }
    await _box.put(_usedCountKey, _usedCount + 1);
  }
}
