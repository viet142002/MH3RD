import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/others.dart';
import '../bloc/quest_bloc.dart';
import '../bloc/quest_event_state.dart';

class QuestFilterSheet extends StatefulWidget {
  final TextEditingController searchController;
  final QuestBloc questBloc;
  final QuestHub activeHub;

  const QuestFilterSheet({
    super.key,
    required this.searchController,
    required this.questBloc,
    required this.activeHub,
  });

  @override
  State<QuestFilterSheet> createState() => _QuestFilterSheetState();
}

class _QuestFilterSheetState extends State<QuestFilterSheet> {
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        widget.questBloc.add(QuestSearchChanged(query));
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
      value: widget.questBloc,
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
                        'Filter Quests',
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
                          widget.questBloc.add(QuestSearchChanged(q));
                          Navigator.pop(context);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search quest name...',
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
                      BlocBuilder<QuestBloc, QuestState>(
                        builder: (context, state) {
                          if (state is QuestListLoaded &&
                              widget.searchController.text.isNotEmpty) {
                            final matches = state.getFiltered(widget.activeHub);
                            if (matches.isEmpty) return const SizedBox.shrink();
                            return Container(
                              constraints: const BoxConstraints(maxHeight: 180),
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
                                  final q = matches[i];
                                  return ListTile(
                                    leading: const Icon(Icons.history,
                                        size: 18, color: Colors.grey),
                                    title: Text(q.name,
                                        style: const TextStyle(fontSize: 14)),
                                    onTap: () {
                                      widget.searchController.text = q.name;
                                      widget.questBloc
                                          .add(QuestSearchChanged(q.name));
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
                      const SizedBox(height: 24),
                      const Text(
                        'Star Level',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<QuestBloc, QuestState>(
                        builder: (context, state) {
                          if (state is! QuestListLoaded)
                            return const SizedBox.shrink();
                          final maxStars = widget.activeHub == QuestHub.village ? 6 : 8;
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(maxStars, (index) {
                              final starValue = index + 1;
                              final isSelected = state.star == starValue;
                              return ChoiceChip(
                                label: Text('$starValue \u2605'),
                                selected: isSelected,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                onSelected: (selected) {
                                  widget.questBloc.add(
                                    QuestListRequested(
                                      hub: widget.activeHub,
                                      star: selected ? starValue : null,
                                    ),
                                  );
                                },
                              );
                            }),
                          );
                        },
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
