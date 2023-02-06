import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  //Load env file
  await dotenv.load(fileName: ".env");
  runApp(MaterialApp(
    title: "Weather App",
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  var temp;
  var description;
  var currently;
  var humidity;
  var windSpeed;
  var name;
  var tempNumber;
  var windSpeedKmh;

  Future getWeather(String city) async {

    //Get weather data by openweathermap api
    String apiKey = dotenv.env['API_KEY']!;
    Uri uri = Uri.parse("https://api.openweathermap.org/data/2.5/weather?q=" +
        city +
        "&appid=" +
        apiKey);

    http.Response response = await http.get(uri);

    //parse data
    var results = jsonDecode(response.body);
    setState(() {
      temp = results['main']['temp'];
      description = results['weather'][0]['description'];
      currently = results['weather'][0]['main'];
      humidity = results['main']['humidity'];
      windSpeed = results['wind']['speed'];
      name = results['name'];

      tempNumber = double.parse(temp.toString()) - 273.15;
      windSpeedKmh = double.parse(windSpeed.toString()) * 3.60;
    });
  }

  @override
  void initState() {
    super.initState();
    this.getWeather("Vienna");
  }

  @override
  Widget build(BuildContext context) {
    //Create controller to get what user typed in
    final _textController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.teal.shade900,
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 60.0),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    "Currently in " + name.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  temp != null
                      ? tempNumber.toStringAsFixed(2) + "\u00B0C"
                      : "Loading",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 40.0,
                      fontWeight: FontWeight.w600),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: Text(
                    currently != null ? currently.toString() + "" : "Loading",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600),
                  ),
                )
              ],
            ),
          ),
          Expanded(
              child: ListView(
            children: [
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.thermometerHalf,
                  color: Colors.white,
                ),
                title: Text(
                  "Temperature",
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  temp != null
                      ? tempNumber.toStringAsFixed(2) + "\u00B0C"
                      : "Loading",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.cloud,
                  color: Colors.white,
                ),
                title: Text(
                  "Weather",
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  description != null ? description.toString() : "Loading",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.sun,
                  color: Colors.white,
                ),
                title: Text(
                  "Humidity",
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  humidity != null ? humidity.toString() + "%" : "Loading",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.wind,
                  color: Colors.white,
                ),
                title: Text(
                  "Wind Speed",
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  windSpeed != null
                      ? windSpeedKmh.toStringAsFixed(2) + " km/h"
                      : "Loading",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          )),
          TextField(
            controller: _textController,
            style: TextStyle(color: Colors.white, fontSize: 20),
            decoration: InputDecoration(
              hintText: "Enter City",
              hintStyle: TextStyle(color: Colors.white, fontSize: 28),
              filled: true,
              fillColor: Colors.teal.shade800,
              suffixStyle: TextStyle(color: Colors.white),
              suffix: IconButton(
                onPressed: () {
                  _textController.clear();
                },
                icon: const Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
              ),
            ),
            onSubmitted: (value) {
              //When submitted, update
              getWeather(_textController.text);
            },
          ),
        ],
      ),
    );
  }
}
