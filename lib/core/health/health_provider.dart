import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/health_service.dart';
import '../models/health_models.dart';

// ── 건강 입력 폼 상태 ──────────────────────────────────

@immutable
class HealthInputForm {
  final int? systolicBp;
  final int? diastolicBp;
  final int? totalCholesterol;
  final int? glucose;
  final double? height;
  final double? weight;
  final bool smokeYn;
  final bool alcoholYn;
  final bool exerciseYn;

  // 비회원 추가 필드
  final String? birthDate; // YYYY-MM-DD
  final String gender; // M | F

  const HealthInputForm({
    this.systolicBp,
    this.diastolicBp,
    this.totalCholesterol,
    this.glucose,
    this.height,
    this.weight,
    this.smokeYn = false,
    this.alcoholYn = false,
    this.exerciseYn = false,
    this.birthDate,
    this.gender = 'M',
  });

  bool get isValid =>
      systolicBp != null &&
      diastolicBp != null &&
      totalCholesterol != null &&
      glucose != null &&
      height != null &&
      weight != null;

  HealthInputForm copyWith({
    int? systolicBp,
    int? diastolicBp,
    int? totalCholesterol,
    int? glucose,
    double? height,
    double? weight,
    bool? smokeYn,
    bool? alcoholYn,
    bool? exerciseYn,
    String? birthDate,
    String? gender,
  }) {
    return HealthInputForm(
      systolicBp: systolicBp ?? this.systolicBp,
      diastolicBp: diastolicBp ?? this.diastolicBp,
      totalCholesterol: totalCholesterol ?? this.totalCholesterol,
      glucose: glucose ?? this.glucose,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      smokeYn: smokeYn ?? this.smokeYn,
      alcoholYn: alcoholYn ?? this.alcoholYn,
      exerciseYn: exerciseYn ?? this.exerciseYn,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
    );
  }
}

// ── 건강 분석 전체 상태 ────────────────────────────────

@immutable
class HealthState {
  final HealthInputForm form;
  final HealthRecordModel? record;
  final AnalysisResult? analysisResult;
  final bool isSubmitting;
  final bool isAnalyzing;
  final String? error;

  const HealthState({
    this.form = const HealthInputForm(),
    this.record,
    this.analysisResult,
    this.isSubmitting = false,
    this.isAnalyzing = false,
    this.error,
  });

  HealthState copyWith({
    HealthInputForm? form,
    HealthRecordModel? record,
    AnalysisResult? analysisResult,
    bool? isSubmitting,
    bool? isAnalyzing,
    String? error,
  }) {
    return HealthState(
      form: form ?? this.form,
      record: record ?? this.record,
      analysisResult: analysisResult ?? this.analysisResult,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      error: error,
    );
  }
}

// ── 노티파이어 ─────────────────────────────────────────

class HealthNotifier extends StateNotifier<HealthState> {
  final HealthService _service;

  HealthNotifier(this._service) : super(const HealthState());

  void updateForm(HealthInputForm form) {
    state = state.copyWith(form: form);
  }

  /// 회원: 기록 생성 → AI 분석 요청 → 롱폴링 완료까지 대기
  Future<void> submitAndAnalyze() async {
    final form = state.form;
    if (!form.isValid) return;

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      // 1. 건강검진 기록 생성
      final record = await _service.createRecord(
        systolicBp: form.systolicBp!,
        diastolicBp: form.diastolicBp!,
        totalCholesterol: form.totalCholesterol!,
        glucose: form.glucose!,
        height: form.height!,
        weight: form.weight!,
        smokeYn: form.smokeYn,
        alcoholYn: form.alcoholYn,
        exerciseYn: form.exerciseYn,
      );

      state = state.copyWith(record: record, isSubmitting: false, isAnalyzing: true);

      // 2. AI 분석 요청 (캐시 HIT → 즉시 결과, MISS → task_id)
      AnalysisResult result = await _service.requestAnalysis(record.id);

      // 3. pending이면 롱폴링으로 대기
      while (result.isPending && result.taskId != null) {
        result = await _service.waitForAnalysis(result.taskId!);
      }

      state = state.copyWith(analysisResult: result, isAnalyzing: false);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        isAnalyzing: false,
        error: e.toString(),
      );
    }
  }

  /// 비회원: 직접 AI 분석 요청 (기록 생성 없음)
  Future<void> submitGuestAnalysis() async {
    final form = state.form;
    if (!form.isValid || form.birthDate == null) return;

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      AnalysisResult result = await _service.requestGuestAnalysis(
        birthDate: form.birthDate!,
        gender: form.gender,
        height: form.height!,
        weight: form.weight!,
        systolicBp: form.systolicBp!,
        diastolicBp: form.diastolicBp!,
        totalCholesterol: form.totalCholesterol!,
        glucose: form.glucose!,
        smokeYn: form.smokeYn,
        alcoholYn: form.alcoholYn,
        exerciseYn: form.exerciseYn,
      );

      state = state.copyWith(isSubmitting: false, isAnalyzing: true);

      while (result.isPending && result.taskId != null) {
        result = await _service.waitForAnalysis(result.taskId!);
      }

      state = state.copyWith(analysisResult: result, isAnalyzing: false);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        isAnalyzing: false,
        error: e.toString(),
      );
    }
  }

  void clearError() => state = state.copyWith(error: null);
}

final healthProvider =
    StateNotifierProvider<HealthNotifier, HealthState>((ref) {
  return HealthNotifier(ref.read(healthServiceProvider));
});
