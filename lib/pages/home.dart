import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/space_model.dart';
import '../theme/app_theme.dart';
import 'room.dart';
import 'search.dart';
import 'settings.dart';

enum _SpaceMenuAction { rename, delete }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _refreshSpaces() async {
    await SpaceModel.loadItems();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openSearch() async {
    HapticFeedback.selectionClick();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchPage()),
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openSettings() async {
    HapticFeedback.selectionClick();
    final bool? loaded = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
    if (!mounted) return;
    if (loaded == true) {
      await SpaceModel.loadItems();
      setState(() {});
    }
  }

  Future<void> _openSpace(SpaceModel space) async {
    HapticFeedback.selectionClick();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomPage(curSpace: space),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _addSpace() async {
    HapticFeedback.lightImpact();
    final String? name = await _promptForName(
      title: 'Create a new space',
      label: 'Space name',
      confirmLabel: 'Add',
    );
    if (name == null || name.trim().isEmpty) {
      return;
    }
    setState(() {
      SpaceModel.currentSpaces.add(SpaceModel(name: name.trim()));
    });
    final saved = await SpaceModel.saveItems();
    if (!saved) {
      _showSaveFailure();
      return;
    }
    HapticFeedback.mediumImpact();
  }

  Future<void> _renameSpace(int index) async {
    HapticFeedback.selectionClick();
    final space = SpaceModel.currentSpaces[index];
    final String? newName = await _promptForName(
      title: 'Rename space',
      label: 'Space name',
      confirmLabel: 'Save',
      initialValue: space.name,
    );
    if (newName == null || newName.trim().isEmpty) {
      return;
    }
    setState(() {
      space.name = newName.trim();
    });
    final saved = await SpaceModel.saveItems();
    if (!saved) {
      _showSaveFailure();
      return;
    }
    HapticFeedback.lightImpact();
  }

  Future<void> _deleteSpace(int index) async {
    HapticFeedback.selectionClick();
    final space = SpaceModel.currentSpaces[index];
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete space'),
          content: Text('Remove "${space.name}" and everything inside it?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
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
      final saved = await SpaceModel.saveItems();
      if (!saved) {
        _showSaveFailure();
        return;
      }
      HapticFeedback.mediumImpact();
    }
  }

  Future<String?> _promptForName({
    required String title,
    required String label,
    required String confirmLabel,
    String? initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: label),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    return result;
  }

  void _showSaveFailure() {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('We couldn\'t save your changes. Please try again.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extras = theme.extension<AppThemeColors>()!;
    final spaces = SpaceModel.currentSpaces;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Find It',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: extras.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchField(theme),
                const SizedBox(height: 28),
                Text(
                  'Spaces',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxCrossAxisExtent = constraints.maxWidth < 480
                          ? 220.0
                          : constraints.maxWidth < 768
                              ? 260.0
                              : 320.0;
                      final aspectRatio = constraints.maxWidth < 600 ? 0.9 : 1.05;

                      if (spaces.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: _refreshSpaces,
                          edgeOffset: 12,
                          displacement: 36,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: constraints.maxHeight * 0.1),
                              _EmptyState(onAddSpace: _addSpace),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _refreshSpaces,
                        edgeOffset: 12,
                        displacement: 36,
                        child: GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 12),
                          itemCount: spaces.length + 1,
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: maxCrossAxisExtent,
                            mainAxisSpacing: 24,
                            crossAxisSpacing: 24,
                            childAspectRatio: aspectRatio,
                          ),
                          itemBuilder: (context, index) {
                            if (index == spaces.length) {
                              return _AddSpaceCard(onTap: _addSpace);
                            }
                            return _SpaceCard(
                              space: spaces[index],
                              onOpen: () => _openSpace(spaces[index]),
                              onRename: () => _renameSpace(index),
                              onDelete: () => _deleteSpace(index),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextField _buildSearchField(ThemeData theme) {
    final extras = theme.extension<AppThemeColors>()!;
    return TextField(
      readOnly: true,
      onTap: _openSearch,
      decoration: InputDecoration(
        hintText: 'Search for an item',
        hintStyle: theme.textTheme.bodyLarge?.copyWith(color: extras.subtleText),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(
            'assets/icons/Search.svg',
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.35),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.tune_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

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
    final theme = Theme.of(context);
    final extras = theme.extension<AppThemeColors>()!;
    final colorScheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            gradient: extras.cardGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: extras.shadowColor,
                blurRadius: 22,
                offset: const Offset(0, 12),
                spreadRadius: -12,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 16,
                right: 16,
                child: _SpaceMenu(
                  onRename: onRename,
                  onDelete: onDelete,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/dots.svg',
                          color: colorScheme.onPrimaryContainer,
                          width: 28,
                          height: 28,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      space.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${space.mySpaces.length} subspaces • ${space.items.length} items',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),
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
    final theme = Theme.of(context);
    final extras = theme.extension<AppThemeColors>()!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: extras.glassBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: extras.borderColor),
            boxShadow: [
              BoxShadow(
                color: extras.shadowColor,
                blurRadius: 18,
                offset: const Offset(0, 10),
                spreadRadius: -8,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 36,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Add space',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to create a new location',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: extras.subtleText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpaceMenu extends StatelessWidget {
  const _SpaceMenu({required this.onRename, required this.onDelete});

  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return PopupMenuButton<_SpaceMenuAction>(
      tooltip: 'Space options',
      offset: const Offset(0, 36),
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
        PopupMenuItem<_SpaceMenuAction>(
          value: _SpaceMenuAction.rename,
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 18, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              const Text('Rename'),
            ],
          ),
        ),
        PopupMenuItem<_SpaceMenuAction>(
          value: _SpaceMenuAction.delete,
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: colorScheme.error),
              const SizedBox(width: 12),
              const Text('Delete'),
            ],
          ),
        ),
      ],
      icon: const Icon(Icons.more_horiz_rounded),
      color: theme.colorScheme.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddSpace});

  final VoidCallback onAddSpace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extras = theme.extension<AppThemeColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            size: 86,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Create your first space',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Group your rooms, drawers and shelves to make searching effortless.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: extras.subtleText),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAddSpace,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add a space'),
          ),
        ],
      ),
    );
  }
}
