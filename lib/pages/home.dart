import 'package:flutter/material.dart';
import 'package:find_it/models/space_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:find_it/colors.dart';

import 'search.dart';
import 'room.dart';
import 'settings.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  void asyncInit() async {
    await SpaceModel.loadItems();
    setState(() {
      print("asyncInit");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,

        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textPrimary),
          bodySmall: TextStyle(color: AppColors.textSecondary),
        ),
      ),
      home: Scaffold(
        appBar: appBar(),
        body: Container(
          color: AppColors.background,
          child: Column(
            children: [
              searchField(),
              const SizedBox(height: 40),
              spacesText(),
              Expanded(child: spacesList()),
            ],
          ),
        )
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        'Home Page',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      actions: [
        GestureDetector(
          onTap: () async {
            final loaded = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
            if(loaded == true){
              setState(() {
                print("Settings loaded");
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.all(10),
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.iconBackground,
              borderRadius: BorderRadius.circular(10)
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.settings,
              color: AppColors.iconColor,
            ),
          ),
        ),
      ],
    );
  }

  Container searchField() {
    return Container(
      margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
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
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchPage()),
          );
        },
        child: TextField(
          enabled: false,
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
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset('assets/icons/Search.svg'),
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
      ),
    );
  }

  GridView spacesList() {
    return GridView.custom(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.9,
      ),
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      scrollDirection: Axis.vertical,
      childrenDelegate: SliverChildBuilderDelegate(
        childCount: SpaceModel.currentSpaces.length + 1,
        (context, index) {
          if (index == SpaceModel.currentSpaces.length) {
            return addSpace(context);
          } else {
            return spaceThumbnail(context, index);
          }
        },
      ),
    );
  }

  Stack spaceThumbnail(BuildContext context, int index) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RoomPage(curSpace: SpaceModel.currentSpaces[index])),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.secondary.withOpacity(0.5),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 2, // Adjust flex to control the size ratio between the image and the tag
                  child: SvgPicture.asset(
                    'assets/icons/dots.svg',
                    fit: BoxFit.cover,
                    color: AppColors.iconColor,
                  ),
                ),
                Expanded(
                  flex: 1, // Adjust flex if needed
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.tertiary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        SpaceModel.currentSpaces[index].name,
                        style: const TextStyle(
                          color: AppColors.textPrimary, // Adjust text color to contrast with the tag background
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Text("Rename"),
              ),
              PopupMenuItem(
                value: 2,
                child: Text("Delete"),
              ),
            ],
            onSelected: (value) async {
              if (value == 1) {
                // Rename the space
                String? newName = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Enter new space name'),
                      content: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'Space Name',
                        ),
                        onSubmitted: (value) {
                          Navigator.of(context).pop(value);
                        },
                      ),
                    );
                  },
                );
                if (newName != null && newName.isNotEmpty) {
                  setState(() {
                    SpaceModel.currentSpaces[index].name = newName;
                  });
                  SpaceModel.saveItems();
                }
              } else if (value == 2) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                    title: Text('Are you sure?'),
                    content: Text('Do you want to delete this space?'),
                    actions: [
                      TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      ),
                      TextButton(
                      child: Text('Delete'),
                      onPressed: () {
                        setState(() {
                          SpaceModel.currentSpaces.removeAt(index);
                        });
                        SpaceModel.saveItems();
                        Navigator.of(context).pop();
                      },
                      ),
                    ],
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  GestureDetector addSpace(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        String? newName = await showDialog<String>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Enter new space name'),
              content: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Space Name',
                ),
                onSubmitted: (value) {
                  Navigator.of(context).pop(value);
                },
              ),
            );
          },
        );
        if (newName != null && newName.isNotEmpty) {
          // Add the new space to currentSpaces
          setState(() {
            SpaceModel.currentSpaces.add(SpaceModel(name: newName));
          });
          await SpaceModel.saveItems();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.secondary.withOpacity(0.5), // Adjusted color opacity
        ),
        child: Column(
          children: [
            const Expanded(
              flex: 2,
              child: Icon(
                Icons.add,
                size: 50.0,
                color: AppColors.iconColor,
              ),
            ),
            Expanded(
              flex: 1, // Adjust flex if needed
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.tertiary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Add Space',
                    style: TextStyle(
                      color: AppColors.textPrimary, // Adjust text color to contrast with the tag background
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Padding spacesText() {
    return const Padding(
      padding: EdgeInsets.only(left: 20),
      child: Text(
        'spaces',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

}