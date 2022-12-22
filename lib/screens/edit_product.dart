import 'package:app/Providres/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../Providres/Products.dart';

class EditPrduct extends StatefulWidget {
  static const routeName = '/editPage';
  EditPrduct();

  @override
  State<EditPrduct> createState() => _EditPrductState();
}

class _EditPrductState extends State<EditPrduct> {
  final _FocusPrice = FocusNode();
  final DescriptionFocus = FocusNode();
  final _controllerUrl = TextEditingController();
  final _ImageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var editingProduct =
      Product(id: null, title: '', description: '', price: 0.0, imageUrl: '');
  var initChange = true;
  var _initailProd = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };
  var initLoading = false;
  @override
  void initState() {
    _ImageUrlFocusNode.addListener(updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (initChange) {
      final ProductId = ModalRoute.of(context)!.settings.arguments as String?;
      if (ProductId != null) {
        editingProduct = Provider.of<Products>(context).findById(ProductId);
        _initailProd = {
          'title': editingProduct.title,
          'description': editingProduct.description,
          'price': editingProduct.price.toString(),
          'imageUrl': ''
        };
        _controllerUrl.text = editingProduct.imageUrl;
      }
    }
    initChange = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _FocusPrice.dispose();
    _ImageUrlFocusNode.removeListener(updateImageUrl);
    DescriptionFocus.dispose();
    _controllerUrl.dispose();
    super.dispose();
  }

  void updateImageUrl() {
    if (!_ImageUrlFocusNode.hasFocus) {
      if ((!_controllerUrl.text.startsWith('http') &&
              !_controllerUrl.text.startsWith('https')) ||
          (!_controllerUrl.text.endsWith('png') &&
              !_controllerUrl.text.endsWith('jpg') &&
              !_controllerUrl.text.endsWith('jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final valid = _form.currentState!.validate();
    if (!valid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      initLoading = true;
    });
    if (editingProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(editingProduct.id.toString(), editingProduct);
      setState(() {
        initLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(editingProduct);
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error Occured !'),
                  content: Text('Something went wrong !'),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Okay')),
                  ],
                ));
      } finally {
        setState(() {
          initLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(onPressed: _saveForm, icon: const Icon(Icons.save))
        ],
      ),
      body: initLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _initailProd['title'],
                        decoration: const InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_FocusPrice);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Pleaze enter a title';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          editingProduct = Product(
                            id: editingProduct.id,
                            title: value as String,
                            description: editingProduct.description,
                            price: editingProduct.price,
                            imageUrl: editingProduct.imageUrl,
                            isFavorite: editingProduct.isFavorite,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _initailProd['price'],
                        decoration: const InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(DescriptionFocus);
                        },
                        focusNode: _FocusPrice,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Pleaze enter a Price';
                          }
                          if (double.parse(value) == null) {
                            return 'Your price must be a number ';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Your price must be great than 0';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          editingProduct = Product(
                              id: editingProduct.id,
                              title: editingProduct.title,
                              description: editingProduct.description,
                              price: double.parse(value!),
                              imageUrl: editingProduct.imageUrl,
                              isFavorite: editingProduct.isFavorite);
                        },
                      ),
                      TextFormField(
                          initialValue: _initailProd['description'],
                          decoration:
                              const InputDecoration(labelText: 'Decription'),
                          textInputAction: TextInputAction.next,
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          focusNode: DescriptionFocus,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Description is required !';
                            }
                            if (value.length < 10) {
                              return 'Enter at least 10 caractere';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            editingProduct = Product(
                                id: editingProduct.id,
                                title: editingProduct.title,
                                description: value as String,
                                price: editingProduct.price,
                                imageUrl: editingProduct.imageUrl,
                                isFavorite: editingProduct.isFavorite);
                          }),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            margin: const EdgeInsets.only(right: 10, top: 8),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey)),
                            child: _controllerUrl.text.isEmpty
                                ? const Text('Enter Url ')
                                : FittedBox(
                                    clipBehavior: Clip.antiAlias,
                                    fit: BoxFit.cover,
                                    child: Image.network(_controllerUrl.text),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'image'),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.url,
                              controller: _controllerUrl,
                              focusNode: _ImageUrlFocusNode,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter an image URL.';
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'Please enter a valid URL.';
                                }
                                if (!value.endsWith('.png') &&
                                    !value.endsWith('.jpg') &&
                                    !value.endsWith('.jpeg')) {
                                  return 'Please enter a valid image URL.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                editingProduct = Product(
                                    id: editingProduct.id,
                                    title: editingProduct.title,
                                    description: editingProduct.description,
                                    price: editingProduct.price,
                                    imageUrl: value as String,
                                    isFavorite: editingProduct.isFavorite);
                              },
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ))),
    );
  }
}
