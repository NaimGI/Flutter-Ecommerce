import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../Providres/Products.dart';
import '../widget/AppDrawer.dart';
import '../widget/user_productItem.dart';
import 'edit_product.dart';

class UserProduct extends StatelessWidget {
  static const routeName = '/productUser';
  UserProduct();

  @override
  Widget build(BuildContext context) {
    Future<void> _referenceData(BuildContext context) async {
      await Provider.of<Products>(context, listen: false).FetchData(true);
    }

    //final ProductData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Product'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditPrduct.routeName);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _referenceData(context),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _referenceData(context),
                    child: Consumer<Products>(
                      builder: (context, ProductData, _) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: ProductData.items.length,
                          itemBuilder: (_, i) => Column(
                            children: [
                              UserProductItem(
                                  ProductData.items[i].id.toString(),
                                  ProductData.items[i].title,
                                  ProductData.items[i].imageUrl),
                              const Divider(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
