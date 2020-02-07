import 'package:eventevent/Models/PopularEventModel.dart';
import 'package:eventevent/Providers/EventListProviders.dart';
import 'package:flutter/material.dart';

class EventListRepo { 
  EventListProviders _apiProvider = EventListProviders();

  Future<PopularEventModel> getPopularEventList(bool isRest, BuildContext context){
    return _apiProvider.getPopularEvent(isRest, context);
  }
}