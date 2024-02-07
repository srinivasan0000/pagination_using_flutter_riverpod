import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pagination_using_flutter_riverpod/repositories/product_repository.dart';

import '../../models/product.dart';

final getProductProvider =
    FutureProvider.family.autoDispose<Product, int>((ref, id) async {
  return ref.watch(productRepositoryProvider).fetchProduct(id);
});

class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({super.key, required this.id});
  final int id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productDetail = ref.watch(getProductProvider(id));
    return Scaffold(
        appBar: AppBar(
          title: const Text("Product Detail Page"),
        ),
        body: productDetail.when(
          data: (data) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  SizedBox(
                      height: 300,
                      child: Image.network(data.images![0], fit: BoxFit.cover)),
                  Text(data.title!,
                      style: Theme.of(context).textTheme.headlineLarge),
                  Text(data.description!),
                  Text("\$${data.price!}",
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text(data.brand!)
                ],
              ),
            );
          },
          error: (error, stackTrace) => Center(
            child: Text(error.toString()),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ));
  }
}
