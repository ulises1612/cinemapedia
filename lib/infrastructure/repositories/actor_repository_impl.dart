import 'package:cinemapedia/domain/datasources/actors_datasource.dart';
import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/domain/repositories/actors_repository.dart';

class ActorRepositoryImpl extends ActorsRepository{

  final ActorsDatasource actorsDatasource;

  ActorRepositoryImpl({required this.actorsDatasource});

  @override
  Future<List<Actor>> getActorsByMovie(String movidId) {
    return actorsDatasource.getActorsByMovie(movidId);
  }

}