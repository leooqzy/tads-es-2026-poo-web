class AdminDashboard {
  const AdminDashboard({
    required this.products,
    required this.activeProducts,
    required this.users,
    required this.categories,
    required this.orders,
    required this.reviews,
  });

  final int products;
  final int activeProducts;
  final int users;
  final int categories;
  final int orders;
  final int reviews;

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  factory AdminDashboard.fromJson(Map<String, dynamic> json) {
    final totals = Map<String, dynamic>.from(json['totals'] as Map? ?? {});

    return AdminDashboard(
      products: _toInt(totals['products']),
      activeProducts: _toInt(totals['active_products']),
      users: _toInt(totals['users']),
      categories: _toInt(totals['categories']),
      orders: _toInt(totals['orders']),
      reviews: _toInt(totals['reviews']),
    );
  }
}
