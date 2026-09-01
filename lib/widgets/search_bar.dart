import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/product_view_model.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({
    super.key,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ProductViewModel>();

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      textInputAction: TextInputAction.search,
      onChanged: viewModel.onSearchChanged,
      onSubmitted: viewModel.onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Search products...',
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 14,
        ),

// ---------------------------------------------------------------
// SEARCH ICON
// ---------------------------------------------------------------
        prefixIcon: Icon(
          Icons.search_rounded,
          color: Colors.grey.shade600,
          size: 22,
        ),

// ---------------------------------------------------------------
// CLEAR BUTTON
// ---------------------------------------------------------------
        suffixIcon: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            if (_controller.text.isEmpty) {
              return const SizedBox.shrink();
            }

            return IconButton(
              tooltip: 'Clear search',
              icon: Icon(
                Icons.close_rounded,
                color: Colors.grey.shade600,
                size: 20,
              ),
              onPressed: () {
                _controller.clear();

                viewModel.clearSearch();

                _focusNode.requestFocus();

                setState(() {});
              },
            );
          },
        ),

// ---------------------------------------------------------------
// FIELD STYLE
// ---------------------------------------------------------------
        filled: true,
        fillColor: Colors.grey.shade100,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.green.shade400,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}
