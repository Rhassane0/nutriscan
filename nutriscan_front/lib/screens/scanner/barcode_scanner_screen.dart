import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/ai_service.dart';
import '../../models/scan_result.dart';
import 'barcode_scan_result_screen.dart';
import '../../providers/meal_provider.dart';

/// Écran de scan de code-barres avec design époustouflant
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with TickerProviderStateMixin {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  late AnimationController _scanLineController;
  late AnimationController _pulseController;
  late Animation<double> _scanLineAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Animation de la ligne de scan
    _scanLineController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );

    // Animation de pulsation pour le cadre
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _pulseController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first.rawValue;
    if (barcode == null) return;

    setState(() {
      _isProcessing = true;
    });

    // Vibration légère
    HapticFeedback.mediumImpact();

    try {
      final aiService = context.read<AiService>();
      final result = await aiService.scanBarcode(barcode);

      if (!mounted) return;

      final res = await Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              BarcodeScanResultScreen(scanResult: result),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            );
          },
        ),
      );

      // Si le résultat est true => un repas a été ajouté, recharger la liste
      if (res == true) {
        context.read<MealProvider>().loadMealsForDate(DateTime.now());
      }

      setState(() {
        _isProcessing = false;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Erreur: ${e.toString()}')),
            ],
          ),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );

      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),

          // Overlay sombre avec découpe
          _buildScanOverlay(),

          // Header
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const Spacer(),
                _buildBottomPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scanner Code-Barres',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Placez le code dans le cadre',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          _buildControlButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                return Icon(
                  state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                  color: state == TorchState.on
                      ? AppTheme.warningYellow
                      : Colors.white,
                  size: 22,
                );
              },
            ),
            onTap: () => cameraController.toggleTorch(),
          ),
          const SizedBox(width: 12),
          _buildControlButton(
            icon: const Icon(Icons.cameraswitch, color: Colors.white, size: 22),
            onTap: () => cameraController.switchCamera(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({required Widget icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: icon,
      ),
    );
  }

  Widget _buildScanOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanAreaSize = constraints.maxWidth * 0.75;
        final scanAreaTop = (constraints.maxHeight - scanAreaSize) / 2 - 50;
        final scanAreaLeft = (constraints.maxWidth - scanAreaSize) / 2;

        return Stack(
          children: [
            // Fond sombre
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.6),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    top: scanAreaTop,
                    left: scanAreaLeft,
                    child: Container(
                      width: scanAreaSize,
                      height: scanAreaSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Cadre de scan avec coins stylisés
            Positioned(
              top: scanAreaTop,
              left: scanAreaLeft,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: scanAreaSize,
                    height: scanAreaSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppTheme.primaryGreen.withOpacity(
                          0.5 + (_pulseAnimation.value * 0.3),
                        ),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(
                            0.2 + (_pulseAnimation.value * 0.2),
                          ),
                          blurRadius: 20 + (_pulseAnimation.value * 10),
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Coins décoratifs
                        ..._buildCorners(scanAreaSize),

                        // Ligne de scan animée
                        AnimatedBuilder(
                          animation: _scanLineAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: 20 + (_scanLineAnimation.value * (scanAreaSize - 40)),
                              left: 20,
                              right: 20,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppTheme.primaryGreen,
                                      AppTheme.primaryGreenLight,
                                      AppTheme.primaryGreen,
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryGreen.withOpacity(0.6),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildCorners(double size) {
    const cornerLength = 40.0;
    const cornerWidth = 4.0;

    Widget buildCorner({
      required Alignment alignment,
      required BorderRadius radius,
    }) {
      return Positioned(
        top: alignment.y < 0 ? 0 : null,
        bottom: alignment.y > 0 ? 0 : null,
        left: alignment.x < 0 ? 0 : null,
        right: alignment.x > 0 ? 0 : null,
        child: Container(
          width: cornerLength,
          height: cornerLength,
          decoration: BoxDecoration(
            border: Border(
              top: alignment.y < 0
                  ? const BorderSide(color: AppTheme.primaryGreen, width: cornerWidth)
                  : BorderSide.none,
              bottom: alignment.y > 0
                  ? const BorderSide(color: AppTheme.primaryGreen, width: cornerWidth)
                  : BorderSide.none,
              left: alignment.x < 0
                  ? const BorderSide(color: AppTheme.primaryGreen, width: cornerWidth)
                  : BorderSide.none,
              right: alignment.x > 0
                  ? const BorderSide(color: AppTheme.primaryGreen, width: cornerWidth)
                  : BorderSide.none,
            ),
            borderRadius: radius,
          ),
        ),
      );
    }

    return [
      buildCorner(
        alignment: Alignment.topLeft,
        radius: const BorderRadius.only(topLeft: Radius.circular(24)),
      ),
      buildCorner(
        alignment: Alignment.topRight,
        radius: const BorderRadius.only(topRight: Radius.circular(24)),
      ),
      buildCorner(
        alignment: Alignment.bottomLeft,
        radius: const BorderRadius.only(bottomLeft: Radius.circular(24)),
      ),
      buildCorner(
        alignment: Alignment.bottomRight,
        radius: const BorderRadius.only(bottomRight: Radius.circular(24)),
      ),
    ];
  }

  Widget _buildBottomPanel() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isProcessing) ...[
            // État de chargement
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                  ),
                ),
                const SizedBox(width: 16),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppTheme.primaryGreen, AppTheme.primaryGreenLight],
                  ).createShader(bounds),
                  child: const Text(
                    'Analyse en cours...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Récupération des informations nutritionnelles',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ] else ...[
            // Instructions
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: AppTheme.primaryGreen,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Scan automatique',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Positionnez le code-barres dans le cadre',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Features
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFeatureItem(Icons.speed, 'Rapide'),
                _buildFeatureItem(Icons.verified, 'Précis'),
                _buildFeatureItem(Icons.auto_awesome, 'IA'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryGreenLight, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
