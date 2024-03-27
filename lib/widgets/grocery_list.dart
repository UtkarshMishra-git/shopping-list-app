import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  // late Future<List<GroceryItem>> _loadedItems;
  String? _error;
  @override
  void initState() {
    super.initState();
    // _loadedItems = _loadItems();
  }

  // Future<List<GroceryItem>> _loadItems() async {
  void _loadItems() async {
    final url = Uri.https(
        'flutter-prpn-default-rtdb.firebaseio.com', 'shopping-list.json');

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        //with future builder
        // throw Exception('Failed to fetch grocery items. Please try again later.');

        //without future builder
        setState(() {
          _error = 'Failed to fetch data. Please try again later.';
        });
      }

      if (response.body == 'null') {
        // without future builder
        setState(() {
          _isLoading = false;
        });
        return;
        // with future builder
        // return [];
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        loadedItems.add(GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category));
      }
      //without future builder
      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (err) {
      setState(() {
        _error = 'Something went wrong!. Please try again later.';
      });
    }
    //with future builder
    // return loadedItems;
  }

  void _addItem() async {
    final newItem = await Navigator.of(context)
        .push<GroceryItem>(MaterialPageRoute(builder: (ctx) => NewItem()));

    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https('flutter-prpn-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //without future builder
    Widget content = const Center(
      child: Text('No items added yet.'),
    );
    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (ctx, index) => Dismissible(
                onDismissed: (direction) {
                  _removeItem(_groceryItems[index]);
                },
                key: ValueKey(_groceryItems[index].id),
                child: ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: _groceryItems[index].category.color,
                  ),
                  title: Text(
                    _groceryItems[index].name,
                  ),
                  trailing: Text(_groceryItems[index].quantity.toString()),
                ),
              ));
    }
    //without future builder
    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      // without future builder
      body: content,

      //with future builder just for learning about future builder
      // body: FutureBuilder(
      //     future: _loadedItems,
      //     builder: (context, snapshot) {
      //       if (snapshot.connectionState == ConnectionState.waiting) {
      //         return const Center(child: CircularProgressIndicator());
      //       }
      //       if (snapshot.hasError) {
      //         return Center(child: Text(_error!));
      //       }
      //       if (snapshot.data!.isEmpty) {
      //         return const Center(
      //           child: Text('No items added yet.'),
      //         );
      //       }
      //       return ListView.builder(
      //     itemCount: snapshot.data!.length,
      //     itemBuilder: (ctx, index) => Dismissible(
      //           onDismissed: (direction) {
      //             _removeItem(snapshot.data![index]);
      //           },
      //           key: ValueKey(snapshot.data![index].id),
      //           child: ListTile(
      //             leading: Container(
      //               width: 24,
      //               height: 24,
      //               color: snapshot.data![index].category.color,
      //             ),
      //             title: Text(
      //               snapshot.data![index].name,
      //             ),
      //             trailing: Text(snapshot.data![index].quantity.toString()),
      //           ),
      //         ));
      //     }),
    );
  }
}
