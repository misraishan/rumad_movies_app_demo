import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_movies_api_demo/constants.dart';
import 'package:flutter_movies_api_demo/movie_details_screen.dart';
import 'package:flutter_movies_api_demo/search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';

Future<void> main() async {
  await dotenv.load(fileName: "assets/.env");
  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Map<String, List<dynamic>> movieLists = {
    'Now Playing': [],
    'Popular': [],
    'Upcoming': [],
  };

  @override
  void initState() {
    super.initState();
    fetchMovieLists();
  }

  Future<void> fetchMovieLists() async {
    final endpoints = {
      'Now Playing': '/movie/now_playing',
      'Popular': '/movie/popular',
      'Upcoming': '/movie/upcoming',
    };

    for (var entry in endpoints.entries) {
      final response =
          await http.get(Uri.parse('$baseUrl${entry.value}?api_key=$apiKey'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          movieLists[entry.key] = data['results'];
        });
      }
    }
  }

  Widget buildMovieCarousel(String title, List<dynamic> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        CarouselSlider(
          options: CarouselOptions(height: 200.0, enlargeCenterPage: true),
          items: movies.map((movie) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MovieDetailsScreen(movieId: movie['id']),
                      ),
                    );
                  },
                  child: _carouselCard(movie),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
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
                delegate: MovieSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: movieLists.entries
            .map((entry) => buildMovieCarousel(entry.key, entry.value))
            .toList(),
      ),
    );
  }

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
