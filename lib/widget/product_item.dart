import 'package:app/Providres/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../Providres/auth.dart';
import '../Providres/cart.dart';
import '../screens/ProductDetailScreen.dart';
import '../screens/Product_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productObj = Provider.of<Product>(context, listen: false);
    final CartProv = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black45,
          leading: Consumer<Product>(
            builder: (context, product, child) => IconButton(
              icon: Icon(productObj.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border),
              onPressed: () {
                productObj.toggleFavoriteItem(
                    auth.token.toString(), auth.userId);
              },
              color: Theme.of(context).accentColor,
            ),
          ),
          title: Text(
            productObj.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.shopping_cart),
            color: Theme.of(context).accentColor,
            onPressed: () {
              CartProv.addCart(
                  productObj.id.toString(), productObj.title, productObj.price);
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Your product is added to cart ',
                    textAlign: TextAlign.center,
                  ),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      CartProv.removeSingleItem(productObj.id.toString());
                    },
                  ),
                ),
              );
            },
          ),
        ),
        child: GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .pushNamed('/Detail', arguments: productObj.id);
            },
            child: Hero(
              tag: productObj.id.toString(),
              child: FadeInImage(
                placeholder:
                    AssetImage('assets/images/product-placeholder.png'),
                image: NetworkImage(productObj.imageUrl),
                fit: BoxFit.cover,
              ),
            )),
      ),
    );
  }
}
