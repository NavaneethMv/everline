import 'package:flutter/material.dart';

/// A flexible grid widget that arranges child widgets in a grid pattern,
/// filling rows first and expanding the last item to fill remaining space.
///
/// This widget takes a list of widgets and arranges them in a grid with the
/// specified number of columns. It fills each row before moving to the next one.
/// The last item in an incomplete row will expand to fill the remaining width.
class HomeGridWidget extends StatelessWidget {
  /// The widgets to be displayed in the grid
  final List<Widget> children;

  /// Number of columns in the grid
  final int crossAxisCount;

  /// Spacing between columns
  final double crossAxisSpacing;

  /// Spacing between rows
  final double mainAxisSpacing;

  /// Padding around the entire grid
  final EdgeInsetsGeometry padding;

  /// Whether the grid should take up all available height
  final bool expandHeight;

  /// Whether each child should have equal width
  final bool equalWidth;

  /// Whether each child should have equal height
  final bool equalHeight;

  /// How to align items horizontally within their grid cells
  final CrossAxisAlignment crossAxisAlignment;

  /// How to align items vertically within their grid cells
  final MainAxisAlignment mainAxisAlignment;

  /// Optional title to display at the top left of the grid
  final String? title;

  /// Style for the title text
  final TextStyle? titleStyle;

  /// Spacing between title and grid content
  final double titleSpacing;

  const HomeGridWidget({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 16.0,
    this.mainAxisSpacing = 16.0,
    this.padding = EdgeInsets.zero,
    this.expandHeight = false,
    this.equalWidth = true,
    this.equalHeight = true,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.title,
    this.titleStyle,
    this.titleSpacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final int totalItems = children.length;
    final int rowCount = (totalItems / crossAxisCount).ceil();

    if (totalItems == 0) {
      return Container();
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title!,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: titleSpacing),
          ],

          ...List.generate(rowCount, (rowIndex) {
            final int startIndex = rowIndex * crossAxisCount;
            final int endIndex = (startIndex + crossAxisCount <= totalItems)
                ? startIndex + crossAxisCount
                : totalItems;

            final List<Widget> rowChildren = children
                .sublist(startIndex, endIndex)
                .toList();

            final bool isLastRow = rowIndex == rowCount - 1;
            final bool isIncompleteRow = rowChildren.length < crossAxisCount;

            return Padding(
              padding: EdgeInsets.only(
                bottom: rowIndex < rowCount - 1 ? mainAxisSpacing : 0,
              ),
              child: Row(
                crossAxisAlignment: crossAxisAlignment,
                mainAxisAlignment: mainAxisAlignment,
                children: _buildRowItems(
                  rowChildren,
                  isLastRow,
                  isIncompleteRow,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Widget> _buildRowItems(
    List<Widget> rowChildren,
    bool isLastRow,
    bool isIncompleteRow,
  ) {
    if (!equalWidth) {
      return rowChildren;
    }

    final List<Widget> rowItems = [];

    // Check if this is the last row with an incomplete set
    if (isLastRow && isIncompleteRow && rowChildren.length > 1) {
      // Add all items except the last one with equal width
      for (int i = 0; i < rowChildren.length - 1; i++) {
        rowItems.add(Expanded(flex: 1, child: rowChildren[i]));
        if (i < rowChildren.length - 2) {
          rowItems.add(SizedBox(width: crossAxisSpacing));
        }
      }

      // Add spacing before the last item
      rowItems.add(SizedBox(width: crossAxisSpacing));

      // Calculate how many columns the last item should span
      final int remainingColumns = crossAxisCount - rowChildren.length + 1;

      // Add the last item with flex to fill remaining space
      // The flex includes the space for the remaining columns + their spacings
      rowItems.add(Expanded(flex: remainingColumns, child: rowChildren.last));
    } else {
      // Normal row or single item in last row
      for (int i = 0; i < rowChildren.length; i++) {
        rowItems.add(Expanded(child: rowChildren[i]));
        if (i < rowChildren.length - 1) {
          rowItems.add(SizedBox(width: crossAxisSpacing));
        }
      }

      // Add empty spacers for incomplete rows (except the special case above)
      if (isIncompleteRow && rowChildren.length < crossAxisCount) {
        final int remainingItems = crossAxisCount - rowChildren.length;
        for (int i = 0; i < remainingItems; i++) {
          rowItems.add(SizedBox(width: crossAxisSpacing));
          rowItems.add(Expanded(child: Container()));
        }
      }
    }

    return rowItems;
  }
}
