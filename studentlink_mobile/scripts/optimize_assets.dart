import 'dart:io';
import 'package:image/image.dart' as img;

/// Asset optimization script for StudentLink mobile app
/// This script compresses images to reduce app size
void main() async {
  print('🚀 Starting asset optimization...');
  
  final assetsDir = Directory('assets/images');
  if (!assetsDir.existsSync()) {
    print('❌ Assets directory not found');
    return;
  }
  
  final imageFiles = assetsDir
      .listSync()
      .where((file) => file is File && _isImageFile(file.path))
      .cast<File>();
  
  for (final file in imageFiles) {
    await _optimizeImage(file);
  }
  
  print('✅ Asset optimization complete!');
}

bool _isImageFile(String path) {
  final extension = path.toLowerCase().split('.').last;
  return ['png', 'jpg', 'jpeg'].contains(extension);
}

Future<void> _optimizeImage(File file) async {
  try {
    print('📸 Optimizing: ${file.path}');
    
    final bytes = await file.readAsBytes();
    final originalSize = bytes.length;
    
    // Decode image
    final image = img.decodeImage(bytes);
    if (image == null) {
      print('⚠️ Could not decode image: ${file.path}');
      return;
    }
    
    // Resize if too large (max 512x512 for logos)
    img.Image optimizedImage = image;
    if (image.width > 512 || image.height > 512) {
      optimizedImage = img.copyResize(
        image,
        width: image.width > 512 ? 512 : image.width,
        height: image.height > 512 ? 512 : image.height,
        interpolation: img.Interpolation.cubic,
      );
    }
    
    // Encode with compression
    final optimizedBytes = img.encodePng(optimizedImage, level: 6);
    final optimizedSize = optimizedBytes.length;
    
    // Only save if we achieved significant compression
    if (optimizedSize < originalSize * 0.8) {
      await file.writeAsBytes(optimizedBytes);
      final savings = ((originalSize - optimizedSize) / originalSize * 100).toStringAsFixed(1);
      print('✅ Optimized ${file.path}: ${_formatBytes(originalSize)} → ${_formatBytes(optimizedSize)} (${savings}% saved)');
    } else {
      print('ℹ️ No significant optimization for ${file.path}');
    }
  } catch (e) {
    print('❌ Error optimizing ${file.path}: $e');
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

