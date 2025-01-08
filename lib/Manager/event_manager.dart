import 'event_listener.dart';

class EventManager {
  List<resetFilter> listeners = <resetFilter>[];

  EventManager._privateConstructor();

  static final EventManager _instance = EventManager._privateConstructor();

  static EventManager get instance => _instance;

  bool? addListener(resetFilter eventListener) {
    listeners.add(eventListener);
    print("Aggiunto" + eventListener.toString());
  }

  void resetList() {
    print("Lunghezza" + listeners.length.toString());
    for (resetFilter x in listeners) {
      x.reset();
      print("Fatto resettato");
    }
  }
}
