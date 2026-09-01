class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final String category;
  final String thumbnail;
  final List<String> images;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.category,
    required this.thumbnail,
    required this.images,
  });

  /// Converts a DummyJSON product into our application's Product model.
  ///
  /// Required fields are validated. If the record cannot be interpreted,
  /// FormatException is thrown so the service can discard only that record.
  factory Product.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];

// These are the minimum fields we need for a valid product.
    if (id is! int || title is! String) {
      throw const FormatException(
        'Invalid product: id or title is missing/incorrect',
      );
    }

    return Product(
      id: id,
      title: title,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
      (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] as int? ?? 0,
      brand: json['brand'] as String? ?? '',
      category: json['category'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      images: (json['images'] as List?)
          ?.whereType<String>()
          .toList() ??
          const [],
    );
  }

  /// Converts the Product model back into a JSON-compatible map.
  ///
  /// Not required by the assignment right now, but useful if the model
  /// later needs to be cached or sent to another API.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'category': category,
      'thumbnail': thumbnail,
      'images': images,
    };
  }

  /// Calculates the original MRP from the selling price and discount.
  ///
  /// Example:
  /// price = $80
  /// discount = 20%
  /// MRP ≈ $100
  double get mrp {
    if (discountPercentage <= 0) {
      return price;
    }

    return price / (1 - discountPercentage / 100);
  }

  /// Returns whether the product is currently available.
  bool get isInStock => stock > 0;
}

