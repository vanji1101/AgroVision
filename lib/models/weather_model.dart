class WeatherData {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final double rainProbability;
  final String condition;
  final String icon;
  final String locationName;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final String alert;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.rainProbability,
    required this.condition,
    required this.icon,
    required this.locationName,
    required this.hourly,
    required this.daily,
    this.alert = '',
  });
}

class HourlyForecast {
  final String time;
  final double temp;
  final String icon;
  final double rainProb;

  HourlyForecast({
    required this.time,
    required this.temp,
    required this.icon,
    required this.rainProb,
  });
}

class DailyForecast {
  final String day;
  final String tamilDay;
  final String icon;
  final double rainProb;
  final double highTemp;
  final double lowTemp;

  DailyForecast({
    required this.day,
    required this.tamilDay,
    required this.icon,
    required this.rainProb,
    required this.highTemp,
    required this.lowTemp,
  });
}
