import 'package:nex_app/src/core/network/dio_client.dart';
import 'package:nex_app/src/core/constants/api_constants.dart';
import '../../domain/entities/gis_entities.dart';

class GISRepository {
  final DioClient _dioClient;

  GISRepository(this._dioClient);

  Future<List<GISBlockEntity>> getBlocks() async {
    try {
      final response = await _dioClient.dio.get('${ApiConstants.gis}blocks');
      return (response.data as List)
          .map((json) => GISBlockEntity.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
