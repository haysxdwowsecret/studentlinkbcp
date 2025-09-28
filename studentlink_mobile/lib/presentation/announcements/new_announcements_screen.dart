import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import './widgets/new_announcement_card_widget.dart';
import './widgets/new_announcement_detail_modal.dart';
import './widgets/modern_announcement_filter_chips_widget.dart';

class NewAnnouncementsScreen extends StatefulWidget {
  const NewAnnouncementsScreen({Key? key}) : super(key: key);

  @override
  State<NewAnnouncementsScreen> createState() => _NewAnnouncementsScreenState();
}

class _NewAnnouncementsScreenState extends State<NewAnnouncementsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late TabController _tabController;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  String _searchQuery = '';

  // Filter states
  String _categoryFilter = 'All';
  List<String> _availableCategories = [
    'All',
    'School Updates',
    'Class Schedules & Exams',
    'Enrollment & Clearance',
    'Scholarships & Financial Aid',
    'Student Activities & Events',
    'Emergency Notices',
    'Administrative Updates',
    'OJT & Career Services',
    'Campus Ministry',
    'Faculty Announcements',
    'System Maintenance',
    'Student Services',
  ];

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
    _loadAnnouncements();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔄 Loading announcements...');
      // Load announcements from API service
      final announcements = await apiService.getAnnouncements(
        status: 'published',
        perPage: 50,
      );
      
      print('📢 Loaded ${announcements.length} announcements');
      for (var announcement in announcements) {
        print('  - ${announcement['title'] ?? 'Announcement #${announcement['id']}'} (ID: ${announcement['id']})');
      }
      
      // Note: Using predefined categories instead of extracting from API
      // This ensures consistent filtering across all announcements
      
      setState(() {
        _allAnnouncements = announcements;
        _filteredAnnouncements = List.from(_allAnnouncements);
      });
      _loadBookmarked();
      _applyFilters();
    } catch (e) {
      print('❌ Error loading announcements: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load announcements: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
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

  void _applyFilters() {
    setState(() {
      _filteredAnnouncements = _allAnnouncements.where((announcement) {
        // Category filter
        bool categoryMatch = _categoryFilter == 'All' || 
                           announcement['category'] == _categoryFilter;
        
        // Search filter
        bool searchMatch = _searchQuery.isEmpty ||
                          (announcement['title']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                          (announcement['category']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        
        return categoryMatch && searchMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Search bar
            _buildSearchBar(),
            
            // Modern Filter Chips
            if (_categoryFilter != 'All')
              ModernAnnouncementFilterChipsWidget(
                categoryFilter: _categoryFilter,
                onClearAll: _clearAllFilters,
              ),
            
            // Tab bar
            _buildTabBar(),
            
            // Tab content
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
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'General Announcements',
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              color: AppTheme.textPrimaryLight,
              fontWeight: FontWeight.w800,
              fontSize: 28,
            ),
          ),
          IconButton(
            onPressed: () {
              // Global search functionality
              HapticFeedback.lightImpact();
            },
            icon: Icon(
              Icons.search_rounded,
              color: AppTheme.textPrimaryLight,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: TextEditingController(text: _searchQuery),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  _applyFilters();
                },
                decoration: InputDecoration(
                  hintText: 'Search announcements...',
                  hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF9CA3AF),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: const Color(0xFF6B7280),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryLight.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: _showCategoryFilter,
              icon: Icon(
                Icons.filter_list_rounded,
                color: AppTheme.primaryLight,
                size: 20,
              ),
              tooltip: 'Filter announcements',
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.primaryLight.withValues(alpha: 0.1),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppTheme.primaryLight,
        unselectedLabelColor: AppTheme.textSecondaryLight,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  Icon(
                    Icons.campaign_rounded,
                    size: 18,
                  ),
                const SizedBox(width: 8),
                Text('School Updates'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_rounded,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text('Saved'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllAnnouncementsTab() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
        ),
      );
    }
    
    if (_filteredAnnouncements.isEmpty && !_isRefreshing) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.primaryLight,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filteredAnnouncements.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _filteredAnnouncements.length) {
            return _buildLoadingIndicator();
          }

          final announcement = _filteredAnnouncements[index];
          return NewAnnouncementCardWidget(
            announcement: announcement,
            onTap: () => _showAnnouncementDetail(announcement),
            onBookmark: () => _toggleBookmark(announcement),
            onShare: () => _shareAnnouncement(announcement),
          );
        },
      ),
    );
  }

  Widget _buildBookmarkedAnnouncementsTab() {
    final bookmarkedAnnouncements = _filteredAnnouncements
        .where((announcement) => announcement['is_bookmarked'] == true)
        .toList();

    if (bookmarkedAnnouncements.isEmpty) {
      return _buildEmptyBookmarksState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: bookmarkedAnnouncements.length,
      itemBuilder: (context, index) {
        final announcement = bookmarkedAnnouncements[index];
        return NewAnnouncementCardWidget(
          announcement: announcement,
          onTap: () => _showAnnouncementDetail(announcement),
          onBookmark: () => _toggleBookmark(announcement),
          onShare: () => _shareAnnouncement(announcement),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // More subtle icon with better proportions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.announcement_outlined,
                color: AppTheme.primaryLight.withValues(alpha: 0.7),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            
            // Better typography hierarchy
            Text(
              'No announcements found',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF374151),
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new updates',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B7280),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyBookmarksState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // More subtle icon with better proportions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_outline_rounded,
                color: AppTheme.primaryLight.withValues(alpha: 0.7),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            
            // Better typography hierarchy
            Text(
              'No saved announcements',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF374151),
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the bookmark icon to save announcements',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B7280),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
        ),
      ),
    );
  }


  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    
    await _loadAnnouncements();
    
    setState(() {
      _isRefreshing = false;
    });
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
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => NewAnnouncementDetailModal(
        announcement: announcement,
        onBookmark: () => _toggleBookmark(announcement),
        onShare: () => _shareAnnouncement(announcement),
      ),
    );
  }

  void _toggleBookmark(Map<String, dynamic> announcement) {
    setState(() {
      announcement['is_bookmarked'] = !announcement['is_bookmarked'];

      if (announcement['is_bookmarked']) {
        _bookmarkedAnnouncements.add(announcement);
      } else {
        _bookmarkedAnnouncements.remove(announcement);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          announcement['is_bookmarked']
              ? 'Announcement bookmarked'
              : 'Bookmark removed',
        ),
        backgroundColor: announcement['is_bookmarked']
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

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter by Category',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _availableCategories.length,
                itemBuilder: (context, index) {
                  final category = _availableCategories[index];
                  return ListTile(
                    title: Text(category),
                    leading: Radio<String>(
                      value: category,
                      groupValue: _categoryFilter,
                      onChanged: (value) {
                        setState(() {
                          _categoryFilter = value!;
                        });
                        _applyFilters();
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _categoryFilter = 'All';
      _searchQuery = '';
      _searchController.clear();
    });
    _applyFilters();
  }
}
