import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app1/src/api/api_provider.dart';
import 'package:flutter_app1/src/models/orders/order_attribute.dart';
import 'package:flutter_app1/src/models/orders/order_data.dart';
import 'package:flutter_app1/src/models/orders/order_product.dart';

class OrderDetailPage extends StatefulWidget {
  OrderData order;

  OrderDetailPage(this.order);

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Detail"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    buildProductsList(widget.order.data),
                    buildBillingAddressCard(),
                    buildShippingAddressCard(),
                    buildShippingMethodCard(),
                    buildPaymentMethodsCard(),
                    buildPriceList(),
/*
                    BlocConsumer<OrderBloc, OrderState>(
                      builder: (BuildContext context, state) {
                        return Container();
                      },
                      listener: (BuildContext context, state) {
                        if (state is PlaceOrderInitial) {
                        } else if (state is PlaceOrderLoading) {
                          showLoaderDialog(context);
                        } else if (state is PlaceOrderLoaded) {
                          AddToOrderResponse addToOrderResponse =
                              state.addToOrderResponse;
                          if (addToOrderResponse.success == "1") {
                            for (int i = widget.cartEntries.length;
                            i > 0;
                            i--) {
                              _box.deleteAt(i - 1);
                            }
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ThankYou()));
                          } else {
                            if (addToOrderResponse.products_id != null) {
                              Navigator.pop(context);
                              int count = 0;
                              Navigator.popUntil(context, (route) {
                                return count++ == 3;
                              });
                              Navigator.pop(
                                  context, addToOrderResponse.message);
                            }
                          }
                        } else if (state is PlaceOrderError) {
                          Navigator.pop(context);
                        }
                      },
                    )
*/
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                    child: FlatButton(
                        color: Colors.red[800],
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        child: Text(
                          "Cancel Order",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {})),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildProductsList(List<OrderProduct> products) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: products.length,
      itemBuilder: (context, index) {
        OrderProduct product = products[index];

        return Card(
          margin: EdgeInsets.all(4),
          child: Row(children: [
            Container(
              width: 120,
              height: 120,
              child: CachedNetworkImage(
                imageUrl: ApiProvider.imageBaseUrl + product.image,
                fit: BoxFit.contain,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.productsName),
                            if (product.categories.length > 0)
                              Text(
                                product.categories[0].categoriesName,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                          ]),
                      Divider(
                        color: Colors.grey,
                      ),
                      Row(children: [
                        Expanded(
                            child: Text(
                          "Price",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        )),
                        Text("\$" +
                            double.parse(product.productsPrice.toString())
                                .toStringAsFixed(2)),
                      ]),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: product.attributes.length,
                        itemBuilder: (context, index) {
                          return Row(children: [
                            Expanded(
                                child: Text(
                              product.attributes[index].productsOptions,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            )),
                            Text(
                              product.attributes[index].productsOptionsValues,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(product.attributes[index].pricePrefix +
                                "\$" +
                                double.parse(product
                                        .attributes[index].optionsValuesPrice
                                        .toString())
                                    .toStringAsFixed(2)),
                          ]);
                        },
                      ),
                      Row(children: [
                        Expanded(
                            child: Text(
                          "Quantity",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        )),
                        Text("x " + product.productsQuantity.toString()),
                      ]),
                      Divider(
                        color: Colors.grey,
                      ),
                      Row(children: [
                        Expanded(
                            child: Text(
                          "Total Price",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        )),
                        Text(
                          "\$" +
                              double.parse(product.finalPrice.toString())
                                  .toStringAsFixed(2),
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ])
                    ]),
              ),
            )
          ]),
        );
      },
    );
  }

  Widget buildBillingAddressCard() {
    return Card(
      margin: EdgeInsets.all(4.0),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Billing Address:"),
            SizedBox(
              height: 8.0,
            ),
            Text(
              widget.order.billingName,
              style: TextStyle(color: Colors.black54),
            ),
            Text(
              widget.order.billingStreetAddress +
                  ", " +
                  widget.order.billingCity,
              style: TextStyle(color: Colors.black54),
            ),
            Text(
              widget.order.billingPhone,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildShippingAddressCard() {
    return Card(
      margin: EdgeInsets.all(4.0),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Shipping Address:"),
            SizedBox(
              height: 8.0,
            ),
            Text(
              widget.order.deliveryName,
              style: TextStyle(color: Colors.black54),
            ),
            Text(
              widget.order.deliveryStreetAddress +
                  ", " +
                  widget.order.deliveryCity,
              style: TextStyle(color: Colors.black54),
            ),
            Text(
              widget.order.deliveryPhone,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildShippingMethodCard() {
    return Card(
      margin: EdgeInsets.all(4.0),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Shipping Method:"),
            SizedBox(
              height: 8.0,
            ),
            Text(
              widget.order.shippingMethod,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentMethodsCard() {
    return Card(
      margin: EdgeInsets.all(4.0),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("PaymentMethods"),
            SizedBox(
              height: 8.0,
            ),
            Text(
              widget.order.paymentMethod,
              style: TextStyle(color: Colors.black54),
            )
          ],
        ),
      ),
    );
  }

  Widget buildPriceList() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(children: [
            Text("Subtotal"),
            Expanded(child: SizedBox()),
            Text("\$0.00"),
          ]),
          SizedBox(
            height: 4,
          ),
          Row(children: [
            Text("Discount"),
            Expanded(child: SizedBox()),
            Text("\$0.00"),
          ]),
          SizedBox(
            height: 4,
          ),
          Row(children: [
            Text("Tax"),
            Expanded(child: SizedBox()),
            Text("\$" + double.parse(widget.order.totalTax.toString()).toStringAsFixed(2)),
          ]),
          SizedBox(
            height: 4,
          ),
          Row(children: [
            Text("Packing Changes"),
            Expanded(child: SizedBox()),
            Text("\$0.00"),
          ]),
          SizedBox(
            height: 4,
          ),
          Row(children: [
            Text("Shipping Charges"),
            Expanded(child: SizedBox()),
            Text("\$" +
                double.parse(widget.order.shippingCost.toString())
                    .toStringAsFixed(2)),
          ]),
          SizedBox(
            height: 4,
          ),
          Row(children: [
            Text("Total"),
            Expanded(child: SizedBox()),
            Text(
              "\$" + double.parse(widget.order.orderPrice.toString()).toStringAsFixed(2),
              style: TextStyle(
                  fontSize: 18, color: Theme.of(context).primaryColor),
            ),
          ]),
        ],
      ),
    );
  }

}
