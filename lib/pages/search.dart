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
    getItems();
    List<ItemModel> filteredItems = getFilteredItems();
    final theme = Theme.of(context);
    final extras = theme.extension<AppThemeColors>()!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        titleSpacing: 12,
        title: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: searchBar(context),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: extras.backgroundGradient),
        child: SafeArea(
          top: false,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              String parentName = '';
              if (filteredItems[index].parent != null) {
                parentName = filteredItems[index].parent!.name;
                if (filteredItems[index].parent!.parent != null) {
                  parentName = '${filteredItems[index].parent!.parent!.name} > $parentName';
                  if (filteredItems[index].parent!.parent!.parent != null) {
                    parentName =
                        '${filteredItems[index].parent!.parent!.parent!.name} > $parentName';
                  }
                }
              }
              return searchEntry(filteredItems, index, parentName, context);
            },
          ),
        ),
      ),
    );
  }

  Widget searchEntry(
      List<ItemModel> filteredItems, int index, String parentName, BuildContext context) {
    final theme = Theme.of(context);
    final extras = theme.extension<AppThemeColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(filteredItems[index].name),
        subtitle: parentName.isEmpty
            ? null
            : Text(
                parentName,
                style: theme.textTheme.bodySmall?.copyWith(color: extras.subtleText),
              ),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.4),
          foregroundColor: theme.colorScheme.primary,
          child: filteredItems[index].imagePath == null
              ? Icon(
                  ItemModel.defaultIcons[
                      Random().nextInt(ItemModel.defaultIcons.length)],
                )
              : null,
          backgroundImage: filteredItems[index].imagePath != null
              ? FileImage(File(filteredItems[index].imagePath!))
              : null,
        ),
        onTap: () async {
          HapticFeedback.selectionClick();
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDisplayPage(item: filteredItems[index]),
            ),
          );
          if (result == true) {
            setState(() {
              getItems();
            });
          }
        },
      ),
    );
  }

  Widget searchBar(BuildContext context) {
    final theme = Theme.of(context);
    final extras = theme.extension<AppThemeColors>()!;
    return TextField(
      onChanged: (value) {
        setState(() {
          searchValue = value;
        });
      },
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search for an item',
        hintStyle: theme.textTheme.bodyLarge?.copyWith(color: extras.subtleText),
        prefixIcon: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/Arrow - Left 2.svg',
            colorFilter: ColorFilter.mode(
              theme.colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            Navigator.pop(context);
          },
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: GestureDetector(
            onTap: () => HapticFeedback.selectionClick(),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.35),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/Filter.svg',
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
