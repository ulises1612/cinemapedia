import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:flutter/material.dart';

typedef SearchMoviesCallBack = Future<List<Movie>> Function(String query);

class SearchMovieDelegate extends SearchDelegate<Movie?>{

  
  final SearchMoviesCallBack searchMovies;
  StreamController<List<Movie>> debouncedMovies = StreamController.broadcast();
  StreamController<bool> isLoadingStream = StreamController.broadcast();

  List<Movie> initialMovies;
  Timer? _debounceTimer;

  SearchMovieDelegate({
    required this.searchMovies,
    required this.initialMovies
  });

  void clearStraems(){
    debouncedMovies.close();
  }

  void _onQueryChanged(String query){
    isLoadingStream.add(true);

    if(_debounceTimer?.isActive ?? false ) _debounceTimer!.cancel;

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async { 
      
      // if(query.isEmpty){
      //   debouncedMovies.add([]);
      //   return;
      // }
      
      final movies = await searchMovies(query);
      initialMovies = movies;
      debouncedMovies.add(movies);
      isLoadingStream.add(false);

    });
  }

  Widget buildResultsAndSuggestions(){
    return StreamBuilder( 
      initialData: initialMovies,
      stream: debouncedMovies.stream,
      builder: (context,snapshot){

        final movies = snapshot.data ?? [];

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) => _MovieItem(
            movie: movies[index],
            onMovieSelected: (context,movie){
              clearStraems();
              close(context, movie);
            },
          )
        );
      }
    );
  }

  @override
  String get searchFieldLabel => 'Buscar pelicula';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [

      StreamBuilder(
        initialData: false,
        stream: isLoadingStream.stream, 
        builder: (context,snapshot){

          if(snapshot.data ?? false){

            return SpinPerfect(
              infinite: true,
              spins: 10,
              duration: const Duration(seconds: 10),
              child: IconButton(
                onPressed: ()=> query = '', 
                icon: const Icon(Icons.refresh_rounded)
              ),
            );
          }

          return FadeIn(
            animate: query.isEmpty,
            child: IconButton(
              onPressed: ()=> query = '',
              icon: const Icon(Icons.clear),
            ),
          );
        }
      )

      
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () { 
        clearStraems();
        close(context,null);
      }, 
      icon: const Icon(Icons.arrow_back_ios_new_rounded)
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildResultsAndSuggestions();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _onQueryChanged(query);
    return buildResultsAndSuggestions();
  }
}

class _MovieItem extends StatelessWidget {

  final Movie movie;
  final Function onMovieSelected;

  const _MovieItem({
    required this.movie, 
    required this.onMovieSelected
  });

  @override
  Widget build(BuildContext context) {

    final textStyle = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        onMovieSelected(context,movie);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
        child: Row(
          children: [
            
            //Image 
            SizedBox(
              width: size.width * .2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  movie.posterPath,
                  loadingBuilder: (context, child, loadingProgress) => FadeIn(child: child),
                ),
              ),
            ),
      
            const SizedBox(width: 10,),
            //Descripcion
            SizedBox(
              width: size.width *.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Text(movie.title,style: textStyle.titleMedium,),
      
                  (movie.overview.length > 100)
                  ? Text('${movie.overview.substring(0,100)}...')
                  : Text(movie.overview),
      
                  Row(
                    children: [
                      Icon(Icons.star_half_rounded,color: Colors.yellow.shade800,),
                      const SizedBox(width: 10,),
                      Text(
                        HumanFormats.number(movie.voteAverage,1),
                        style: textStyle.bodyMedium!.copyWith(color:Colors.yellow.shade900),
                      )
                    ],
                  )
      
                ],
              ),
            )
      
          ],
        ),
      ),
    );
  }
}