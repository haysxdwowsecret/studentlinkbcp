import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Modern dropdown widget with enhanced styling and consistency
class ModernDropdownWidget<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? hint;
  final String? label;
  final String? errorText;
  final bool enabled;
  final Widget? prefixIcon;
  final bool isExpanded;
  final String? Function(T?)? validator;

  const ModernDropdownWidget({
    Key? key,
    required this.items,
    this.value,
    this.onChanged,
    this.hint,
    this.label,
    this.errorText,
    this.enabled = true,
    this.prefixIcon,
    this.isExpanded = true,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: errorText != null 
                  ? theme.colorScheme.error 
                  : theme.colorScheme.outline,
              width: 1.5,
            ),
            color: theme.colorScheme.surface,
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: enabled ? onChanged : null,
            validator: validator,
            isExpanded: isExpanded,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: prefixIcon,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 3.w,
                vertical: 1.8.h,
              ),
              errorText: errorText,
              errorStyle: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            dropdownColor: theme.colorScheme.surface,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
            iconSize: 5.w,
            borderRadius: BorderRadius.circular(16.0),
            menuMaxHeight: 40.h,
            itemHeight: 6.h,
          ),
        ),
      ],
    );
  }
}

/// Modern searchable dropdown widget
class ModernSearchableDropdownWidget<T> extends StatefulWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? hint;
  final String? label;
  final String? errorText;
  final bool enabled;
  final Widget? prefixIcon;
  final bool isExpanded;
  final String? Function(T?)? validator;
  final String Function(T)? displayItem;
  final String Function(T)? searchKey;

  const ModernSearchableDropdownWidget({
    Key? key,
    required this.items,
    this.value,
    this.onChanged,
    this.hint,
    this.label,
    this.errorText,
    this.enabled = true,
    this.prefixIcon,
    this.isExpanded = true,
    this.validator,
    this.displayItem,
    this.searchKey,
  }) : super(key: key);

  @override
  State<ModernSearchableDropdownWidget<T>> createState() => _ModernSearchableDropdownWidgetState<T>();
}

class _ModernSearchableDropdownWidgetState<T> extends State<ModernSearchableDropdownWidget<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<DropdownMenuItem<T>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: widget.errorText != null 
                  ? theme.colorScheme.error 
                  : theme.colorScheme.outline,
              width: 1.5,
            ),
            color: theme.colorScheme.surface,
          ),
          child: DropdownButtonFormField<T>(
            value: widget.value,
            items: _filteredItems,
            onChanged: widget.enabled ? widget.onChanged : null,
            validator: widget.validator,
            isExpanded: widget.isExpanded,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: widget.prefixIcon,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 3.w,
                vertical: 1.8.h,
              ),
              errorText: widget.errorText,
              errorStyle: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            dropdownColor: theme.colorScheme.surface,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
            iconSize: 5.w,
            borderRadius: BorderRadius.circular(16.0),
            menuMaxHeight: 40.h,
            itemHeight: 6.h,
          ),
        ),
      ],
    );
  }
}

/// Modern multi-select dropdown widget
class ModernMultiSelectDropdownWidget<T> extends StatefulWidget {
  final List<T> selectedValues;
  final List<DropdownMenuItem<T>> items;
  final void Function(List<T>)? onChanged;
  final String? hint;
  final String? label;
  final String? errorText;
  final bool enabled;
  final Widget? prefixIcon;
  final String Function(T)? displayItem;

  const ModernMultiSelectDropdownWidget({
    Key? key,
    required this.items,
    required this.selectedValues,
    this.onChanged,
    this.hint,
    this.label,
    this.errorText,
    this.enabled = true,
    this.prefixIcon,
    this.displayItem,
  }) : super(key: key);

  @override
  State<ModernMultiSelectDropdownWidget<T>> createState() => _ModernMultiSelectDropdownWidgetState<T>();
}

class _ModernMultiSelectDropdownWidgetState<T> extends State<ModernMultiSelectDropdownWidget<T>> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: widget.errorText != null 
                  ? theme.colorScheme.error 
                  : theme.colorScheme.outline,
              width: 1.5,
            ),
            color: theme.colorScheme.surface,
          ),
          child: InkWell(
            onTap: widget.enabled ? _showMultiSelectDialog : null,
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 3.w,
                vertical: 1.8.h,
              ),
              child: Row(
                children: [
                  if (widget.prefixIcon != null) ...[
                    widget.prefixIcon!,
                    SizedBox(width: 2.w),
                  ],
                  Expanded(
                    child: Text(
                      widget.selectedValues.isEmpty
                          ? widget.hint ?? 'Select items'
                          : '${widget.selectedValues.length} item(s) selected',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: widget.selectedValues.isEmpty
                            ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 5.w,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          SizedBox(height: 0.5.h),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  void _showMultiSelectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.label ?? 'Select Items'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.items.map((item) {
                final isSelected = widget.selectedValues.contains(item.value);
                return CheckboxListTile(
                  title: Text(item.child.toString()),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        widget.selectedValues.add(item.value!);
                      } else {
                        widget.selectedValues.remove(item.value!);
                      }
                    });
                  },
                );
              }).toList(),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onChanged?.call(widget.selectedValues);
              Navigator.pop(context);
            },
            child: Text('Done'),
          ),
        ],
      ),
    );
  }
}
