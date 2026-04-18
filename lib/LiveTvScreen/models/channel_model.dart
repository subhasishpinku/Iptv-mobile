class Channel {
  final int id;
  final String name;
  final String streamUrl;
  final String logoUrl;
  final String category;
  final String localNumber;

  Channel({
    required this.id,
    required this.name,
    required this.streamUrl,
    required this.logoUrl,
    required this.category,
    required this.localNumber,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'],
      name: json['name'],
      streamUrl: json['streamUrl'],
      logoUrl: json['logoUrl'],
      category: json['category'],
      localNumber: json['local_number'],
    );
  }
}