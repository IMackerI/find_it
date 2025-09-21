import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/space_model.dart';
import '../theme/app_theme.dart';
import 'room.dart';
import 'search.dart';
import 'settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.themeController});

  final AppThemeController themeController;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSpaces();
  }

  Future<void> _loadSpaces() async {
    await SpaceModel.loadItems();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _calculateColumns(double width) {
    if (width >= 1200) return 5;
    if (width >= 992) return 4;
    if (width >= 720) return 3;
    if (width >= 520) return 2;
    return 1;
  }

  double _calculateTileAspect(double width, int columns) {
    final tileWidth = (width - (columns - 1) * 20) / columns;
    if (columns == 1) {
      return tileWidth / 150;
    }
    return tileWidth / 220;
  }

  Future<void> _openSearch() async {
    Feedback.forTap(context);
    await HapticFeedback.selectionClick();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchPage()),
    );
    setState(() {});
  }

  Future<void> _openSettings() async {
    Feedback.forTap(context);
    await HapticFeedback.selectionClick();
    final loaded = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(themeController: widget.themeController),
      ),
    );
    if (loaded == true) {
      setState(() {});
    }
  }

  Future<void> _openSpace(SpaceModel space) async {
    Feedback.forTap(context);
    await HapticFeedback.selectionClick();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RoomPage(curSpace: space)),
    );
    setState(() {});
  }

  Future<void> _addSpace() async {
    final controller = TextEditingController();
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create a new space'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Space name',
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
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
      await HapticFeedback.mediumImpact();
    }
  }

  Future<void> _renameSpace(SpaceModel space) async {
    final controller = TextEditingController(text: space.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename space'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Space name'),
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
    if (newName != null && newName.isNotEmpty) {
      setState(() {
        space.name = newName;
      });
      await SpaceModel.saveItems();
      await HapticFeedback.lightImpact();
    }
  }

  Future<void> _deleteSpace(SpaceModel space) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove space?'),
        content: Text('This will delete "${space.name}" and all nested items.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() {
        SpaceModel.currentSpaces.remove(space);
      });
      await SpaceModel.saveItems();
      await HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Find It',
          style: textStyles.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_rounded),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  color: colors.primary,
                  onRefresh: () async {
                    await SpaceModel.loadItems();
                    setState(() {});
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = _calculateColumns(constraints.maxWidth);
                      final aspectRatio =
                          _calculateTileAspect(constraints.maxWidth, columns);
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSearchBar(context),
                            const SizedBox(height: 32),
                            _buildHeaderRow(context),
                            const SizedBox(height: 20),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                childAspectRatio: aspectRatio,
                              ),
                              itemCount: SpaceModel.currentSpaces.length + 1,
                              itemBuilder: (context, index) {
                                if (index == SpaceModel.currentSpaces.length) {
                                  return _AddSpaceCard(onCreate: () {
                                    _addSpace();
                                  });
                                }
                                final space = SpaceModel.currentSpaces[index];
                                return _SpaceTile(
                                  space: space,
                                  onTap: () {
                                    _openSpace(space);
                                  },
                                  onRename: () {
                                    _renameSpace(space);
                                  },
                                  onDelete: () {
                                    _deleteSpace(space);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final palette = context.palette;
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Material(
      color: palette.surfaceComponent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _openSearch,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: colors.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Search for anything…',
                  style: textStyles.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(Icons.tune_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            'Spaces',
            style: textStyles.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          '${SpaceModel.currentSpaces.length} total',
          style: textStyles.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _SpaceTile extends StatelessWidget {
  const _SpaceTile({
    required this.space,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  final SpaceModel space;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Material(
      color: palette.surfaceComponent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(
                        colors.primary.withOpacity(0.12),
                        palette.surfaceComponent,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      Icons.inventory_2_rounded,
                      color: colors.primary,
                      size: 32,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    space.name,
                    style: textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${space.items.length} items',
                    style: textStyles.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 4,
              child: PopupMenuButton<int>(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onSelected: (value) {
                  if (value == 0) {
                    onRename();
                  } else if (value == 1) {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Text('Rename'),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: Text('Delete'),
                  ),
                ],
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddSpaceCard extends StatelessWidget {
  const _AddSpaceCard({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colors = context.colors;
    final textStyles = context.textStyles;

    return OutlinedButton(
      onPressed: () {
        Feedback.forTap(context);
        HapticFeedback.lightImpact();
        onCreate();
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: palette.surfaceComponent,
        side: BorderSide(color: colors.primary.withOpacity(0.6)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: colors.primary, size: 34),
            const SizedBox(height: 12),
            Text(
              'Add space',
              style: textStyles.titleMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Organize a new area',
              style: textStyles.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
