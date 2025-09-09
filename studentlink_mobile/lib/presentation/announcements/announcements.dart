import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import './widgets/announcement_card_widget.dart';
import './widgets/announcement_detail_modal.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/search_bar_widget.dart';

class Announcements extends StatefulWidget {
  const Announcements({Key? key}) : super(key: key);

  @override
  State<Announcements> createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late TabController _tabController;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  String _searchQuery = '';

  // Filter states
  Set<String> _selectedDepartments = {};
  Set<String> _selectedCategories = {};
  Set<String> _selectedPriorities = {};
  DateTimeRange? _selectedDateRange;

  // Announcements will be loaded from API
  List<Map<String, dynamic>> _allAnnouncements = [];

  List<Map<String, dynamic>> _filteredAnnouncements = [];
  Set<Map<String, dynamic>> _bookmarkedAnnouncements = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filteredAnnouncements = List.from(_allAnnouncements);
    _loadAnnouncements(); // Load from API
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load announcements from API service
      final announcements = await apiService.getAnnouncements(
        status: 'published',
        perPage: 50,
      );
      
      setState(() {
        _allAnnouncements = announcements;
        _filteredAnnouncements = List.from(_allAnnouncements);
      });
      _loadBookmarked();
    } catch (e) {
      print('Error loading announcements: $e');
      // Keep empty state on error - you might want to show an error message
      setState(() {
        _allAnnouncements = [];
        _filteredAnnouncements = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadBookmarked() {
    _bookmarkedAnnouncements = _allAnnouncements
        .where((announcement) => announcement['isBookmarked'] == true)
        .toSet();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreAnnouncements();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: AppTheme.lightTheme.colorScheme.surface,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              children: [
                SearchBarWidget(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onFilterTap: _showFilterBottomSheet,
                ),
                if (_hasActiveFilters()) ...[
                  SizedBox(height: 1.h),
                  FilterChipsWidget(
                    selectedDepartments: _selectedDepartments,
                    selectedCategories: _selectedCategories,
                    selectedPriorities: _selectedPriorities,
                    selectedDateRange: _selectedDateRange,
                    onRemoveFilter: _removeFilter,
                    onClearAll: _clearAllFilters,
                  ),
                ],
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: AppTheme.lightTheme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'campaign',
                        color: _tabController.index == 0
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text('All Announcements'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'bookmark',
                        color: _tabController.index == 1
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text('Saved'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllAnnouncementsTab(),
                _buildBookmarkedAnnouncementsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      leading: IconButton(
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: Colors.white,
          size: 24,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Announcements',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: CustomIconWidget(
            iconName: 'refresh',
            color: Colors.white,
            size: 24,
          ),
          onPressed: _handleRefresh,
        ),
      ],
    );
  }

  Widget _buildAllAnnouncementsTab() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
    }
    
    if (_filteredAnnouncements.isEmpty && !_isRefreshing) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(vertical: 1.h),
        itemCount: _filteredAnnouncements.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _filteredAnnouncements.length) {
            return _buildLoadingIndicator();
          }

          final announcement = _filteredAnnouncements[index];
          return AnnouncementCardWidget(
            announcement: announcement,
            onTap: () => _showAnnouncementDetail(announcement),
            onBookmark: () => _toggleBookmark(announcement),
            onShare: () => _shareAnnouncement(announcement),
            searchQuery: _searchQuery,
          );
        },
      ),
    );
  }

  Widget _buildBookmarkedAnnouncementsTab() {
    final bookmarkedList = _bookmarkedAnnouncements.toList();

    if (bookmarkedList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'bookmark_border',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'No Saved Announcements',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Bookmark important announcements to save them here',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      itemCount: bookmarkedList.length,
      itemBuilder: (context, index) {
        final announcement = bookmarkedList[index];
        return AnnouncementCardWidget(
          announcement: announcement,
          onTap: () => _showAnnouncementDetail(announcement),
          onBookmark: () => _toggleBookmark(announcement),
          onShare: () => _shareAnnouncement(announcement),
          searchQuery: '',
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'search_off',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Announcements Found',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Try adjusting your search or filters',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          TextButton(
            onPressed: _clearAllFilters,
            child: Text('Clear All Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredAnnouncements = _allAnnouncements.where((announcement) {
        // Search query filter
        if (_searchQuery.isNotEmpty) {
          final searchLower = _searchQuery.toLowerCase();
          final titleMatch = announcement['title']
              .toString()
              .toLowerCase()
              .contains(searchLower);
          final contentMatch = announcement['content']
              .toString()
              .toLowerCase()
              .contains(searchLower);
          if (!titleMatch && !contentMatch) return false;
        }

        // Department filter
        if (_selectedDepartments.isNotEmpty &&
            !_selectedDepartments.contains(announcement['department'])) {
          return false;
        }

        // Category filter
        if (_selectedCategories.isNotEmpty &&
            !_selectedCategories.contains(announcement['category'])) {
          return false;
        }

        // Priority filter
        if (_selectedPriorities.isNotEmpty &&
            !_selectedPriorities.contains(announcement['priority'])) {
          return false;
        }

        // Date range filter
        if (_selectedDateRange != null) {
          final publishDate = announcement['publishedAt'] as DateTime;
          if (publishDate.isBefore(_selectedDateRange!.start) ||
              publishDate
                  .isAfter(_selectedDateRange!.end.add(Duration(days: 1)))) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  bool _hasActiveFilters() {
    return _selectedDepartments.isNotEmpty ||
        _selectedCategories.isNotEmpty ||
        _selectedPriorities.isNotEmpty ||
        _selectedDateRange != null ||
        _searchQuery.isNotEmpty;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheetWidget(
        selectedDepartments: _selectedDepartments,
        selectedCategories: _selectedCategories,
        selectedPriorities: _selectedPriorities,
        selectedDateRange: _selectedDateRange,
        onApplyFilters: (departments, categories, priorities, dateRange) {
          setState(() {
            _selectedDepartments = departments;
            _selectedCategories = categories;
            _selectedPriorities = priorities;
            _selectedDateRange = dateRange;
          });
          _applyFilters();
        },
      ),
    );
  }

  void _removeFilter(String type, String value) {
    setState(() {
      switch (type) {
        case 'department':
          _selectedDepartments.remove(value);
          break;
        case 'category':
          _selectedCategories.remove(value);
          break;
        case 'priority':
          _selectedPriorities.remove(value);
          break;
        case 'date':
          _selectedDateRange = null;
          break;
      }
    });
    _applyFilters();
  }

  void _clearAllFilters() {
    setState(() {
      _selectedDepartments.clear();
      _selectedCategories.clear();
      _selectedPriorities.clear();
      _selectedDateRange = null;
      _searchQuery = '';
      _searchController.clear();
    });
    _applyFilters();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      // Simulate adding new announcements
      if (_allAnnouncements.length < 20) {
        _allAnnouncements.insert(0, {
          'id': _allAnnouncements.length + 1,
          'title': 'New Announcement ${_allAnnouncements.length + 1}',
          'content': 'This is a new announcement that was just added.',
          'department': 'Administration',
          'category': 'Administrative',
          'priority': 'medium',
          'publishedAt': DateTime.now(),
          'author': 'Admin Staff',
          'targetCourse': 'All',
          'isBookmarked': false,
        });
      }
    });
    _applyFilters();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Announcements refreshed'),
        backgroundColor: AppTheme.successLight,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _loadMoreAnnouncements() {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate loading more announcements
    Future.delayed(Duration(seconds: 1)).then((_) {
      setState(() {
        _isLoadingMore = false;
      });
    });
  }

  void _showAnnouncementDetail(Map<String, dynamic> announcement) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AnnouncementDetailModal(
        announcement: announcement,
        onBookmark: () => _toggleBookmark(announcement),
        onShare: () => _shareAnnouncement(announcement),
      ),
    );
  }

  void _toggleBookmark(Map<String, dynamic> announcement) {
    setState(() {
      announcement['isBookmarked'] = !announcement['isBookmarked'];

      if (announcement['isBookmarked']) {
        _bookmarkedAnnouncements.add(announcement);
      } else {
        _bookmarkedAnnouncements.remove(announcement);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          announcement['isBookmarked']
              ? 'Announcement bookmarked'
              : 'Bookmark removed',
        ),
        backgroundColor: announcement['isBookmarked']
            ? AppTheme.successLight
            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _shareAnnouncement(Map<String, dynamic> announcement) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Announcement shared successfully'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
