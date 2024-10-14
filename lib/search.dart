import 'package:flutter/material.dart';
import 'package:flutter_movies_api_demo/movie_details_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';

// As mentioned previously, SearchDelegate is a class that helps us create a
// search interface. It bootstraps an appbar with a search field, and we can
// override methods to customize the search behavior.
class MovieSearchDelegate extends SearchDelegate {
  Future<List> fetchMovies(String query) async {
    // Implementation of the fetchMovies method
    // Temporary response to return an empty list if the query is empty
    final response = await http.get(
      Uri.parse('$baseUrl/search/movie'), // Uses the search endpoint
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      debugPrint(response.body);
      throw Exception('Failed to load movies');
    }
  }

// A list of 'action' buttons to be displayed in the appbar. In this case, we
// have a clear button that clears the search query.
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
    // FutureBuilders are used to build widgets based on the result of a future.
    // In this case, we're fetching movies based on the query, and building a
    // ListView based on the results.

    // Futures can be in different states, such as waiting, done, or error.
    // In this scenario, a "Future" is a placeholder for a value that hasn't
    // been computed yet, and the FutureBuilder helps us build widgets based on
    // the state of the future (the result of the API call).
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
              // Renders a list tile that will be clickable to navigate to the
              // movie details screen that has already been implemented.
              return ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return MovieDetailsScreen(movieId: movie['id']);
                  }));
                },
                title: Text(movie['title']),
                subtitle: Text(movie['release_date'] ?? 'No release date'),
                leading: movie['poster_path'] !=
                        null // Not all movies have posters
                    ? Image.network('$smallImageBaseUrl${movie['poster_path']}')
                    : null,
              );
            },
          );
        }
      },
    );
  }

// This is a necessary override for the search delegate to work. It's used to
// build suggestions based on the query. We're not implementing this in this
// tutorial, but it's a good place to show suggestions based on the query.
  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
