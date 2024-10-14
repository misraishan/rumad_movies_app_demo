import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_movies_api_demo/constants.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  MovieDetailsScreenState createState() => MovieDetailsScreenState();
}

class MovieDetailsScreenState extends State<MovieDetailsScreen> {
  bool isFavorite = false;
  final int accountId = int.parse(dotenv.env['ACCOUNT_ID']!);
  final Map<String, dynamic> movie = {};

  @override
  void initState() {
    super.initState();
    fetchMovieDetails();
  }

  Future<void> fetchMovieDetails() async {
    final response = await http.get(
        Uri.parse(
          '$baseUrl/movie/${widget.movieId}',
        ),
        headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        movie.addAll(data);
      });
    }
  }

  Future<void> toggleFavorite() async {
    try {
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
        setState(() {
          isFavorite = !isFavorite;
        });

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
