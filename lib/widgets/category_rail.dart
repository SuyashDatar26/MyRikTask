import 'package:flutter/material.dart';

class CategoryRail extends StatefulWidget {
  const CategoryRail({super.key});

  @override
  State<CategoryRail> createState() => _CategoryRailState();
}

class _CategoryRailState extends State<CategoryRail> {
  int _selectedIndex = 0;

  final List<_CategoryItem> _categories = const [
    _CategoryItem(
      name: 'All',
      icon: Icons.grid_view_rounded,
    ),
    _CategoryItem(
      name: 'Beverages',
      icon: Icons.local_drink_outlined,
    ),
    _CategoryItem(
      name: 'Sweets',
      icon: Icons.cake_outlined,
    ),
    _CategoryItem(
      name: 'Bakery',
      icon: Icons.bakery_dining_outlined,
    ),
    _CategoryItem(
      name: 'Dairy',
      icon: Icons.egg_alt_outlined,
    ),
    _CategoryItem(
      name: 'Snacks',
      icon: Icons.fastfood_outlined,
    ),
    _CategoryItem(
      name: 'Fruits',
      icon: Icons.apple_outlined,
    ),
    _CategoryItem(
      name: 'Vegetables',
      icon: Icons.eco_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = index == _selectedIndex;

          return _CategoryTile(
            category: category,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CATEGORY TILE
// -----------------------------------------------------------------------------

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final _CategoryItem category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 6,
          ),
          child: Column(
            children: [
// ---------------------------------------------------------------
// ICON
// ---------------------------------------------------------------
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.green.shade50
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.green.shade200
                        : Colors.grey.shade200,
                  ),
                ),
                child: Icon(
                  category.icon,
                  size: 25,
                  color: isSelected
                      ? Colors.green.shade700
                      : Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 5),

// ---------------------------------------------------------------
// CATEGORY NAME
// ---------------------------------------------------------------
              Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.15,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: isSelected
                      ? Colors.green.shade700
                      : Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 4),

// ---------------------------------------------------------------
// SELECTED INDICATOR
// ---------------------------------------------------------------
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: isSelected ? 24 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CATEGORY MODEL
// -----------------------------------------------------------------------------

class _CategoryItem {
  final String name;
  final IconData icon;

  const _CategoryItem({
    required this.name,
    required this.icon,
  });
}
