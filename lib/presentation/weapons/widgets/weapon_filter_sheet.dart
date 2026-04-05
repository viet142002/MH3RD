import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/weapon_constants.dart';
import '../../../../domain/entities/weapon.dart';
import '../bloc/weapon_bloc.dart';
import '../bloc/weapon_event_state.dart';

class WeaponFilterSheet extends StatefulWidget {
  final TextEditingController searchController;
  final WeaponBloc weaponBloc;
  final WeaponType weaponType;
  final int? initialRarity;
  final WeaponElement? initialElement;
  final Function(int?, WeaponElement?) onFilterChanged;

  const WeaponFilterSheet({
    super.key,
    required this.searchController,
    required this.weaponBloc,
    required this.weaponType,
    required this.onFilterChanged,
    this.initialRarity,
    this.initialElement,
  });

  @override
  State<WeaponFilterSheet> createState() => _WeaponFilterSheetState();
}

class _WeaponFilterSheetState extends State<WeaponFilterSheet> {
  Timer? _debounce;
  int? _rarity;
  WeaponElement? _element;

  @override
  void initState() {
    super.initState();
    _rarity = widget.initialRarity;
    _element = widget.initialElement;
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _apply();
      }
    });
  }

  void _apply() {
    widget.onFilterChanged(_rarity, _element);
    widget.weaponBloc.add(
      WeaponFilterChanged(
        type: widget.weaponType,
        rarity: _rarity,
        element: _element,
        nameQuery: widget.searchController.text.isEmpty
            ? null
            : widget.searchController.text,
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.weaponBloc,
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
                        'Filter ${widget.weaponType.displayName}',
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
                          _apply();
                          Navigator.pop(context);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search weapon name...',
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
                      BlocBuilder<WeaponBloc, WeaponState>(
                        builder: (context, state) {
                          if (state is WeaponListLoaded &&
                              widget.searchController.text.isNotEmpty) {
                            final matches = state.filtered;
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
                                  final w = matches[i];
                                  return ListTile(
                                    leading: const Icon(Icons.history,
                                        size: 18, color: Colors.grey),
                                    title: Text(w.name,
                                        style: const TextStyle(fontSize: 14)),
                                    onTap: () {
                                      widget.searchController.text = w.name;
                                      _apply();
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
                        'Rarity',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(7, (index) {
                          final r = index + 1;
                          final isSelected = _rarity == r;
                          return ChoiceChip(
                            label: Text('R$r'),
                            selected: isSelected,
                            selectedColor: rarityColor(r).withValues(alpha: 0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _rarity = selected ? r : null;
                              });
                              _apply();
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Element',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: WeaponElement.values.map((el) {
                          final isSelected = _element == el;
                          return ChoiceChip(
                            label: Text(el.displayName),
                            selected: isSelected,
                            selectedColor: elementColor(el).withValues(alpha: 0.15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _element = selected ? el : null;
                              });
                              _apply();
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
