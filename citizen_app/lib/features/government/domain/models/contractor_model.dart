class Contractor {
  final String id;
  final String companyName;
  final String? specialization;
  final double rating;
  final String? status; // We'll infer status based on some logic if needed, backend has no status right now, but UI shows active/inactive

  Contractor({
    required this.id,
    required this.companyName,
    this.specialization,
    this.rating = 5.0,
    this.status = 'Active',
  });

  factory Contractor.fromJson(Map<String, dynamic> json) {
    return Contractor(
      id: json['id'].toString(),
      companyName: json['companyName'] ?? '',
      specialization: json['specialization'],
      rating: json['rating'] != null ? (double.tryParse(json['rating'].toString()) ?? 5.0) : 5.0,
      status: 'Active', // Mocking status since backend Contractor model has none
    );
  }
}
