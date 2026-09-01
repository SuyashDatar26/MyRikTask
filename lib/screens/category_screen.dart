import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/product_view_model.dart';
import '../widgets/cart_bar.dart';
import '../widgets/category_rail.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  /// Loads another page when the user gets close to the bottom.
  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

// Start loading before the user actually reaches the bottom.
    if (position.pixels >= position.maxScrollExtent - 500) {
      context.read<ProductViewModel>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Myrik',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: SafeArea(
        child: Row(
          children: [
// ---------------------------------------------------------------
// LEFT CATEGORY RAIL
// ---------------------------------------------------------------
            const SizedBox(
              width: 82,
              child: CategoryRail(),
            ),

// ---------------------------------------------------------------
// MAIN CONTENT
// ---------------------------------------------------------------
            Expanded(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                      12,
                      8,
                      12,
                      8,
                    ),
                    child: SearchBarWidget(),
                  ),

                  Expanded(
                    child: Consumer<ProductViewModel>(
                      builder: (context, viewModel, child) {
                        return _buildProductContent(viewModel);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

// ---------------------------------------------------------------
// CART
// ---------------------------------------------------------------
      bottomNavigationBar: Consumer<ProductViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.cartItemCount == 0) {
            return const SizedBox.shrink();
          }

          return CartBar(
            itemCount: viewModel.cartItemCount,
            total: viewModel.cartTotal,
          );
        },
      ),
    );
  }

  Widget _buildProductContent(ProductViewModel viewModel) {
// -----------------------------------------------------------------
// INITIAL LOADING
// -----------------------------------------------------------------

    if (viewModel.isLoading && viewModel.products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

// -----------------------------------------------------------------
// ERROR WITH NO PRODUCTS
// -----------------------------------------------------------------

    if (viewModel.hasError && viewModel.products.isEmpty) {
      return _buildErrorState(viewModel);
    }

// -----------------------------------------------------------------
// EMPTY STATE
// -----------------------------------------------------------------

    if (viewModel.products.isEmpty) {
      return _buildEmptyState(viewModel);
    }

// -----------------------------------------------------------------
// PRODUCT GRID
// -----------------------------------------------------------------

    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.loadProducts();
      },
      child: GridView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          10,
          4,
          10,
          20,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,

// Product card is taller than it is wide.
          childAspectRatio: 0.62,
        ),
        itemCount: viewModel.products.length +
            (viewModel.isLoadingMore ? 2 : 0),
        itemBuilder: (context, index) {
// Loading placeholders at the bottom while another page loads.
          if (index >= viewModel.products.length) {
            return const _LoadingProductCard();
          }

          final product = viewModel.products[index];

          return ProductCard(
            product: product,
            quantity: viewModel.quantityFor(product),
            isFavourite: viewModel.isFavourite(product),

            onAdd: () {
              viewModel.addToCart(product);
            },

            onRemove: () {
              viewModel.removeFromCart(product);
            },

            onFavourite: () {
              viewModel.toggleFavourite(product);
            },
          );
        },
      ),
    );
  }

// ---------------------------------------------------------------------------
// ERROR STATE
// ---------------------------------------------------------------------------

  Widget _buildErrorState(ProductViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text(
              'Couldn\'t load products',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage ??
                  'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: viewModel.retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

// ---------------------------------------------------------------------------
// EMPTY STATE
// ---------------------------------------------------------------------------

  Widget _buildEmptyState(ProductViewModel viewModel) {
    final isSearch = viewModel.searchQuery.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearch
                  ? Icons.search_off_rounded
                  : Icons.inventory_2_outlined,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              isSearch
                  ? 'No products found'
                  : 'No products available',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearch
                  ? 'Try searching for something else.'
                  : 'There are no products to display right now.',
              textAlign: TextAlign.center,
            ),
            if (isSearch) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: viewModel.clearSearch,
                child: const Text('Clear search'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SIMPLE LOADING CARD
// -----------------------------------------------------------------------------

class _LoadingProductCard extends StatelessWidget {
  const _LoadingProductCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}
