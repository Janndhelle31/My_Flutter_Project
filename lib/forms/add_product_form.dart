import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductForm extends StatefulWidget {
  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  Future<void> getProducts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('products').get();

    setState(() {
      products = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID to the product data
        return data;
      }).toList();
    });
  }

  Future<void> addProductToDatabase() async {
    if (_formKey.currentState!.validate()) {
      final product = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
      };

      try {
        await FirebaseFirestore.instance.collection('products').add(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added successfully')),
        );
        _nameController.clear();
        _descriptionController.clear();
        _priceController.clear();
        getProducts(); // Refresh the products list
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product')),
        );
      }
    }
  }

  Future<void> updateProduct(String productId) async {
    if (_formKey.currentState!.validate()) {
      final product = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
      };

      try {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .update(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product updated successfully')),
        );
        _nameController.clear();
        _descriptionController.clear();
        _priceController.clear();
        getProducts(); // Refresh the products list
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update product')),
        );
      }
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully')),
      );
      getProducts(); // Refresh the products list
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product')),
      );
    }
  }

  void filterProducts(String searchTerm) {
    if (searchTerm.trim().isEmpty) {
      getProducts(); // Show all products if the search term is empty
    } else {
      setState(() {
        products = products.where((product) {
          final name = product['name'].toString().toLowerCase();
          final description = product['description'].toString().toLowerCase();
          return name.contains(searchTerm.toLowerCase()) ||
              description.contains(searchTerm.toLowerCase());
        }).toList();
      });
    }
  }

  void editProduct(Map<String, dynamic> product) {
    _nameController.text = product['name'];
    _descriptionController.text = product['description'];
    _priceController.text = product['price'].toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a product name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Product Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a product description';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Product Price'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a product price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid price';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              updateProduct(product['id']);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Product Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a product name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration:
                        InputDecoration(labelText: 'Product Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a product description';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Product Price'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a product price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: addProductToDatabase,
                    child: Text('Add Product'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    filterProducts('');
                  },
                ),
              ),
              onChanged: (value) => filterProducts(value),
            ),
            SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  return ListTile(
                    title: Text(product['name']),
                    subtitle: Text(product['description']),
                    trailing: Text('\$${product['price']}'),
                    onTap: () => editProduct(product),
                    onLongPress: () => _confirmDeleteProduct(product['id']),
                    leading: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _confirmDeleteProduct(product['id']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteProduct(String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _deleteProduct(productId); // Delete the product
            },
            child: Text('Delete'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(String productId) {
    FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .delete()
        .then((_) {
      // Item deleted successfully from the database
      setState(() {
        products.removeWhere((product) => product['id'] == productId);
      });
    }).catchError((error) {
      // Error occurred while deleting the item
      print('Failed to delete product: $error');
    });
  }
}
