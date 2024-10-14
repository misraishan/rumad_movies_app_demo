import 'package:flutter_dotenv/flutter_dotenv.dart';

const String baseUrl = 'https://api.themoviedb.org/3';
const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
const String smallImageBaseUrl = 'https://image.tmdb.org/t/p/w400';

final String apiKey = dotenv.env['BEARER_TOKEN']!;
final headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer $apiKey',
};
