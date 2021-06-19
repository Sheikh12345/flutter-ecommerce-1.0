import 'package:flutter/material.dart';
import 'package:flutter_app1/src/blocs/orders/my_orders_bloc.dart';
import 'package:flutter_app1/src/models/orders/order_data.dart';
import 'package:flutter_app1/src/ui/pages/order_detail_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  MyOrdersBloc ordersBloc;

  @override
  void initState() {
    super.initState();

    ordersBloc = BlocProvider.of<MyOrdersBloc>(context);
    ordersBloc.add(GetOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders"),
      ),
      body: BlocBuilder<MyOrdersBloc, MyOrdersState>(
        builder: (context, state) {
          if (state is MyOrdersInitial) {
            return buildLoading();
          } else if (state is MyOrdersLoading) {
            return buildLoading();
          } else if (state is MyOrdersLoaded) {
            return buildColumnWithData(context, state.ordersResponse.data);
          } else if (state is MyOrdersError) {
            return buildLoading();
          } else {
            return buildLoading();
          }
        },
      ),
    );
  }

  Widget buildColumnWithData(BuildContext context, List<OrderData> data) {
    return ListView.builder(
      padding: EdgeInsets.all(4.0),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return buildListItem(data[index]);
      },
    );
  }

  Widget buildListItem(OrderData data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => OrderDetailPage(data)));
      },
      child: Card(
        margin: EdgeInsets.all(4.0),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text("Order ID: " + data.ordersId.toString()),
              Row(children: [
                Text("No. of Products"),
                Expanded(child: SizedBox()),
                Text(data.data.length.toString()),
              ]),
              SizedBox(
                height: 4,
              ),
              Row(children: [
                Text("Checkout Price"),
                Expanded(child: SizedBox()),
                Text("\$" + double.parse(data.orderPrice.toString()).toStringAsFixed(2)),
              ]),
              SizedBox(
                height: 4,
              ),
              Row(children: [
                Text("Order Date"),
                Expanded(child: SizedBox()),
                Text(data.datePurchased),
              ]),
              SizedBox(
                height: 4,
              ),
              Row(children: [
                Text("Order Status"),
                Expanded(child: SizedBox()),
                Text(data.ordersStatus),
              ]),
              SizedBox(
                height: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildLoading() {
  return Center(
    child: CircularProgressIndicator(),
  );
}
