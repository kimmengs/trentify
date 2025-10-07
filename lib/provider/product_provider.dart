import 'package:trentify/model/demodb.dart';
import 'package:trentify/screens/home/product_detail.dart';

/// Abstraction you can later back with a real API.
abstract class ProductRepository {
  Future<ProductDetailData> fetchProductDetail(String id);
}

/// Demo implementation that reads from DemoDb and simulates network.
class InMemoryProductRepository implements ProductRepository {
  final Duration simulatedLatency;
  InMemoryProductRepository({
    this.simulatedLatency = const Duration(milliseconds: 350),
  });

  @override
  Future<ProductDetailData> fetchProductDetail(String id) async {
    await Future.delayed(simulatedLatency);
    final data = DemoDb.productDetailById(id);
    if (data == null) throw Exception('Product not found: $id');
    return data;
  }
}
