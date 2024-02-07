import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/api_service.dart';
import '../models/weather_model.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final ApiService apiService = ApiService();
  WeatherModel? weatherData;
  bool isLocationServiceEnabled = true;
  bool isLoading = false;
  late LocationPermission permission;

  @override
  void initState() {
    super.initState();
    checkLocationService();
  }

  Future<void> checkLocationService() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> getWeatherDataForCurrentLocation() async {
    setState(() {
      isLoading = true;
    });
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // User denied permissions, show a message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Please grant location permissions to get weather data')),
        );
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.'),
        ),
      );
      return Future.error('Location permissions are denied forever');
    }
    isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    try {
      final WeatherModel data =
          await apiService.getWeatherDataForCurrentLocation();
      setState(() {
        weatherData = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load weather data')),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getWeatherData(String cityName) async {
    try {
      final WeatherModel data = await apiService.getWeatherData(cityName);
      setState(() {
        weatherData = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load weather data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            weatherData != null
                ? Column(
                    children: [
                      Text(
                        '${weatherData!.temperature.toStringAsFixed(1)}°C',
                        style: TextStyle(
                          fontSize: 48,
                        ),
                      ),
                      Text(
                        '${weatherData!.cityName}, ${weatherData!.countryName}',
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            'http://openweathermap.org/img/w/${weatherData!.weatherIcon}.png',
                            scale: 0.6,
                            alignment: Alignment.center,
                          ),
                          Text(
                            '${weatherData!.weatherDescription}',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : CircularProgressIndicator(),
            SizedBox(
              height: 16,
            ),

            // isLoading ? CircularProgressIndicator() : SizedBox.shrink(),
            ElevatedButton(
              onPressed: isLoading ? null : getWeatherDataForCurrentLocation,
              child: isLoading
                  ? SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(),
                    )
                  : Text('Get Weather for Current Location'),
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onSubmitted: (value) {
                  getWeatherData(value);
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.location_city,
                    color: Colors.grey,
                  ),
                  labelText: 'Enter a City',
                  labelStyle: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'sans-serif',
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Lagos, London...",
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'sans-serif',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
