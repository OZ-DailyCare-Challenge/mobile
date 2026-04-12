import 'package:flutter/foundation.dart';

// ── 건강검진 기록 ────────────────────────────────────────

@immutable
class HealthRecordModel {
  final int id;
  final int userId;
  final int systolicBp;
  final int diastolicBp;
  final int totalCholesterol;
  final int glucose;
  final double height;
  final double weight;
  final double bmi;
  final bool smokeYn;
  final bool alcoholYn;
  final bool exerciseYn;
  final String createdAt;

  const HealthRecordModel({
    required this.id,
    required this.userId,
    required this.systolicBp,
    required this.diastolicBp,
    required this.totalCholesterol,
    required this.glucose,
    required this.height,
    required this.weight,
    required this.bmi,
    required this.smokeYn,
    required this.alcoholYn,
    required this.exerciseYn,
    required this.createdAt,
  });

  factory HealthRecordModel.fromJson(Map<String, dynamic> json) {
    return HealthRecordModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      systolicBp: json['systolic_bp'] as int,
      diastolicBp: json['diastolic_bp'] as int,
      totalCholesterol: json['total_cholesterol'] as int,
      glucose: json['glucose'] as int,
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
      smokeYn: json['smoke_yn'] as bool,
      alcoholYn: json['alcohol_yn'] as bool,
      exerciseYn: json['exercise_yn'] as bool,
      createdAt: json['created_at'] as String,
    );
  }
}

// ── AI 분석 결과 ─────────────────────────────────────────

@immutable
class Ml1Predict {
  /// 심혈관 위험도 (%)
  final double riskPercent;

  /// 낮음 / 보통 / 중간 / 높음 / 매우높음
  final String riskGrade;

  /// 심혈관 나이
  final int heartAge;

  /// 캐릭터 단계 (1~5)
  final int characterStage;

  /// 상위 3개 위험 요인
  final List<String> topRiskFactors;

  const Ml1Predict({
    required this.riskPercent,
    required this.riskGrade,
    required this.heartAge,
    required this.characterStage,
    required this.topRiskFactors,
  });

  factory Ml1Predict.fromJson(Map<String, dynamic> json) {
    return Ml1Predict(
      riskPercent: (json['risk_percent'] as num).toDouble(),
      riskGrade: json['risk_grade'] as String,
      heartAge: json['heart_age'] as int,
      characterStage: json['character_stage'] as int,
      topRiskFactors: (json['top_risk_factors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }
}

@immutable
class Ml1Comment {
  final String evaluation;
  final String? alert;
  final List<String> missions;
  final String encouragement;

  const Ml1Comment({
    required this.evaluation,
    this.alert,
    required this.missions,
    required this.encouragement,
  });

  factory Ml1Comment.fromJson(Map<String, dynamic> json) {
    return Ml1Comment(
      evaluation: json['evaluation'] as String,
      alert: json['alert'] as String?,
      missions: (json['missions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      encouragement: json['encouragement'] as String,
    );
  }
}

@immutable
class AnalysisResult {
  /// 'success' | 'pending' | 'failed'
  final String status;

  /// MISS 상태일 때 Celery task ID
  final String? taskId;

  final Ml1Predict? ml1Predict;
  final Ml1Comment? ml1Comment;
  final String? error;

  const AnalysisResult({
    required this.status,
    this.taskId,
    this.ml1Predict,
    this.ml1Comment,
    this.error,
  });

  bool get isPending => status == 'pending';
  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed';

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String? ?? 'pending';

    // MISS → pending + task_id
    if (json.containsKey('task_id')) {
      return AnalysisResult(
        status: status,
        taskId: json['task_id'] as String?,
      );
    }

    // SUCCESS → data object
    final data = json['data'] as Map<String, dynamic>?;
    Ml1Predict? predict;
    Ml1Comment? comment;
    if (data != null) {
      final predictJson =
          data['ml1_predict'] as Map<String, dynamic>?;
      final commentJson =
          data['ml1_comment'] as Map<String, dynamic>?;
      if (predictJson != null) predict = Ml1Predict.fromJson(predictJson);
      if (commentJson != null) comment = Ml1Comment.fromJson(commentJson);
    }

    return AnalysisResult(
      status: status,
      ml1Predict: predict,
      ml1Comment: comment,
      error: json['error'] as String?,
    );
  }
}
