import 'package:flutter/material.dart';

import '../models/space_model.dart';
import '../theme/app_theme.dart';
import '../utils/haptics.dart';
import 'room.dart';
import 'search.dart';
import 'settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (SpaceModel.currentSpaces.isEmpty) {
      _reloadSpaces();
    }
  }

  Future<void> _reloadSpaces() async {
    setState(() => _isLoading = true);
    await SpaceModel.loadItems();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final spaces = SpaceModel.currentSpaces;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find It'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () async {
              await AppHaptics.selection();
              final loaded = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => SettingsPage()),
              );
              if (mounted && loaded == true) {
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: theme.colorScheme.primary,
          onRefresh: _reloadSpaces,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = _horizontalPadding(constraints.maxWidth);
              final crossAxisCount = _crossAxisCount(constraints.maxWidth);

              return CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        24,
                        horizontalPadding,
                        12,
                      ),
                      child: _SearchCard(
                        onTap: _handleSearchTap,
                        palette: palette,
                        theme: theme,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 8,
                      ),
                      child: Text(
                        'Spaces',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                  if (_isLoading)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    )
                  else if (spaces.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(
                        onCreate: _handleCreateSpace,
                        palette: palette,
                        theme: theme,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        12,
                        horizontalPadding,
                        24,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: crossAxisCount > 2 ? 1.05 : 0.92,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == spaces.length) {
                              return _AddSpaceCard(
                                onTap: _handleCreateSpace,
                                palette: palette,
                                theme: theme,
                              );
                            }
                            final space = spaces[index];
                            return _SpaceCard(
                              space: space,
                              palette: palette,
                              theme: theme,
                              onOpen: () => _openSpace(space),
                              onRename: () => _renameSpace(space),
                              onDelete: () => _deleteSpace(space),
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

  double _horizontalPadding(double maxWidth) {
    if (maxWidth >= 1280) return 88;
    if (maxWidth >= 1024) return 64;
    if (maxWidth >= 768) return 36;
    return 20;
  }

  int _crossAxisCount(double maxWidth) {
    if (maxWidth >= 1280) return 4;
    if (maxWidth >= 1024) return 3;
    if (maxWidth >= 768) return 2;
    return 1;
  }

  Future<void> _handleSearchTap() async {
    await AppHaptics.lightImpact();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SearchPage()),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleCreateSpace() async {
    await AppHaptics.mediumImpact();
    final controller = TextEditingController();
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create a new space'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Space name'),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () {
                AppHaptics.selection();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                AppHaptics.selection();
                Navigator.of(context).pop(controller.text.trim());
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() {
        SpaceModel.currentSpaces.add(SpaceModel(name: newName));
      });
      await SpaceModel.saveItems();
    }
  }

  Future<void> _renameSpace(SpaceModel space) async {
    await AppHaptics.selection();
    final controller = TextEditingController(text: space.name);
    final updated = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename space'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'New space name'),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () {
                AppHaptics.selection();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                AppHaptics.selection();
                Navigator.of(context).pop(controller.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (updated != null && updated.isNotEmpty) {
      setState(() {
        space.name = updated;
      });
      await SpaceModel.saveItems();
    }
  }

  Future<void> _deleteSpace(SpaceModel space) async {
    await AppHaptics.selection();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove space'),
          content: Text('Are you sure you want to delete "${space.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                AppHaptics.selection();
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              onPressed: () {
                AppHaptics.heavyImpact();
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      setState(() {
        SpaceModel.currentSpaces.remove(space);
      });
      await SpaceModel.saveItems();
    }
  }

  Future<void> _openSpace(SpaceModel space) async {
    await AppHaptics.lightImpact();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RoomPage(curSpace: space)),
    );
    if (mounted) {
      setState(() {});
    }
  }
}

enum _SpaceMenuAction { rename, delete }

class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.onTap,
    required this.palette,
    required this.theme,
  });

  final VoidCallback onTap;
  final AppPalette palette;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final onPrimary = theme.colorScheme.onPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          decoration: BoxDecoration(
            gradient: palette.primaryGradient,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.search_rounded, color: onPrimary),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  'Search for an item',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.tune_rounded, color: onPrimary.withOpacity(0.9)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpaceCard extends StatelessWidget {
  const _SpaceCard({
    required this.space,
    required this.palette,
    required this.theme,
    required this.onOpen,
    required this.onRename,
    required this.onDelete,
  });

  final SpaceModel space;
  final AppPalette palette;
  final ThemeData theme;
  final VoidCallback onOpen;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: PopupMenuButton<_SpaceMenuAction>(
                  elevation: 4,
                  onSelected: (action) {
                    switch (action) {
                      case _SpaceMenuAction.rename:
                        onRename();
                        break;
                      case _SpaceMenuAction.delete:
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _SpaceMenuAction.rename,
                      child: Text('Rename'),
                    ),
                    PopupMenuItem(
                      value: _SpaceMenuAction.delete,
                      child: Text('Delete'),
                    ),
                  ],
                  icon: Icon(Icons.more_horiz_rounded, color: palette.mutedForeground),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: palette.primaryGradient,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.inventory_2_rounded,
                      size: 44,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              Text(
                space.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _itemSummary(space.items.length),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _itemSummary(int count) {
    if (count == 0) return 'No items yet';
    if (count == 1) return '1 item saved';
    return '$count items saved';
  }
}

class _AddSpaceCard extends StatelessWidget {
  const _AddSpaceCard({
    required this.onTap,
    required this.palette,
    required this.theme,
  });

  final VoidCallback onTap;
  final AppPalette palette;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: palette.outlineMuted, width: 1.4),
            ),
            child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.surfaceTint,
                    border: Border.all(color: palette.outlineMuted),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 32,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Add space',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Organise another area',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onCreate,
    required this.palette,
    required this.theme,
  });

  final VoidCallback onCreate;
  final AppPalette palette;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: palette.primaryGradient,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 48,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Create your first space',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Group rooms, drawers and items in beautifully organised collections.',
            style: theme.textTheme.bodyLarge?.copyWith(color: palette.mutedForeground),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: onCreate,
            child: const Text('Add a space'),
          ),
        ],
      ),
    );
  }
}
