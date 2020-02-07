import 'package:eventevent/Models/PopularEventModel.dart';
import 'package:eventevent/Repositories/EventListRepo.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

class EventListBloc {
  final EventListRepo _repo = EventListRepo();
  final BehaviorSubject<PopularEventModel> _subject = BehaviorSubject<PopularEventModel>();

  getPopularEventList(bool isRest, BuildContext context) async {
    PopularEventModel response = await _repo.getPopularEventList(isRest, context);
    _subject.sink.add(response);
  }

  dispose() {
    _subject.close();
  }

  BehaviorSubject<PopularEventModel> get subject => _subject;
}

final bloc = EventListBloc();