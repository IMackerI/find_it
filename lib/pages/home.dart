import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:find_it/models/space_model.dart';

import '../theme/app_theme.dart';
import 'room.dart';
import 'search.dart';
import 'settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);
    final spaces = SpaceModel.currentSpaces;

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [palette.surfaceDim, palette.background],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = _crossAxisCountForWidth(constraints.maxWidth);
              final aspectRatio = constraints.maxWidth < 600 ? 0.95 : 1.1;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Find it',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Keep track of your rooms, drawers and everything inside them.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: palette.muted,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _SearchField(onTap: _openSearch),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Spaces',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          FilledButton.icon(
                            onPressed: _createSpace,
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('New space'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == spaces.length) {
                            return _AddSpaceCard(onTap: _createSpace);
                          }
                          final space = spaces[index];
                          return _SpaceCard(
                            space: space,
                            onOpen: () => _openSpace(space),
                            onRename: () => _renameSpace(index),
                            onDelete: () => _deleteSpace(index),
                          );
                        },
                        childCount: spaces.length + 1,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Text(
        'Find it',
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      actions: [
        IconButton(
          tooltip: 'Settings',
          onPressed: _openSettings,
          icon: const Icon(Icons.settings_rounded),
        ),
      ],
    );
  }

  int _crossAxisCountForWidth(double width) {
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
  }

  Future<void> _openSearch() async {
    HapticFeedback.selectionClick();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchPage()),
    );
    setState(() {});
  }

  Future<void> _openSpace(SpaceModel space) async {
    HapticFeedback.lightImpact();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RoomPage(curSpace: space)),
    );
    setState(() {});
  }

  Future<void> _openSettings() async {
    HapticFeedback.selectionClick();
    final loaded = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
    if (loaded == true) {
      setState(() {});
    }
  }

  Future<void> _createSpace() async {
    HapticFeedback.mediumImpact();
    final newName = await _promptForName(
      title: 'Create a space',
      label: 'Space name',
    );
    if (newName != null && newName.trim().isNotEmpty) {
      setState(() {
        SpaceModel.currentSpaces.add(SpaceModel(name: newName.trim()));
      });
      await SpaceModel.saveItems();
    }
  }

  Future<void> _renameSpace(int index) async {
    HapticFeedback.selectionClick();
    final currentName = SpaceModel.currentSpaces[index].name;
    final updatedName = await _promptForName(
      title: 'Rename space',
      label: 'Space name',
      initialValue: currentName,
    );
    if (updatedName != null && updatedName.trim().isNotEmpty) {
      setState(() {
        SpaceModel.currentSpaces[index].name = updatedName.trim();
      });
      await SpaceModel.saveItems();
    }
  }

  Future<void> _deleteSpace(int index) async {
    HapticFeedback.selectionClick();
    final palette = context.palette;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete space'),
          content: const Text('Are you sure you want to delete this space and everything inside it?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                HapticFeedback.heavyImpact();
                Navigator.of(context).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: palette.accent,
                foregroundColor: palette.onPrimary,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      setState(() {
        SpaceModel.currentSpaces.removeAt(index);
      });
      await SpaceModel.saveItems();
    }
  }

  Future<String?> _promptForName({
    required String title,
    required String label,
    String? initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(labelText: label),
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).whenComplete(controller.dispose);
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: palette.surfaceBright,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: palette.iconBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SvgPicture.asset(
                  'assets/icons/Search.svg',
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(palette.iconForeground, BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Search for an item',
                  style: theme.textTheme.bodyLarge?.copyWith(color: palette.muted),
                ),
              ),
              Icon(Icons.tune_rounded, color: palette.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddSpaceCard extends StatelessWidget {
  const _AddSpaceCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: palette.border),
            color: palette.surfaceBright.withOpacity(0.7),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.iconBackground,
                ),
                child: Icon(Icons.add_rounded, color: palette.iconForeground, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'Add space',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Create a new area to organize your items.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: palette.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _SpaceMenuAction { rename, delete }

class _SpaceCard extends StatelessWidget {
  const _SpaceCard({
    required this.space,
    required this.onOpen,
    required this.onRename,
    required this.onDelete,
  });

  final SpaceModel space;
  final VoidCallback onOpen;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);
    final totalSpaces = _countSpaces(space);
    final totalItems = _countItems(space);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [palette.cardGradientStart, palette.cardGradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: PopupMenuButton<_SpaceMenuAction>(
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                    onSelected: (value) {
                      HapticFeedback.selectionClick();
                      switch (value) {
                        case _SpaceMenuAction.rename:
                          onRename();
                          break;
                        case _SpaceMenuAction.delete:
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: _SpaceMenuAction.rename,
                        child: Text('Rename'),
                      ),
                      const PopupMenuItem(
                        value: _SpaceMenuAction.delete,
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/dots.svg',
                      colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  space.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$totalSpaces space${totalSpaces == 1 ? '' : 's'} • $totalItems item${totalItems == 1 ? '' : 's'}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _countSpaces(SpaceModel space) {
    int count = space.mySpaces.length;
    for (final child in space.mySpaces) {
      count += _countSpaces(child);
    }
    return count;
  }

  int _countItems(SpaceModel space) {
    int count = space.items.length;
    for (final child in space.mySpaces) {
      count += _countItems(child);
    }
    return count;
  }
}
