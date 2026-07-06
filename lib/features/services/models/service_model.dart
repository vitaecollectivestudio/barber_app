class ServiceModel {
  final String id;
  final String name;
  final String description;
  final int priceCents;
  final int durationMinutes;
  final bool active;
  final int sortOrder;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.priceCents,
    required this.durationMinutes,
    required this.active,
    required this.sortOrder,
  });

  factory ServiceModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return ServiceModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      priceCents: data['priceCents'] ?? 0,
      durationMinutes: data['durationMinutes'] ?? 30,
      active: data['active'] == true,
      sortOrder: data['sortOrder'] ?? 999,
    );
  }

  String get priceLabel {
    final euros = priceCents / 100;

    return euros.truncateToDouble() == euros
        ? '€${euros.toInt()}'
        : '€${euros.toStringAsFixed(2)}';
  }
}