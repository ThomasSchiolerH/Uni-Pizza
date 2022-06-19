import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../classes/restaurant.dart';
import '../models/menu_item.dart';


class RestaurantDetailsScreen extends StatefulWidget {
  @override
  _RestaurantDetailsScreenState createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = ModalRoute
        .of(context)
        .settings
        .arguments as Restaurant;
    final myController = TextEditingController();

    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    shape: RoundedRectangleBorder(),
                    primary: Theme
                        .of(context)
                        .colorScheme
                        .secondary,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/basket');
                  },
                  child: Text('Basket'),
                ),
              ],
            )),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom:
                  Radius.elliptical(MediaQuery
                      .of(context)
                      .size
                      .width, 50),

                ),
                image: DecorationImage(
                    image: NetworkImage(
                      restaurant.imageUrl,
                    ),
                    fit: BoxFit.cover),
              ),
            ),
            RestaurantInformation(restaurant: restaurant),
            Padding(
              padding: EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 5.0),
              child: TextFormField(
                validator: (val) => val.isEmpty ? 'Test mand' : null,
                onChanged: (val) {},
                controller: myController,
                decoration: const InputDecoration(
                  labelText: 'Kommenter pizzariaet',
                ),
              ),
            ),
            OutlinedButton(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection("testing")
                      .add({"comment": myController.text});
                  myController.clear();
                  FocusManager.instance.primaryFocus.unfocus();
                },
                child: Icon(Icons.send)
            ),
            Container(
              width: 370,
              height: 150,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection("testing").snapshots(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot> snapshot,) {
                  if (!snapshot.hasData) return const SizedBox.shrink();

                  return MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, int index) {
                        final docData = snapshot.data.docs[index];
                        final comment = (docData['comment'] as String);

                        return Container(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey.shade300))
                          ),
                          child: ListTile(
                            leading: Icon(Icons.person),
                            title: Text(comment),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ]
          ,
        )
        ,
      )
      ,
    );
  }
}



Widget _buildMenuItems(Restaurant restaurant, BuildContext context, int index) {
  int getIndexOf(String name, MenuItemDetail menuItem){
    for (int i = 0; i < menuItem.pizzaria.keys.length; i++) {
      if(menuItem.pizzaria.keys.elementAt(i) == name){
        return i;
      }
    };
    return 0;
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          restaurant.tags[index],

          style: Theme
              .of(context)
              .textTheme
              .headline3
              .copyWith(color: Theme
              .of(context)
              .accentColor),
        ),
      ),
      Column(
          children: restaurant.menuItems
              .where((menuItem) => menuItem.category == restaurant.tags[index])
              .map((menuItem) =>
              Column(
                children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(menuItem.name,
                          style: Theme
                              .of(context)
                              .textTheme
                              .headline5),
                      subtitle: Text(menuItem.description,
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyText1),
                      trailing: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('\$${menuItem.pizzaria.values.elementAt(getIndexOf(restaurant.name, menuItem))}',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .headline5),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 2,
                  )
                ],
              ))
              .toList())
    ],
  );
}

class RestaurantInformation extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantInformation({Key key, this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Text(restaurant.name,
              style: Theme
                  .of(context)
                  .textTheme
                  .headline3
                  .copyWith(
                color: Theme
                    .of(context)
                    .accentColor,
              )),
        ],
      ),
    );
  }
}
