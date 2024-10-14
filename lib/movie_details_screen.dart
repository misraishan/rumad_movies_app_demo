import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_movies_api_demo/constants.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;

  // Takes in the movieId as a required parameter
  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  MovieDetailsScreenState createState() => MovieDetailsScreenState();
}

class MovieDetailsScreenState extends State<MovieDetailsScreen> {
  bool isFavorite = false; // Default value for isFavorite
  final int accountId = int.parse(
      dotenv.env['ACCOUNT_ID']!); // Grabs the accountId from the .env file

  // Dynamic type is used because we don't know the type of the data that will be stored in the map
  // JSON data is dynamic, and we can't always predict the structure of the data
  final Map<String, dynamic> movie = {}; // Holds the movie details

  @override
  void initState() {
    super.initState();
    fetchMovieDetails(); // Calls the fetchMovieDetails method when the screen is loaded
  }

// This is pre-filled in as an example, so we can focus on the aspect of favoriting a movie
  Future<void> fetchMovieDetails() async {
    // Fetches the movie details from the API
    final response = await http.get(
        Uri.parse(
          '$baseUrl/movie/${widget.movieId}', // Uses the movieId from the widget
        ),
        headers: headers);

// Fetches the favorite movies for the user from the API
    final favoriteResponse = await http.get(
      Uri.parse(
        '$baseUrl/account/$accountId/favorite/movies',
      ),
      headers: headers,
    );

// Decodes the response from the API to use as a map instead of a string
    final favoriteData = json.decode(favoriteResponse.body);

// Checks if the movie is already a favorite by filtering the favoriteData
// It checks if the movieId is in the list of favorite movies
    final isMovieFavorite =
        favoriteData['results'].any((movie) => movie['id'] == widget.movieId);

    if (response.statusCode == 200 && favoriteResponse.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        movie.addAll(data);
        isFavorite = isMovieFavorite;
      });
    }
  }

// Example for post request
  Future<void> toggleFavorite() async {
    try {
      // Sends a request to the API to favorite or unfavorite a movie
      final response = await http.post(
        Uri.parse('$baseUrl/account/$accountId/favorite'),
        headers: headers,
        body: json.encode({
          'media_type': 'movie',
          'media_id': movie['id'],
          'favorite': !isFavorite,
        }),
      );

      final jsonResponse = json.decode(response.body);

      if (jsonResponse['success'] == true) {
        // This will update the UI to show the user that the movie is a favorite
        setState(() {
          isFavorite =
              !isFavorite; // It inverses the previous state of favourite
        });

        // Snackbars are used to show a brief message at the bottom of the screen
        // It's a good way to show a message without interrupting the user
        // Instant feedback is important for the user to know if their action was successful
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(isFavorite
                  ? 'Added to favorites'
                  : 'Removed from favorites')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update favorites')),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update favorites')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (movie.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(movie['title'])),
      body: SingleChildScrollView(
        // Allows the user to scroll through the content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network('$imageBaseUrl${movie['backdrop_path']}'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(movie['title'],
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red),
                    onPressed: toggleFavorite,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Release Date: ${movie['release_date']}'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(movie['overview']),
            ),
          ],
        ),
      ),
    );
  }
}
