import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/monster_bloc.dart';
import '../bloc/monster_event_state.dart';

class MonsterFilterSheet extends StatefulWidget {
  final TextEditingController searchController;
  final MonsterBloc monsterBloc;

  const MonsterFilterSheet({
    super.key,
    required this.searchController,
    required this.monsterBloc,
  });

  @override
  State<MonsterFilterSheet> createState() => _MonsterFilterSheetState();
}

class _MonsterFilterSheetState extends State<MonsterFilterSheet> {
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        widget.monsterBloc.add(MonsterSearchChanged(query));
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.monsterBloc,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'Filter Monsters',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: widget.searchController,
                        autofocus: widget.searchController.text.isEmpty,
                        textInputAction: TextInputAction.search,
                        onChanged: _onSearchChanged,
                        onSubmitted: (q) {
                          widget.monsterBloc.add(MonsterSearchChanged(q));
                          Navigator.pop(context);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by name...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Real-time suggestions
                      BlocBuilder<MonsterBloc, MonsterState>(
                        builder: (context, state) {
                          if (state is MonsterListLoaded &&
                              widget.searchController.text.isNotEmpty) {
                            final matches = state.filtered;
                            if (matches.isEmpty) return const SizedBox.shrink();
                            return Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: matches.length.clamp(0, 5),
                                itemBuilder: (context, i) {
                                  final m = matches[i];
                                  return ListTile(
                                    leading: const Icon(Icons.history,
                                        size: 18, color: Colors.grey),
                                    title: Text(m.name),
                                    onTap: () {
                                      widget.searchController.text = m.name;
                                      widget.monsterBloc
                                          .add(MonsterSearchChanged(m.name));
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Recommended Searches',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'Jinouga',
                          'Rathalos',
                          'Nargacuga',
                          'Tigrex',
                          'Amatsu',
                          'Barioth',
                          'Deviljho'
                        ].map((name) {
                          return ActionChip(
                            label: Text(name),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onPressed: () {
                              widget.searchController.text = name;
                              widget.monsterBloc
                                  .add(MonsterSearchChanged(name));
                              Navigator.pop(context);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
