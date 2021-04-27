import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:connectivity/connectivity.dart';

void main() => runApp(new JsonData());

class JsonData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnlineJsonData(),
    );
  }
}

class OnlineJsonData extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CalendarExample();
}

class CalendarExample extends State<OnlineJsonData> {
  List<Color> _colorCollection=<Color>[];
  String? _networkStatusMsg;
  final Connectivity _internetConnectivity = new Connectivity();

  @override
  void initState() {
    _initializeEventColor();
    _checkNetworkStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Container(
        child: FutureBuilder(
          future: getDataFromWeb(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data != null) {
              return SafeArea(
                child: Container(
                    child: SfCalendar(
                      view: CalendarView.week,
                      initialDisplayDate: DateTime(2017, 6, 01, 9, 0, 0),
                      dataSource: MeetingDataSource(snapshot.data),
                    )),
              );
            } else {
              return Container(
                child: Center(
                  child: Text('$_networkStatusMsg'),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<Meeting>> getDataFromWeb() async {
    var data = await http.get(Uri.parse("https://js.syncfusion.com/demos/ejservices/api/Schedule/LoadData"));
    var jsonData = json.decode(data.body);

    final List<Meeting> appointmentData = [];
    final Random random = new Random();
    for (var data in jsonData) {
      Meeting meetingData = Meeting(
          eventName: data['Subject'],
          from: _convertDateFromString(
            data['StartTime'],
          ),
          to: _convertDateFromString(data['EndTime']),
          background: _colorCollection[random.nextInt(9)],
          allDay: data['AllDay']);
      appointmentData.add(meetingData);
    }
    return appointmentData;
  }


  DateTime _convertDateFromString(String date) {
    return DateTime.parse(date);
  }

  void _initializeEventColor() {
    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF8B1FA9));
    _colorCollection.add(const Color(0xFFD20100));
    _colorCollection.add(const Color(0xFFFC571D));
    _colorCollection.add(const Color(0xFF36B37B));
    _colorCollection.add(const Color(0xFF01A1EF));
    _colorCollection.add(const Color(0xFF3D4FB5));
    _colorCollection.add(const Color(0xFFE47C73));
    _colorCollection.add(const Color(0xFF636363));
    _colorCollection.add(const Color(0xFF0A8043));
  }

  void _checkNetworkStatus() {
    _internetConnectivity.onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        _networkStatusMsg = result.toString();
        if (_networkStatusMsg == "ConnectivityResult.mobile") {
          _networkStatusMsg =
          "You are connected to mobile network, loading calendar data ....";
        } else if (_networkStatusMsg == "ConnectivityResult.wifi") {
          _networkStatusMsg =
          "You are connected to wifi network, loading calendar data ....";
        } else {
          _networkStatusMsg =
          "Internet connection may not be available. Connect to another network";
        }
      });
    });
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].allDay;
  }
}

class Meeting {
  Meeting(
      {this.eventName,
        this.from,
        this.to,
        this.background,
        this.allDay = false});

  String? eventName;
  DateTime? from;
  DateTime? to;
  Color? background;
  bool? allDay;
}
