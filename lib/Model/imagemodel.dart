class ImageEntry {
  int? id;
  String name;
  String type;
  String date;
  String image;

  ImageEntry({
    this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.image,
  });
  factory ImageEntry.fromMap(Map<String, dynamic> map) {
    return ImageEntry(
      id: map['_id'],
      name: map['name'],
      type: map['type'],
      date: map['date'],
      image: map['image'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'type': type,
      'date': date,
      'image': image,
    };
  }
}
