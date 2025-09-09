import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import './widgets/concern_card_widget.dart';
import './widgets/context_menu_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/search_bar_widget.dart';

class MyConcerns extends StatefulWidget {
  const MyConcerns({Key? key}) : super(key: key);

  @override
  State<MyConcerns> createState() => _MyConcernsState();
}

class _MyConcernsState extends State<MyConcerns> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {
    'status': 'All',
    'department': 'All',
  };
  bool _isLoadingMore = false;
  OverlayEntry? _overlayEntry;

  // Concerns will be loaded from API
  List<Map<String, dynamic>> _allConcerns = [];

  // All data now loaded from backend API

  List<Map<String, dynamic>> _filteredConcerns = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadConcerns(); // Load from API
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadConcerns() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load concerns from API service
      final concerns = await apiService.getConcerns(perPage: 50);
      
      setState(() {
        _allConcerns = concerns;
        _filteredConcerns = List.from(_allConcerns);
      });
    } catch (e) {
      print('Error loading concerns: $e');
      // Keep empty state on error
      setState(() {
        _allConcerns = [];
        _filteredConcerns = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreConcerns();
    }
  }

  Future<void> _loadMoreConcerns() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate loading more data
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshConcerns() async {
    HapticFeedback.lightImpact();

    // Simulate refresh
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _filteredConcerns = List.from(_allConcerns);
    });

    _applyFilters();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allConcerns);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((concern) {
        final title = (concern['title'] as String).toLowerCase();
        final description = (concern['description'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || description.contains(query);
      }).toList();
    }

    // Apply status filter
    if (_activeFilters['status'] != null && _activeFilters['status'] != 'All') {
      filtered = filtered
          .where((concern) => concern['status'] == _activeFilters['status'])
          .toList();
    }

    // Apply department filter
    if (_activeFilters['department'] != null &&
        _activeFilters['department'] != 'All') {
      filtered = filtered
          .where((concern) =>
              concern['department'] == _activeFilters['department'])
          .toList();
    }

    // Apply date range filter
    if (_activeFilters['dateRange'] != null) {
      final DateTimeRange dateRange =
          _activeFilters['dateRange'] as DateTimeRange;
      filtered = filtered.where((concern) {
        final submissionDate = concern['submissionDate'] as DateTime;
        return submissionDate
                .isAfter(dateRange.start.subtract(Duration(days: 1))) &&
            submissionDate.isBefore(dateRange.end.add(Duration(days: 1)));
      }).toList();
    }

    setState(() {
      _filteredConcerns = filtered;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _activeFilters,
        onFiltersApplied: (filters) {
          setState(() {
            _activeFilters = filters;
          });
          _applyFilters();
        },
      ),
    );
  }

  void _removeFilter(String filterKey) {
    setState(() {
      if (filterKey == 'dateRange') {
        _activeFilters.remove(filterKey);
      } else {
        _activeFilters[filterKey] = 'All';
      }
    });
    _applyFilters();
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilters = {
        'status': 'All',
        'department': 'All',
      };
      _searchQuery = '';
    });
    _applyFilters();
  }

  void _showContextMenu(Map<String, dynamic> concern, Offset position) {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy - 100,
        left: position.dx - 150,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: 70.w,
            child: ContextMenuWidget(
              concern: concern,
              onShareStatus: () {
                _removeOverlay();
                _shareStatus(concern);
              },
              onDownloadPdf: () {
                _removeOverlay();
                _downloadPdf(concern);
              },
              onSetNotifications: () {
                _removeOverlay();
                _setNotifications(concern);
              },
              onClose: _removeOverlay,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _shareStatus(Map<String, dynamic> concern) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing status for: ${concern['title']}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _downloadPdf(Map<String, dynamic> concern) {
    // Implement PDF download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading PDF for: ${concern['title']}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _setNotifications(Map<String, dynamic> concern) {
    // Implement notification settings
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Setting notifications for: ${concern['title']}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _hasActiveFilters() {
    return (_activeFilters['status'] != null &&
            _activeFilters['status'] != 'All') ||
        (_activeFilters['department'] != null &&
            _activeFilters['department'] != 'All') ||
        (_activeFilters['dateRange'] != null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Concerns'),
        leading: IconButton(
          onPressed: () => Navigator.pushNamed(context, '/dashboard-home'),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: Colors.white,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile-settings'),
            icon: CustomIconWidget(
              iconName: 'person',
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _removeOverlay,
        child: Column(
          children: [
            // Sticky Search Bar
            SearchBarWidget(
              searchQuery: _searchQuery,
              onSearchChanged: _onSearchChanged,
              onFilterPressed: _showFilterBottomSheet,
            ),

            // Filter Chips
            if (_hasActiveFilters())
              FilterChipsWidget(
                activeFilters: _activeFilters,
                onFilterRemoved: _removeFilter,
                onClearAll: _clearAllFilters,
              ),

            // Main Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    )
                  : _filteredConcerns.isEmpty
                      ? EmptyStateWidget(
                          onSubmitConcern: () =>
                              Navigator.pushNamed(context, '/submit-concern'),
                        )
                      : RefreshIndicator(
                      onRefresh: _refreshConcerns,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount:
                            _filteredConcerns.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _filteredConcerns.length) {
                            return Container(
                              padding: EdgeInsets.all(4.w),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
                              ),
                            );
                          }

                          final concern = _filteredConcerns[index];
                          return ConcernCardWidget(
                            concern: concern,
                            onViewDetails: () {
                              Navigator.pushNamed(
                                context,
                                '/concern-details',
                                arguments: concern,
                              );
                            },
                            onAddReply: () {
                              Navigator.pushNamed(
                                context,
                                '/concern-details',
                                arguments: {
                                  'concern': concern,
                                  'openReply': true
                                },
                              );
                            },
                            onArchive: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Concern archived: ${concern['title']}'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            onLongPress: () {
                              final RenderBox renderBox =
                                  context.findRenderObject() as RenderBox;
                              final position =
                                  renderBox.localToGlobal(Offset.zero);
                              _showContextMenu(concern, position);
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/submit-concern'),
        icon: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 24,
        ),
        label: Text(
          'New Concern',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }
}
