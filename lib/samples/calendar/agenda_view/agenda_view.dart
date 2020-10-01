///Dart imports
import 'dart:math';

///Package imports
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

///calendar import
import 'package:syncfusion_flutter_calendar/calendar.dart';

///Local import
import '../../../model/sample_view.dart';

/// Widget of the AgendaView Calendar.
class AgendaViewCalendar extends SampleView {
  /// Cr
  const AgendaViewCalendar(Key key) : super(key: key);

  @override
  _AgendaViewCalendarState createState() => _AgendaViewCalendarState();
}

class _AgendaViewCalendarState extends SampleViewState {
  _AgendaViewCalendarState();

  List<String> subjectCollection;
  List<Color> colorCollection;
  List<_Meeting> meetings;
  _MeetingDataSource events;
  CalendarController calendarController;
  Orientation _deviceOrientation;

  @override
  void initState() {
    meetings = <_Meeting>[];
    calendarController = CalendarController();
    calendarController.selectedDate = DateTime.now();
    _addAppointmentDetails();
    _addAppointments();
    events = _MeetingDataSource(meetings);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _deviceOrientation = MediaQuery.of(context).orientation;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final Widget _calendar = Theme(
        data: model.themeData.copyWith(accentColor: model.backgroundColor),
        child:
            _getAgendaViewCalendar(events, _onViewChanged, calendarController));
    return model.isMobileResolution &&
            _deviceOrientation == Orientation.landscape
        ? Scrollbar(
            child: ListView(
            children: <Widget>[
              Container(
                color: model.cardThemeColor,
                height: 600,
                child: _calendar,
              )
            ],
          ))
        : Container(
            color: model.cardThemeColor,
            child: _calendar,
          );
  }

  /// Creates the required appointment details as a list.
  void _addAppointmentDetails() {
    subjectCollection = <String>[];
    subjectCollection.add('General Meeting');
    subjectCollection.add('Plan Execution');
    subjectCollection.add('Project Plan');
    subjectCollection.add('Consulting');
    subjectCollection.add('Support');
    subjectCollection.add('Development Meeting');
    subjectCollection.add('Scrum');
    subjectCollection.add('Project Completion');
    subjectCollection.add('Release updates');
    subjectCollection.add('Performance Check');

    colorCollection = <Color>[];
    colorCollection.add(const Color(0xFF0F8644));
    colorCollection.add(const Color(0xFF8B1FA9));
    colorCollection.add(const Color(0xFFD20100));
    colorCollection.add(const Color(0xFFFC571D));
    colorCollection.add(const Color(0xFF36B37B));
    colorCollection.add(const Color(0xFF01A1EF));
    colorCollection.add(const Color(0xFF3D4FB5));
    colorCollection.add(const Color(0xFFE47C73));
    colorCollection.add(const Color(0xFF636363));
    colorCollection.add(const Color(0xFF0A8043));
  }

  /// Method that creates the collection the data source for calendar, with
  /// required information.
  void _addAppointments() {
    final Random random = Random();
    final DateTime rangeStartDate =
        DateTime.now().add(const Duration(days: -(365 ~/ 2)));
    final DateTime rangeEndDate = DateTime.now().add(const Duration(days: 365));
    for (DateTime i = rangeStartDate;
        i.isBefore(rangeEndDate);
        i = i.add(const Duration(days: 1))) {
      final DateTime date = i;
      final int count = 1 + random.nextInt(3);
      for (int j = 0; j < count; j++) {
        final DateTime startDate = DateTime(
            date.year, date.month, date.day, 8 + random.nextInt(8), 0, 0);
        meetings.add(_Meeting(
            subjectCollection[random.nextInt(7)],
            '',
            '',
            null,
            startDate,
            startDate.add(Duration(hours: random.nextInt(3))),
            colorCollection[random.nextInt(9)],
            false,
            '',
            '',
            ''));
      }
    }

    // added recurrence appointment
    meetings.add(_Meeting(
        'Development status',
        '',
        '',
        null,
        DateTime.now(),
        DateTime.now().add(const Duration(hours: 2)),
        colorCollection[random.nextInt(9)],
        false,
        '',
        '',
        'FREQ=WEEKLY;BYDAY=FR;INTERVAL=1'));
  }

  /// Updated the selected date of calendar, when the months swiped, selects the
  /// current date when the calendar displays the current month, and selects the
  /// first date of the month for rest of the months.
  void _onViewChanged(ViewChangedDetails visibleDatesChangedDetails) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final DateTime currentViewDate = visibleDatesChangedDetails
          .visibleDates[visibleDatesChangedDetails.visibleDates.length ~/ 2];
      if (model.isWeb) {
        if (DateTime.now()
                .isAfter(visibleDatesChangedDetails.visibleDates[0]) &&
            DateTime.now().isBefore(visibleDatesChangedDetails.visibleDates[
                visibleDatesChangedDetails.visibleDates.length - 1])) {
          calendarController.selectedDate = DateTime.now();
        } else {
          calendarController.selectedDate =
              visibleDatesChangedDetails.visibleDates[0];
        }
      } else {
        if (currentViewDate.month == DateTime.now().month &&
            currentViewDate.year == DateTime.now().year) {
          calendarController.selectedDate = DateTime.now();
        } else {
          calendarController.selectedDate =
              DateTime(currentViewDate.year, currentViewDate.month, 01);
        }
      }
    });
  }

  /// Returns the calendar widget based on the properties passed.
  SfCalendar _getAgendaViewCalendar(
      [CalendarDataSource _calendarDataSource,
      ViewChangedCallback onViewChanged,
      CalendarController controller]) {
    return SfCalendar(
      view: CalendarView.month,
      controller: controller,
      showDatePickerButton: true,
      showNavigationArrow: model.isWeb,
      onViewChanged: onViewChanged,
      dataSource: _calendarDataSource,
      monthViewSettings: MonthViewSettings(
          showAgenda: true, numberOfWeeksInView: model.isWeb ? 2 : 6),
      timeSlotViewSettings: TimeSlotViewSettings(
          minimumAppointmentDuration: const Duration(minutes: 60)),
    );
  }
}

/// An object to set the appointment collection data source to collection, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class _MeetingDataSource extends CalendarDataSource {
  _MeetingDataSource(this.source);

  List<_Meeting> source;

  @override
  List<_Meeting> get appointments => source;

  @override
  DateTime getStartTime(int index) {
    return source[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return source[index].to;
  }

  @override
  bool isAllDay(int index) {
    return source[index].isAllDay;
  }

  @override
  String getSubject(int index) {
    return source[index].eventName;
  }

  @override
  String getStartTimeZone(int index) {
    return source[index].startTimeZone;
  }

  @override
  String getEndTimeZone(int index) {
    return source[index].endTimeZone;
  }

  @override
  Color getColor(int index) {
    return source[index].background;
  }

  @override
  String getRecurrenceRule(int index) {
    return source[index].recurrenceRule;
  }
}

/// Custom business object class which contains properties to hold the detailed
/// information about the event data which will be rendered in calendar.
class _Meeting {
  _Meeting(
      this.eventName,
      this.organizer,
      this.contactID,
      this.capacity,
      this.from,
      this.to,
      this.background,
      this.isAllDay,
      this.startTimeZone,
      this.endTimeZone,
      this.recurrenceRule);

  String eventName;
  String organizer;
  String contactID;
  int capacity;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
  String startTimeZone;
  String endTimeZone;
  String recurrenceRule;
}
