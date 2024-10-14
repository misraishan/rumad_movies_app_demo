import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_movies_api_demo/constants.dart';
import 'package:flutter_movies_api_demo/movie_details_screen.dart';
import 'package:flutter_movies_api_demo/search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';

Future<void> main() async {
  await dotenv.load(fileName: "assets/.env"); // Load .env file
  runApp(const MovieApp());
}

// The main entry point for the app
class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData
          .dark(), // Set the theme to dark, can be customized as needed
      home: const HomeScreen(), // Set the home screen to HomeScreen
    );
  }
}

// HomeScreen widget used to display the main part of the app
// This includes the sections for Now Playing, Popular, and Upcoming movies
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  // Map to store the movie lists for Now Playing, Popular, and Upcoming
  Map<String, List<dynamic>> movieLists = {
    'Now Playing': [],
    'Popular': [],
    'Upcoming': [],
  };

  @override
  void initState() {
    super.initState();
    fetchMovieLists(); // When the app starts, fetch the movie lists and set the state
  }

  Future<void> fetchMovieLists() async {
    // This is just to make it easy to call the endpoints, as all of them are under the same base URL
    final endpoints = {
      'Now Playing': '/movie/now_playing',
      'Popular': '/movie/popular',
      'Upcoming': '/movie/upcoming',
    };

    for (var entry in endpoints.entries) {
      // Implement the GET request for each endpoint
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TMDB Movie App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                // Search delegates are a new concept, they make it easier to
                // create full search pages with functional search bars
                delegate: MovieSearchDelegate(),
              );
            },
          ),
        ],
      ),
      // Refresh indicators are also new to the demos, they allow
      // "pull to refresh" functionality in the app and it just calls
      // the fetchMovieLists function again
      body: RefreshIndicator(
        onRefresh: fetchMovieLists,
        child: ListView(
          children: movieLists.entries
              .map((entry) => _buildMovieCarousel(entry.key, entry.value))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildMovieCarousel(String title, List<dynamic> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        // CarouselSlider is a package, and not a built-in widget
        // It allows you to create a carousel of widgets, in this case,
        // we are creating a carousel of movie posters and titles
        CarouselSlider(
          options: CarouselOptions(height: 200.0, enlargeCenterPage: true),
          items: movies.map((movie) {
            return Builder(
              builder: (BuildContext context) {
                // GestureDetectors act as buttons when a normal button widget
                // is not enough. It comes in handy when turning an entire card
                // or child widget into something tappable that you can create
                // an action for.
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            // On click, navigate to the MovieDetailsScreen with the movie ID
                            MovieDetailsScreen(movieId: movie['id']),
                      ),
                    );
                  },
                  child: _carouselCard(movie), // Return the carousel card
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

// Carousel cards are just widgets to return the image and title of the movie
  Widget _carouselCard(dynamic movie) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Image.network(
                '$imageBaseUrl${movie['poster_path']}',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              movie['title'],
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
