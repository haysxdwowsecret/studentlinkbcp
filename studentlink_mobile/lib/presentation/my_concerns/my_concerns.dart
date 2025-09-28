import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import './widgets/modern_concern_card_widget.dart';
import './widgets/enhanced_concern_details_modal.dart';
import './widgets/modern_context_menu_widget.dart';
import './widgets/modern_empty_state_widget.dart';
import './widgets/modern_filter_chips_widget.dart';

class MyConcerns extends StatefulWidget {
  const MyConcerns({Key? key}) : super(key: key);

  @override
  State<MyConcerns> createState() => _MyConcernsState();
}

class _MyConcernsState extends State<MyConcerns> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  String _statusFilter = 'All';
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
      print('Loading concerns from API...');
      // Load concerns from API service
      final concerns = await apiService.getConcerns(perPage: 50);
      print('Received ${concerns.length} concerns from API');
      print('Concerns data: $concerns');
      
      setState(() {
        _allConcerns = concerns;
        _filteredConcerns = List.from(_allConcerns);
      });
    } catch (e) {
      print('Error loading concerns: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load concerns: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
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
    if (_statusFilter != 'All') {
      filtered = filtered
          .where((concern) => concern['status'] == _statusFilter)
          .toList();
    }

    setState(() {
      _filteredConcerns = filtered;
    });
  }

  void _showStatusFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter by Status',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...['All', 'Received', 'In Process', 'Resolved'].map((status) {
              return ListTile(
                title: Text(status),
                leading: Radio<String>(
                  value: status,
                  groupValue: _statusFilter,
                  onChanged: (value) {
                    setState(() {
                      _statusFilter = value!;
                    });
                    _applyFilters();
                    Navigator.pop(context);
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _statusFilter = 'All';
      _searchQuery = '';
    });
    _applyFilters();
  }

  void _showEnhancedConcernDetailsModal(Map<String, dynamic> concern) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EnhancedConcernDetailsModal(
        concern: concern,
        onResolutionUpdated: () {
          // Refresh the concerns list when resolution is updated
          _loadConcerns();
        },
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return 'Resolved';
      case 'in_progress':
        return 'In Progress';
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      default:
        return 'Unknown';
    }
  }

  void _showContextMenu(Map<String, dynamic> concern, Offset position) {
    print('Showing context menu for concern: ${concern['title']} at position: $position');
    _removeOverlay();

    // Calculate better positioning for the context menu
    final screenSize = MediaQuery.of(context).size;
    final menuWidth = screenSize.width * 0.7;
    final menuHeight = screenSize.height * 0.4; // Approximate height
    
    double left = position.dx - (menuWidth / 2);
    double top = position.dy - menuHeight;
    
    // Ensure menu stays within screen bounds
    if (left < 0) left = 8.0;
    if (left + menuWidth > screenSize.width) left = screenSize.width - menuWidth - 8.0;
    if (top < 0) top = position.dy + 8.0;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: top,
        left: left,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: menuWidth,
            child: ModernContextMenuWidget(
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
              onDelete: () {
                _removeOverlay();
                _showDeleteConfirmation(concern);
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

  void _showDeleteConfirmation(Map<String, dynamic> concern) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Concern',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this concern?',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surfaceVariant
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      concern['title'] ?? 'Untitled Concern',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: ${concern['status'] ?? 'Unknown'}',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteConcern(concern);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Delete',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteConcern(Map<String, dynamic> concern) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Deleting concern...',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        },
      );

      // Call API to delete concern
      await apiService.deleteConcern(concern['id']);
      
      // Remove from local lists
      setState(() {
        _allConcerns.removeWhere((item) => item['id'] == concern['id']);
        _filteredConcerns.removeWhere((item) => item['id'] == concern['id']);
      });

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Concern deleted successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete concern: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Modern light background
      appBar: _buildModernAppBar(),
      body: GestureDetector(
        onTap: _removeOverlay,
        child: Column(
          children: [
            // Modern Search Bar
            _buildModernSearchBar(),

            // Modern Filter Chips
            if (_statusFilter != 'All')
              ModernFilterChipsWidget(
                statusFilter: _statusFilter,
                onClearAll: _clearAllFilters,
              ),

            // Main Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
                      ),
                    )
                  : _filteredConcerns.isEmpty
                      ? ModernEmptyStateWidget(
                          onSubmitConcern: () =>
                              Navigator.pushNamed(context, '/submit-concern'),
                        )
                      : RefreshIndicator(
                      onRefresh: _refreshConcerns,
                      color: AppTheme.primaryLight,
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount:
                            _filteredConcerns.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _filteredConcerns.length) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
                                ),
                              ),
                            );
                          }

                          final concern = _filteredConcerns[index];
                          return ModernConcernCardWidget(
                            concern: concern,
                            onViewDetails: () {
                              _showEnhancedConcernDetailsModal(concern);
                            },
                            onAddReply: () {
                              Navigator.pushNamed(
                                context,
                                '/concern-details',
                                arguments: {
                                  'id': concern['id'],
                                  'openReply': true
                                },
                              );
                            },
                            onDelete: () {
                              _showDeleteConfirmationDialog(concern);
                            },
                            onLongPress: () {
                              print('Long press detected for concern: ${concern['title']}');
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
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      title: Text(
        'My Concerns',
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
                  hintText: 'Search concerns...',
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
              onPressed: _showStatusFilter,
              icon: Icon(
                Icons.filter_list_rounded,
                color: AppTheme.primaryLight,
                size: 20,
              ),
              tooltip: 'Filter concerns',
            ),
          ),
        ],
      ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmationDialog(Map<String, dynamic> concern) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: AppTheme.emergencyLight,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text('Delete Concern'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this concern?',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.emergencyLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.emergencyLight.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Title:',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.emergencyLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      concern['title'] ?? 'Untitled Concern',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status:',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.emergencyLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusLabel(concern['status'] ?? 'pending'),
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This action cannot be undone. All messages and replies associated with this concern will be permanently deleted.',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            // Cancel Button - White with black border and text
            Container(
              height: 40,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Confirm Button - Red with white text
            Container(
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteConcern(concern);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626), // Red color
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    }
  }
