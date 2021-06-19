import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app1/app_data.dart';
import 'package:flutter_app1/src/api/api_provider.dart';
import 'package:flutter_app1/src/blocs/products/products_bloc.dart';
import 'package:flutter_app1/src/models/cart_entry.dart';
import 'package:flutter_app1/src/models/product_models/product.dart';
import 'package:flutter_app1/src/models/product_models/product_attributes.dart';
import 'package:flutter_app1/src/repositories/products_repo.dart';
import 'package:flutter_app1/src/ui/screens/shipping_address_page.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  ProductsBloc _productsBloc;
  Box _box;
  List<CartEntry> list;

  @override
  void initState() {
    super.initState();
    _box = Hive.box("my_cartBox");
    _productsBloc = ProductsBloc(RealProductsRepo());
  }

  @override
  void dispose() {
    super.dispose();
    _productsBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MyCart"),
      ),
      body: ValueListenableBuilder(
        valueListenable: _box.listenable(),
        builder: (BuildContext context, box, Widget child) {
          if (list == null) {
            list = new List<CartEntry>();
            Map<dynamic, dynamic> raw = box.toMap();
            raw.values.forEach((element) {
              list.add(element);
            });
            _productsBloc.cart_products_event_sink.add(GetCartProducts(list));
          }
          return buildCartBody(list);
        },
      ),
    );
  }

  Widget buildCartBody(list) {
    return (list.length > 0)
        ? StreamBuilder(
            stream: _productsBloc.cart_product_stream,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data != null) {
                  List<Product> data = snapshot.data as List<Product>;

                  double subtotalPrice = 0.0;
                  double discountPrice = 0.0;
                  double totalPrice = 0.0;

                  for (int i = 0; i < data.length; i++) {
                    Product product = data[i];
                    CartEntry cartEntry = list[i];
                    int isDiscount = _calculateDiscount(
                        product.productsPrice, product.discountPrice);

                    List<ProductAttribute> cartProductAttributes =
                        new List<ProductAttribute>();
                    json.decode(cartEntry.attributes).forEach((v) {
                      cartProductAttributes
                          .add(new ProductAttribute.fromJson(v));
                    });

                    if (data[i].productsId != null) {
                      double attrsPrice = 0.0;
                      cartProductAttributes.forEach((element) {
                        attrsPrice +=
                            double.parse(element.values[0].price.toString());
                      });
                      subtotalPrice +=
                          ((double.parse(product.productsPrice.toString()) +
                                  attrsPrice) *
                              cartEntry.quantity);
                      if (isDiscount != null && isDiscount != 0) {
                        discountPrice +=
                            (double.parse(product.productsPrice.toString()) -
                                    double.parse(
                                        product.discountPrice.toString())) *
                                cartEntry.quantity;
                      }
                      totalPrice += (((isDiscount != null && isDiscount != 0)
                              ? double.parse(product.discountPrice.toString())
                              : double.parse(product.productsPrice.toString()) +
                                  attrsPrice) *
                          cartEntry.quantity);
                    } else {
                      _productsBloc.cart_products_event_sink
                          .add(DeleteCartProduct(i));
                      _box.deleteAt(i);
                      break;
                    }
                  }

                  return Column(
                    children: [
                      Expanded(child: buildProductsList(data, list)),
                      Container(
                        decoration: new BoxDecoration(color: Colors.white),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(children: [
                                    Text("Subtotal"),
                                    Expanded(child: SizedBox()),
                                    Text("\$" +
                                        subtotalPrice.toStringAsFixed(2)),
                                  ]),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Row(children: [
                                    Text("Discount"),
                                    Expanded(child: SizedBox()),
                                    Text("\$" +
                                        discountPrice.toStringAsFixed(2)),
                                  ]),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Row(children: [
                                    Text("Total"),
                                    Expanded(child: SizedBox()),
                                    Text(
                                      "\$" + totalPrice.toStringAsFixed(2),
                                      style: TextStyle(
                                          fontSize: 18,
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: FlatButton(
                                color: Colors.green[800],
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                child: Text(
                                  "Proceed",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () async {
                                  if (AppData.user == null) {
                                    Scaffold.of(context).showSnackBar(SnackBar(content: Text("Login First")));
                                    return;
                                  }
                                  String message = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ShippingAddress(list, data)));
                                  if (message != null && message.isNotEmpty) {
                                    Scaffold.of(context)
                                        .removeCurrentSnackBar();
                                    Scaffold.of(context).showSnackBar(
                                        new SnackBar(
                                            content: new Text(message)));
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return buildLoading();
                }
              } else {
                return buildLoading();
              }
            },
          )
        : Container(
            margin: EdgeInsets.all(16.0),
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: IconTheme(
                          data: IconThemeData(color: Colors.green[800]),
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            size: 100.0,
                          )),
                    ),
                    Text(
                      "Empty Cart",
                      style: TextStyle(
                          fontSize: 21.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text("Your cart is empty! Continue Shopping."),
                    SizedBox(
                      height: 8.0,
                    ),
                    FlatButton(
                      color: Colors.green[800],
                      child: Text(
                        "EXPLORE",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              ],
            ),
          );
  }

  Widget buildProductsList(List<Product> products, List<CartEntry> list) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          CartEntry cartEntry = list[index];
          List<ProductAttribute> cartProductAttributes =
              new List<ProductAttribute>();
          json.decode(cartEntry.attributes).forEach((v) {
            cartProductAttributes.add(new ProductAttribute.fromJson(v));
          });
          Product product = products[index];
          if (product.productsId == null) {
            return Container();
          } else {
            int discount = _calculateDiscount(
                product.productsPrice, product.discountPrice);

            double attrsPrice = 0.0;
            cartProductAttributes.forEach((element) {
              attrsPrice += double.parse(element.values[0].price.toString());
            });

            return Card(
              margin: EdgeInsets.all(4),
              child: Row(children: [
                Container(
                  width: 120,
                  height: 120,
                  child: CachedNetworkImage(
                    imageUrl: ApiProvider.imageBaseUrl + product.productsImage,
                    fit: BoxFit.contain,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(children: [
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.productsName),
                                    if (product.categories.length > 0)
                                      Text(
                                        product.categories[0].categoriesName,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54),
                                      ),
                                  ]),
                            ),
                            GestureDetector(
                              onTap: () {
                                _productsBloc.cart_products_event_sink
                                    .add(DeleteCartProduct(index));
                                _box.deleteAt(index);
                              },
                              child: IconTheme(
                                  data: IconThemeData(
                                      color: Theme.of(context).primaryColor),
                                  child: Icon(Icons.delete_outline)),
                            ),
                          ]),
                          Divider(
                            color: Colors.grey,
                          ),
                          Row(children: [
                            Expanded(
                                child: Text(
                              "Price",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            )),
                            (discount != null && discount != 0)
                                ? Row(
                                    children: [
                                      Text(
                                        "\$" +
                                            double.parse(product.productsPrice
                                                    .toString())
                                                .toStringAsFixed(2),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                            decoration:
                                                TextDecoration.lineThrough),
                                      ),
                                      SizedBox(width: 4),
                                      Text("\$" +
                                          double.parse(product.discountPrice
                                                  .toString())
                                              .toStringAsFixed(2)),
                                    ],
                                  )
                                : Text("\$" +
                                    double.parse(
                                            product.productsPrice.toString())
                                        .toStringAsFixed(2)),
                          ]),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: cartProductAttributes.length,
                            itemBuilder: (context, index) {
                              return Row(children: [
                                Expanded(
                                    child: Text(
                                  cartProductAttributes[index].option.name,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                )),
                                Text(
                                  cartProductAttributes[index].values[0].value,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(cartProductAttributes[index]
                                        .values[0]
                                        .pricePrefix +
                                    "\$" +
                                    double.parse(cartProductAttributes[index]
                                            .values[0]
                                            .price
                                            .toString())
                                        .toStringAsFixed(2)),
                              ]);
                            },
                          ),
                          Row(children: [
                            Expanded(
                                child: Text(
                              "Quantity",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            )),
                            GestureDetector(
                              onTap: () {
                                if (cartEntry.quantity > 1) {
                                  _productsBloc.cart_products_event_sink
                                      .add(DecrementCartProductQuantity(index));
                                  cartEntry.quantity--;
                                  _box.putAt(index, cartEntry);
                                }
                              },
                              child: IconTheme(
                                  data: IconThemeData(
                                      color: Theme.of(context).primaryColor),
                                  child: Icon(Icons.remove_circle)),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(product.customerBasketQuantity.toString()),
                            SizedBox(
                              width: 8,
                            ),
                            GestureDetector(
                              onTap: () {
                                cartEntry.quantity++;
                                _productsBloc.cart_products_event_sink
                                    .add(IncrementCartProductQuantity(index));
                                _box.putAt(index, cartEntry);
                              },
                              child: IconTheme(
                                  data: IconThemeData(
                                      color: Theme.of(context).primaryColor),
                                  child: Icon(Icons.add_circle)),
                            ),
                          ]),
                          Divider(
                            color: Colors.grey,
                          ),
                          Row(children: [
                            Expanded(
                                child: Text(
                              "Total Price",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            )),
                            (discount != null && discount != 0)
                                ? Row(
                                    children: [
                                      Text(
                                        "\$" +
                                            ((double.parse(product.productsPrice
                                                            .toString()) +
                                                        attrsPrice) *
                                                    cartEntry.quantity)
                                                .toStringAsFixed(2),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                            decoration:
                                                TextDecoration.lineThrough),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "\$" +
                                            ((double.parse(product.discountPrice
                                                            .toString()) +
                                                        attrsPrice) *
                                                    cartEntry.quantity)
                                                .toStringAsFixed(2),
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                    ],
                                  )
                                : Text(
                                    "\$" +
                                        ((double.parse(product.productsPrice
                                                        .toString()) +
                                                    attrsPrice) *
                                                cartEntry.quantity)
                                            .toStringAsFixed(2),
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  ),
                          ])
                        ]),
                  ),
                )
              ]),
            );
          }
        },
      ),
    );
  }

  Widget buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  int _calculateDiscount(productsPrice, discountPrice) {
    if (discountPrice == null) discountPrice = productsPrice;
    double discount = (productsPrice - discountPrice) / productsPrice * 100;
    return num.parse(discount.toStringAsFixed(0));
  }
}
