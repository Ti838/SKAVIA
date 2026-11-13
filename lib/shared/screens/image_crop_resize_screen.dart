import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/services/app_language_service.dart';
import '../../core/services/media_picker_service.dart';

/// Pure-Flutter interactive pinch-zoom, pan, and slider-resize crop editor
/// for both circular profile pictures (1:1) and Facebook-style cover banners (16:9).
class ImageCropResizeScreen extends StatefulWidget {
  final File imageFile;
  final bool isBanner;
  @visibleForTesting
  final ui.Image? initialImage;

  const ImageCropResizeScreen({
    super.key,
    required this.imageFile,
    this.isBanner = false,
    this.initialImage,
  });

  static Future<File?> open(
    BuildContext context, {
    required File imageFile,
    bool isBanner = false,
  }) {
    return Navigator.of(context).push<File?>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            ImageCropResizeScreen(imageFile: imageFile, isBanner: isBanner),
      ),
    );
  }

  @override
  State<ImageCropResizeScreen> createState() => _ImageCropResizeScreenState();
}

class _ImageCropResizeScreenState extends State<ImageCropResizeScreen> {
  final TransformationController _transformController =
      TransformationController();

  ui.Image? _decodedImage;
  String? _loadError;
  bool _isSaving = false;
  bool _initializedTransform = false;
  double _zoom = 1.0;

  // Layout geometry captured for exact WYSIWYG export
  double _cropW = 280;
  double _cropH = 280;
  double _dispW = 280;
  double _dispH = 280;

  @override
  void initState() {
    super.initState();
    _transformController.addListener(_syncZoomFromController);
    if (widget.initialImage != null) {
      _decodedImage = widget.initialImage;
    } else {
      _decodeImage();
    }
  }

  @override
  void dispose() {
    _transformController.removeListener(_syncZoomFromController);
    _transformController.dispose();
    _decodedImage?.dispose();
    super.dispose();
  }

  Future<void> _decodeImage() async {
    try {
      final bytes = await widget.imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      codec.dispose();
      if (!mounted) {
        frame.image.dispose();
        return;
      }
      setState(() {
        _decodedImage = frame.image;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loadError = 'Unable to open selected photo: $e');
      }
    }
  }

  void _syncZoomFromController() {
    final scale = _transformController.value.getMaxScaleOnAxis().clamp(1.0, 4.5);
    if ((scale - _zoom).abs() > 0.01 && mounted) {
      setState(() => _zoom = scale);
    }
  }

  Matrix4 _clampedTransform(double targetScale, double rawTx, double rawTy) {
    final scaledW = _dispW * targetScale;
    final scaledH = _dispH * targetScale;
    final minTx = (_cropW - scaledW).clamp(-double.infinity, 0.0);
    final minTy = (_cropH - scaledH).clamp(-double.infinity, 0.0);
    final tx = rawTx.clamp(minTx, 0.0);
    final ty = rawTy.clamp(minTy, 0.0);
    final m = Matrix4.diagonal3Values(targetScale, targetScale, 1.0);
    m.setEntry(0, 3, tx);
    m.setEntry(1, 3, ty);
    return m;
  }

  void _resetTransform() {
    final tx = (_cropW - _dispW) / 2.0;
    final ty = (_cropH - _dispH) / 2.0;
    _transformController.value = _clampedTransform(1.0, tx, ty);
    setState(() => _zoom = 1.0);
  }

  void _applySliderZoom(double newScale) {
    final clamped = newScale.clamp(1.0, 4.5);
    final m = _transformController.value;
    final currentScale = m.getMaxScaleOnAxis().clamp(1.0, 4.5);
    final currentTx = m.entry(0, 3);
    final currentTy = m.entry(1, 3);

    // Preserve the image point currently centered in the crop frame
    final cx = _cropW / 2.0;
    final cy = _cropH / 2.0;
    final childX = (cx - currentTx) / currentScale;
    final childY = (cy - currentTy) / currentScale;

    final nextTx = cx - childX * clamped;
    final nextTy = cy - childY * clamped;
    _transformController.value = _clampedTransform(clamped, nextTx, nextTy);
    setState(() => _zoom = clamped);
  }

  Future<void> _exportCroppedImage() async {
    final img = _decodedImage;
    if (img == null || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final outW = widget.isBanner ? 1280 : 640;
      final outH = widget.isBanner ? 720 : 640;
      final scaleToOutput = outW / _cropW;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, outW.toDouble(), outH.toDouble()),
      );

      canvas.scale(scaleToOutput, scaleToOutput);
      canvas.transform(_transformController.value.storage);
      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        Rect.fromLTWH(0, 0, _dispW, _dispH),
        Paint()
          ..filterQuality = FilterQuality.high
          ..isAntiAlias = true,
      );

      final picture = recorder.endRecording();
      final rendered = await picture.toImage(outW, outH);
      picture.dispose();

      final byteData = await rendered.toByteData(
        format: ui.ImageByteFormat.png,
      );
      rendered.dispose();

      if (byteData == null) {
        throw StateError('Failed to encode cropped image.');
      }

      final tempDir = Directory.systemTemp;
      final pngFile = File(
        '${tempDir.path}${Platform.pathSeparator}skavia_crop_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await pngFile.writeAsBytes(
        byteData.buffer.asUint8List(),
        flush: true,
      );

      final compressed = await MediaPickerService.compressToJpeg(
        pngFile,
        maxDimension: widget.isBanner ? 1280 : 640,
        quality: 88,
      );
      if (compressed.path != pngFile.path) {
        unawaited(pngFile.delete().catchError((_) => pngFile));
      }

      if (!mounted) return;
      Navigator.of(context).pop(compressed);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.errorRed,
          content: Text('Could not crop photo: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final img = _decodedImage;

    final title = widget.isBanner
        ? (isBn ? 'কভার ব্যানার রিসাইজ করুন' : 'Crop & Resize Cover Banner')
        : (isBn ? 'প্রোফাইল ছবি রিসাইজ করুন' : 'Crop & Resize Profile Photo');

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E14),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: (_isSaving || img == null) ? null : _resetTransform,
            child: Text(
              isBn ? 'রিসেট' : 'Reset',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
      body: _loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _loadError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            )
          : img == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final availW = constraints.maxWidth;
                      final availH = constraints.maxHeight;
                      final aspect = widget.isBanner ? (16.0 / 9.0) : 1.0;

                      double frameW = availW - 36;
                      double frameH = frameW / aspect;
                      if (frameH > availH - 36) {
                        frameH = availH - 36;
                        frameW = frameH * aspect;
                      }
                      frameW = frameW.clamp(160.0, availW);
                      frameH = frameH.clamp(120.0, availH);

                      final imgW = img.width.toDouble();
                      final imgH = img.height.toDouble();
                      final baseScale = math.max(frameW / imgW, frameH / imgH);
                      final nextDispW = imgW * baseScale;
                      final nextDispH = imgH * baseScale;

                      final geometryChanged =
                          (_cropW - frameW).abs() > 0.5 ||
                          (_cropH - frameH).abs() > 0.5 ||
                          (_dispW - nextDispW).abs() > 0.5;

                      _cropW = frameW;
                      _cropH = frameH;
                      _dispW = nextDispW;
                      _dispH = nextDispH;

                      if (!_initializedTransform || geometryChanged) {
                        _initializedTransform = true;
                        final tx = (_cropW - _dispW) / 2.0;
                        final ty = (_cropH - _dispH) / 2.0;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          _transformController.value = _clampedTransform(
                            1.0,
                            tx,
                            ty,
                          );
                          setState(() => _zoom = 1.0);
                        });
                      }

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Center(
                            child: SizedBox(
                              width: _cropW,
                              height: _cropH,
                              child: InteractiveViewer(
                                transformationController: _transformController,
                                constrained: false,
                                clipBehavior: Clip.none,
                                minScale: 1.0,
                                maxScale: 4.5,
                                child: SizedBox(
                                  width: _dispW,
                                  height: _dispH,
                                  child: RawImage(
                                    image: img,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IgnorePointer(
                            child: CustomPaint(
                              size: Size(availW, availH),
                              painter: _CropMaskPainter(
                                cropWidth: _cropW,
                                cropHeight: _cropH,
                                isCircular: !widget.isBanner,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  color: const Color(0xFF131823),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.zoom_out_rounded,
                              color: Colors.white60,
                              size: 20,
                            ),
                            Expanded(
                              child: Slider(
                                value: _zoom.clamp(1.0, 4.5),
                                min: 1.0,
                                max: 4.5,
                                activeColor: AppColors.primarySky,
                                inactiveColor: Colors.white24,
                                onChanged: _isSaving ? null : _applySliderZoom,
                              ),
                            ),
                            const Icon(
                              Icons.zoom_in_rounded,
                              color: Colors.white60,
                              size: 20,
                            ),
                          ],
                        ),
                        Text(
                          isBn
                              ? 'ছবি সরাতে টেনে নিন এবং জুম করতে পিঞ্চ বা স্লাইডার ব্যবহার করুন'
                              : 'Drag to reposition and pinch or slide to resize',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white24),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: _isSaving
                                    ? null
                                    : () => Navigator.of(context).pop(null),
                                child: Text(isBn ? 'বাতিল' : 'Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryRoyal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: _isSaving
                                    ? null
                                    : _exportCroppedImage,
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.check_rounded, size: 18),
                                label: Text(
                                  _isSaving
                                      ? (isBn
                                            ? 'প্রসেস হচ্ছে...'
                                            : 'Applying...')
                                      : (isBn ? 'সেভ ও আপলোড' : 'Crop & Save'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CropMaskPainter extends CustomPainter {
  final double cropWidth;
  final double cropHeight;
  final bool isCircular;

  _CropMaskPainter({
    required this.cropWidth,
    required this.cropHeight,
    required this.isCircular,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final frameRect = Rect.fromCenter(
      center: center,
      width: cropWidth,
      height: cropHeight,
    );

    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path();
    if (isCircular) {
      cutoutPath.addOval(frameRect);
    } else {
      cutoutPath.addRRect(
        RRect.fromRectAndRadius(frameRect, const Radius.circular(14)),
      );
    }

    final maskPath = Path.combine(
      PathOperation.difference,
      fullPath,
      cutoutPath,
    );
    canvas.drawPath(
      maskPath,
      Paint()..color = const Color(0xAA000000),
    );

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    if (isCircular) {
      canvas.drawOval(frameRect, borderPaint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(frameRect, const Radius.circular(14)),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CropMaskPainter oldDelegate) {
    return oldDelegate.cropWidth != cropWidth ||
        oldDelegate.cropHeight != cropHeight ||
        oldDelegate.isCircular != isCircular;
  }
}

