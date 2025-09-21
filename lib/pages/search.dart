import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remove_diacritic/remove_diacritic.dart';

import '../models/item_model.dart';
import '../models/space_model.dart';
import '../theme/app_theme.dart';
import 'item.dart';

class SearchPage extends StatefulWidget {
  SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<SpaceModel> places = SpaceModel.currentSpaces;
  String searchValue = '';
  List<ItemModel> items = [];

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _refreshItems() {
    items = [];
    for (final place in places) {
      place.assignParents();
      items.addAll(place.items);
      for (final space in place.mySpaces) {
        items.addAll(space.items);
        for (final subSpace in space.mySpaces) {
          items.addAll(subSpace.items);
        }
      }
    }
  }

  List<ItemModel> get _filteredItems {
    final query = removeDiacritics(searchValue.toLowerCase());
    return items.where((item) {
      final name = removeDiacritics(item.name.toLowerCase());
      final description = removeDiacritics(item.description.toLowerCase());
      return name.contains(query) || description.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    _refreshItems();
    final filteredItems = _filteredItems;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 96,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: _buildSearchBar(context),
          ),
        ),
      ),
      body: filteredItems.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'No items match your search just yet. Try a different keyword or add more details to your items.',
                  textAlign: TextAlign.center,
                  style: textStyles.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: filteredItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final parentName = _buildParentLabel(item);
                return _SearchResultTile(
                  item: item,
                  parentName: parentName,
                  onTap: () async {
                    Feedback.forTap(context);
                    await HapticFeedback.selectionClick();
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDisplayPage(item: item),
                      ),
                    );
                    if (result == true) {
                      setState(() {
                        _refreshItems();
                      });
                    }
                  },
                );
              },
            ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colors = context.colors;
    final palette = context.palette;
    final textStyles = context.textStyles;

    return Material(
      color: palette.surfaceComponent,
      borderRadius: BorderRadius.circular(24),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: colors.onSurfaceVariant,
            onPressed: () {
              Feedback.forTap(context);
              HapticFeedback.selectionClick();
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  searchValue = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search for an item',
                hintStyle: textStyles.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                border: InputBorder.none,
                suffixIcon: Icon(
                  Icons.search_rounded,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildParentLabel(ItemModel item) {
    String parentName = '';
    if (item.parent != null) {
      parentName = item.parent!.name;
      if (item.parent!.parent != null) {
        parentName = '${item.parent!.parent!.name} › $parentName';
        if (item.parent!.parent!.parent != null) {
          parentName = '${item.parent!.parent!.parent!.name} › $parentName';
        }
      }
    }
    return parentName;
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.item,
    required this.parentName,
    required this.onTap,
  });

  final ItemModel item;
  final String parentName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final palette = context.palette;

    return Material(
      color: palette.surfaceComponent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Color.alphaBlend(
                  colors.primary.withOpacity(0.12),
                  palette.surfaceComponent,
                ),
                child: item.imagePath == null
                    ? Icon(
                        ItemModel.defaultIcons[item.name.hashCode.abs() % ItemModel.defaultIcons.length],
                        color: colors.primary,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Image.file(
                          File(item.imagePath!),
                          fit: BoxFit.cover,
                          width: 52,
                          height: 52,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: textStyles.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (parentName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        parentName,
                        style: textStyles.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
