import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.isFavourite,
    required this.onAdd,
    required this.onRemove,
    required this.onFavourite,
  });

  final Product product;
  final int quantity;
  final bool isFavourite;

  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = !product.isInStock;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
// -----------------------------------------------------------------
// PRODUCT IMAGE
// -----------------------------------------------------------------
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: Colors.grey.shade50,
                    padding: const EdgeInsets.all(12),
                    child: Opacity(
                      opacity: isOutOfStock ? 0.45 : 1,
                      child: Image.network(
                        product.thumbnail,
                        fit: BoxFit.contain,
                        errorBuilder: (
                            context,
                            error,
                            stackTrace,
                            ) {
                          return const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 42,
                              color: Colors.grey,
                            ),
                          );
                        },
                        loadingBuilder: (
                            context,
                            child,
                            loadingProgress,
                            ) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

// -----------------------------------------------------------
// FAVOURITE BUTTON
// -----------------------------------------------------------
                Positioned(
                  top: 6,
                  right: 6,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.92),
                    shape: const CircleBorder(),
                    elevation: 1,
                    child: InkWell(
                      onTap: onFavourite,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(7),
                        child: Icon(
                          isFavourite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 21,
                          color: isFavourite
                              ? Colors.red
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),

// -----------------------------------------------------------
// OUT OF STOCK OVERLAY
// -----------------------------------------------------------
                if (isOutOfStock)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.35),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.70),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Out of stock',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

// -----------------------------------------------------------------
// CARD INFORMATION
// -----------------------------------------------------------------
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                10,
                7,
                10,
                8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
// ---------------------------------------------------------
// METADATA + ADD BUTTON
// ---------------------------------------------------------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          _packSize(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(width: 5),

                      _buildCartControl(isOutOfStock),
                    ],
                  ),

                  const SizedBox(height: 6),

// ---------------------------------------------------------
// PRICE
// ---------------------------------------------------------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _formatPrice(product.price),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      if (product.discountPercentage > 0) ...[
                        const SizedBox(width: 5),
                        Text(
                          _formatPrice(product.mrp),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                            decorationThickness: 1.2,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 4),

// ---------------------------------------------------------
// PRODUCT TITLE
// ---------------------------------------------------------
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

// ---------------------------------------------------------
// RATING + DELIVERY
// ---------------------------------------------------------
                  Row(
                    children: [
                      if (product.rating > 0) ...[
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],

                      const Spacer(),

                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                      ),

                      const SizedBox(width: 2),

                      Text(
                        _deliveryTime(),
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// ---------------------------------------------------------------------------
// CART CONTROL
// ---------------------------------------------------------------------------

  Widget _buildCartControl(bool isOutOfStock) {
    if (isOutOfStock) {
      return Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          'ADD',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

// No items in cart → show ADD button.
    if (quantity == 0) {
      return Material(
        color: Colors.green.shade600,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(7),
          child: const SizedBox(
            height: 32,
            width: 60,
            child: Center(
              child: Text(
                'ADD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      );
    }

// Item already in cart → show stepper.
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.green.shade600,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove,
            onTap: onRemove,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
            ),
            child: Text(
              '$quantity',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          _StepperButton(
            icon: Icons.add,
            onTap: onAdd,
          ),
        ],
      ),
    );
  }

// ---------------------------------------------------------------------------
// PACK SIZE
// ---------------------------------------------------------------------------

  String _packSize() {
// DummyJSON doesn't provide a real pack-size field.
// Brand/category provides useful secondary information instead.
    if (product.brand.trim().isNotEmpty) {
      return product.brand;
    }

    if (product.category.trim().isNotEmpty) {
      return product.category;
    }

    return '1 pack';
  }

// ---------------------------------------------------------------------------
// PRICE
// ---------------------------------------------------------------------------

  String _formatPrice(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

// ---------------------------------------------------------------------------
// DELIVERY TIME
// ---------------------------------------------------------------------------

  String _deliveryTime() {
// DummyJSON does not provide delivery time.
// Keep the presentation consistent rather than pretending this
// is an API-provided value.
    return '10 min';
  }
}

// -----------------------------------------------------------------------------
// STEPPER BUTTON
// -----------------------------------------------------------------------------

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: SizedBox(
        width: 27,
        height: 32,
        child: Icon(
          icon,
          size: 15,
          color: Colors.white,
        ),
      ),
    );
  }
}
