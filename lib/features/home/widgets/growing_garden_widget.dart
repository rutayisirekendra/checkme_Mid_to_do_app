import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';

class GrowingGardenWidget extends StatefulWidget {
  final int completedTasks;
  final int totalTasks;

  const GrowingGardenWidget({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
  });

  @override
  State<GrowingGardenWidget> createState() => _GrowingGardenWidgetState();
}

class _GrowingGardenWidgetState extends State<GrowingGardenWidget>
    with TickerProviderStateMixin {
  late AnimationController _swayController;
  late AnimationController _confettiController;
  late AnimationController _leafController;
  late Animation<double> _swayAnimation;
  late Animation<double> _confettiAnimation;
  late Animation<double> _leafAnimation;
  
  final List<ConfettiLeaf> _confettiLeaves = [];
  bool _isAllTasksCompleted = false;
  bool _wasAllTasksCompleted = false;

  @override
  void initState() {
    super.initState();
    
    // Gentle swaying animation for plants
    _swayController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _swayAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _swayController,
      curve: Curves.easeInOut,
    ));
    
    // Confetti animation for completion
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    ));
    
    // Subtle leaf animation
    _leafController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _leafAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _leafController,
      curve: Curves.easeInOut,
    ));
    
    _checkCompletion();
  }

  @override
  void didUpdateWidget(GrowingGardenWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.completedTasks != widget.completedTasks || 
        oldWidget.totalTasks != widget.totalTasks) {
      _checkCompletion();
    }
  }

  void _checkCompletion() {
    _isAllTasksCompleted = widget.totalTasks > 0 && widget.completedTasks >= widget.totalTasks;
    
    // Trigger confetti when tasks are completed for the first time
    if (_isAllTasksCompleted && !_wasAllTasksCompleted) {
      _triggerConfetti();
      _wasAllTasksCompleted = true;
    } else if (!_isAllTasksCompleted) {
      _wasAllTasksCompleted = false;
    }
  }

  void _triggerConfetti() {
    _generateConfettiLeaves();
    _confettiController.reset();
    _confettiController.forward();
  }

  void _generateConfettiLeaves() {
    _confettiLeaves.clear();
    final random = math.Random();
    
    for (int i = 0; i < 25; i++) {
      _confettiLeaves.add(ConfettiLeaf(
        startX: random.nextDouble() * 300,
        startY: -20,
        endX: random.nextDouble() * 300,
        endY: 200 + random.nextDouble() * 50,
        rotation: random.nextDouble() * math.pi * 2,
        size: 8 + random.nextDouble() * 12,
        color: _getRandomLeafColor(random),
        fallDuration: 1.5 + random.nextDouble() * 1.5,
      ));
    }
  }

  Color _getRandomLeafColor(math.Random random) {
    final colors = [
      AppColors.grassGreen,
      AppColors.grassGreen.withValues(alpha: 0.8),
      const Color(0xFF66BB6A), // Light green
      const Color(0xFF43A047), // Medium green
      const Color(0xFF388E3C), // Dark green
      const Color(0xFFFDD835), // Yellow for autumn leaves
      const Color(0xFFFFB300), // Orange
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _swayController.dispose();
    _confettiController.dispose();
    _leafController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = widget.totalTasks > 0 ? widget.completedTasks / widget.totalTasks : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.grassGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_florist,
                  color: AppColors.grassGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Growing Garden',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Watch your garden bloom with productivity',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark 
                            ? AppColors.darkSecondaryText 
                            : AppColors.lightMainText.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Garden visualization
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.grassGreen.withValues(alpha: 0.1),
                  AppColors.grassGreen.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: AnimatedBuilder(
              animation: Listenable.merge([_swayAnimation, _confettiAnimation, _leafAnimation]),
              builder: (context, child) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Ground
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.grassGreen.withValues(alpha: 0.3),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    // Animated plants based on progress
                    ...List.generate(
                      (progress * 8).round().clamp(0, 8),
                      (index) => Positioned(
                        bottom: 20,
                        left: 20 + (index * 40.0),
                        child: Transform.rotate(
                          angle: _swayAnimation.value * (1 + (index * 0.2)),
                          child: _buildAnimatedPlant(progress, index),
                        ),
                      ),
                    ),
                    // Confetti leaves
                    if (_confettiAnimation.value > 0)
                      ..._confettiLeaves.map((leaf) => _buildConfettiLeaf(leaf)),
                    // Progress percentage overlay
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.grassGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${(progress * 100).toInt()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Progress stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Completed',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark 
                          ? AppColors.darkSecondaryText 
                          : AppColors.lightMainText.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    '${widget.completedTasks}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.grassGreen,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark 
                          ? AppColors.darkSecondaryText 
                          : AppColors.lightMainText.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    '${widget.totalTasks}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedPlant(double progress, int index) {
    final plantHeight = 20 + (progress * 40);
    final plantColor = AppColors.grassGreen.withValues(alpha: 0.6 + (progress * 0.4));
    
    return Container(
      width: 20,
      height: plantHeight,
      decoration: BoxDecoration(
        color: plantColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          // Plant stem
          Container(
            width: 4,
            height: plantHeight * 0.7,
            margin: EdgeInsets.only(left: 8, top: plantHeight * 0.3),
            decoration: BoxDecoration(
              color: AppColors.grassGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Enhanced animated leaves
          if (progress > 0.2)
            _buildAnimatedLeaf(
              top: plantHeight * 0.15,
              left: 1,
              size: 6 + (progress * 4),
              delay: index * 0.1,
            ),
          if (progress > 0.3)
            _buildAnimatedLeaf(
              top: plantHeight * 0.25,
              right: 1,
              size: 5 + (progress * 3),
              delay: index * 0.1 + 0.2,
            ),
          if (progress > 0.5)
            _buildAnimatedLeaf(
              top: plantHeight * 0.35,
              left: 2,
              size: 4 + (progress * 2),
              delay: index * 0.1 + 0.4,
            ),
          if (progress > 0.7)
            _buildAnimatedLeaf(
              top: plantHeight * 0.45,
              right: 2,
              size: 3 + (progress * 2),
              delay: index * 0.1 + 0.6,
            ),
          if (progress > 0.8)
            _buildAnimatedLeaf(
              top: plantHeight * 0.1,
              left: 6,
              size: 4 + (progress * 2),
              delay: index * 0.1 + 0.8,
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedLeaf({
    required double top,
    double? left,
    double? right,
    required double size,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _leafAnimation,
      builder: (context, child) {
        final animationValue = (_leafAnimation.value + delay) % 1.0;
        final scale = 0.8 + (math.sin(animationValue * math.pi * 2) * 0.2);
        final opacity = 0.6 + (math.sin(animationValue * math.pi * 2 + math.pi) * 0.3);
        
        return Positioned(
          top: top,
          left: left,
          right: right,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.grassGreen.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfettiLeaf(ConfettiLeaf leaf) {
    final animationProgress = _confettiAnimation.value;
    final currentY = leaf.startY + (leaf.endY - leaf.startY) * animationProgress;
    final currentX = leaf.startX + (leaf.endX - leaf.startX) * animationProgress;
    final currentRotation = leaf.rotation * animationProgress * 4;
    final opacity = 1.0 - (animationProgress * 0.8);
    
    if (opacity <= 0) return const SizedBox.shrink();
    
    return Positioned(
      top: currentY,
      left: currentX,
      child: Transform.rotate(
        angle: currentRotation,
        child: Container(
          width: leaf.size,
          height: leaf.size,
          decoration: BoxDecoration(
            color: leaf.color.withValues(alpha: opacity),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class ConfettiLeaf {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double rotation;
  final double size;
  final Color color;
  final double fallDuration;

  ConfettiLeaf({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.rotation,
    required this.size,
    required this.color,
    required this.fallDuration,
  });
}
