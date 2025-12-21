import '../engine/event.dart';

abstract class EventRepository {
  List<String> get channels;
  List<Event> getByChannel(String channel);
}
