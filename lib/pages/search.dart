import 'dart:io';
import 'dart:math';
import 'package:find_it/colors.dart';
import 'package:find_it/pages/item.dart';
import 'package:flutter/material.dart';
import 'package:find_it/models/space_model.dart';
import 'package:find_it/models/item_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:remove_diacritic/remove_diacritic.dart';

class SearchPage extends StatefulWidget {
  SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<SpaceModel> places = SpaceModel.currentSpaces;
  String searchValue = '';
  List<ItemModel> items = [];

  void getItems(){
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

  List<ItemModel> getFilteredItems(){
    return items.where((item) {
      return removeDiacritics(item.name.toLowerCase()).contains(removeDiacritics(searchValue.toLowerCase())) 
      || removeDiacritics(item.description.toLowerCase()).contains(removeDiacritics(searchValue.toLowerCase()));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    getItems();
    List<ItemModel> filteredItems = getFilteredItems();

    return Scaffold(
      appBar: AppBar(
        title: searchBar(context),
        automaticallyImplyLeading: false, // Add this line to remove the back arrow
        backgroundColor: AppColors.primary,
      ),
      body: Container(
        color: AppColors.background,
        child: ListView.builder(
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            String parentName = '';
            if (filteredItems[index].parent != null) {
              parentName = filteredItems[index].parent!.name;
              if(filteredItems[index].parent!.parent != null) {
                parentName = filteredItems[index].parent!.parent!.name + ' > ' + parentName;
                if(filteredItems[index].parent!.parent!.parent != null) {
                  parentName = filteredItems[index].parent!.parent!.parent!.name + ' > ' + parentName;
                }
              }
            }
            return searchEntry(filteredItems, index, parentName, context);
          },
        ),
      ),
    );
  }

  ListTile searchEntry(List<ItemModel> filteredItems, int index, String parentName, BuildContext context) {
    return ListTile(
      title: Text(filteredItems[index].name, style: const TextStyle(color: AppColors.textPrimary)),
      subtitle: Text(parentName, style: const TextStyle(color: AppColors.textSecondary)),
      leading: CircleAvatar(
        child: filteredItems[index].imagePath == null ? ItemModel.defaultIcons[Random().nextInt(ItemModel.defaultIcons.length)] : null,
        backgroundImage: filteredItems[index].imagePath != null ? FileImage(File(filteredItems[index].imagePath!)) : null,
        backgroundColor: AppColors.iconBackground,
      ),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDisplayPage(item: filteredItems[index]),
          ),
        );
        if(result == true){
          setState(() {
            getItems();
            filteredItems = getFilteredItems();
          });
        }
      },
    );
  }

  Container searchBar(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(80, 177, 185, 192),
              blurRadius: 40,
              spreadRadius: 5,
              offset: Offset(0, 0)
            )
          ]
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              searchValue = value;
            });
          },
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search for an item',
            hintStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none
            ),
            contentPadding: const EdgeInsets.all(10),
            prefixIcon: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset('assets/icons/Arrow - Left 2.svg'),
              ),
            ),
            suffixIcon: SizedBox(
              width: 100,
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    VerticalDivider(
                      color: Colors.grey[300],
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: SvgPicture.asset('assets/icons/Filter.svg'),
                    ),
                  ],
                ),
              ),
            ),
            fillColor: Colors.white,
            filled: true
          ),
        ),
      );
  }
}