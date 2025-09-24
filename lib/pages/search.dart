import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:remove_diacritic/remove_diacritic.dart';

import 'package:find_it/models/item_model.dart';
import 'package:find_it/models/space_model.dart';
import 'package:find_it/pages/item.dart';
import 'package:find_it/theme/app_theme.dart';

class SearchPage extends StatefulWidget {
  SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<SpaceModel> places = SpaceModel.currentSpaces;
  String searchValue = '';
  List<ItemModel> items = [];

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
          removeDiacritics(item.description.toLowerCase())
              .contains(removeDiacritics(searchValue.toLowerCase()));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<SpaceModel>>(
      valueListenable: SpaceModel.spacesListenable,
      builder: (context, spaces, _) {
        places = spaces;
        getItems();
        final filteredItems = getFilteredItems();
        final theme = Theme.of(context);
        final extras = theme.extension<AppThemeColors>()!;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(gradient: extras.backgroundGradient),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: searchBar(context),
                  ),
                  Expanded(
                    child: filteredItems.isEmpty
                        ? _buildEmptyResults(theme, extras)
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: filteredItems.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              String parentName = '';
                              if (filteredItems[index].parent != null) {
                                parentName = filteredItems[index].parent!.name;
                                if (filteredItems[index].parent!.parent != null) {
                                  parentName =
                                      '${filteredItems[index].parent!.parent!.name} > $parentName';
                                  if (filteredItems[index].parent!.parent!.parent !=
                                      null) {
                                    parentName =
                                        '${filteredItems[index].parent!.parent!.parent!.name} > $parentName';
                                  }
                                }
                              }
                              return searchEntry(
                                filteredItems,
                                index,
                                parentName,
                                context,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyResults(ThemeData theme, AppThemeColors extras) {
    final bool hasQuery = searchValue.isNotEmpty;
    final String title = hasQuery ? 'No items found' : 'Start searching';
    final String message = hasQuery
        ? 'Try a different keyword or check the item\'s description.'
        : 'Search to quickly jump to any item across your spaces.';
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasQuery ? Icons.search_off_rounded : Icons.search_rounded,
            size: 48,
            color: extras.subtleText,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: extras.subtleText),
          ),
        ],
      ),
    );
  }

  Widget searchEntry(
      List<ItemModel> filteredItems, int index, String parentName, BuildContext context) {
    final theme = Theme.of(context);
    final extras = theme.extension<AppThemeColors>()!;
    final item = filteredItems[index];
    final String description = item.description.trim();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          HapticFeedback.selectionClick();
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDisplayPage(item: item),
            ),
          );
          if (result == true) {
            setState(() {
              getItems();
            });
          }
        },
        child: Ink(
          decoration: BoxDecoration(
            color: extras.glassBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: extras.borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.35),
                foregroundColor: theme.colorScheme.primary,
                child: item.imagePath == null
                    ? Icon(
                        ItemModel.defaultIcons[
                            Random().nextInt(ItemModel.defaultIcons.length)],
                      )
                    : null,
                backgroundImage:
                    item.imagePath != null ? FileImage(File(item.imagePath!)) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (parentName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          parentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: extras.subtleText,
                          ),
                        ),
                      ),
                    if (description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: extras.subtleText,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: extras.subtleText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchBar(BuildContext context) {
    final theme = Theme.of(context);
    final extras = theme.extension<AppThemeColors>()!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: extras.glassBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: extras.borderColor),
        boxShadow: [
          BoxShadow(
            color: extras.shadowColor,
            blurRadius: 22,
            offset: const Offset(0, 12),
            spreadRadius: -12,
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchValue = value;
          });
        },
        autofocus: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search for an item',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(color: extras.subtleText),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          prefixIcon: IconButton(
            padding: const EdgeInsets.all(12),
            icon: SvgPicture.asset(
              'assets/icons/Arrow - Left 2.svg',
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
            },
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 52),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => HapticFeedback.selectionClick(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SvgPicture.asset(
                  'assets/icons/Filter.svg',
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(maxHeight: 48),
        ),
      ),
    );
  }
}
