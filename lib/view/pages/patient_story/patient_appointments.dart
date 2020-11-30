import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourhealth/data/models/doctor.dart';
import 'package:yourhealth/data/services/auth_services.dart';
import 'package:yourhealth/view/pages/patient_story/make_appointment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yourhealth/view/widgets/rounded_button.dart';
// visitingHour
// visitingHour to maxNumberofappointments
// appointmentList and maxNumberofappointments comparison

class PatientAppointments extends StatefulWidget {
  final String department;
  PatientAppointments({this.department});

  @override
  _PatientAppointmentsState createState() => _PatientAppointmentsState();
}

class _PatientAppointmentsState extends State<PatientAppointments> {

  String visitingHour;
  int appointmentListLength;
  int maxNumberOfAppointment;

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

  bool appointmentFull(int maxApp, int applist){
    if(applist>=maxApp)
      return true;
    return false;
  }

  void initState() {
    // TODO: implement initState
    super.initState();

    AuthenticationService().acceptedAppointments(false).listen((value) {
      setState(() {
        //Number Of Appointment Approved
        appointmentListLength = value.length;
        print("Appointment List Length: " +value.length.toString());
      });
    });

   // _getProfileData();
  }
  @override
  Widget build(BuildContext context) {
    //final doctors = Provider.of<List<Doctor>>(context);

    // for (var doc in doctors) {
    //   print(doc.name);
    //   print(doc.uid);
    //   print(doc.speciality);
    // }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Doctors'),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('doctors')
              .where("speciality", isEqualTo: widget.department.toString())
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
              ));
            }
            // for (var doc in snapshot.data) {
            //   print(doc.name);
            //   print(doc.uid);
            //   print(doc.speciality);
            // }

            print(snapshot.data.docs.length);
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {

                  visitingHour = snapshot.data.docs[index].data()['visitingHour'];
                  print(visitingHour);
                 // maxNumberOfAppointment = maxNumberOfApp(visitingHour);
                  return Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.person,
                            size: 40,
                          ),
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data.docs[index].data()['name'] ?? '',
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.timer),
                                      Text(snapshot.data.docs[index]
                                              .data()['visitingHour'] ??
                                          ''),
                                    ],
                                  ),
                                  /*Text(snapshot.data.docs[index]
                                          .data()['speciality'] ??
                                      ''),*/
                                  Row(
                                    children: [
                                      Icon(Icons.location_city),
                                      Text(snapshot.data.docs[index]
                                              .data()['location'] ??
                                          ''),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {},
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            RaisedButton(
                                child: Text(
                                  'Info',
                                  style: TextStyle(color: Colors.white),
                                ),
                                color: Colors.blue,
                                onPressed: () {
                                  Doctor doctor = Doctor(
                                    name: snapshot.data.docs[index]
                                        .data()['name'],
                                    uid: snapshot.data.docs[index].id,
                                    speciality: snapshot.data.docs[index]
                                        .data()['speciality'],
                                    location: snapshot.data.docs[index]
                                        .data()['location'],
                                    visitingHour: snapshot.data.docs[index]
                                        .data()['visitingHour'],
                                  );
                                  _showDoctorInfo(context, doctor);
                                }),

                            //appointmentFull(maxNumberOfAppointment, appointmentListLength) ? Text('Doctor Booked') :

                            RaisedButton(
                                child: Text(
                                  'Make Appointment',
                                  style: TextStyle(color: Colors.white),
                                ),
                                color: Colors.blue,
                                onPressed: () {
                                  Doctor doctor = Doctor(
                                    name: snapshot.data.docs[index]
                                        .data()['name'],
                                    uid: snapshot.data.docs[index].id,
                                    speciality: snapshot.data.docs[index]
                                        .data()['speciality'],
                                    location: snapshot.data.docs[index]
                                        .data()['location'],
                                    visitingHour: snapshot.data.docs[index]
                                        .data()['visitingHour'],
                                  );
                                  _listTileTapped(context, doctor);
                                }),
                          ],
                        ),
                      ],
                    ),
                  );
                });
          }),
    );
  }

  _listTileTapped(BuildContext context, Doctor doctor) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MakeAppointment(doctor: doctor)));
  }

  Future<void> _showDoctorInfo(BuildContext context, Doctor doctor) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Doctor Info'),
          content: SingleChildScrollView(
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoWidget(
                    fieldName: 'Name',
                    fieldData: doctor.name,
                  ),
                  InfoWidget(
                    fieldName: 'Speciality',
                    fieldData: doctor.speciality,
                  ),
                  InfoWidget(
                    fieldName: 'Visiting Hour',
                    fieldData: doctor.visitingHour,
                  ),
                  InfoWidget(
                    fieldName: 'Location',
                    fieldData: doctor.location,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Return'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class InfoWidget extends StatelessWidget {
  final String fieldName;
  final String fieldData;

  InfoWidget({this.fieldData, this.fieldName});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(fieldName,
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(fieldData,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
              )),
          Divider(),
        ],
      ),
    );
  }
}
