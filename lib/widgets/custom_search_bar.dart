import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String)? onSearch;

  const CustomSearchBar({super.key, this.onSearch});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: (value) {
          if (widget.onSearch != null) {
            widget.onSearch!(value);
          }
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: '정비소, 서비스 검색...',
          hintStyle: TextStyle(color: Theme.of(context).hintColor),
          prefixIcon: const Icon(LucideIcons.search, size: 20),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(LucideIcons.x, size: 18),
                  onPressed: () {
                    _controller.clear();
                    if (widget.onSearch != null) {
                      widget.onSearch!('');
                    }
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}
