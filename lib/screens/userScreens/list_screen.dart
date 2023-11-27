import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroceryListScreen extends StatefulWidget {
  final DocumentReference groceryListRef;

  const GroceryListScreen({Key? key, required this.groceryListRef}) : super(key: key);

  @override
  _GroceryListScreenState createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  final TextEditingController _itemController = TextEditingController();
  bool _currentlyShopping = false;

  void _addItem() async {
    String itemName = _itemController.text.trim();
    if (itemName.isNotEmpty) {
      await widget.groceryListRef.update({
        'items': FieldValue.arrayUnion([{'name': itemName, 'isBought': false}])
      });
      _itemController.clear();
    }
  }

  void _toggleItemBought(Map item) async {
    await widget.groceryListRef.update({
      'items': FieldValue.arrayRemove([item])
    });
    item['isBought'] = !item['isBought'];
    await widget.groceryListRef.update({
      'items': FieldValue.arrayUnion([item])
    });
  }

  void _toggleCurrentlyShopping() async {
    setState(() {
      _currentlyShopping = !_currentlyShopping;
    });
    await widget.groceryListRef.update({
      'currentlyShopping': _currentlyShopping
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Grocery List'),
      ),
      child: StreamBuilder<DocumentSnapshot>(
        stream: widget.groceryListRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CupertinoActivityIndicator());
          var data = snapshot.data!.data() as Map;
          var items = data['items'] as List;
          var users = data['users'] as List;
          _currentlyShopping = data['currentlyShopping'] as bool;

          return Column(
            children: [
              // Displaying users
              Text('Users: ${users.join(", ")}', style: TextStyle(fontSize: 12)),
              // List of items
              Expanded(
                child: ListView(
                  children: items.map((item) {
                    return ListTile(
                      title: Text(item['name']),
                      trailing: CupertinoButton(
                        child: Icon(item['isBought'] ? CupertinoIcons.check_mark_circled : CupertinoIcons.circle),
                        onPressed: () => _toggleItemBought(item),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Add item field
              Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(controller: _itemController),
                  ),
                  CupertinoButton(
                    child: const Icon(CupertinoIcons.add),
                    onPressed: _addItem,
                  ),
                ],
              ),
              // Currently Shopping button
              CupertinoButton(
                child: Text(_currentlyShopping ? 'Stop Shopping' : 'Start Shopping'),
                color: _currentlyShopping ? CupertinoColors.systemRed : CupertinoColors.activeBlue,
                onPressed: _toggleCurrentlyShopping,
              ),
            ],
          );
        },
      ),
    );
  }
}
