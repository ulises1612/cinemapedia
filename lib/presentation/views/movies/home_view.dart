import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends ConsumerState<HomeView> {

  @override
  void initState() {
    super.initState();
    ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
    ref.read(popularMoviesProvider.notifier).loadNextPage();
    ref.read(upcomingMoviesProvider.notifier).loadNextPage();
    ref.read(topRatedMoviesProvider.notifier).loadNextPage();
  }


  @override
  Widget build(BuildContext context) {


    final initialLoading = ref.watch(intialLoadingProvier);

    if(initialLoading) return const FullScreenLoader();

    final nowPlayingMovies = ref.watch(nowPlayingMoviesProvider);
    final popularMovies = ref.watch(popularMoviesProvider);
    final upcomingMovies = ref.watch(upcomingMoviesProvider);
    final topRatedMovies = ref.watch(topRatedMoviesProvider);
    final moviesSlideshow = ref.watch(moviesSlideshowProvider);

    return CustomScrollView(
      slivers:[

        const SliverAppBar(
          floating: true,
          flexibleSpace: FlexibleSpaceBar(
            title: CustomAppbar(),
          ),
        ),

        SliverList(delegate: SliverChildBuilderDelegate(
          (context,index){
            return Column(
                    children: [
                  
                      // const CustomAppbar(),
                      
                      MoviesSlideshow(movies: moviesSlideshow),
                  
                      MovieHorizontalListview(
                        movies: nowPlayingMovies,
                        title: 'En cines',
                        subTitle: 'Lunes 20',
                        loadNextpage: (){
                          ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
                        },
                      ),
                      MovieHorizontalListview(
                        movies: upcomingMovies,
                        title: 'Proximamente',
                        // subTitle: 'En este mes',
                        loadNextpage: (){
                          ref.read(upcomingMoviesProvider.notifier).loadNextPage();
                        },
                      ),
                      MovieHorizontalListview(
                        movies: popularMovies,
                        title: 'Populares',
                        subTitle: 'ahora',
                        loadNextpage: (){
                          ref.read(popularMoviesProvider.notifier).loadNextPage();
                        },
                      ),
                      MovieHorizontalListview(
                        movies: topRatedMovies,
                        title: 'Mejor calificadas',
                        subTitle: 'De todos los tiempos',
                        loadNextpage: (){
                          ref.read(topRatedMoviesProvider.notifier).loadNextPage();
                        },
                      ),
                  
                      const SizedBox(height: 10,)
                  
                    ],
                  );
          },
          childCount: 1
        ))
      ] 
    );

  }
}
