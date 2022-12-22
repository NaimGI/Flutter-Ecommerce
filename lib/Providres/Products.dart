import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exiption.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    /* Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),*/
  ];

  List<Product> get items {
    return [..._items];
  }

  final String authToken;
  final String userId;
  Products(this.authToken, this._items, this.userId);

  List<Product> get favoriteItem {
    return items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> FetchData([bool filterByProduct = false]) async {
    final userUrl =
        filterByProduct ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url =
        'https://shop-c1a5d-default-rtdb.firebaseio.com/products.json?auth=$authToken&$userUrl';
    try {
      final response = await http.get(Uri.parse(url));
      var exstractedData = json.decode(response.body) as Map<String, dynamic>;
      if (exstractedData == null) {
        return;
      }
      final List<Product> laodingProduct = [];
      final otherUrl =
          'https://shop-c1a5d-default-rtdb.firebaseio.com/userFovorite/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(Uri.parse(otherUrl));
      final favoriteData = json.decode(favoriteResponse.body);

      exstractedData.forEach((prodId, value) {
        laodingProduct.add(Product(
            id: prodId,
            title: value['title'],
            description: value['description'],
            price: value['price'],
            imageUrl: value['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false));
      });
      _items = laodingProduct;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product prod) async {
    final url =
        'https://shop-c1a5d-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'title': prod.title,
            'price': prod.price,
            'description': prod.description,
            'imageUrl': prod.imageUrl,
            'creatorId': userId
          }));
      final newProduct = Product(
        title: prod.title,
        price: prod.price,
        description: prod.description,
        imageUrl: prod.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((element) => element.id == id);
    if (productIndex >= 0) {
      final url =
          'https://shop-c1a5d-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(Uri.parse(url),
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl
          }));
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deletedProduct(String id) async {
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final url =
        'https://shop-c1a5d-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could Not delete product');
    }
    existingProduct = null;
  }
}
