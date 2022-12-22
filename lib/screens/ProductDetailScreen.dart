import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../Providres/Products.dart';

class ProductDetail extends StatelessWidget {
  static const routeName = '/Detail';

  @override
  Widget build(BuildContext context) {
    final productID = ModalRoute.of(context)?.settings.arguments as String;
    final ListID =
        Provider.of<Products>(context, listen: false).findById(productID);
    return Scaffold(
      // appBar: AppBar(
      //title: Text(ListID.title),
//),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(ListID.title),
              background: Hero(
                tag: ListID.id.toString(),
                child: Image.network(
                  ListID.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            const SizedBox(height: 20),
            Text(
              '\$${ListID.price}',
              style: const TextStyle(color: Colors.grey, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                ListID.description,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
            const SizedBox(
              height: 800,
            ),
          ]))
        ],
      ),
    );
  }
}
