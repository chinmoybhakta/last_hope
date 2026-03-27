class Country {
  final String name;
  final String code;
  final double latitude;
  final double longitude;
  final List<State> states;

  Country({
    required this.name,
    required this.code,
    required this.latitude,
    required this.longitude,
    required this.states,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'],
      code: json['code'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      states: (json['states'] as List)
          .map((e) => State.fromJson(e))
          .toList(),
    );
  }
}

class State {
  final String name;
  final double latitude;
  final double longitude;

  State({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory State.fromJson(Map<String, dynamic> json) {
    return State(
      name: json['name'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

class SearchResult {
  final String name;
  final String type; // 'country' or 'state'
  final String parent; // parent country name if type is state
  final double latitude;
  final double longitude;

  SearchResult({
    required this.name,
    required this.type,
    required this.parent,
    required this.latitude,
    required this.longitude,
  });
}