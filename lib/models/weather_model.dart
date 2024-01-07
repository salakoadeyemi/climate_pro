class WeatherModel {
  final double temperature;
  final String cityName;
  final String countryName;
  final String weatherIcon;
  final String weatherDescription;

  WeatherModel({
    required this.temperature,
    required this.cityName,
    required this.countryName,
    required this.weatherIcon,
    required this.weatherDescription,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['main']['temp']),
      cityName: json['name'],
      countryName: json['sys']['country'],
      weatherIcon: json['weather'][0]['icon'],
      weatherDescription: json['weather'][0]['description'],
    );
  }
}
