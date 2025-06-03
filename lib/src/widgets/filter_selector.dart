import 'package:flutter/material.dart';
import '../core/camera_controller.dart';
import '../filters/filter.dart';
import '../filters/preset_filters.dart';

/// A widget that displays and allows selection of available filters
class FilterSelector extends StatelessWidget {
  /// The camera controller
  final CameraController controller;
  
  /// List of filters to display
  final List<Filter> filters;
  
  /// Callback when a filter is selected
  final Function(Filter)? onFilterSelected;
  
  /// Height of the filter list
  final double height;
  
  /// Width of each filter item
  final double itemWidth;
  
  /// Border radius for filter items
  final BorderRadius borderRadius;
  
  /// Spacing between filter items
  final double spacing;

  /// Creates a FilterSelector instance
  const FilterSelector({
    Key? key,
    required this.controller,
    this.filters = const [],
    this.onFilterSelected,
    this.height = 80,
    this.itemWidth = 80,
    this.spacing = 8,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If no filters provided, use preset filters
    final displayFilters = filters.isEmpty ? PresetFilters.getAll() : filters;
    
    return Container(
      height: height,
      color: Colors.black54,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: spacing, vertical: spacing / 2),
        scrollDirection: Axis.horizontal,
        itemCount: displayFilters.length,
        separatorBuilder: (context, index) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          final filter = displayFilters[index];
          return _FilterItem(
            filter: filter,
            controller: controller,
            itemWidth: itemWidth,
            borderRadius: borderRadius,
            onTap: () {
              controller.setFilter(filter);
              onFilterSelected?.call(filter);
            },
          );
        },
      ),
    );
  }
}

/// Individual filter item widget
class _FilterItem extends StatelessWidget {
  /// The filter to display
  final Filter filter;
  
  /// The camera controller
  final CameraController controller;
  
  /// Width of the item
  final double itemWidth;
  
  /// Border radius for the item
  final BorderRadius borderRadius;
  
  /// Callback when the item is tapped
  final VoidCallback onTap;

  /// Creates a _FilterItem instance
  const _FilterItem({
    Key? key,
    required this.filter,
    required this.controller,
    required this.itemWidth,
    required this.borderRadius,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Filter?>(
      valueListenable: controller.activeFilterNotifier,
      builder: (context, activeFilter, _) {
        final isSelected = activeFilter?.id == filter.id;
        
        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: itemWidth,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
              borderRadius: borderRadius,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: borderRadius.copyWith(
                      bottomLeft: Radius.zero,
                      bottomRight: Radius.zero,
                    ),
                    child: _buildFilterPreview(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(2),
                  width: double.infinity,
                  color: Colors.black54,
                  child: Text(
                    filter.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterPreview() {
    // If the filter has a thumbnail, use it
    if (filter.thumbnail != null) {
      return Image.memory(
        filter.thumbnail!,
        fit: BoxFit.cover,
      );
    }
    
    // Otherwise show placeholder with filter name
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: Text(
          filter.name.substring(0, 1),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 