import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../Providres/Products.dart';
import '../Providres/product.dart';
import 'product_item.dart';

class ProductGrid extends StatelessWidget {
  final bool showFav;
  ProductGrid(this.showFav);
  @override
  Widget build(BuildContext context) {
    final ProviderData = Provider.of<Products>(context);
    final ProductList =
        showFav ? ProviderData.favoriteItem : ProviderData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10.1),
      itemCount: ProductList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        value: ProductList[index],
        child: ProductItem(),
      ),
    );
  }
}
