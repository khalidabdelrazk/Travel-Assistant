import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:either_dart/either.dart';
import 'package:injectable/injectable.dart';
import 'package:travel/presentation/trips/data/Models/explore_response_dm.dart';
import '../../../../../../../core/api manager/api_endpoints.dart';
import '../../../../../../../core/api manager/api_manager.dart';
import '../../../../../../../core/error/failures.dart';
import '../hotels_remote_data_source.dart';

@Injectable(as: HotelsRemoteDataSource)
class HotelsRemoteDataSourceImpl implements HotelsRemoteDataSource {
  final ApiManager apiManager;
  HotelsRemoteDataSourceImpl({required this.apiManager});

  @override
  Future<Either<Failures, List<ExploreResponseDm>>> getHotels(
    String? controllerText,
  ) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    Map<String, dynamic>? queryParams;

    if (controllerText != null && controllerText.trim().isNotEmpty) {
      queryParams = {'city': controllerText};
    }

    try {
      if (connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.mobile)) {
        final response = await apiManager.getData(
          path: ApiEndPoints.getHotels,
          queryParameters: queryParams,
        );

        if (response.statusCode! >= 200 && response.statusCode! < 300) {
          List<dynamic> jsonList = response.data;
          List<ExploreResponseDm> trips =
              jsonList
                  .map((item) => ExploreResponseDm.fromJson(item))
                  .toList();

          return Right(trips);
        }

        return Left(ServerError(errorMessage: 'Server error'));
      } else {
        return Left(NetworkError(errorMessage: "No internet connection"));
      }
    } catch (e) {
      return Left(ServerError(errorMessage: 'Unhandled Error, Please Try again'));
    }
  }
}
