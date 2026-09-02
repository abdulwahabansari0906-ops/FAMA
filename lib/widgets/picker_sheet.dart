// widgets/searchable_picker_sheet.dart
import 'dart:async';
import 'package:flutter/material.dart';

class PickerItem {
  final String id;
  final String label;
  const PickerItem({required this.id, required this.label});
}

typedef PickerFetcher = Future<List<PickerItem>> Function(String search);

Future<PickerItem?> showSearchablePicker({
  required BuildContext context,
  required String title,
  required PickerFetcher fetcher,
}) {
  return showModalBottomSheet<PickerItem>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _SearchablePickerSheet(title: title, fetcher: fetcher),
  );
}

class _SearchablePickerSheet extends StatefulWidget {
  final String title;
  final PickerFetcher fetcher;
  const _SearchablePickerSheet({required this.title, required this.fetcher});

  @override
  State<_SearchablePickerSheet> createState() => _SearchablePickerSheetState();
}

class _SearchablePickerSheetState extends State<_SearchablePickerSheet> {
  static const Color _darkColor = Color(0xFF020A16);
  static const Color _borderColor = Color(0xFFE4E8ED);

  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  List<PickerItem> _items = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load('');
  }

  Future<void> _load(String search) async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final items = await widget.fetcher(search);
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _load(value));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _borderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: 'Rob',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _darkColor,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(fontFamily: 'Rob', fontSize: 13, color: _darkColor),
                  decoration: InputDecoration(
                    hintText: 'Search ${widget.title.toLowerCase()}...',
                    hintStyle: const TextStyle(fontFamily: 'Rob', fontSize: 13, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, size: 20, color: _darkColor),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: _borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: _borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: _darkColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildList(scrollController)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(ScrollController scrollController) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _darkColor));
    }
    if (_error.isNotEmpty) {
      return Center(
        child: TextButton(
          onPressed: () => _load(_searchCtrl.text),
          child: Text(
            '$_error\nTap to retry.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Rob', color: Color(0xFF60656B)),
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(
        child: Text('No results found.', style: TextStyle(fontFamily: 'Rob', color: Colors.grey)),
      );
    }
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: _borderColor),
      itemBuilder: (context, index) {
        final item = _items[index];
        return ListTile(
          title: Text(
            item.label,
            style: const TextStyle(
              fontFamily: 'Rob',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _darkColor,
            ),
          ),
          onTap: () => Navigator.pop(context, item),
        );
      },
    );
  }
}