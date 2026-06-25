import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bepay_interview/core/theme/app_theme.dart';

/// A premium simulated QR viewfinder widget.
///
/// Features a dark scanning overlay, animated laser scanline, pulsing instructions,
/// and auto-populates a mock EVM address after a 1.2s delay.
class MockQrScanner extends StatefulWidget {
  const MockQrScanner({super.key});

  /// Displays the mock scanner bottom sheet and returns the scanned result address if successful.
  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MockQrScanner(),
    );
  }

  @override
  State<MockQrScanner> createState() => _MockQrScannerState();
}

class _MockQrScannerState extends State<MockQrScanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scanPositionAnimation;
  Timer? _scanTimer;
  bool _isScanned = false;

  @override
  void initState() {
    super.initState();

    // Laser scanline animation back and forth
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scanPositionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);

    // Simulate scanning delay and success callback
    _scanTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isScanned = true;
        });
        // Short feedback delay before popping
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            Navigator.of(context).pop('0x742d35Cc6634C0532925a3b844Bc454e4438f44e');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const darkBgColor = Color(0xFF0D0F1B);

    return Container(
      height: screenHeight * 0.7,
      decoration: BoxDecoration(
        color: darkBgColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Top indicator bar
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 12.h),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Text(
                  'Scan QR Code',
                  style: AppTheme.outfit(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white54,
                  ),
                  splashRadius: 20.r,
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Camera Viewfinder Box
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Simulated Camera Scan Area / Grid lines background
                  Container(
                    width: 240.w,
                    height: 240.w,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Stack(
                      children: [
                        // Viewfinder Corner Brackets
                        _buildViewfinderCorners(),

                        // Laser Scanner line animation
                        AnimatedBuilder(
                          animation: _scanPositionAnimation,
                          builder: (context, child) {
                            final laserOffset = _scanPositionAnimation.value * 230.w;
                            return Positioned(
                              top: 5.w + laserOffset,
                              left: 12.w,
                              right: 12.w,
                              child: Container(
                                height: 3.h,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: _isScanned
                                          ? Colors.green.withValues(alpha: 0.8)
                                          : AppTheme.royalBlue.withValues(alpha: 0.8),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                  color: _isScanned ? Colors.green : AppTheme.royalBlue,
                                ),
                              ),
                            );
                          },
                        ),

                        // Success green flash overlay
                        if (_isScanned)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: Colors.green,
                                size: 50,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Instruction panel
          Padding(
            padding: EdgeInsets.only(bottom: 40.h, left: 30.w, right: 30.w),
            child: Column(
              children: [
                Text(
                  _isScanned ? 'Scan Successful!' : 'Scanning Address...',
                  style: AppTheme.inter(
                    color: _isScanned ? Colors.green : Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Align QR code inside the viewfinder frame to automatically scan and import recipient wallet address.',
                  textAlign: TextAlign.center,
                  style: AppTheme.inter(
                    color: Colors.white54,
                    fontSize: 12.sp,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24.h),
                // Flashlight & Gallery mock actions for high UX feel
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMockActionButton(Icons.flash_on_rounded, 'Flash'),
                    SizedBox(width: 40.w),
                    _buildMockActionButton(Icons.photo_library_rounded, 'Gallery'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white70,
            size: 20.w,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: AppTheme.inter(
            color: Colors.white54,
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildViewfinderCorners() {
    const double borderSize = 24.0;
    const double borderWidth = 4.0;
    final color = _isScanned ? Colors.green : AppTheme.royalBlue;

    return Stack(
      children: [
        // Top Left
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: borderSize,
            height: borderSize,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: borderWidth),
                left: BorderSide(color: color, width: borderWidth),
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.r),
              ),
            ),
          ),
        ),
        // Top Right
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: borderSize,
            height: borderSize,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: borderWidth),
                right: BorderSide(color: color, width: borderWidth),
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8.r),
              ),
            ),
          ),
        ),
        // Bottom Left
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: borderSize,
            height: borderSize,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color, width: borderWidth),
                left: BorderSide(color: color, width: borderWidth),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.r),
              ),
            ),
          ),
        ),
        // Bottom Right
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: borderSize,
            height: borderSize,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color, width: borderWidth),
                right: BorderSide(color: color, width: borderWidth),
              ),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
