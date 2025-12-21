class Actor {
  final String name;

  const Actor({
    required this.name,
  });

  static const system = Actor(name: '[SYSTEM]');
}
