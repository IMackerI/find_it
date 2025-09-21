import 'dart:io';

import 'package:flutter/material.dart';
import 'package:remove_diacritic/remove_diacritic.dart';

import '../models/item_model.dart';
import '../models/space_model.dart';
import '../theme/app_theme.dart';
import '../utils/haptics.dart';
import 'item.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<SpaceModel> _spaces = SpaceModel.currentSpaces;

  List<ItemModel> _items = [];

  @override
  void initState() {
    super.initState();
    _populateItems();
  }

  void _populateItems() {
    final items = <ItemModel>[];
    for (final space in _spaces) {
      space.assignParents();
      items.addAll(space.items);
      for (final nested in space.mySpaces) {
        nested.assignParents();
        items.addAll(nested.items);
        for (final inner in nested.mySpaces) {
          inner.assignParents();
          items.addAll(inner.items);
        }
      }
    }
    setState(() {
      _items = items;
    });
  }

  List<ItemModel> get _filteredItems {
    final query = removeDiacritics(_searchController.text.trim().toLowerCase());
    if (query.isEmpty) {
      return _items;
    }

    return _items.where((item) {
      final name = removeDiacritics(item.name.toLowerCase());
      final description = removeDiacritics(item.description.toLowerCase());
      final tags = item.tags?.map((tag) => removeDiacritics(tag.toLowerCase())).join(' ') ?? '';
      return name.contains(query) || description.contains(query) || tags.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final filteredItems = _filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            AppHaptics.selection();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = 720.0;
            final horizontalPadding = constraints.maxWidth > maxWidth
                ? (constraints.maxWidth - maxWidth) / 2
                : 20.0;

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    20,
                    horizontalPadding,
                    16,
                  ),
                  child: _SearchField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    onCleared: () {
                      _searchController.clear();
                      FocusScope.of(context).unfocus();
                      setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      0,
                      horizontalPadding,
                      20,
                    ),
                    child: filteredItems.isEmpty
                        ? _EmptySearchState(
                            palette: palette,
                            theme: theme,
                            query: _searchController.text.trim(),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              final parentPath = _buildParentPath(item);
                              return _SearchResultTile(
                                item: item,
                                parentPath: parentPath,
                                palette: palette,
                                theme: theme,
                                onTap: () async {
                                  await AppHaptics.lightImpact();
                                  final result = await Navigator.of(context).push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) => ItemDisplayPage(item: item),
                                    ),
                                  );
                                  if (mounted && result == true) {
                                    _populateItems();
                                  }
                                },
                              );
                            },
                            separatorBuilder: (context, _) => const SizedBox(height: 12),
                            itemCount: filteredItems.length,
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _buildParentPath(ItemModel item) {
    final segments = <String>[];
    SpaceModel? parent = item.parent;
    while (parent != null) {
      segments.insert(0, parent.name);
      parent = parent.parent;
    }
    return segments.join(' • ');
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onCleared,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      autofocus: true,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search for an item',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  AppHaptics.selection();
                  onCleared();
                },
              ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.item,
    required this.parentPath,
    required this.palette,
    required this.theme,
    required this.onTap,
  });

  final ItemModel item;
  final String parentPath;
  final AppPalette palette;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: palette.elevatedSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        leading: _ItemAvatar(item: item, palette: palette, theme: theme),
        title: Text(
          item.name,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: parentPath.isEmpty
            ? null
            : Text(
                parentPath,
                style: theme.textTheme.bodySmall?.copyWith(color: palette.mutedForeground),
              ),
        trailing: Icon(Icons.chevron_right_rounded, color: colorScheme.primary),
      ),
    );
  }
}

class _ItemAvatar extends StatelessWidget {
  const _ItemAvatar({
    required this.item,
    required this.palette,
    required this.theme,
  });

  final ItemModel item;
  final AppPalette palette;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final size = 56.0;
    if (item.imagePath != null && item.imagePath!.isNotEmpty) {
      final file = File(item.imagePath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    final iconIndex = item.name.isEmpty
        ? 0
        : item.name.hashCode.abs() % ItemModel.defaultIcons.length;
    final iconData = ItemModel.defaultIcons[iconIndex];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: palette.primaryGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        iconData,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({
    required this.palette,
    required this.theme,
    required this.query,
  });

  final AppPalette palette;
  final ThemeData theme;
  final String query;

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: palette.primaryGradient,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 42,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            query.isEmpty ? 'Nothing to show yet' : 'No matches for "$query"',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            query.isEmpty
                ? 'Start typing to look through all of your saved items.'
                : 'Try searching with another name or keyword.',
            style: theme.textTheme.bodyMedium?.copyWith(color: palette.mutedForeground),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
