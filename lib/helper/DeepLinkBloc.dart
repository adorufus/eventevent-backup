import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class DeepLinkBloc extends Bloc{

  static const stream = const EventChannel('deeplink.eventevent.open/events');
  static const platform = const MethodChannel('deeplink.eventevent.open/channel');

  StreamController<String> _stateController = StreamController();
  Stream<String> get state => _stateController.stream;
  Sink<String> get stateSink => _stateController.sink;

  DeepLinkBloc(){
    startUri().then(_onRedirected);
    stream.receiveBroadcastStream().listen((d) => _onRedirected(d));
  }

  _onRedirected(String uri){
    stateSink.add(uri);
  }

  @override
  void dispose(){
    _stateController.close();
  }

  Future<String> startUri() async{
    try{
      return platform.invokeMethod('initialLink');
    } on PlatformException catch (e){
      return "Failed to Invoke: '${e.message}'.";
    }
  }

  @override
  // TODO: implement initialState
  get initialState => null;

  @override
  Stream mapEventToState(event) {
    // TODO: implement mapEventToState
    return null;
  }
  
}