import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yourhealth/data/models/appointment.dart';
import 'package:yourhealth/data/services/auth_services.dart';
import 'package:yourhealth/view/widgets/widgets.dart';


// number of appointments
// starting time and ending time
// fixed 20 minutes for everypatient | constant

class AppointmentPage extends StatefulWidget {
  AppointmentPage({Key key}) : super(key: key);

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  //List<AppointmentWidget> appointmentWidgetList = List<AppointmentWidget>();

  var _searchQuery;
  var numberOfAppointments;

  AsyncSnapshot<List<Appointment>> bubbleSort(AsyncSnapshot<List<Appointment>> snapshot){
    numberOfAppointments = snapshot.data.length;
    // print(numberOfAppointments);
    //snapshot.data.toList().reversed;
    Appointment temp;
    int com1; int com2;
    for( int i=0; i<numberOfAppointments-1; i++){

      for( int j=0; j<numberOfAppointments-i-1; j++) {
        com1 = timeSize(snapshot.data[j].time);
        com2 = timeSize(snapshot.data[j+1].time);

        if (com1 > com2) {
          temp = snapshot.data[j];
          snapshot.data[j] = snapshot.data[j + 1];
          snapshot.data[j + 1] = temp;
        }
      }
      //print( '${snapshot.data[i].time} = ${com1}');
    }

    return snapshot;
  }

  int timeSize(String visitingHour){

    String x = visitingHour;
    int startHour = int.parse(x.substring(0, 2));
    int startMin = int.parse(x.substring(3, 5));
    String startPeriod = x.substring(6, 8);

    startHour = startPeriod == 'PM' ? startHour + 12 : startHour;

    int time1 = (startHour*60) + startMin;

    return time1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [UserAvatarCustomSize(height: 40, width: 40)],
      ),
      body: StreamBuilder(
        stream: AuthenticationService().acceptedAppointments(false),
        builder:
            (BuildContext context, AsyncSnapshot<List<Appointment>> snapshot) {
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

           snapshot = bubbleSort(snapshot);
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
                        SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          padding: EdgeInsets.all(1),
                          child: FlatButton(
                            child: Text(
                              'Remove',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              _removeButtonPressed(snapshot.data[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                );
              });
        },
      ),
    );
  }

  _removeButtonPressed(Appointment appointment) async {
    await FirebaseFirestore.instance
        .collection('patients')
        .doc(appointment.patientId)
        .collection('appointments')
        .doc(appointment.appointmentId)
        .delete();
    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(appointment.doctorId)
        .collection('appointments')
        .doc(appointment.appointmentId)
        .delete();
    print('done');
  }
}
