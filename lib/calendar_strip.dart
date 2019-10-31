library calendar_strip;

import 'dart:developer';

import 'package:flutter/material.dart';
import './date-utils.dart';

class CalendarStrip extends StatefulWidget {
  // This widget is the root of your application.
  State<CalendarStrip> createState() => CalendarStripState();
}

class CalendarStripState extends State<CalendarStrip> {
  DateTime currentDate = DateTime.now();
  DateTime selectedDate = DateTime.now();
  String monthLabel;
  bool inBetweenMonths = false;
  int rowStartingDay;
  DateTime lastDayOfMonth;
  List monthLabels = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  CalendarStripState() {
    lastDayOfMonth = DateUtils.getLastDayOfMonth(currentDate);
  }

  int getLastDayOfMonth(rowStartingDay) {
    return DateUtils.getLastDayOfMonth(currentDate.add(Duration(days: rowStartingDay))).day;
  }

  String getMonthLabel() {
    int startingDayMonth, endingDayMonth;
    int rowEndingDay = rowStartingDay + 7;
    String label = "";
    print(rowStartingDay);
    if (rowStartingDay > 0) {
      startingDayMonth = currentDate.add(Duration(days: rowStartingDay.abs())).month;
    } else {
      startingDayMonth = currentDate.subtract(Duration(days: rowStartingDay.abs())).month;
    }

    if (rowEndingDay > 0) {
      endingDayMonth = currentDate.add(Duration(days: rowEndingDay.abs())).month;
    } else {
      endingDayMonth = currentDate.subtract(Duration(days: rowEndingDay.abs())).month;
    }

    print("$startingDayMonth $endingDayMonth");
    if (startingDayMonth == endingDayMonth) {
      label = monthLabels[startingDayMonth - 1];
    } else {
      label = "${monthLabels[startingDayMonth - 1]} / ${monthLabels[endingDayMonth - 1]}";
    }
    return label;
  }

  onPrevRow() {
    setState(() {
      rowStartingDay = rowStartingDay - 7;
    });
  }

  onNextRow() {
    setState(() {
      rowStartingDay = rowStartingDay + 7;
    });
  }

  buildDateRow() {
    List<Widget> currentWeekRow = [];
    rowStartingDay = rowStartingDay != null ? rowStartingDay : currentDate.day - currentDate.weekday + 1;
    monthLabel = getMonthLabel();
    for (var eachDay = rowStartingDay; eachDay < rowStartingDay + 7; eachDay++) {
      if (eachDay > currentDate.day) {
        currentWeekRow.add(dateTileBuilder(currentDate.add(Duration(days: eachDay))));
      } else {
        currentWeekRow.add(dateTileBuilder(currentDate.subtract(Duration(days: currentDate.day - eachDay))));
      }
    }
    return Column(children: [
      Container(child: Text(monthLabel)),
      Container(
        child: Row(children: [
          GestureDetector(child: Container(child: Icon(Icons.chevron_left, size: 40)), onTap: onPrevRow),
          Expanded(child: Row(children: currentWeekRow)),
          GestureDetector(child: Container(child: Icon(Icons.chevron_right, size: 40)), onTap: onNextRow),
        ]),
      )
    ]);
  }

  Widget dateTileBuilder(DateTime date) {
    return Expanded(
      child: Container(
          alignment: Alignment.center,
          child: Text(
            date.day.toString(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          )),
    );
  }

  build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.red)),
      child: buildDateRow(),
    );
  }
}
