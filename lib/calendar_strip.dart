library calendar_strip;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './date-utils.dart';

class CalendarStrip extends StatefulWidget {
  // This widget is the root of your application.
  final Function onDateSelected;
  final Function dateTileBuilder;
  final BoxDecoration containerDecoration;
  final double containerHeight;
  final Function monthNameWidget;
  final Color iconColor;
  final DateTime selectedDate;
  final DateTime startDate;
  final DateTime endDate;
  final List<DateTime> markedDates;
  final bool addSwipeGesture;
  final bool weekStartsOnSunday;
  final Icon rightIcon;
  final Icon leftIcon;

  CalendarStrip({
    this.addSwipeGesture = false,
    this.weekStartsOnSunday = false,
    @required this.onDateSelected,
    this.dateTileBuilder,
    this.containerDecoration,
    this.containerHeight,
    this.monthNameWidget,
    this.iconColor,
    this.selectedDate,
    this.startDate,
    this.endDate,
    this.markedDates,
    this.rightIcon,
    this.leftIcon,
  });

  State<CalendarStrip> createState() =>
      CalendarStripState(selectedDate, startDate, endDate);
}

class CalendarStripState extends State<CalendarStrip>
    with TickerProviderStateMixin {
  DateTime currentDate = DateTime.now();
  DateTime selectedDate;
  String monthLabel;
  bool inBetweenMonths = false;
  DateTime rowStartingDate;
  double opacity = 0.0;
  DateTime lastDayOfMonth;
  TextStyle monthLabelStyle = TextStyle(
      fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87);
  TextStyle selectedDateStyle =
      TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white);
  bool isOnEndingWeek = false, isOnStartingWeek = false;
  bool doesDateRangeExists = false;
  DateTime today;

  List<String> monthLabels = [
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

  List<String> dayLabels = ["Mon", "Tue", "Wed", "Thr", "Fri", "Sat", "Sun"];

  CalendarStripState(
      DateTime selectedDate, DateTime startDate, DateTime endDate) {
    today = getDateOnly(DateTime.now());
    lastDayOfMonth = DateUtils.getLastDayOfMonth(currentDate);
    runPresetsAndExceptions(selectedDate, startDate, endDate);
    this.selectedDate = currentDate;
  }

  runPresetsAndExceptions(selectedDate, startDate, endDate) {
    if ((startDate == null && endDate != null) ||
        (startDate != null && endDate == null)) {
      throw Exception(
          "Both 'startDate' and 'endDate' are mandatory to specify range");
    } else if (selectedDate != null &&
        (isDateBefore(selectedDate, startDate) ||
            isDateAfter(selectedDate, endDate))) {
      throw Exception("Selected Date is out of range from start and end dates");
    } else if (startDate == null && startDate == null) {
      doesDateRangeExists = false;
    } else {
      doesDateRangeExists = true;
    }
    if (doesDateRangeExists) {
      if (endDate != null && isDateAfter(currentDate, endDate)) {
        currentDate = getDateOnly(startDate);
      } else if (isDateBefore(currentDate, startDate)) {
        currentDate = getDateOnly(startDate);
      }
    }
    if (selectedDate != null) {
      currentDate = getDateOnly(nullOrDefault(selectedDate, currentDate));
    }
  }

  @override
  void didUpdateWidget(CalendarStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate &&
        widget.selectedDate != null &&
        (isDateBefore(widget.selectedDate, widget.startDate) ||
            isDateAfter(widget.selectedDate, widget.endDate))) {
      throw Exception("Selected Date is out of range from start and end dates");
    } else {
      setState(() {
        selectedDate = getDateOnly(widget.selectedDate);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    int subtractDuration = widget.weekStartsOnSunday == true
        ? currentDate.weekday
        : currentDate.weekday - 1;
    rowStartingDate = rowStartingDate != null
        ? rowStartingDate
        : currentDate.subtract(Duration(days: subtractDuration));
    var dateRange = calculateDateRange(null);

    setState(() {
      isOnEndingWeek = dateRange['isEndingWeekOnRange'];
      isOnStartingWeek = dateRange['isStartingWeekOnRange'];
    });
  }

  int getLastDayOfMonth(rowStartingDay) {
    return DateUtils.getLastDayOfMonth(
            currentDate.add(Duration(days: rowStartingDay)))
        .day;
  }

  String getMonthName(
    DateTime dateObj,
  ) {
    return monthLabels[dateObj.month - 1];
  }

  String getMonthLabel() {
    DateTime startingDayObj = rowStartingDate,
        endingDayObj = rowStartingDate.add(Duration(days: 6));
    String label = "";
    if (startingDayObj.month == endingDayObj.month) {
      label = "${getMonthName(startingDayObj)} ${startingDayObj.year}";
    } else {
      var startingDayYear =
          "${startingDayObj.year == endingDayObj.year ? "" : startingDayObj.year}";
      label =
          "${getMonthName(startingDayObj)} $startingDayYear / ${getMonthName(endingDayObj)} ${endingDayObj.year}";
    }
    return label;
  }

  isDateBefore(date1, date2) {
    DateTime _date1 = DateTime(date1.year, date1.month, date1.day);
    DateTime _date2 = DateTime(date2.year, date2.month, date2.day);
    return _date1.isBefore(_date2);
  }

  isDateAfter(date1, date2) {
    DateTime _date1 = DateTime(date1.year, date1.month, date1.day);
    DateTime _date2 = DateTime(date2.year, date2.month, date2.day);
    return _date1.isAfter(_date2);
  }

  DateTime getDateOnly(DateTime dateTimeObj) {
    return DateTime(dateTimeObj.year, dateTimeObj.month, dateTimeObj.day);
  }

  bool isDateMarked(date) {
    date = getDateOnly(date);
    bool _isDateMarked = false;
    if (widget.markedDates != null) {
      widget.markedDates.forEach((DateTime eachMarkedDate) {
        if (getDateOnly(eachMarkedDate) == date) {
          _isDateMarked = true;
        }
      });
    }
    return _isDateMarked;
  }

  Map<String, bool> calculateDateRange(mode) {
    if (doesDateRangeExists) {
      DateTime _nextRowStartingDate;
      DateTime weekStartingDate, weekEndingDate;
      if (mode != null) {
        _nextRowStartingDate = mode == "PREV"
            ? rowStartingDate.subtract(Duration(days: 7))
            : rowStartingDate.add(Duration(days: 7));
      } else {
        _nextRowStartingDate = rowStartingDate;
      }
      weekStartingDate = getDateOnly(_nextRowStartingDate);
      weekEndingDate = getDateOnly(_nextRowStartingDate.add(Duration(days: 6)));
      bool isStartingWeekOnRange =
          isDateAfter(widget.startDate, weekStartingDate);
      bool isEndingWeekOnRange = isDateBefore(widget.endDate, weekEndingDate);
      return {
        "isEndingWeekOnRange": isEndingWeekOnRange,
        "isStartingWeekOnRange": isStartingWeekOnRange
      };
    } else {
      return {"isEndingWeekOnRange": false, "isStartingWeekOnRange": false};
    }
  }

  onPrevRow() {
    var dateRange = calculateDateRange("PREV");
    setState(() {
      rowStartingDate = rowStartingDate.subtract(Duration(days: 7));
      isOnEndingWeek = dateRange['isEndingWeekOnRange'];
      isOnStartingWeek = dateRange['isStartingWeekOnRange'];
    });
  }

  onNextRow() {
    var dateRange = calculateDateRange("NEXT");
    setState(() {
      rowStartingDate = rowStartingDate.add(Duration(days: 7));
      isOnEndingWeek = dateRange['isEndingWeekOnRange'];
      isOnStartingWeek = dateRange['isStartingWeekOnRange'];
    });
  }

  onDateTap(date) {
    if (!doesDateRangeExists) {
      setState(() {
        selectedDate = date;
        widget.onDateSelected(date);
      });
    } else if (!isDateBefore(date, widget.startDate) &&
        !isDateAfter(date, widget.endDate)) {
      setState(() {
        selectedDate = date;
        widget.onDateSelected(date);
      });
    } else {}
  }

  nullOrDefault(var normalValue, var defaultValue) {
    if (normalValue == null) {
      return defaultValue;
    }
    return normalValue;
  }

  monthLabelWidget(monthLabel) {
    if (widget.monthNameWidget != null) {
      return widget.monthNameWidget(monthLabel);
    }
    return Container(
        child: Text(monthLabel, style: monthLabelStyle),
        padding: EdgeInsets.only(top: 7, bottom: 3));
  }

  rightIconWidget() {
    if (!isOnEndingWeek) {
      return InkWell(
        child: widget.rightIcon ??
            Icon(
              CupertinoIcons.right_chevron,
              size: 30,
              color: nullOrDefault(widget.iconColor, Colors.black),
            ),
        onTap: onNextRow,
        splashColor: Colors.black26,
      );
    } else {
      return Container(width: 20);
    }
  }

  leftIconWidget() {
    if (!isOnStartingWeek) {
      return InkWell(
        child: widget.leftIcon ??
            Icon(
              CupertinoIcons.left_chevron,
              size: 30,
              color: nullOrDefault(widget.iconColor, Colors.black),
            ),
        onTap: onPrevRow,
        splashColor: Colors.black26,
      );
    } else {
      return Container(width: 20);
    }
  }

  checkOutOfRangeStatus(DateTime date) {
    date = DateTime(date.year, date.month, date.day);
    if (widget.startDate != null && widget.endDate != null) {
      if (!isDateBefore(date, widget.startDate) &&
          !isDateAfter(date, widget.endDate)) {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  onStripDrag(DragEndDetails details) {
    if (details.primaryVelocity == 0 || !widget.addSwipeGesture) return;
    if (details.primaryVelocity < 0) {
      if (!isOnEndingWeek) {
        onNextRow();
      }
    } else {
      if (!isOnStartingWeek) {
        onPrevRow();
      }
    }
  }

  buildDateRow() {
    List<Widget> currentWeekRow = [];
    for (var eachDay = 0; eachDay < 7; eachDay++) {
      var index = eachDay;
      currentWeekRow.add(dateTileBuilder(
          rowStartingDate.add(Duration(days: eachDay)), selectedDate, index));
    }
    monthLabel = getMonthLabel();
    return Column(children: [
      monthLabelWidget(monthLabel),
      Container(
          padding: EdgeInsets.all(0),
          child: GestureDetector(
            onHorizontalDragEnd: (DragEndDetails details) =>
                onStripDrag(details),
            child: Row(children: [
              leftIconWidget(),
              Expanded(child: Row(children: currentWeekRow)),
              rightIconWidget()
            ]),
          ))
    ]);
  }

  Widget dateTileBuilder(DateTime date, DateTime selectedDate, int rowIndex) {
    bool isDateOutOfRange = checkOutOfRangeStatus(date);
    String dayName = dayLabels[date.weekday - 1];
    if (widget.dateTileBuilder != null) {
      return Expanded(
        child: SlideFadeTransition(
          delay: 30 + (30 * rowIndex),
          id: "${date.day}${date.month}${date.year}",
          curve: Curves.ease,
          child: InkWell(
            customBorder: CircleBorder(),
            onTap: () => onDateTap(date),
            child: Container(
              child: widget.dateTileBuilder(date, selectedDate, rowIndex,
                  dayName, isDateMarked(date), isDateOutOfRange),
            ),
          ),
        ),
      );
    }

    bool isSelectedDate = date.compareTo(selectedDate) == 0;
    var normalStyle = TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: isDateOutOfRange ? Colors.black26 : Colors.black54);
    return Expanded(
      child: SlideFadeTransition(
        delay: 30 + (30 * rowIndex),
        id: "${date.day}${date.month}${date.year}",
        curve: Curves.ease,
        child: InkWell(
          onTap: () => onDateTap(date),
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 8, left: 5, right: 5, bottom: 5),
            decoration: BoxDecoration(
              color: !isSelectedDate ? Colors.transparent : Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(60)),
            ),
            child: Column(
              children: [
                Text(
                  dayLabels[date.weekday - 1],
                  style: TextStyle(
                    fontSize: 14.5,
                    color: !isSelectedDate ? Colors.black : Colors.white,
                  ),
                ),
                Text(date.day.toString(),
                    style: !isSelectedDate ? normalStyle : selectedDateStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }

  build(BuildContext context) {
    return Container(
      height: nullOrDefault(widget.containerHeight, 90.0),
      child: buildDateRow(),
      decoration: widget.containerDecoration != null
          ? widget.containerDecoration
          : BoxDecoration(),
    );
  }
}

class SlideFadeTransition extends StatefulWidget {
  final Widget child;
  final int delay;
  final String id;
  final Curve curve;

  SlideFadeTransition(
      {@required this.child, @required this.id, this.delay, this.curve});

  @override
  SlideFadeTransitionState createState() => SlideFadeTransitionState();
}

class SlideFadeTransitionState extends State<SlideFadeTransition>
    with TickerProviderStateMixin {
  AnimationController _animController;
  Animation<Offset> _animOffset;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();

    _animController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    final _curve = CurvedAnimation(
        curve: widget.curve != null ? widget.curve : Curves.decelerate,
        parent: _animController);
    _animOffset =
        Tween<Offset>(begin: const Offset(0.0, 0.25), end: Offset.zero)
            .animate(_curve);

    if (widget.delay == null) {
      if (!_disposed) _animController.forward();
    } else {
      _animController.reset();
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (!_disposed) _animController.forward();
      });
    }
  }

  @override
  void didUpdateWidget(SlideFadeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.id != oldWidget.id) {
      _animController.reset();
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (!_disposed) _animController.forward();
      });
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      child: SlideTransition(position: _animOffset, child: widget.child),
      opacity: _animController,
    );
  }
}
