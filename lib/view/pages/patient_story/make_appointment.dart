import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yourhealth/data/models/doctor.dart';
import 'package:yourhealth/data/services/auth_services.dart';
import 'package:yourhealth/view/pages/patient_story/patient_home.dart';
import 'package:intl/intl.dart';
// visiting Hour
// max number of appointments
// appointment List length
class MakeAppointment extends StatefulWidget {
  final Doctor doctor;

  MakeAppointment({this.doctor});
  @override
  _MakeAppointmentState createState() => _MakeAppointmentState();
}

class _MakeAppointmentState extends State<MakeAppointment> {
  bool _sendingData = false;
  final _formKey = GlobalKey<FormState>();
  double _height;
  double _width;

  DateTime _selectedDate = DateTime.now().add(Duration(days: 1));
  String _setTime, _setDate;

  String _hour, _minute, _time;

  String dateTime;

  TimeOfDay _selectedTime = TimeOfDay(hour: 00, minute: 00);

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  String _message = '';

  var visitingHour;
  var docUID;
  var appointmentListLength;
  var maxNoAppointments;

  int maxNumberOfApp(String visitingHour){

    String x = visitingHour;

    int startHour = int.parse(x.substring(0, 2));
    int startMin = int.parse(x.substring(3, 5));
    String startPeriod = x.substring(6, 8);

//   print('$startHour $startMin $startPeriod');
    startHour = startPeriod == 'PM' ? startHour + 12 : startHour;

    int endHour = int.parse(x.substring(11, 13));
    int endMin = int.parse(x.substring(14, 16));
    String endPeriod = x.substring(17, 19);
//   print('$endHour $endMin $endPeriod');
    endHour = endPeriod == 'PM' ? endHour + 12 : endHour;

    final now = DateTime.now();
    var dt = DateTime(now.year, now.month, now.day, startHour, startMin);
    var endDt = DateTime(now.year, now.month, now.day, endHour, endMin);
    var diff = endDt.difference(dt).inMinutes;

    //print(diff);
    var maxNoApp = diff/20;

//  print(maxNoApp);

    return maxNoApp.toInt();

  }


  _getProfileData() async {

    String uid = widget.doctor.uid; //Fwidget.doctor.ui

    DocumentSnapshot snapshot =
    await FirebaseFirestore.instance.collection('doctors').doc(uid).get();
    var _profileData = snapshot.data();
    //print(_profileData);
    setState(() {
      visitingHour = _profileData['visitingHour'];
      //  print("Visting Hour: " + visitingHour);
      //  getAppointmentTime(visitingHour, 5);
    });
    print(visitingHour);
    var x = visitingHour;
    maxNoAppointments = maxNumberOfApp(x);
    print('Max number of app: ${maxNoAppointments}');
    print('Appointments List length: ${appointmentListLength}');

  }
  @override
  void initState() {
    super.initState();
    _dateController.text =
        DateFormat('EEEE, d MMM, yyyy').format(_selectedDate);
    _hour = _selectedTime.hour.toString();
    _minute = _selectedTime.minute.toString();
    _time = _hour + ' : ' + _minute;
    _timeController.text = _time;
//need to build a new fuction with Widget.uid
    String uid;
    AuthenticationService().acceptedAppointmentsForAPP(widget.doctor.uid).listen((value) {
      setState(() {
        //Number Of Appointment Approved
        appointmentListLength = value.length;
       // print(value.length);
      });
    });

    _getProfileData();

  }



  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      //resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Make an appointment'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Choose Date',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5),
              ),
              InkWell(
                onTap: () {
                  _showDatePicker(context);
                },
                child: Container(
                  width: _width / 1.7,
                  height: _height / 9,
                  margin: EdgeInsets.only(top: 30),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  child: TextFormField(
                    style: TextStyle(fontSize: 40),
                    textAlign: TextAlign.center,
                    enabled: false,
                    keyboardType: TextInputType.text,
                    controller: _dateController,
                    onSaved: (String val) {
                      _setDate = val;
                    },
                    decoration: InputDecoration(
                        disabledBorder:
                            UnderlineInputBorder(borderSide: BorderSide.none),
                        // labelText: 'Time',
                        contentPadding: EdgeInsets.only(top: 0.0)),
                  ),
                ),
              ),
              Text(
                'Doctor will see your short massage and after acceptinng appoinment you will get yout time',
                style: TextStyle(
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5),
              ),
              // InkWell(
              //   onTap: () {
              //     _selectTime(context);
              //   },
              //   child: Container(
              //     margin: EdgeInsets.only(top: 30),
              //     width: _width / 1.7,
              //     height: _height / 9,
              //     alignment: Alignment.center,
              //     decoration: BoxDecoration(color: Colors.grey[200]),
              //     child: TextFormField(
              //       style: TextStyle(fontSize: 40),
              //       textAlign: TextAlign.center,
              //       onSaved: (String val) {
              //         _setTime = val;
              //       },
              //       enabled: false,
              //       keyboardType: TextInputType.text,
              //       controller: _timeController,
              //       decoration: InputDecoration(
              //           disabledBorder:
              //               UnderlineInputBorder(borderSide: BorderSide.none),
              //           // labelText: 'Time',
              //           contentPadding: EdgeInsets.all(5)),
              //     ),
              //   ),
              // ),
              Form(
                key: _formKey,
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextFormField(
                    validator: (value) => value.isEmpty
                        ? 'Please provide a message for doctor'
                        : null,
                    onChanged: (value) {
                      setState(() {
                        _message = value;
                      });
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Write a short message for doctor',
                    ),
                  ),
                ),
              ),
              (appointmentListLength<maxNoAppointments) ?
              Builder(builder: (buttonContext) {

                
                return RaisedButton(
                  elevation: 10,
                  onPressed: () {
                    _setAppointment(context, buttonContext);
                  },
                  color: Colors.blue,
                  child: !_sendingData
                      ? Text(
                          'Set appointment',
                          style: TextStyle(color: Colors.white),
                        )
                      : CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                );
              }) : Text("Doctor Busy! Come Back Later. Thank You!")
            ],
          ),
        ),
      ),
    );
  }

  _showDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // Refer step 1
      firstDate: _selectedDate,
      lastDate: DateTime(2025),
      initialEntryMode: DatePickerEntryMode.input,
      helpText: 'Select a day for your appointment',
      confirmText: 'Set this day',
      errorFormatText: 'Enter valid date',
      errorInvalidText: 'Enter date in valid range',
      fieldLabelText: 'Appointment date',
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            DateFormat('EEEE, d MMM, yyyy').format(_selectedDate);
      });
  }

  _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null)
      setState(() {
        _selectedTime = picked;
        _hour = _selectedTime.hour.toString();
        _minute = _selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        _timeController.text = _selectedTime.format(context);
        //_timeController.text = _selectedTime.toString();
        // formatDate(
        //     DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
        //     [hh, ':', nn, " ", am]).toString();
      });
  }

  _setAppointment(BuildContext context, BuildContext buttonContext) async {
    if (_formKey.currentState.validate()) {
      setState(() => _sendingData = true);
      String patientName = '';
      String uid = FirebaseAuth.instance.currentUser.uid;
      final data =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      patientName = data.data()['name'];

      DocumentReference document = FirebaseFirestore.instance
          .collection('patients')
          .doc(uid)
          .collection('pendingAppointments')
          .doc();

      Map<String, dynamic> appointment = {
        'patientName': patientName,
        'doctorName': widget.doctor.name,
        'date': _dateController.text,
        'time': null,
        'message': _message,
        'patientId': uid,
        'doctorId': widget.doctor.uid,
        'appointmentId': document.id,
      };
      await document.set(appointment);
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctor.uid)
          .collection('pendingAppointments')
          .doc(document.id)
          .set(appointment);
      setState(() => _sendingData = false);
      Scaffold.of(buttonContext).showSnackBar(SnackBar(
          content: Text('Appointment request sent successfully'),
          onVisible: () async {
            await Future.delayed(Duration(seconds: 3));
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => PatientHome()),
                (Route<dynamic> route) => false);
          }));
    }
  }
}
