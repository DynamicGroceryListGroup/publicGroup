import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_test/screens/userScreens/list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();

  void _createNewList() async {
    // Prompt the user to enter a name for the new list
    String newListName = await _promptForNewListName();
    if (newListName.isNotEmpty) {
      try {
        // Get the current user's UID
        String? userUid = _auth.currentUser?.uid;
        if (userUid != null) {
          // Create a new document in the 'groceryLists' collection
          await _firestore.collection('groceryLists').add({
            'name': newListName,
            'items': [], // Empty list of items
            'users': [userUid], // Initialize with the creator's UID
          });
        }
      } catch (e) {
        print('Error creating new list: $e');
        // Handle errors, e.g., show a dialog
      }
    }
  }

  Future<String> _promptForNewListName() async {
    String newListName = '';
    await showCupertinoDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController();
        return CupertinoAlertDialog(
          title: const Text('New Grocery List'),
          content: CupertinoTextField(
            controller: nameController,
            placeholder: 'Enter list name',
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text('Create'),
              onPressed: () {
                newListName = nameController.text.trim();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return newListName;
  }

  void _showInviteDialog(DocumentReference listRef) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Invite User'),
          content: CupertinoTextField(
            controller: _emailController,
            placeholder: 'Enter user email',
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              child: const Text('Send Invite'),
              onPressed: () {
                _inviteUser(listRef);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _inviteUser(DocumentReference listRef) async {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      try {
        // Placeholder for getting UID from email
        // You need to implement this based on your Firebase setup
        String? uid = await getUidFromEmail(email);
        if (uid != null) {
          listRef.update({
            'users': FieldValue.arrayUnion([uid])
          });
        }
      } catch (e) {
        print('Error inviting user: $e');
        // Implement error handling logic here, such as showing an error dialog
      }
    }
  }

  Future<String?> getUidFromEmail(String email) async {
    // Implementation depends on your Firebase setup
    // For example, you might have a mapping in Firestore between emails and UIDs
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Grocery List App'),
      ),
      child: StreamBuilder(
        stream: _firestore.collection('groceryLists').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CupertinoActivityIndicator());
          return ListView(
            children: snapshot.data!.docs.map((document) {
              return ListTile(
                title: Text(document['name']),
                trailing: CupertinoButton(
                  child: const Icon(CupertinoIcons.forward),
                  onPressed: () =>
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) =>
                            GroceryListScreen(
                                groceryListRef: document.reference)),
                      ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
 }