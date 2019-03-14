import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../widgets/helpers/ensure_visible.dart';
import '../widgets/form_inputs/location.dart';
import '../scoped-models/main.dart';
import '../models/product.dart';
import '../models/location_data.dart';

class ProductEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductEditPageState();
  }
}

class _ProductEditPageState extends State<ProductEditPage> {
  final Map<String, dynamic> _formData = {
    "title": null,
    "description": null,
    "price": null,
    "image": 'https://picsum.photos/500/200/?random',
    'location': null
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final TextEditingController _titleTextEditingController =TextEditingController();

  void _setLocation(LocationData locData) {
    _formData['location'] = locData;
  }

  void _submitForm(
      Function addProduct, Function updateProduct, Function setSelectedProduct,
      [int selectedProductIndex]) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    if (selectedProductIndex == -1) {
      addProduct(
        _titleTextEditingController.text,
        _formData["description"],
        _formData["image"],
        _formData["price"],
        _formData["location"]
      ).then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/')
              .then((_) => setSelectedProduct(null));
        } else {
          showDialog(context: context, builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Something went wrong'),
              content: Text('Please try again later'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Okay'),
                )
              ],
            );
          });
        }
      });
    } else {
      updateProduct(
        _titleTextEditingController.text,
        _formData["description"],
        _formData["image"],
        _formData["price"],
        _formData["location"]
      ).then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/')
              .then((_) => setSelectedProduct(null));
        } else {
          showDialog(context: context, builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Something went wrong'),
              content: Text('Please try again later'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Okay'),
                )
              ],
            );
          });
        }
      });
    }
  }

  Widget _buildTitleField(Product product) {
    if (product == null && _titleTextEditingController.text.trim() == '') {
      _titleTextEditingController.text = '';
    } else if (product != null && _titleTextEditingController.text.trim() == '') {
      _titleTextEditingController.text = product.title;
    } else if (product != null && _titleTextEditingController.text.trim() != '') {
      _titleTextEditingController.text = _titleTextEditingController.text;
    } else if (product == null && _titleTextEditingController.text.trim() != '') {
      _titleTextEditingController.text = _titleTextEditingController.text;
    } else {
      _titleTextEditingController.text = '';
    }
    return EnsureVisibleWhenFocused(
      focusNode: _titleFocusNode,
      child: TextFormField(
        focusNode: _titleFocusNode,
        decoration: InputDecoration(labelText: "Title"),
        controller: _titleTextEditingController,
        // initialValue: product == null ? "" : product.title,
        validator: (String value) {
          return value.isEmpty ? "Title cannot be empty" : null;
        },
        onSaved: (String title) {
          _formData["title"] = title;
        },
      ),
    );
  }

  Widget _buildDescriptionField(Product product) {
    return EnsureVisibleWhenFocused(
      focusNode: _descriptionFocusNode,
      child: TextFormField(
        focusNode: _descriptionFocusNode,
        decoration: InputDecoration(labelText: "Product description"),
        maxLines: 4,
        initialValue: product == null ? "" : product.description,
        validator: (String value) {
          return value.isEmpty ? "Description cannot be empty" : null;
        },
        onSaved: (String description) {
          _formData["description"] = description;
        },
      ),
    );
  }

  Widget _buildPriceField(Product product) {
    return EnsureVisibleWhenFocused(
      focusNode: _priceFocusNode,
      child: TextFormField(
        focusNode: _priceFocusNode,
        decoration: InputDecoration(labelText: "Price"),
        keyboardType: TextInputType.number,
        initialValue: product == null ? "" : product.price.toString(),
        validator: (String value) {
          if (value.isEmpty ||
              !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
            return "Price must be a valid number";
          }
        },
        onSaved: (String price) {
          _formData["price"] = double.parse(price);
        },
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? Center(child: CircularProgressIndicator())
            : RaisedButton(
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Text("SAVE"),
                onPressed: () => _submitForm(
                    model.addProduct,
                    model.updateProduct,
                    model.selectProduct,
                    model.selectedProductIndex),
              );
      },
    );
  }

  Widget _buildPageContent(BuildContext context, Product product) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
        margin: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildTitleField(product),
              _buildDescriptionField(product),
              _buildPriceField(product),
              SizedBox(
                height: 12.0,
              ),
              LocationInput(_setLocation, product),
              SizedBox(
                height: 12.0,
              ),
              _buildSubmitButton(context),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        final Widget pageContent =
            _buildPageContent(context, model.selectedProduct);
        return model.selectedProductIndex == -1
            ? pageContent
            : Scaffold(
                appBar: AppBar(
                  title: Text("Edit Product"),
                ),
                body: pageContent,
              );
      },
    );
  }
}
