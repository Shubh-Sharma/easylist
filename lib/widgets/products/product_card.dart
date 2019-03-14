import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './price_tag.dart';
import '../ui_elements/address_tag.dart';
import '../ui_elements/title_default.dart';

import '../../scoped-models/main.dart';
import '../../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int productIndex;

  ProductCard({this.product, this.productIndex});

  Widget _buildTitlePriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        TitleDefault(
          title: product.title,
        ),
        SizedBox(
          width: 8.0,
        ),
        PriceTag(price: product.price.toString())
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.info,
              ),
              color: Theme.of(context).primaryColor,
              onPressed: () => Navigator.pushNamed<bool>(
                  context, '/product/' + model.allProducts[productIndex].id),
            ),
            IconButton(
              icon: Icon(model.allProducts[productIndex].isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border),
              color: model.allProducts[productIndex].isFavorite
                  ? Theme.of(context).primaryColorLight
                  : Theme.of(context).primaryColorDark,
              onPressed: () {
                model.selectProduct(model.allProducts[productIndex].id);
                model.toggleFavorite();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        child: Column(
          children: <Widget>[
            FadeInImage(
              image: NetworkImage(product.image),
              height: 300.0,
              fit: BoxFit.cover,
              placeholder: AssetImage('assets/placeholder.jpg'),
            ),
            Container(
              padding: EdgeInsets.only(top: 8.0),
              child: _buildTitlePriceRow(),
            ),
            AddressTag(
              address: "Union Streen, San Francisco",
            ),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }
}
