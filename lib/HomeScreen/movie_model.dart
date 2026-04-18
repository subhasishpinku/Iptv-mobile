class Movie {
  final int id;
  final String title;
  final String image;
  final String videoUrl;
  final String? subtitleUri;
  final int? rank;
  final String? rankUpDown;
  final String? fullTitle;
  final int? year;
  final String? releaseDate;
  final String? image169;
  final int? runtimeMins;
  final String? runtimeStr;
  final String? plot;
  final String? contentRating;
  final double? rating;
  final int? ratingCount;
  final int? metaCriticRating;
  final String? genres;
  final String? directors;
  final String? stars;

  Movie({
    required this.id,
    required this.title,
    required this.image,
    required this.videoUrl,
    this.subtitleUri,
    this.rank,
    this.rankUpDown,
    this.fullTitle,
    this.year,
    this.releaseDate,
    this.image169,
    this.runtimeMins,
    this.runtimeStr,
    this.plot,
    this.contentRating,
    this.rating,
    this.ratingCount,
    this.metaCriticRating,
    this.genres,
    this.directors,
    this.stars,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      image: json['image_2_3'] ?? '',
      videoUrl: json['videoUri'] ?? '',
      subtitleUri: json['subtitleUri'],
      rank: json['rank'],
      rankUpDown: json['rankUpDown'],
      fullTitle: json['fullTitle'],
      year: json['year'],
      releaseDate: json['releaseDate'],
      image169: json['image_16_9'],
      runtimeMins: json['runtimeMins'],
      runtimeStr: json['runtimeStr'],
      plot: json['plot'],
      contentRating: json['contentRating'],
      rating: json['rating']?.toDouble(),
      ratingCount: json['ratingCount'],
      metaCriticRating: json['metaCriticRating'],
      genres: json['genres'],
      directors: json['directors'],
      stars: json['stars'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_2_3': image,
      'videoUri': videoUrl,
      'subtitleUri': subtitleUri,
      'rank': rank,
      'rankUpDown': rankUpDown,
      'fullTitle': fullTitle,
      'year': year,
      'releaseDate': releaseDate,
      'image_16_9': image169,
      'runtimeMins': runtimeMins,
      'runtimeStr': runtimeStr,
      'plot': plot,
      'contentRating': contentRating,
      'rating': rating,
      'ratingCount': ratingCount,
      'metaCriticRating': metaCriticRating,
      'genres': genres,
      'directors': directors,
      'stars': stars,
    };
  }
}