import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/vehicle.dart';

class SearchBarWidget extends StatefulWidget {
  final List<Vehicle> vehicles;
  final Function(String) onSearchChanged;
  final Function(String) onMakeFilterChanged;
  final Function(int) onYearFilterChanged;
  final VoidCallback onClearFilters;
  final String searchQuery;
  final String selectedMake;
  final int selectedYear;

  const SearchBarWidget({
    super.key,
    required this.vehicles,
    required this.onSearchChanged,
    required this.onMakeFilterChanged,
    required this.onYearFilterChanged,
    required this.onClearFilters,
    required this.searchQuery,
    required this.selectedMake,
    required this.selectedYear,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _availableMakes {
    final makes = widget.vehicles.map((v) => v.make).toSet().toList();
    makes.sort();
    return makes;
  }

  List<int> get _availableYears {
    final years = widget.vehicles.map((v) => v.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a)); // Latest first
    return years;
  }

  bool get _hasActiveFilters {
    return widget.selectedMake.isNotEmpty || widget.selectedYear > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: widget.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search vehicles...',
              hintStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              prefixIcon: Icon(
                CupertinoIcons.search,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Clear search button
                  if (widget.searchQuery.isNotEmpty)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: () {
                        _searchController.clear();
                        widget.onSearchChanged('');
                      },
                      child: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        size: 20,
                      ),
                    ),
                  
                  // Filter toggle button
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minSize: 0,
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                    child: Stack(
                      children: [
                        Icon(
                          CupertinoIcons.slider_horizontal_3,
                          color: _showFilters || _hasActiveFilters
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        if (_hasActiveFilters)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),

        // Filter Options
        if (_showFilters) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (_hasActiveFilters)
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 0,
                        onPressed: widget.onClearFilters,
                        child: Text(
                          'Clear All',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Make Filter
                Text(
                  'Make',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: widget.selectedMake.isEmpty ? null : widget.selectedMake,
                    decoration: const InputDecoration(
                      hintText: 'All Makes',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    dropdownColor: Theme.of(context).cardColor,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Makes'),
                      ),
                      ..._availableMakes.map((make) => DropdownMenuItem<String>(
                            value: make,
                            child: Text(make),
                          )),
                    ],
                    onChanged: (value) {
                      widget.onMakeFilterChanged(value ?? '');
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Year Filter
                Text(
                  'Year',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<int>(
                    value: widget.selectedYear == 0 ? null : widget.selectedYear,
                    decoration: const InputDecoration(
                      hintText: 'All Years',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    dropdownColor: Theme.of(context).cardColor,
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('All Years'),
                      ),
                      ..._availableYears.map((year) => DropdownMenuItem<int>(
                            value: year,
                            child: Text(year.toString()),
                          )),
                    ],
                    onChanged: (value) {
                      widget.onYearFilterChanged(value ?? 0);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}