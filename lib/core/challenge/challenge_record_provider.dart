import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 오늘의 챌린지 항목 정의 (대시보드 + 캘린더에서 공유)
class ChallengeItem {
  final String emoji;
  final String title;
  final String desc;
  const ChallengeItem({
    required this.emoji,
    required this.title,
    required this.desc,
  });
}

/// 앱 전역 챌린지 목록 (총 4개)
const List<ChallengeItem> kDailyChallenges = [
  ChallengeItem(emoji: '🚭', title: '담배 안 피웠나요?', desc: '금연 챌린지'),
  ChallengeItem(emoji: '🚶', title: '30분 걸었나요?', desc: '유산소 운동'),
  ChallengeItem(emoji: '💧', title: '물 8잔 마셨나요?', desc: '수분 섭취'),
  ChallengeItem(emoji: '🥦', title: '채소 먹었나요?', desc: '균형 잡힌 식단'),
];

/// 날짜 키 포맷: "yyyy-MM-dd"
String dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// 날짜별 완료된 챌린지 인덱스 집합을 관리
/// State: Map(날짜 문자열, 완료된 챌린지 인덱스 집합)
class ChallengeRecordNotifier
    extends StateNotifier<Map<String, Set<int>>> {
  ChallengeRecordNotifier() : super({}) {
    _initSampleData();
  }

  /// 지난 30일 샘플 데이터 (데모용)
  void _initSampleData() {
    final now = DateTime.now();
    final seed = <String, Set<int>>{};

    for (int i = 30; i >= 1; i--) {
      final date = now.subtract(Duration(days: i));
      final key = dateKey(date);
      final completed = <int>{};

      // 결정적 패턴: 최근일수록 달성률 높게
      final threshold = i > 20 ? 50 : (i > 10 ? 70 : 85);
      for (int j = 0; j < kDailyChallenges.length; j++) {
        final hash = (date.day * 31 + j * 17 + i * 13) % 100;
        if (hash < threshold) completed.add(j);
      }
      if (completed.isNotEmpty) seed[key] = completed;
    }
    state = seed;
  }

  /// 특정 날짜의 챌린지 완료 토글
  void toggle(DateTime date, int index) {
    final key = dateKey(date);
    final next = Map<String, Set<int>>.from(state);
    final set = Set<int>.from(next[key] ?? {});

    if (set.contains(index)) {
      set.remove(index);
    } else {
      set.add(index);
    }

    if (set.isEmpty) {
      next.remove(key);
    } else {
      next[key] = set;
    }
    state = next;
  }

  /// 특정 날짜에서 완료된 챌린지 인덱스 집합
  Set<int> completedFor(DateTime date) => state[dateKey(date)] ?? {};

  /// 완료 개수
  int completedCount(DateTime date) => completedFor(date).length;

  /// 전체 완료 여부
  bool isFullyCompleted(DateTime date) =>
      completedCount(date) >= kDailyChallenges.length;

  /// 해당 월의 통계 반환
  ({int activeDays, int fullDays, int totalCompleted}) monthStats(
      DateTime month) {
    final daysInMonth =
        DateTime(month.year, month.month + 1, 0).day;
    final today = DateTime.now();
    int activeDays = 0, fullDays = 0, totalCompleted = 0;

    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      if (date.isAfter(today)) break;
      final count = completedCount(date);
      if (count > 0) activeDays++;
      if (count >= kDailyChallenges.length) fullDays++;
      totalCompleted += count;
    }
    return (
      activeDays: activeDays,
      fullDays: fullDays,
      totalCompleted: totalCompleted,
    );
  }
}

final challengeRecordProvider = StateNotifierProvider<
    ChallengeRecordNotifier, Map<String, Set<int>>>(
  (ref) => ChallengeRecordNotifier(),
);
