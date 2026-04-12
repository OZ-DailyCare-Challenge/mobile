import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'endpoints.dart';
import '../models/health_models.dart';

class HealthService {
  final ApiClient _client;

  HealthService(this._client);

  // ── 건강검진 기록 ────────────────────────────────────

  /// POST /api/v1/health/records
  Future<HealthRecordModel> createRecord({
    required int systolicBp,
    required int diastolicBp,
    required int totalCholesterol,
    required int glucose,
    required double height,
    required double weight,
    required bool smokeYn,
    required bool alcoholYn,
    required bool exerciseYn,
  }) async {
    final resp = await _client.post(
      Endpoints.healthRecords,
      data: {
        'systolic_bp': systolicBp,
        'diastolic_bp': diastolicBp,
        'total_cholesterol': totalCholesterol,
        'glucose': glucose,
        'height': height,
        'weight': weight,
        'smoke_yn': smokeYn,
        'alcohol_yn': alcoholYn,
        'exercise_yn': exerciseYn,
      },
    );
    return HealthRecordModel.fromJson(resp.data as Map<String, dynamic>);
  }

  /// GET /api/v1/health/records/{record_id}
  Future<HealthRecordModel> getRecord(int recordId) async {
    final resp = await _client.get(Endpoints.healthRecord(recordId));
    return HealthRecordModel.fromJson(resp.data as Map<String, dynamic>);
  }

  // ── AI 분석 (회원) ────────────────────────────────────

  /// POST /api/v1/health/analysis/{record_id}
  /// 캐시 HIT → AnalysisResult(status: success, data...)
  /// 캐시 MISS → AnalysisResult(status: pending, taskId: ...)
  Future<AnalysisResult> requestAnalysis(int recordId) async {
    final resp =
        await _client.post(Endpoints.analysis(recordId));
    return AnalysisResult.fromJson(resp.data as Map<String, dynamic>);
  }

  /// GET /api/v1/health/analysis/{task_id}/wait  (long-poll 최대 30초)
  /// pending 반환 시 클라이언트가 즉시 재요청해야 함
  Future<AnalysisResult> waitForAnalysis(String taskId) async {
    final resp =
        await _client.get(Endpoints.analysisWait(taskId));
    return AnalysisResult.fromJson(resp.data as Map<String, dynamic>);
  }

  // ── AI 분석 (비회원) ──────────────────────────────────

  /// POST /api/v1/health/analysis/guest
  Future<AnalysisResult> requestGuestAnalysis({
    required String birthDate, // YYYY-MM-DD
    required String gender, // M | F
    required double height,
    required double weight,
    required int systolicBp,
    required int diastolicBp,
    required int totalCholesterol,
    required int glucose,
    required bool smokeYn,
    required bool alcoholYn,
    required bool exerciseYn,
  }) async {
    final resp = await _client.post(
      Endpoints.analysisGuest,
      data: {
        'birth_date': birthDate,
        'gender': gender,
        'height': height,
        'weight': weight,
        'systolic_bp': systolicBp,
        'diastolic_bp': diastolicBp,
        'total_cholesterol': totalCholesterol,
        'glucose': glucose,
        'smoke_yn': smokeYn,
        'alcohol_yn': alcoholYn,
        'exercise_yn': exerciseYn,
      },
    );
    return AnalysisResult.fromJson(resp.data as Map<String, dynamic>);
  }
}

final healthServiceProvider = Provider<HealthService>((ref) {
  return HealthService(ref.read(apiClientProvider));
});
