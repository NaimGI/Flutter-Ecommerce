import 'package:app/screens/Cart_screen.dart';
import 'package:app/screens/SnapScreen.dart';
import 'package:app/screens/auth_screen.dart';
import 'package:app/screens/edit_product.dart';
import 'package:app/screens/user_product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Providres/Products.dart';
import 'Providres/auth.dart';
import 'Providres/cart.dart';
import 'Providres/order.dart';
import 'helper/costum_route.dart';
import 'screens/ProductDetailScreen.dart';
import 'screens/Product_screen.dart';
import 'screens/orders_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products('', [], ''),
          update: (ctx, auth, previesProd) => Products(auth.token.toString(),
              previesProd == null ? [] : previesProd.items, auth.userId),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders('', '', []),
          update: (ctx, auth, previesProd) => Orders(auth.token.toString(),
              auth.userId, previesProd == null ? [] : previesProd.ordresList),
        ),
      ],
      child: Consumer<Auth>(
          builder: (context, auth, _) => MaterialApp(
                  title: 'MyShop',
                  theme: ThemeData(
                      primarySwatch: Colors.purple,
                      accentColor: Colors.deepOrange,
                      fontFamily: 'Lato',
                      pageTransitionsTheme: PageTransitionsTheme(builders: {
                        TargetPlatform.android: CustomPageTransitionBuild(),
                      })),
                  home: auth.isAuth
                      ? ProductScreen()
                      : FutureBuilder(
                          future: auth.tryAutoLogin(),
                          builder: (context, authSnapshot) =>
                              authSnapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? SnapScreen()
                                  : AuthScreen()),
                  routes: {
                    //ProductScreen.routeName: (ctx) => ProductScreen(),
                    ProductDetail.routeName: (ctx) => ProductDetail(),
                    CartScreen.routeName: (context) => CartScreen(),
                    OrderScreen.routeName: (context) => OrderScreen(),
                    UserProduct.routeName: (context) => UserProduct(),
                    EditPrduct.routeName: (context) => EditPrduct()
                  })),
    );
  }
}
