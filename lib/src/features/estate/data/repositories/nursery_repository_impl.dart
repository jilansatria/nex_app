import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';
import '../../domain/entities/nursery_summary.dart';
import '../../domain/repositories/nursery_repository.dart';

class NurseryRepositoryImpl implements NurseryRepository {
  final DioClient _dioClient;

  NurseryRepositoryImpl(this._dioClient);

  @override
  Future<NurserySummary> getNurserySummary() async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.nursery}summary',
      );
      return NurserySummary.fromJson(response.data);
    } catch (e) {
      // Return default (empty) summary on error for now
      return const NurserySummary();
    }
  }
}
