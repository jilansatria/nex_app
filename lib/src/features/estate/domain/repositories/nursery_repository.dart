import '../entities/nursery_summary.dart';

abstract class NurseryRepository {
  Future<NurserySummary> getNurserySummary();
}
