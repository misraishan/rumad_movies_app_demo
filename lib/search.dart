import 'package:flutter/material.dart';
import 'package:flutter_movies_api_demo/movie_details_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';

class MovieSearchDelegate extends SearchDelegate {
  Future<List> fetchMovies(String query) async {
    final response = await http.get(
        Uri.parse('$baseUrl/search/movie?query=${Uri.encodeComponent(query)}'),
        headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load movies');
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: fetchMovies(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final movies = snapshot.data;
          return ListView.builder(
            itemCount: movies?.length ?? 0,
            itemBuilder: (context, index) {
              final movie = movies![index];
              return ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return MovieDetailsScreen(movieId: movie['id']);
                  }));
                },
                title: Text(movie['title']),
                subtitle: Text(movie['release_date'] ?? 'No release date'),
                leading: movie['poster_path'] != null
                    ? Image.network('$smallImageBaseUrl${movie['poster_path']}')
                    : null,
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
