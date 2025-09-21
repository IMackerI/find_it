import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:remove_diacritic/remove_diacritic.dart';

import 'package:find_it/models/item_model.dart';
import 'package:find_it/models/space_model.dart';

import '../theme/app_theme.dart';
import 'item.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<SpaceModel> places = SpaceModel.currentSpaces;
  String searchValue = '';
  List<ItemModel> items = [];
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: searchValue);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void getItems() {
    items = [];
    for (var place in places) {
      place.assignParents();
      items.addAll(place.items);
      for (var space in place.mySpaces) {
        items.addAll(space.items);
        for (var subSpace in space.mySpaces) {
          items.addAll(subSpace.items);
        }
      }
    }
  }

  List<ItemModel> getFilteredItems() {
    return items.where((item) {
      return removeDiacritics(item.name.toLowerCase()).contains(removeDiacritics(searchValue.toLowerCase())) ||
          removeDiacritics(item.description.toLowerCase()).contains(removeDiacritics(searchValue.toLowerCase()));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);

    getItems();
    List<ItemModel> filteredItems = getFilteredItems();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: _SearchBar(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                searchValue = value;
              });
            },
            onBack: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [palette.surfaceDim, palette.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: filteredItems.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/Search.svg',
                        width: 64,
                        height: 64,
                        colorFilter: ColorFilter.mode(palette.muted, BlendMode.srcIn),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No items found',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try searching with a different name or description.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: palette.muted),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: filteredItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  String parentName = '';
                  if (item.parent != null) {
                    parentName = item.parent!.name;
                    if (item.parent!.parent != null) {
                      parentName = '${item.parent!.parent!.name} > ' + parentName;
                      if (item.parent!.parent!.parent != null) {
                        parentName = '${item.parent!.parent!.parent!.name} > ' + parentName;
                      }
                    }
                  }

                  return _SearchResultTile(
                    item: item,
                    parentName: parentName,
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDisplayPage(item: item),
                        ),
                      );
                      if (result == true) {
                        setState(() {
                          getItems();
                          filteredItems = getFilteredItems();
                        });
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.onChanged,
    required this.onBack,
    required this.controller,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback onBack;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surfaceBright,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search for an item',
          border: InputBorder.none,
          prefixIcon: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/Arrow - Left 2.svg',
              colorFilter: ColorFilter.mode(palette.iconForeground, BlendMode.srcIn),
            ),
            onPressed: onBack,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.tune_rounded, color: palette.muted),
          ),
        ),
      ),
    );
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
    final palette = context.palette;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: palette.surfaceBright,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: palette.iconBackground,
                foregroundColor: palette.iconForeground,
                backgroundImage: item.imagePath != null ? FileImage(File(item.imagePath!)) : null,
                child: item.imagePath == null
                    ? Icon(
                        ItemModel.defaultIcons[Random().nextInt(ItemModel.defaultIcons.length)],
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      parentName,
                      style: theme.textTheme.bodySmall?.copyWith(color: palette.muted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
