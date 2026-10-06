import 'package:ergonoworkcoah/features/gamification/domain/entities/user_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('level thresholds keep level 1 until 500 XP and progress stays finite',
      () {
    const initial = UserProgress(userId: 'person');
    for (final entry
        in {0: 1, 50: 1, 499: 1, 500: 2, 1499: 2, 1500: 3}.entries) {
      final progress = initial.addXP(entry.key);
      expect(progress.currentLevel, entry.value, reason: '${entry.key} XP');
      expect(progress.levelProgress.isFinite, isTrue);
      expect(progress.levelProgress, inInclusiveRange(0, 1));
    }
    expect(initial.addXP(500).xpInCurrentLevel, 0);
    expect(initial.addXP(500).xpForNextLevel, 1000);
  });
}
