import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yourhealth/data/models/appointment.dart';
import 'package:yourhealth/data/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
class DoctorAppointmentRequests extends StatefulWidget {

  // number of appointments OK
  // starting time and ending time from doctors OK
  // calculate time string to hour/minute
  // fixed 20 minutes for everypatient | constant


  @override
  _DoctorAppointmentRequestsState createState() => _DoctorAppointmentRequestsState();
}

class _DoctorAppointmentRequestsState extends State<DoctorAppointmentRequests> {

  var appointmentListLength;

  String visitingHour;
  String appointmentTime;

  String convert24To12(DateTime dt ){

    String period = "AM";
    int hour = dt.hour;
    int minute = dt.minute;
    if(hour >= 12){
      period = "PM";
    }
    if(hour > 12){
      hour = hour - 12;
    }

    String hourStr = "";
    String minuteStr = "";
    if( hour < 10){
      hourStr = "0" + hour.toString();
    }else{
      hourStr = hour.toString();
    }
    if(minute < 10){
      minuteStr = "0" + minute.toString();
    }else{
      minuteStr = minute.toString();
    }
    String resultStr = "${hourStr}:${minuteStr}" + " ${period}";
    // print(resultStr);
    return resultStr;

  }

  String getAppointmentTime(String visitingHour, int numberOfAppointment){

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

//   print('${dt.hour}:${dt.minute}\n\n');

    var numberOfApp = numberOfAppointment;
    var minuteIncrease = numberOfApp*20;
    dt = dt.add(Duration(minutes: minuteIncrease));
    String result = convert24To12(dt);
    //print(result);

    return result;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    AuthenticationService().acceptedAppointments(false).listen((value) {
      setState(() {
        //Number Of Appointment Approved
        appointmentListLength = value.length;
        print(value.length);
      });
    });

    _getProfileData();
  }

  _getProfileData() async {

    String uid = FirebaseAuth.instance.currentUser.uid;
    DocumentSnapshot snapshot =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();
    var _profileData = snapshot.data();
    //print(_profileData);
    setState(() {
      visitingHour = _profileData['visitingHour'];
    //  print("Visting Hour: " + visitingHour);
    //  getAppointmentTime(visitingHour, 5);
    });
    print(visitingHour);
    appointmentTime = getAppointmentTime(visitingHour, appointmentListLength);
    print(appointmentTime);
  }
  @override
  Widget build(BuildContext context) {

   // print(appointmentListLength);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Appointment Requests'),
      ),
      body: StreamBuilder(
          stream: AuthenticationService().appointments(false),
          builder: (BuildContext context,
              AsyncSnapshot<List<Appointment>> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
              ));
            }
            // for (var doc in snapshot.data) {
            //   print(doc.patientName);
            //   print(doc.date);
            //   print(doc.time);
            //   print(doc.message);
            // }
           // print(snapshot.data.length);

            return ListView.builder(

                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Icon(
                        Icons.person,
                        size: 40,
                      ),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data[index].patientName,
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          Text(snapshot.data[index].date),
                          Text(snapshot.data[index].time),
                          Text(snapshot.data[index].message),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  icon: Icon(
                                    Icons.library_add_check,
                                  ),
                                  onPressed: () {
                                    _onAcceptButtonPressed(
                                        context, snapshot.data[index]);
                                  }),
                              SizedBox(width: 50),
                              IconButton(
                                  icon: Icon(Icons.cancel),
                                  onPressed: () {
                                    _onRejectButtonPressed(
                                        context, snapshot.data[index]);
                                  }),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {},
                    ),
                  );
                });
          }),
    );
  }

  _onAcceptButtonPressed(BuildContext context, Appointment appointment) async {
    // print("Doctor ID: ${appointment.doctorId}");
    // Stream<QuerySnapshot> snapshot = FirebaseFirestore.instance
    //     .collection("doctors")
    //     .doc(appointment.doctorId)
    //     .collection("appointments")
    //     .snapshots();
    // ;
    //print("Snapshot: ${snapshot}");
    Map<String, dynamic> data = {
      'patientName': appointment.patientName,
      'doctorName': appointment.doctorName,
      'date': appointment.date,
      'time': appointmentTime,
      'message': appointment.message,
      'patientId': appointment.patientId,
      'doctorId': appointment.doctorId,
      'appointmentId': appointment.appointmentId,
    };
    await FirebaseFirestore.instance
        .collection('patients')
        .doc(appointment.patientId)
        .collection('appointments')
        .doc(appointment.appointmentId)
        .set(data);
    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(appointment.doctorId)
        .collection('appointments')
        .doc(appointment.appointmentId)
        .set(data);
    await FirebaseFirestore.instance
        .collection('patients')
        .doc(appointment.patientId)
        .collection('pendingAppointments')
        .doc(appointment.appointmentId)
        .delete();
    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(appointment.doctorId)
        .collection('pendingAppointments')
        .doc(appointment.appointmentId)
        .delete();
  }

  _onRejectButtonPressed(BuildContext context, Appointment appointment) async {
    await FirebaseFirestore.instance
        .collection('patients')
        .doc(appointment.patientId)
        .collection('pendingAppointments')
        .doc(appointment.appointmentId)
        .delete();
    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(appointment.doctorId)
        .collection('pendingAppointments')
        .doc(appointment.appointmentId)
        .delete();
  }
}
