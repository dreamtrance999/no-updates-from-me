import '../engine/event.dart';
import 'event_repository.dart';

class InMemoryEventRepository implements EventRepository {
  final Map<String, List<Event>> _eventsByChannel;

  InMemoryEventRepository(this._eventsByChannel);

  @override
  List<Event> getByChannel(String channel) => _eventsByChannel[channel] ?? [];

  @override
  // TODO: implement channels
  List<String> get channels => throw UnimplementedError();
}
