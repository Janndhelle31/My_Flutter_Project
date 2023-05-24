import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_project/auth.dart';
import 'package:my_flutter_project/forms/add_product_form.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;
  List<Map<String, dynamic>> products = [];

  String? displayName; // Added variable to store the display name

  @override
  void initState() {
    super.initState();
    getUserInfo(); // Fetch the user's display name
    getProducts();
  }

  Future<void> getUserInfo() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();

    setState(() {
      displayName = userDoc['name'];
    });
  }

  Future<void> getProducts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('products').get();

    setState(() {
      products = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> deleteProduct(String docID) async {
    await FirebaseFirestore.instance.collection('products').doc(docID).delete();
    setState(() {
      products.removeWhere((product) => product['id'] == docID);
    });
  }

  Future<void> updateProduct(String docID) async {
    // Handle updating the product
    // Replace the code below with your implementation
    print('Update product: $docID');
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  void navigateToAddProductForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductForm(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JANNDHELLE MARTH ZULUETA CRUD'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: navigateToAddProductForm,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: signOut,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'Welcome,',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              displayName ?? 'User name',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  return Card(
                    child: ListTile(
                      title: Text(
                        'Product Name: ${product['name']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Description: ${product['description']}'),
                          Text('Price: \$${product['price']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => updateProduct(product['id']),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => deleteProduct(product['id']),
                          ),
                        ],
                      ),
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
}
