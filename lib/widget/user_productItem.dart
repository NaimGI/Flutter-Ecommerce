import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../Providres/Products.dart';
import '../screens/edit_product.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String ImageUrl;
  UserProductItem(this.id, this.title, this.ImageUrl);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(ImageUrl),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditPrduct.routeName, arguments: id);
              },
              icon: const Icon(Icons.edit, color: Colors.blue)),
          IconButton(
              onPressed: () async {
                try {
                  await Provider.of<Products>(context, listen: false)
                      .deletedProduct(id);
                } catch (error) {
                  scaffold.showSnackBar(const SnackBar(
                      content: Text(
                    'Deleting failed',
                    textAlign: TextAlign.center,
                  )));
                }
              },
              icon: const Icon(Icons.delete, color: Colors.red)),
        ],
      ),
    );
  }
}
