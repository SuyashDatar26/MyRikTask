import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class ProductViewModel extends ChangeNotifier {
  ProductViewModel({
    ProductService? productService,
  }) : _productService = productService ?? ProductService() {
    _initialize();
  }

  final ProductService _productService;

// ---------------------------------------------------------------------------
// Product state
// ---------------------------------------------------------------------------

  final List<Product> _products = [];

  List<Product> get products => List.unmodifiable(_products);

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;

  bool get isLoadingMore => _isLoadingMore;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  bool _hasMore = true;

  bool get hasMore => _hasMore;

// ---------------------------------------------------------------------------
// Search state
// ---------------------------------------------------------------------------

  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  bool get isSearching => _searchQuery.trim().isNotEmpty;

  Timer? _searchDebounce;

// ---------------------------------------------------------------------------
// Pagination state
// ---------------------------------------------------------------------------

  static const int _pageSize = 20;

  int _skip = 0;

// ---------------------------------------------------------------------------
// Cart state
// ---------------------------------------------------------------------------

  final Map<int, int> _cart = {};

  /// Returns the complete cart as productId -> quantity.
  Map<int, int> get cart => Map.unmodifiable(_cart);

  /// Returns the quantity of a particular product in the cart.
  int quantityFor(Product product) {
    return _cart[product.id] ?? 0;
  }

  /// Total number of items in the cart.
  int get cartItemCount {
    return _cart.values.fold(
      0,
          (total, quantity) => total + quantity,
    );
  }

  /// Total cart value.
  double get cartTotal {
    double total = 0;

    for (final entry in _cart.entries) {
      final productId = entry.key;
      final quantity = entry.value;

      final product = _findProductById(productId);

      if (product != null) {
        total += product.price * quantity;
      }
    }

    return total;
  }

// ---------------------------------------------------------------------------
// Favourite state
// ---------------------------------------------------------------------------

  static const String _favouritesKey = 'favourite_product_ids';

  final Set<int> _favourites = {};

  Set<int> get favourites => Set.unmodifiable(_favourites);

  bool isFavourite(Product product) {
    return _favourites.contains(product.id);
  }

  SharedPreferences? _preferences;

// ---------------------------------------------------------------------------
// Initialization
// ---------------------------------------------------------------------------

  Future<void> _initialize() async {
    await _loadFavourites();
    await loadProducts();
  }

  /// Loads favourite product IDs saved from previous app sessions.
  Future<void> _loadFavourites() async {
    try {
      _preferences = await SharedPreferences.getInstance();

      final savedIds = _preferences!.getStringList(_favouritesKey);

      if (savedIds != null) {
        _favourites.addAll(
          savedIds
              .map(int.tryParse)
              .whereType<int>(),
        );
      }

      notifyListeners();
    } catch (_) {
// Favourite persistence should never prevent the app from loading.
    }
  }

// ---------------------------------------------------------------------------
// Products
// ---------------------------------------------------------------------------

  /// Loads the first page of products.
  Future<void> loadProducts() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _skip = 0;
    _hasMore = true;

    notifyListeners();

    try {
      final page = await _fetchCurrentPage();

      _products
        ..clear()
        ..addAll(page.products);

      _skip = page.skip + page.products.length;

// Use the API's total when possible.
      _hasMore = _skip < page.total;

// If the API says more exists but no valid records were parsed,
// stop pagination to avoid an infinite loading loop.
      if (page.products.isEmpty) {
        _hasMore = false;
      }
    } on ProductServiceException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Something went wrong while loading products.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads the next page when the user reaches the bottom of the grid.
  Future<void> loadMore() async {
    if (_isLoading ||
        _isLoadingMore ||
        !_hasMore ||
        _products.isEmpty) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final page = await _fetchCurrentPage();

// Prevent accidental duplicate products.
      final existingIds = _products.map((product) => product.id).toSet();

      for (final product in page.products) {
        if (!existingIds.contains(product.id)) {
          _products.add(product);
          existingIds.add(product.id);
        }
      }

      _skip = page.skip + page.products.length;

      _hasMore = _skip < page.total;

      if (page.products.isEmpty) {
        _hasMore = false;
      }
    } on ProductServiceException catch (e) {
// Keep already loaded products visible.
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Unable to load more products.';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<ProductPage> _fetchCurrentPage() {
    if (isSearching) {
      return _productService.searchProducts(
        query: _searchQuery.trim(),
        limit: _pageSize,
        skip: _skip,
      );
    }

    return _productService.getProducts(
      limit: _pageSize,
      skip: _skip,
    );
  }

// ---------------------------------------------------------------------------
// Search
// ---------------------------------------------------------------------------

  /// Called by the search field whenever the user changes the text.
  ///
  /// A small debounce prevents an API request from being made for every
  /// individual keystroke.
  void onSearchChanged(String query) {
    _searchDebounce?.cancel();

    _searchQuery = query;

    _searchDebounce = Timer(
      const Duration(milliseconds: 400),
          () {
        _performSearch();
      },
    );

    notifyListeners();
  }

  Future<void> _performSearch() async {
    _searchDebounce?.cancel();

    _products.clear();
    _skip = 0;
    _hasMore = true;
    _errorMessage = null;

    notifyListeners();

    if (_searchQuery.trim().isEmpty) {
      await loadProducts();
      return;
    }

    await _loadSearchResults();
  }

  Future<void> _loadSearchResults() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final page = await _fetchCurrentPage();

      _products
        ..clear()
        ..addAll(page.products);

      _skip = page.skip + page.products.length;

      _hasMore = _skip < page.total;

      if (page.products.isEmpty) {
        _hasMore = false;
      }
    } on ProductServiceException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Unable to search products.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the search field and restores the normal product list.
  Future<void> clearSearch() async {
    _searchDebounce?.cancel();

    _searchQuery = '';

    _products.clear();
    _skip = 0;
    _hasMore = true;
    _errorMessage = null;

    notifyListeners();

    await loadProducts();
  }

// ---------------------------------------------------------------------------
// Cart
// ---------------------------------------------------------------------------

  /// Adds one item to the cart.
  void addToCart(Product product) {
    if (!product.isInStock) {
      return;
    }

    final currentQuantity = _cart[product.id] ?? 0;

// Don't allow the cart quantity to exceed available stock.
    if (currentQuantity >= product.stock) {
      return;
    }

    _cart[product.id] = currentQuantity + 1;

    notifyListeners();
  }

  /// Removes one item from the cart.
  void removeFromCart(Product product) {
    final currentQuantity = _cart[product.id] ?? 0;

    if (currentQuantity <= 1) {
      _cart.remove(product.id);
    } else {
      _cart[product.id] = currentQuantity - 1;
    }

    notifyListeners();
  }

  /// Removes the product completely from the cart.
  void removeProductFromCart(Product product) {
    _cart.remove(product.id);

    notifyListeners();
  }

  /// Clears the entire cart.
  void clearCart() {
    if (_cart.isEmpty) {
      return;
    }

    _cart.clear();

    notifyListeners();
  }

  Product? _findProductById(int id) {
    for (final product in _products) {
      if (product.id == id) {
        return product;
      }
    }

    return null;
  }

// ---------------------------------------------------------------------------
// Favourites
// ---------------------------------------------------------------------------

  /// Toggles a product's favourite state and persists it.
  Future<void> toggleFavourite(Product product) async {
    if (_favourites.contains(product.id)) {
      _favourites.remove(product.id);
    } else {
      _favourites.add(product.id);
    }

    notifyListeners();

    await _saveFavourites();
  }

  Future<void> _saveFavourites() async {
    try {
      _preferences ??= await SharedPreferences.getInstance();

      await _preferences!.setStringList(
        _favouritesKey,
        _favourites.map((id) => id.toString()).toList(),
      );
    } catch (_) {
// Persistence failure shouldn't break the UI.
    }
  }

// ---------------------------------------------------------------------------
// Error handling
// ---------------------------------------------------------------------------

  /// Clears the current error without changing the loaded products.
  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;

    notifyListeners();
  }

  /// Retries the current operation.
  Future<void> retry() async {
    if (isSearching) {
      await _performSearch();
    } else {
      await loadProducts();
    }
  }

// ---------------------------------------------------------------------------
// Lifecycle
// ---------------------------------------------------------------------------

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _productService.dispose();

    super.dispose();
  }
}
