import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:xmux/globals.dart';
import 'package:xmux/mainapp/explore/lost_and_found/create.dart';
import 'package:xmux/mainapp/explore/lost_and_found/detail.dart';
import 'package:xmux/modules/xmux_api/xmux_api_v2.dart';
import 'package:xmux/translations/translation.dart';

class LostAndFoundPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new LostAndFoundPageState();
}

class LostAndFoundPageState extends State<LostAndFoundPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(MainLocalizations.of(context).get("lostandfound")),
      ),
      body: new FirebaseAnimatedList(
        query: FirebaseDatabase.instance.reference().child('lostandfound'),
        sort: (a, b) => b.key.compareTo(a.key),
        padding: new EdgeInsets.all(3),
        reverse: false,
        itemBuilder:
            (_, DataSnapshot snapshot, Animation<double> animation, int index) {
          return new LostAndFoundCard(
              dataSnapshot: snapshot, animation: animation);
        },
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            new MaterialPageRoute(builder: (BuildContext context) {
              return new LostAndFoundCreatePage();
            }),
          );
        },
        child: new Icon(
          Icons.add,
          color: Colors.white,
        ),
        tooltip: "New",
      ),
    );
  }
}

class LostAndFoundCard extends StatelessWidget {
  final DataSnapshot dataSnapshot;
  final Animation<double> animation;

  LostAndFoundCard({@required this.dataSnapshot, @required this.animation});

  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: new FlatButton(
        onPressed: () {
          Navigator.of(context).push(
            new MaterialPageRoute(builder: (BuildContext context) {
              return new LostAndFoundDetailPage(dataSnapshot);
            }),
          );
        },
        child: new Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: new Row(
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(right: 16),
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(XMUXApi.convertAvatarUrl(
                      dataSnapshot.value['senderPhotoUrl'],
                      store.state.user.moodleKey)),
                  radius: 25,
                ),
              ),
              new Expanded(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      dataSnapshot.value['senderName'],
                      style: Theme.of(context).textTheme.subhead,
                    ),
                    new Divider(
                      height: 5,
                      color: Theme.of(context).canvasColor,
                    ),
                    new Text(
                      MainLocalizations.of(context)
                              .get("lostandfound/location") +
                          dataSnapshot.value['location_brief'],
                      style: Theme.of(context).textTheme.caption,
                    ),
                    new Text(
                      MainLocalizations.of(context).get("lostandfound/things") +
                          dataSnapshot.value['brief'],
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
              ),
              new Card(
                child: new Padding(
                  padding: const EdgeInsets.all(5),
                  child: new Column(
                    children: <Widget>[
                      new Text(
                        dataSnapshot.value['isLost']
                            ? MainLocalizations.of(context)
                                .get("lostandfound/lost")
                            : MainLocalizations.of(context)
                                .get("lostandfound/found"),
                        style: Theme.of(context).textTheme.subhead,
                      ),
                      new Text(
                        new DateTime.now()
                                    .difference(DateTime.parse(
                                        dataSnapshot.value['time']))
                                    .inDays ==
                                0
                            ? new DateTime.now()
                                    .difference(DateTime.parse(
                                        dataSnapshot.value['time']))
                                    .inHours
                                    .toString() +
                                MainLocalizations.of(context)
                                    .get("lostandfound/hour")
                            : new DateTime.now()
                                    .difference(DateTime.parse(
                                        dataSnapshot.value['time']))
                                    .inDays
                                    .toString() +
                                MainLocalizations.of(context)
                                    .get("lostandfound/day"),
                        style: Theme.of(context).textTheme.subhead,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
