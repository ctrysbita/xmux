import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:xmux/mainapp/explore/chat_room_page.dart';
import 'package:xmux/mainapp/explore/eatx/eatx_page.dart';
import 'package:xmux/mainapp/tools/room_reservation.dart';
import 'package:xmux/redux/actions.dart';
import 'package:xmux/redux/state.dart';
import 'package:xmux/translations/translation.dart';

class ExplorePage extends StatelessWidget {
  Widget _buildSlider(BuildContext context) {
    return new StoreConnector<MainAppState, List>(
        builder: (context, newsList) => new CarouselSlider(
              items: newsList
                  .map((n) => new Card(
                        child: new Image(
                          image: (n["imageURL"] as String).isEmpty
                              ? AssetImage("res/slider.jpg")
                              : CachedNetworkImageProvider(n["imageURL"]),
                          fit: BoxFit.fill,
                        ),
                      ))
                  .toList(),
              viewportFraction: 0.88,
              aspectRatio: 2.0,
              autoPlay: true,
            ),
        converter: (store) => store.state.uiState.news);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: StoreConnector<MainAppState, VoidCallback>(
          converter: (store) => () => store.dispatch(OpenDrawerAction(true)),
          builder: (context, callback) =>
              IconButton(icon: Icon(Icons.view_list), onPressed: callback),
        ),
        title: Text(MainLocalizations.of(context).get("Explore")),
        backgroundColor: Colors.indigo[800],
      ),
      body: new ListView(
        children: <Widget>[
          _buildSlider(context),
          new Container(
            margin: const EdgeInsets.all(10.0),
            child: new Card(
              child: new Padding(
                padding: const EdgeInsets.all(10.0),
                child: new Row(
                  children: <Widget>[
                    new Container(
                      width: MediaQuery.of(context).size.width - 50.0,
                      child: new Text(
                          MainLocalizations.of(context).get("Warning")),
                    ),
                  ],
                ),
              ),
            ),
          ),
          new FlatButton(
            onPressed: () {
              Navigator.pushNamed(context, "/explore/lostandfound");
            },
            child: new Row(
              children: <Widget>[
                new Icon(Icons.find_in_page),
                new Text(
                  " " + MainLocalizations.of(context).get("lostandfound"),
                  style: Theme.of(context).textTheme.subhead,
                )
              ],
            ),
          ),
          new FlatButton(
            onPressed: () => Navigator.of(context).push(
                new MaterialPageRoute(builder: (_) => new RoomWebviewPage())),
            child: new Row(
              children: <Widget>[
                new Icon(FontAwesomeIcons.table),
                new Text(
                  " " + MainLocalizations.of(context).get("roomreservation"),
                  style: Theme.of(context).textTheme.subhead,
                )
              ],
            ),
          ),
          new FlatButton(
            onPressed: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (_) => new GlobalChatroomPage())),
            child: new Row(
              children: <Widget>[
                new Icon(Icons.chat),
                new Text(
                  " " + MainLocalizations.of(context).get("About/Feedback"),
                  style: Theme.of(context).textTheme.subhead,
                )
              ],
            ),
          ),
          new FlatButton(
            onPressed: () => Navigator
                .of(context)
                .push(new MaterialPageRoute(builder: (_) => new EatXPage())),
            child: new Row(
              children: <Widget>[
                new Icon(Icons.android),
                new Text(
                  " " + "EatX",
                  style: Theme.of(context).textTheme.subhead,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
