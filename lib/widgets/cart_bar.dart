import 'package:flutter/material.dart';

class CartBar extends StatelessWidget {
  const CartBar({
    super.key,
    required this.itemCount,
    required this.total,
  });

  final int itemCount;
  final double total;

  @override
  Widget build(BuildContext context) {
// Don't show the bar when the cart is empty.
    if (itemCount <= 0) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          12,
          6,
          12,
          10,
        ),
        child: Material(
          color: Colors.green.shade600,
          borderRadius: BorderRadius.circular(10),
          elevation: 4,
          child: InkWell(
            onTap: () {
// Cart checkout/details are intentionally not implemented.
// The assignment requires the cart to hold state, but does
// not require a separate cart screen.
            },
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
// ---------------------------------------------------------
// CART ICON
// ---------------------------------------------------------
                  const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 22,
                  ),

                  const SizedBox(width: 10),

// ---------------------------------------------------------
// ITEM COUNT
// ---------------------------------------------------------
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'View cart',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

// ---------------------------------------------------------
// TOTAL
// ---------------------------------------------------------
                  Text(
                    _formatPrice(total),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(width: 8),

// ---------------------------------------------------------
// ARROW
// ---------------------------------------------------------
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }
}
