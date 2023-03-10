import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const HealthApp());

class HealthApp extends StatelessWidget {
  const HealthApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "My Health Data",
      home: const HealthDataScreen(),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF101820),
          appBarTheme: const AppBarTheme(color: Color(0xFF101820))),
    );
  }
}

class HealthDataScreen extends StatefulWidget {
  const HealthDataScreen({Key? key}) : super(key: key);

  @override
  _HealthDataScreenState createState() => _HealthDataScreenState();
}

class _HealthDataScreenState extends State<HealthDataScreen> {
  String? heartRate;
  String? bp;
  int steps = 0;
  double activeEnergy = 0;
  double weight = 0.0;

  String? bloodPreSys;
  String? bloodPreDia;

  bool workoutSuccess = false;

  // get data within the last 24 hours
  final now = DateTime.now();
  late DateTime yesterday;

  List<HealthDataPoint> healthData = [];

  HealthFactory health = HealthFactory();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await Permission.activityRecognition.request();
      await fetchData();
    });
    yesterday = now.subtract(
    Duration(hours: now.hour, minutes: now.minute, seconds: now.second));
  }

  /// Fetch data points from the health plugin and show them in the app.
  Future fetchData() async {
    // define the types to get
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.WEIGHT,
      HealthDataType.BODY_FAT_PERCENTAGE,
      HealthDataType.BODY_MASS_INDEX,
      HealthDataType.BODY_TEMPERATURE,
      HealthDataType.HEIGHT,
      HealthDataType.SLEEP_IN_BED,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_AWAKE,
      HealthDataType.WORKOUT,
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];

    final permissions = [
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
      HealthDataAccess.READ_WRITE,
    ];

    // requesting access to the data types before reading them
    bool requested =
        await health.requestAuthorization(types, permissions: permissions);

    if (requested) {
      try {
        // fetch health data
        healthData = await health.getHealthDataFromTypes(yesterday, now, types);

        // filter out duplicates
        healthData = HealthFactory.removeDuplicates(healthData);

        if (healthData.isNotEmpty) {
          for (HealthDataPoint h in healthData) {
            if (h.type == HealthDataType.HEART_RATE) {
              heartRate = "${h.value}";
            } else if (h.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC) {
              bloodPreSys = "${h.value}";
            } else if (h.type == HealthDataType.BLOOD_PRESSURE_DIASTOLIC) {
              bloodPreDia = "${h.value}";
            } else if (h.type == HealthDataType.STEPS) {
              steps += int.parse(h.value.toJson()['numericValue']);
              // steps = await health.getTotalStepsInInterval(yesterday, now) ?? 0;
            } else if (h.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
              activeEnergy += double.parse(h.value.toJson()['numericValue']);
            } else if (h.type == HealthDataType.BODY_FAT_PERCENTAGE) {
              print('fat ${h.value.toJson()}');
            } else if (h.type == HealthDataType.BODY_MASS_INDEX) {
              print('body mass ${h.value.toJson()}');
            } else if (h.type == HealthDataType.BODY_TEMPERATURE) {
              print('body temperature ${h.value.toJson()}');
            } else if (h.type == HealthDataType.HEIGHT) {
              print('height ${h.value.toJson()}');
            } else if (h.type == HealthDataType.SLEEP_IN_BED) {
              print('SLEEP_IN_BED ${h.value.toJson()}');
            } else if (h.type == HealthDataType.SLEEP_ASLEEP) {
              print('SLEEP_ASLEEP ${h.value.toJson()}');
            } else if (h.type == HealthDataType.SLEEP_AWAKE) {
              print('SLEEP_AWAKE ${h.value.toJson()}');
            } else if (h.type == HealthDataType.WORKOUT) {
              print('WORKOUT ${h.value.toJson()}');
            } else if (h.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
              print('ACTIVE_ENERGY_BURNED ${h.value.toJson()}');
            }
          }
          if (bloodPreSys != "null" && bloodPreDia != "null") {
            bp = "$bloodPreSys / $bloodPreDia mmHg";
          }

          setState(() {});
        }
      } catch (error) {
        print("Exception in getHealthDataFromTypes: $error");
      }
    } else {
      print("Authorization not granted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Health Data"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: healthCard(
                        title: "Heart rate",
                        image:
                            "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/Love_Heart_symbol.svg/1200px-Love_Heart_symbol.svg.png",
                        data: heartRate != "null" ? "$heartRate bpm" : "",
                        color: const Color(0xFF8d7ffa))),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: healthCard(
                        title: "Blood pressure",
                        data: bp ?? "",
                        image:
                            "https://cdn-icons-png.flaticon.com/512/5015/5015609.png",
                        color: const Color(0xFF4fd164))),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: healthCard(
                        title: "Step count",
                        image:
                            "https://static.thenounproject.com/png/2978984-200.png",
                        data: steps.toString(),
                        color: const Color(0xFF2086fd))),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: healthCard(
                        title: "Energy burned",
                        image:
                            "https://cdn-icons-png.flaticon.com/512/4812/4812908.png",
                        data: "$activeEnergy cal",
                        color: const Color(0xFFf77e7e))),
              ],
            ),
            GestureDetector(
              onTap: () async{
                bool success = await health.writeHealthData(1000, HealthDataType.STEPS, now, now);
                await health.revokePermissions();
                print('===========');
                print(success);
                setState(() {
                  workoutSuccess = success;
                });
                print('===========');
              },
              child: Container(
                width: double.infinity,
                height: 100,
                color: Colors.amber,
                child: Center(
                  child: Text(
                      workoutSuccess.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () async{
                await health.revokePermissions();
              },
              child: Container(
                width: double.infinity,
                height: 100,
                color: Colors.green,
                child: Center(
                  child: Text(
                    'delete',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () async{
                await health.revokePermissions();
              },
              child: Container(
                width: double.infinity,
                height: 100,
                color: Colors.green,
                child: Center(
                  child: Text(
                    'permission',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget healthCard(
    {String title = "",
    String data = "",
    Color color = Colors.blue,
    String? image}) {
  return Container(
    height: 240,
    margin: const EdgeInsets.symmetric(vertical: 10),
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(20))),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        if (image != null)
          Image.network(image, width: 70)
        else
          SizedBox(
            width: 70,
            height: 70,
          ),
        Text(data),
      ],
    ),
  );
}
