import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductService {
  static const String _baseUrl = 'https://dummyjson.com';

  final http.Client _client;

  ProductService({
    http.Client? client,
  }) : _client = client ?? http.Client();

// ---------------------------------------------------------------------------
// GET PRODUCTS
// ---------------------------------------------------------------------------

  /// Fetches a page of products from DummyJSON.
  ///
  /// Example:
  ///
  /// skip = 0, limit = 20
  /// GET /products?limit=20&skip=0
  ///
  /// skip = 20, limit = 20
  /// GET /products?limit=20&skip=20
  Future<ProductPage> getProducts({
    int limit = 20,
    int skip = 0,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/products?limit=$limit&skip=$skip',
    );

    return _fetchProducts(uri);
  }

// ---------------------------------------------------------------------------
// SEARCH PRODUCTS
// ---------------------------------------------------------------------------

  /// Searches products using DummyJSON's search endpoint.
  ///
  /// Example:
  ///
  /// GET /products/search?q=phone&limit=20&skip=0
  Future<ProductPage> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/products/search'
          '?q=${Uri.encodeQueryComponent(query)}'
          '&limit=$limit'
          '&skip=$skip',
    );

    return _fetchProducts(uri);
  }

// ---------------------------------------------------------------------------
// HTTP + JSON PARSING
// ---------------------------------------------------------------------------

  /// Performs the HTTP request and converts the response into Product objects.
  ///
  /// Networking and JSON parsing stay inside the service.
  /// Widgets never communicate directly with DummyJSON.
  Future<ProductPage> _fetchProducts(Uri uri) async {
    try {
      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

// ---------------------------------------------------------------
// HTTP ERROR
// ---------------------------------------------------------------

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw ProductServiceException(
          'Request failed with status ${response.statusCode}',
        );
      }

// ---------------------------------------------------------------
// JSON DECODING
// ---------------------------------------------------------------

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const ProductServiceException(
          'Invalid API response format',
        );
      }

// ---------------------------------------------------------------
// PRODUCTS
// ---------------------------------------------------------------

      final dynamic productsJson = decoded['products'];

      if (productsJson is! List) {
        throw const ProductServiceException(
          'Products field is missing or invalid',
        );
      }

      final List<Product> products = [];

// ---------------------------------------------------------------
// PRODUCT PARSING
// ---------------------------------------------------------------
//
// If one product is malformed, discard only that product.
// The rest of the page should still be displayed.
//

      for (final item in productsJson) {
        if (item is! Map<String, dynamic>) {
          continue;
        }

        try {
          products.add(
            Product.fromJson(item),
          );
        } on FormatException {
// Ignore malformed product records.
        } catch (_) {
// Ignore unexpected errors for an individual record.
        }
      }

// ---------------------------------------------------------------
// PAGINATION INFORMATION
// ---------------------------------------------------------------
//
// DummyJSON returns:
//
// {
//   "products": [...],
//   "total": 194,
//   "skip": 0,
//   "limit": 20
// }
//
// We use the values returned by the API.
//

      final int total =
          (decoded['total'] as num?)?.toInt() ?? products.length;

      final int currentSkip =
          (decoded['skip'] as num?)?.toInt() ?? 0;

      final int currentLimit =
          (decoded['limit'] as num?)?.toInt() ?? products.length;

      return ProductPage(
        products: products,
        total: total,
        skip: currentSkip,
        limit: currentLimit,
      );
    }

// -------------------------------------------------------------------------
// OUR SERVICE EXCEPTION
// -------------------------------------------------------------------------

    on ProductServiceException {
      rethrow;
    }

// -------------------------------------------------------------------------
// INVALID JSON
// -------------------------------------------------------------------------

    on FormatException {
      throw const ProductServiceException(
        'The server returned invalid JSON',
      );
    }

// -------------------------------------------------------------------------
// NETWORK ERROR
// -------------------------------------------------------------------------

    on http.ClientException catch (e) {
      throw ProductServiceException(
        'Network error: ${e.message}',
      );
    }

// -------------------------------------------------------------------------
// UNEXPECTED ERROR
// -------------------------------------------------------------------------

    catch (e) {
      throw ProductServiceException(
        'Unable to load products: $e',
      );
    }
  }

// ---------------------------------------------------------------------------
// DISPOSE
// ---------------------------------------------------------------------------

  /// Releases the HTTP client when the service is no longer required.
  void dispose() {
    _client.close();
  }
}

// =============================================================================
// PRODUCT PAGE
// =============================================================================

/// Represents one paginated response from DummyJSON.
class ProductPage {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  const ProductPage({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  /// Whether another page of products is available.
  bool get hasMore {
    return skip + products.length < total;
  }
}

// =============================================================================
// PRODUCT SERVICE EXCEPTION
// =============================================================================

/// Exception used for errors originating from ProductService.
class ProductServiceException implements Exception {
  final String message;

  const ProductServiceException(this.message);

  @override
  String toString() => message;
}
