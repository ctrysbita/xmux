import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:xmux/globals.dart';
import 'package:xmux/modules/common/page_routes.dart';
import 'package:xmux/modules/xmux_api/xmux_api_v2.dart';

import 'item_edit_page.dart';
import 'model.dart';

class ItemDetailPage extends StatelessWidget {
  final Item item;

  ItemDetailPage(this.item);

  List<Widget> _buildWidget(BuildContext context) {
    var details = <Widget>[
      Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: CircleAvatar(
              child: FutureBuilder<XMUXApiResponse<User>>(
                future: xmuxApi.getUser(item.from),
                builder: (_, snap) => snap.hasData
                    ? Image.network(snap.data.data.photoUrl)
                    : SpinKitPulse(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FutureBuilder<XMUXApiResponse<User>>(
                  future: xmuxApi.getUser(item.from),
                  builder: (_, snap) => snap.hasData
                      ? Text(
                          snap.data.data.name,
                          style: Theme.of(context).textTheme.subhead,
                        )
                      : Text('...'),
                ),
                Text(
                  '${DateFormat.yMd(Localizations.localeOf(context).languageCode).format(item.timestamp)} ${DateFormat.Hm(Localizations.localeOf(context).languageCode).format(item.timestamp)}',
                  style: Theme.of(context).textTheme.caption,
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              'RM120',
              style: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(13.0, 0.0, 13.0, 0.0),
        child: Divider(),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0.0),
        child: Text(item.description),
      ),
    ];
    var photos = item.photos.map((p) => Image.network(p)).toList();
    var comments = <Widget>[
      Padding(padding: const EdgeInsets.all(8.0)),
      Card(
        margin: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
        elevation: 0.0,
        shape: RoundedRectangleBorder(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 10.0, 5.0, 0.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Comments',
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {},
                  )
                ],
              ),
            ),
            Divider(),
            Container(
              height: MediaQuery.of(context).size.height / 3 * 2,
              child: FirebaseAnimatedList(
                  padding: EdgeInsets.all(0),
                  query: FirebaseDatabase.instance
                      .reference()
                      .child('flea_market/${item.key}/comments'),
                  itemBuilder: (ctx, _, __, index) =>
                      _CommentCard.fromSnapshot(_)),
            ),
          ],
        ),
      )
    ];
    return details + photos + comments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.deepOrange,
          expandedHeight: 256.0,
          pinned: true,
          floating: false,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.create),
              tooltip: 'Edit',
              onPressed: () {
                Navigator.of(context).push(FadeRoute(ItemEditPage()));
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text('Item Details'),
            background: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Hero(
                  tag: item.key,
                  child: Image.network(
                    item.photos[0],
                    fit: BoxFit.cover,
                    height: 20.0,
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.0, -1.0),
                      end: Alignment(0.0, 1.0),
                      colors: <Color>[
                        Color(0x60000000),
                        Color(0),
                        Color(0),
                        Color(0x60000000)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(_buildWidget(context)),
        ),
      ],
    ));
  }
}

class _CommentCard extends StatelessWidget {
  final Comment _comment;

  const _CommentCard(this._comment);

  factory _CommentCard.fromSnapshot(DataSnapshot snap) =>
      _CommentCard(Comment.fromSnapshot(snap));

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: CircleAvatar(
            child: FutureBuilder<XMUXApiResponse<User>>(
              future: xmuxApi.getUser(_comment.from),
              builder: (_, snap) => snap.hasData
                  ? Image.network(snap.data.data.photoUrl)
                  : SpinKitPulse(color: Colors.white),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FutureBuilder<XMUXApiResponse<User>>(
                future: xmuxApi.getUser(_comment.from),
                builder: (_, snap) => snap.hasData
                    ? Text(
                        snap.data.data.name,
                        style: Theme.of(context).textTheme.subhead,
                      )
                    : Text('...'),
              ),
              Text(_comment.comment)
            ],
          ),
        ),
      ],
    );
  }
}