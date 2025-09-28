import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import './widgets/image_announcement_card_widget.dart';
import './widgets/image_announcement_detail_modal.dart';
import './widgets/modern_announcement_filter_chips_widget.dart';

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
  String _categoryFilter = 'All';

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
      print('🔄 Loading announcements...');
      // Load announcements from API service (all are now image-only)
      final announcements = await apiService.getAnnouncements(
        status: 'published',
        perPage: 50,
      );
      
      print('📢 Loaded ${announcements.length} announcements');
      for (var announcement in announcements) {
        print('  - ${announcement['internal_title'] ?? 'Image Announcement #${announcement['id']}'} (ID: ${announcement['id']})');
      }
      
      setState(() {
        _allAnnouncements = announcements;
        _filteredAnnouncements = List.from(_allAnnouncements);
      });
      _loadBookmarked();
    } catch (e) {
      print('❌ Error loading announcements: $e');
      // Show error message to user
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
      backgroundColor: const Color(0xFFFAFAFA), // Modern light background
      appBar: _buildModernAppBar(),
      body: Column(
        children: [
          // Modern Search Bar
          _buildModernSearchBar(),

          // Modern Filter Chips
          if (_categoryFilter != 'All')
            ModernAnnouncementFilterChipsWidget(
              categoryFilter: _categoryFilter,
              onClearAll: _clearAllFilters,
            ),

          // Modern Tab Bar
          _buildModernTabBar(),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildModernAllAnnouncementsTab(),
                _buildModernBookmarkedAnnouncementsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      title: Text(
        'General Announcements',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A1A),
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: _handleRefresh,
          icon: Icon(
            Icons.refresh_rounded,
            color: AppTheme.primaryLight,
            size: 24,
          ),
          tooltip: 'Refresh Announcements',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: const Color(0xFFE5E7EB),
        ),
      ),
    );
  }

  Widget _buildModernSearchBar() {
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
                onChanged: _onSearchChanged,
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

  Widget _buildModernTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.primaryLight,
        indicatorWeight: 3,
        labelColor: AppTheme.primaryLight,
        unselectedLabelColor: const Color(0xFF9CA3AF),
        labelStyle: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _tabController.index == 0 ? Icons.campaign_rounded : Icons.campaign_outlined,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('All'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _tabController.index == 1 ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('Saved'),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildModernAllAnnouncementsTab() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
        ),
      );
    }
    
    if (_filteredAnnouncements.isEmpty && !_isRefreshing) {
      return _buildModernEmptyState();
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
            return _buildModernLoadingIndicator();
          }

          final announcement = _filteredAnnouncements[index];
          return ImageAnnouncementCardWidget(
            announcement: announcement,
            onTap: () => _showAnnouncementDetail(announcement),
            onBookmark: () => _toggleBookmark(announcement),
            onShare: () => _shareAnnouncement(announcement),
          );
        },
      ),
    );
  }

  Widget _buildModernBookmarkedAnnouncementsTab() {
    final bookmarkedList = _bookmarkedAnnouncements.toList();

    if (bookmarkedList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_outline_rounded,
                color: AppTheme.primaryLight,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Saved Announcements',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bookmark important announcements to save them here',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: bookmarkedList.length,
      itemBuilder: (context, index) {
        final announcement = bookmarkedList[index];
        return ImageAnnouncementCardWidget(
          announcement: announcement,
          onTap: () => _showAnnouncementDetail(announcement),
          onBookmark: () => _toggleBookmark(announcement),
          onShare: () => _shareAnnouncement(announcement),
        );
      },
    );
  }

  Widget _buildModernEmptyState() {
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
                Icons.image_outlined,
                color: AppTheme.primaryLight.withValues(alpha: 0.7),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            
            // Better typography hierarchy
            Text(
              'No Image Announcements',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF374151),
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for visual announcements and updates',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B7280),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Smaller, more subtle button
            SizedBox(
              width: 160,
              height: 40,
              child: OutlinedButton(
                onPressed: _clearAllFilters,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryLight,
                  side: BorderSide(
                    color: AppTheme.primaryLight.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  'Clear Filters',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryLight,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
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

        // Category filter
        if (_categoryFilter != 'All' &&
            announcement['category'] != _categoryFilter) {
          return false;
        }

        return true;
      }).toList();
    });
  }


  void _showCategoryFilter() {
    final categories = [
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
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
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

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Actually refresh announcements from API
    await _loadAnnouncements();

    setState(() {
      _isRefreshing = false;
    });

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
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ImageAnnouncementDetailModal(
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
