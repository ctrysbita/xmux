import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:xmux/mainapp/calendar/exams.dart';
import 'package:xmux/mainapp/calendar/timetable.dart';
import 'package:xmux/redux/redux.dart';
import 'package:xmux/translations/translation.dart';

class CalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
          appBar: AppBar(
            leading: StoreConnector<MainAppState, VoidCallback>(
              converter: (store) =>
                  () => store.dispatch(OpenDrawerAction(true)),
              builder: (context, callback) =>
                  IconButton(icon: Icon(Icons.view_list), onPressed: callback),
            ),
            title: Text(MainLocalizations.of(context).get("Calendar")),
            actions: <Widget>[
              IconButton(
                  icon: Icon(FontAwesomeIcons.calendarAlt),
                  tooltip: MainLocalizations.of(context)
                      .get("Calendar/CalendarImage"),
                  onPressed: () {
                    Navigator.of(context).pushNamed("/Calendar/CalendarImage");
                  })
            ],
            bottom: TabBar(isScrollable: false, tabs: <Tab>[
              Tab(
                text: MainLocalizations.of(context).get("Calendar/Classes"),
              ),
              Tab(
                text: MainLocalizations.of(context).get("Calendar/Exams"),
              ),
              Tab(
                text: MainLocalizations.of(context).get("Calendar/Assignments"),
              ),
            ]),
          ),
          body: StoreConnector<MainAppState, AcState>(
              builder: (BuildContext context, acState) =>
                  TabBarView(children: <Widget>[
                    TimeTablePage(acState.timetable),
                    ExamsPage(acState.exams),
//                    AssignmentPage(acState.assignments),
                  ]),
              converter: (s) => s.state.acState)),
    );
  }
}
