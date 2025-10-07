import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trentify/provider/product_provider.dart';
import 'package:trentify/screens/home/product_detail.dart';

class ProductDetailLoader extends StatelessWidget {
  final String productId;
  final ProductDetailData? initial; // optional: show something instantly
  const ProductDetailLoader({super.key, required this.productId, this.initial});

  @override
  Widget build(BuildContext context) {
    // Replace with your DI: Provider/Riverpod/Bloc/etc.
    final repo = context.read<ProductRepository>();

    return FutureBuilder<ProductDetailData>(
      future: repo.fetchProductDetail(productId),
      initialData: initial, // show instant UI if we passed something via extra
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done && snap.data == null) {
          return const _ProductDetailSkeleton(); // loading placeholder
        }
        if (snap.hasError) {
          return _ErrorRetry(
            message: 'Failed to load product',
            onRetry: () => (context as Element).markNeedsBuild(),
          );
        }
        return ProductDetailPage(data: snap.data!);
      },
    );
  }
}

class _ProductDetailSkeleton extends StatelessWidget {
  const _ProductDetailSkeleton();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Product')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 8),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}
