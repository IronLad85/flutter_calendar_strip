import 'package:flutter/material.dart';
import 'package:calendar_strip/calendar_strip.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime startDate = DateTime.now().subtract(Duration(days: 5));
  DateTime endDate = DateTime.now().add(Duration(days: 5));
  DateTime selectedDate = DateTime.now().add(Duration(days: 9));

  onSelect(data) {
    print("DAMN -> $data");
  }

  _monthNameWidget(monthName) {
    return Container(
      child: Text(monthName, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
      padding: EdgeInsets.only(top: 8, bottom: 4),
    );
  }

  dateTileBuilder(DateTime date, DateTime selectedDate, int rowIndex, List<String> dayLabels, bool isDateOutOfRange) {
    bool isSelectedDate = date.compareTo(selectedDate) == 0;
    TextStyle normalStyle =
        TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: isDateOutOfRange ? Colors.white30 : Colors.white);
    TextStyle selectedStyle = TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white);
    TextStyle dayNameStyle = TextStyle(
        fontSize: 14.5, color: isDateOutOfRange ? Colors.white30 : !isSelectedDate ? Colors.white : Colors.white);

    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 8, left: 5, right: 5, bottom: 5),
      decoration: BoxDecoration(
        color: !isSelectedDate ? Colors.transparent : Colors.white30,
        borderRadius: BorderRadius.all(Radius.circular(60)),
      ),
      child: Column(
        children: [
          Text(dayLabels[date.weekday - 1], style: dayNameStyle),
          Text(date.day.toString(), style: !isSelectedDate ? normalStyle : selectedStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
          child: CalendarStrip(
        startDate: startDate,
        endDate: endDate,
        onDateSelected: onSelect,
        dateTileBuilder: dateTileBuilder,
        iconColor: Colors.white,
        monthNameWidget: _monthNameWidget,
        containerDecoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color.fromRGBO(119, 64, 255, 0.9), Color.fromRGBO(191, 57, 113, 0.8)],
          ),
        ),
      )),
    );
  }
}
