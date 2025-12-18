import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';
import '../../config/theme.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animationController;
  late AnimationController _floatingController;
  late AnimationController _glowController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Animation principale d'entrée
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    // Animation flottante continue
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    // Animation de glow
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    _glowController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(authProvider.error ?? 'Erreur de connexion')),
              ],
            ),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Fond avec gradient animé
          _buildAnimatedBackground(size),

          // Particules flottantes
          ..._buildFloatingParticles(size),

          // Contenu principal
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo avec effet liquid glass
                          AnimatedBuilder(
                            animation: _floatingAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _floatingAnimation.value),
                                child: _buildLiquidGlassLogo(),
                              );
                            },
                          ),
                          const SizedBox(height: 40),

                          // Titre avec effet brillant
                          _buildShimmerTitle(),
                          const SizedBox(height: 12),

                          Text(
                            'Scanner, Analyser, Manger sainement',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),

                          // Carte Liquid Glass pour le formulaire
                          _buildLiquidGlassCard(),
                          const SizedBox(height: 32),

                          // Lien vers Inscription avec style glass
                          _buildRegisterLink(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A1F1C), // Vert très foncé
            Color(0xFF0D2922), // Vert foncé
            Color(0xFF0F3328), // Vert moyen foncé
            Color(0xFF0A1F1C), // Retour au vert très foncé
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Cercles de lumière ambiante
          Positioned(
            top: -100,
            right: -100,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryGreen.withOpacity(_glowAnimation.value * 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.accentTeal.withOpacity(_glowAnimation.value * 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingParticles(Size size) {
    final random = math.Random(42);
    return List.generate(15, (index) {
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final particleSize = random.nextDouble() * 6 + 2;
      final delay = random.nextDouble() * 2;

      return Positioned(
        left: startX,
        top: startY,
        child: AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            final progress = (_floatingController.value + delay) % 1.0;
            return Transform.translate(
              offset: Offset(
                math.sin(progress * math.pi * 2) * 20,
                math.cos(progress * math.pi * 2) * 20,
              ),
              child: Container(
                width: particleSize,
                height: particleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1 + random.nextDouble() * 0.1),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildLiquidGlassLogo() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withOpacity(_glowAnimation.value),
                blurRadius: 40,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryGreen.withOpacity(0.8),
                      AppTheme.primaryGreenDark.withOpacity(0.9),
                    ],
                  ),
                ),
                child: const Text('🥗', style: TextStyle(fontSize: 48)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          Colors.white,
          AppTheme.primaryGreenLight,
          Colors.white,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(bounds),
      child: Text(
        'NutriScan',
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 3,
          shadows: [
            Shadow(
              color: AppTheme.primaryGreen.withOpacity(0.5),
              blurRadius: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiquidGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.1),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                border: Border.all(
                  width: 1.5,
                  color: Colors.white.withOpacity(0.2),
                ),
                boxShadow: [
                  // Ombre externe
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                  // Glow subtil
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(_glowAnimation.value * 0.15),
                    blurRadius: 40,
                    spreadRadius: -5,
                  ),
                  // Inner highlight
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Titre de la carte
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: const Icon(
                          Icons.login_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Connexion',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Champ Username avec style glass
                  _buildGlassTextField(
                    controller: _usernameController,
                    label: 'Nom d\'utilisateur',
                    icon: Icons.person_outline_rounded,
                    validator: Validators.validateUsername,
                  ),
                  const SizedBox(height: 18),

                  // Champ Password avec style glass
                  _buildGlassTextField(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    icon: Icons.lock_outline_rounded,
                    obscureText: true,
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 28),

                  // Bouton de connexion style glass
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return _buildGlassButton(
                        text: 'Se connecter',
                        isLoading: authProvider.isLoading,
                        onPressed: _login,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // Fond SOMBRE semi-transparent pour contraste avec texte blanc
        color: const Color(0xFF1A3D35), // Vert très foncé
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        cursorColor: AppTheme.primaryGreen,
        style: const TextStyle(
          color: Colors.white, // Texte BLANC sur fond sombre
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
          ),
          floatingLabelStyle: const TextStyle(
            color: AppTheme.primaryGreenLight,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(
            icon,
            color: AppTheme.primaryGreenLight.withOpacity(0.8),
            size: 22,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppTheme.primaryGreen.withOpacity(0.5),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          errorStyle: const TextStyle(
            color: Color(0xFFFF6B6B),
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required String text,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryGreen,
                  AppTheme.primaryGreenDark,
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(_glowAnimation.value),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegisterLink() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.08),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Pas encore de compte ? ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const RegisterScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.3, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          ),
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryGreen.withOpacity(0.3),
                        AppTheme.primaryGreen.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: const Text(
                    'Créer un compte',
                    style: TextStyle(
                      color: AppTheme.primaryGreenLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

