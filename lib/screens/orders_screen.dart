import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../Providres/order.dart';

import '../widget/AppDrawer.dart';
import '../widget/order_item.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = '/orderScreen';
  OrderScreen();

  @override
  Widget build(BuildContext context) {
    //final orderData = Provider.of<Orders>(context);
    print('building orders');
    return Scaffold(
        appBar: AppBar(title: const Text('Your Order')),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
          builder: (context, Datasnapshot) {
            if (Datasnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              if (Datasnapshot.error != null) {
                return const Center(
                  child: Text('An error occured !'),
                );
              } else {
                return Consumer<Orders>(
                  builder: (context, orderData, child) => ListView.builder(
                    itemCount: orderData.ordresList.length,
                    itemBuilder: (context, index) =>
                        OrderItems(orderData.ordresList[index]),
                  ),
                );
              }
            }
          },
        ));
  }
}
