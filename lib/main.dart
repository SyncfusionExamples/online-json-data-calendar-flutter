import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

void main() => runApp(new JsonData());

class JsonData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnlineJsonData(),
    );
  }
}

class OnlineJsonData extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ScheduleExample();
}

class ScheduleExample extends State<OnlineJsonData> {
  Future<List<OnlineAppointmentData>> _getOnlineData() async {
    var data = await http.get(
        "https://js.syncfusion.com/demos/ejservices/api/Schedule/LoadData");
    var jsonData = json.decode(data.body);
    List<OnlineAppointmentData> appointmentData = [];
    for (var u in jsonData) {
      OnlineAppointmentData user = OnlineAppointmentData(
          u['StartTime'], u['EndTime'], u['Subject'], u['AllDay']);
      appointmentData.add(user);
    }
    print(appointmentData.length);
    return appointmentData;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      body: Container(
        child: FutureBuilder(
          future: _getOnlineData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data != null) {
              List<Meeting> collection;
              if (snapshot.data != null) {
                for (int i = 0; i < snapshot.data.length; i++) {
                  collection ??= <Meeting>[];
                  var meeting= snapshot.data[i];
                  collection.add(
                    Meeting(
                        eventName: meeting.subject,
                        from: convertDateFromString(meeting.startTime),
                        to: convertDateFromString(meeting.endTime),
                        background: Colors.red,
                        allDay: meeting.allDay),
                  );
                }
              }
              return Container(
                  child: SfCalendar(
                    view: CalendarView.month,
                    initialDisplayDate: DateTime(2017, 6, 23, 9, 0, 0),
                    monthViewSettings: MonthViewSettings(showAgenda: true),
                    dataSource: _getCalendarDataSource(collection),
                  ));
            } else {
              return Container(
                child: Center(
                  child: Text('loading...'),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  DateTime convertDateFromString(String date) {
    DateTime todayDate = DateTime.parse(date);
    return todayDate;
  }
}

class OnlineAppointmentData {
  String startTime;
  String endTime;
  String subject;
  bool allDay;

  OnlineAppointmentData(
      this.startTime, this.endTime, this.subject, this.allDay);
}

MeetingDataSource _getCalendarDataSource([List<Meeting> collection]) {
  List<Meeting> meetings = collection ?? <Meeting>[];
  return MeetingDataSource(meetings);
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].to;
  }

  @override
  String getSubject(int index) {
    return appointments[index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments[index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].allDay;
  }
}

class Meeting {
  Meeting(
      {this.eventName,
      this.from,
      this.to,
      this.background,
      this.allDay = false});

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool allDay;
}
