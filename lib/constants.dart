import 'package:flutter_dotenv/flutter_dotenv.dart';

// This file contains some base variables that's used throughout the app
// In particular, it has to do with the API we're using, and the base
// URLs for api and image/cdn domain, along with the headers needed for
// the API requests

const String baseUrl = 'https://api.themoviedb.org/3';
const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
const String smallImageBaseUrl = 'https://image.tmdb.org/t/p/w400';

// In normal cases, you wouldn't want to expose an API key
// Also, we're using a hardcoded bearer token here, which is not recommended
// This would only authenticate for YOUR user, and not for all users
// Actual authentication should be done on the server side, but is
// out of scope for this tutorial.
final String bearerToken = dotenv.env['BEARER_TOKEN']!;
final headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer $bearerToken',
};
