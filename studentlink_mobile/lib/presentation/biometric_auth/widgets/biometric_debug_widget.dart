import 'package:flutter/material.dart';
import '../../../services/biometric_auth_service.dart';
import '../../../theme/app_theme.dart';

/// Debug widget for testing biometric authentication
/// This widget can be temporarily added to any screen for testing purposes
class BiometricDebugWidget extends StatefulWidget {
  const BiometricDebugWidget({Key? key}) : super(key: key);

  @override
  State<BiometricDebugWidget> createState() => _BiometricDebugWidgetState();
}

class _BiometricDebugWidgetState extends State<BiometricDebugWidget> {
  final BiometricAuthService _biometricService = BiometricAuthService();
  String _status = 'Checking...';
  bool _isEnabled = false;
  String _biometricType = 'Unknown';

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final isEnabled = await _biometricService.isBiometricEnabled();
      final biometricType = await _biometricService.getBiometricTypeString();
      final availability = await _biometricService.checkBiometricAvailability();
      
      setState(() {
        _isEnabled = isEnabled;
        _biometricType = biometricType;
        _status = 'Available: ${availability.name}';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtleLight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Biometric Debug',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Status information
          _buildStatusInfo(),
          
          const SizedBox(height: 16),
          
          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatusInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusRow('Status', _status),
        _buildStatusRow('Type', _biometricType),
        _buildStatusRow('Enabled', _isEnabled ? 'Yes' : 'No'),
      ],
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton(
          onPressed: _testBiometric,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryLight,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Test Auth'),
        ),
        ElevatedButton(
          onPressed: _enableBiometric,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.successLight,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Enable'),
        ),
        ElevatedButton(
          onPressed: _disableBiometric,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.warningLight,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Disable'),
        ),
        ElevatedButton(
          onPressed: _loadStatus,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.secondaryLight,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Refresh'),
        ),
      ],
    );
  }

  void _testBiometric() async {
    try {
      final result = await _biometricService.authenticateWithBiometric();
      _showResult('Test Result', result.name);
    } catch (e) {
      _showResult('Test Error', e.toString());
    }
  }

  void _enableBiometric() async {
    try {
      final enabled = await _biometricService.enableBiometricAuth();
      _showResult('Enable Result', enabled ? 'Success' : 'Failed');
      _loadStatus();
    } catch (e) {
      _showResult('Enable Error', e.toString());
    }
  }

  void _disableBiometric() async {
    try {
      await _biometricService.disableBiometricAuth();
      _showResult('Disable Result', 'Success');
      _loadStatus();
    } catch (e) {
      _showResult('Disable Error', e.toString());
    }
  }

  void _showResult(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryLight,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
