import 'dart:async';
import 'package:flutter/material.dart';

import '../widgets/ui_elements/title_default.dart';
import '../widgets/ui_elements/address_tag.dart';
import '../widgets/products/price_tag.dart';

import '../models/product.dart';

class ProductPage extends StatelessWidget {
  final Product product;

  ProductPage(this.product);

  _showWarningDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Are you sure?"),
            content: Text("This action cannot be undone."),
            actions: <Widget>[
              FlatButton(
                child: Text("CANCEL"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("DELETE"),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(product.title),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FadeInImage(
              image: NetworkImage(product.image),
              height: 300.0,
              fit: BoxFit.cover,
              placeholder: AssetImage('assets/placeholder.jpg'),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              child: TitleDefault(title: product.title),
            ),
            PriceTag(
              price: product.price.toString(),
            ),
            SizedBox(
              height: 10.0,
            ),
            AddressTag(
              address: "Union Streen, San Francisco",
            ),
            SizedBox(
              height: 10.0,
            ),
            RaisedButton(
              color: Colors.red,
              child: Text(
                "DELETE",
                style: TextStyle(
                  color: Color(0xffffffff),
                ),
              ),
              onPressed: () => _showWarningDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
