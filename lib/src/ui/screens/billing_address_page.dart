import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app1/src/api/responses/countries_response.dart';
import 'package:flutter_app1/src/api/responses/zones_response.dart';
import 'package:flutter_app1/src/blocs/address/address_bloc.dart';
import 'package:flutter_app1/src/models/address/address.dart';
import 'package:flutter_app1/src/models/cart_entry.dart';
import 'package:flutter_app1/src/models/address/country.dart';
import 'package:flutter_app1/src/models/product_models/product.dart';
import 'package:flutter_app1/src/models/address/zone.dart';
import 'package:flutter_app1/src/repositories/address_repo.dart';
import 'package:flutter_app1/src/ui/screens/shipping_methods_page.dart';

class BillingAddress extends StatelessWidget {
  List<CartEntry> cartEntries;
  List<Product> cartProducts;
  Address shippingAddress;

  BillingAddress(this.cartEntries, this.cartProducts, this.shippingAddress);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Billing Address"),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            MyCustomForm(cartEntries, cartProducts, shippingAddress),
          ],
        ),
      ),
    );
  }
}

// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  List<CartEntry> cartEntries;
  List<Product> cartProducts;
  Address shippingAddress;

  MyCustomForm(this.cartEntries, this.cartProducts, this.shippingAddress);

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();

  final _addressBloc = AddressBloc(RealAddressRepo());

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();

  Country selectedCountry;
  Zone selectedZone;

  bool isChecked = true;

  @override
  void initState() {
    super.initState();

    _firstNameController.text = widget.shippingAddress.deliveryFirstName;
    _lastNameController.text = widget.shippingAddress.deliveryLastName;
    _addressController.text = widget.shippingAddress.deliveryStreetAddress;
    _cityController.text = widget.shippingAddress.deliveryCity;
    _postalCodeController.text = widget.shippingAddress.deliveryPostCode;
    _phoneController.text = widget.shippingAddress.deliveryPhone;
    selectedCountry = widget.shippingAddress.deliveryCountry;
    selectedZone = widget.shippingAddress.deliveryZone;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    enabled: !isChecked,
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(8.0),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                        borderSide: new BorderSide(),
                      ),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  TextFormField(
                    enabled: !isChecked,
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(8.0),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                        borderSide: new BorderSide(),
                      ),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  TextFormField(
                    enabled: !isChecked,
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(8.0),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                        borderSide: new BorderSide(),
                      ),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  isChecked
                      ? Column(
                          children: [
                            TextFormField(
                              enabled: false,
                              initialValue: selectedCountry.countriesName,
                              decoration: InputDecoration(
                                labelText: 'Country',
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.all(8.0),
                                border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(8.0),
                                  borderSide: new BorderSide(),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 16.0,
                            ),
                          ],
                        )
                      : StreamBuilder(
                          stream: _addressBloc.countriesStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData || snapshot.data != null) {
                              CountriesResponse response =
                                  snapshot.data as CountriesResponse;
                              if (response.success == "1" &&
                                  response.data.length > 0) {
                                return Column(
                                  children: [
                                    DropdownButtonFormField(
                                      isExpanded: true,
                                      hint: Text("Country"),
                                      decoration: InputDecoration(
                                        fillColor: Colors.white,
                                        contentPadding: EdgeInsets.all(8.0),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(8.0),
                                          borderSide: new BorderSide(),
                                        ),
                                      ),
                                      items: response.data.map((e) {
                                        return new DropdownMenuItem(
                                            value: e,
                                            child: Text(e.countriesName));
                                      }).toList(),
                                      onChanged: (value) {
                                        selectedCountry = value as Country;
                                        _addressBloc.addressEventSink.add(
                                            GetZones(
                                                selectedCountry.countriesId));
                                      },
                                    ),
                                    SizedBox(
                                      height: 16.0,
                                    ),
                                  ],
                                );
                              } else {
                                return _buildLoadingField("Country");
                              }
                            } else {
                              return _buildLoadingField("Country");
                            }
                          },
                        ),
                  isChecked
                      ? Column(
                          children: [
                            TextFormField(
                              enabled: false,
                              initialValue: selectedZone.zoneName,
                              decoration: InputDecoration(
                                labelText: 'Zone',
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.all(8.0),
                                border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(8.0),
                                  borderSide: new BorderSide(),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 16.0,
                            ),
                          ],
                        )
                      : StreamBuilder(
                          stream: _addressBloc.zonesStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData || snapshot.data != null) {
                              ZonesResponse response =
                                  snapshot.data as ZonesResponse;
                              if (response.success == "1" &&
                                  response.data.length > 0) {
                                return Column(
                                  children: [
                                    DropdownButtonFormField(
                                      isExpanded: true,
                                      hint: Text("Zone"),
                                      decoration: InputDecoration(
                                        fillColor: Colors.white,
                                        contentPadding: EdgeInsets.all(8.0),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(8.0),
                                          borderSide: new BorderSide(),
                                        ),
                                      ),
                                      items: response.data.map((e) {
                                        return new DropdownMenuItem(
                                            value: e, child: Text(e.zoneName));
                                      }).toList(),
                                      onChanged: (value) {
                                        selectedZone = value as Zone;
                                      },
                                    ),
                                    SizedBox(
                                      height: 16.0,
                                    ),
                                  ],
                                );
                              } else {
                                return _buildLoadingField("Zone");
                              }
                            } else {
                              return Container();
                            }
                          },
                        ),
                  TextFormField(
                    enabled: !isChecked,
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'City',
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(8.0),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                        borderSide: new BorderSide(),
                      ),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  TextFormField(
                    enabled: !isChecked,
                    controller: _postalCodeController,
                    decoration: InputDecoration(
                      labelText: 'PostCode',
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(8.0),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                        borderSide: new BorderSide(),
                      ),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  TextFormField(
                    enabled: !isChecked,
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(8.0),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                        borderSide: new BorderSide(),
                      ),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  SwitchListTile(
                    title: Text("Same as shipping address"),
                    contentPadding: EdgeInsets.all(0.0),
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        this.isChecked = value;
                        if (!isChecked) {
                          _firstNameController.clear();
                          _lastNameController.clear();
                          _addressController.clear();
                          _cityController.clear();
                          _postalCodeController.clear();
                          _phoneController.clear();
                          selectedCountry = null;
                          selectedZone = null;
                          _addressBloc.addressEventSink.add(GetCountries());
                        } else  {
                          _firstNameController.text = widget.shippingAddress.deliveryFirstName;
                          _lastNameController.text = widget.shippingAddress.deliveryLastName;
                          _addressController.text = widget.shippingAddress.deliveryStreetAddress;
                          _cityController.text = widget.shippingAddress.deliveryCity;
                          _postalCodeController.text = widget.shippingAddress.deliveryPostCode;
                          _phoneController.text = widget.shippingAddress.deliveryPhone;
                          selectedCountry = widget.shippingAddress.deliveryCountry;
                          selectedZone = widget.shippingAddress.deliveryZone;
                        }
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  )
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: FlatButton(
              color: Colors.green[800],
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () {
                if (_formKey.currentState.validate() &&
                    selectedCountry != null &&
                    selectedZone != null) {
                  Address billingAddress = Address();
                  billingAddress.deliveryFirstName = _firstNameController.text;
                  billingAddress.deliveryLastName = _lastNameController.text;
                  billingAddress.deliveryStreetAddress =
                      _addressController.text;
                  billingAddress.deliveryCity = _cityController.text;
                  billingAddress.deliveryPostCode = _postalCodeController.text;
                  billingAddress.deliveryPhone = _phoneController.text;

                  billingAddress.deliveryZone = selectedZone;
                  billingAddress.deliveryCountry = selectedCountry;
                  billingAddress.deliveryCountryCode = "";
                  billingAddress.deliveryLat = "";
                  billingAddress.deliveryLong = "";

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShippingMethods(
                              widget.cartEntries,
                              widget.cartProducts,
                              widget.shippingAddress,
                              billingAddress)));
                }
              },
              child: Text("Proceed", style: TextStyle(color: Colors.white),),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLoadingField(String title) {
    return Column(
      children: [
        Stack(
          children: <Widget>[
            TextFormField(
              enabled: false,
              decoration: InputDecoration(
                labelText: title,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(8.0),
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(8.0),
                  borderSide: new BorderSide(),
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 16.0,
        ),
      ],
    );
  }
}
