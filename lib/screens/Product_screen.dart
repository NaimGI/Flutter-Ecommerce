import 'package:app/Providres/product.dart';
import 'package:app/widget/badge.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providres/Products.dart';
import '../Providres/cart.dart';

import '../widget/AppDrawer.dart';
import '../widget/provider_grid.dart';

enum FilterOption {
  isFAvorite,
  All,
}

class ProductScreen extends StatefulWidget {
  static const routeName = '/product';

  ProductScreen();

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  var ShowOnlyFavorite = false;
  var _intState = true;
  var _isLoading = false;
  @override
  void didChangeDependencies() {
    if (_intState) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).FetchData().then((_) {
        _isLoading = false;
      });
    }
    _intState = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('shop'),
        actions: [
          PopupMenuButton(
              onSelected: (FilterOption selectedValue) {
                setState(() {
                  if (selectedValue == FilterOption.isFAvorite) {
                    ShowOnlyFavorite = true;
                  } else {
                    ShowOnlyFavorite = false;
                  }
                });
              },
              itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: FilterOption.isFAvorite,
                      child: Text('Only favorite'),
                    ),
                    const PopupMenuItem(
                      value: FilterOption.All,
                      child: Text('Show all '),
                    )
                  ]),
          Consumer<Cart>(
              builder: (_, cart, child) => Badge(
                    value: cart.itemCount().toString(),
                    child: IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/CartPage');
                      },
                    ),
                  )),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductGrid(ShowOnlyFavorite),
    );
  }
}
