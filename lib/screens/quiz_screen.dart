import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hqapp/models/user_profile.dart';
import 'package:hqapp/services/firestore_service.dart';
import 'package:hqapp/services/quiz_service.dart';
import 'package:hqapp/theme/app_theme.dart';
import 'package:hqapp/utils/animations.dart';

class QuizScreen extends StatefulWidget {
  final UserProfile user;

  const QuizScreen({super.key, required this.user});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late List<QuizQuestion> questions;
  int currentQuestionIndex = 0;
  int score = 0;
  int? selectedAnswer;
  bool showResult = false;
  bool isQuizComplete = false;
  bool _resultSaved = false;

  // Animation controllers
  late AnimationController _progressController;
  late AnimationController _questionController;
  late AnimationController _confettiController;
  late AnimationController _buttonController;
  late Animation<double> _progressAnimation;
  late Animation<double> _questionAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    questions = QuizService.getRandomQuestions(5);

    // Initialize animation controllers
    _progressController = AnimationController(
      vsync: this,
      duration: AppAnimations.mediumDuration,
    );
    _questionController = AnimationController(
      vsync: this,
      duration: AppAnimations.mediumDuration,
    );
    _confettiController = AnimationController(
      vsync: this,
      duration: AppAnimations.confettiDuration,
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: AppAnimations.shortDuration,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: AppAnimations.defaultCurve,
      ),
    );
    _questionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _questionController,
        curve: AppAnimations.defaultCurve,
      ),
    );
    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: AppAnimations.defaultCurve,
      ),
    );

    _questionController.forward();
    _updateProgress();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _questionController.dispose();
    _confettiController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    _progressController.value = 0;
    _progressController.forward();
  }

  void _selectAnswer(int answerIndex) {
    if (showResult) return;

    setState(() {
      selectedAnswer = answerIndex;
      showResult = true;
      final isCorrect =
          answerIndex == questions[currentQuestionIndex].correctAnswerIndex;
      if (isCorrect) {
        score++;
        _confettiController.forward(from: 0);
      }
    });
    _buttonController.forward();
  }

  Future<void> _nextQuestion() async {
    _buttonController.reverse();
    _questionController.reverse();

    await Future.delayed(AppAnimations.shortDuration);

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        showResult = false;
      });
      _updateProgress();
      _questionController.forward();
    } else {
      // Stop all animations before showing completion screen
      try {
        if (_progressController.isAnimating) {
          _progressController.stop();
        }
        if (_questionController.isAnimating) {
          _questionController.stop();
        }
        if (_buttonController.isAnimating) {
          _buttonController.stop();
        }
      } catch (e) {
        // Ignore animation errors
      }

      // Show completion screen immediately
      if (mounted) {
        setState(() => isQuizComplete = true);
      }

      // Save result and update achievements in background (don't await)
      _saveResultIfNeeded();
    }
  }

  Future<void> _saveResultIfNeeded() async {
    if (_resultSaved || widget.user.id == 'guest') return;

    try {
      // Save quiz result
      await FirestoreService.recordQuizResult(
        user: widget.user,
        score: score,
        totalQuestions: questions.length,
      );
      _resultSaved = true;

      // Update achievements and leaderboard
      await FirestoreService.updateUserAchievementsAndLeaderboard(
        userId: widget.user.id,
        userName: widget.user.fullName,
      );

      // Check for achievements and show notifications
      if (!mounted) return;

      final quizResults = await FirestoreService.getUserQuizResults(
        widget.user.id,
      );
      if (!mounted) return;

      final quizCount = quizResults.length;
      final hasFullMark = score == questions.length;
      final hasPerfectScore =
          score == questions.length && questions.length >= 5;

      // Create achievement notifications
      if (quizCount == 1) {
        await FirestoreService.createNotification(
          userId: widget.user.id,
          title: '🎯 Achievement Unlocked: First Quiz!',
          message:
              'You completed your first quiz! Keep exploring to unlock more achievements.',
          type: 'achievement',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('🎯 Achievement Unlocked: First Quiz!'),
              duration: const Duration(seconds: 3),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }

      if (hasFullMark) {
        await FirestoreService.createNotification(
          userId: widget.user.id,
          title: '🏆 Achievement Unlocked: Perfect Score!',
          message: 'Amazing! You got full marks in the quiz!',
          type: 'achievement',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('🏆 Achievement Unlocked: Perfect Score!'),
              duration: const Duration(seconds: 3),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }

      if (quizCount == 5) {
        await FirestoreService.createNotification(
          userId: widget.user.id,
          title: '📚 Achievement Unlocked: Quiz Master!',
          message:
              'Congratulations! You\'ve completed 5 quizzes. You\'re becoming a quiz master!',
          type: 'achievement',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('📚 Achievement Unlocked: Quiz Master!'),
              duration: const Duration(seconds: 3),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }

      if (hasPerfectScore) {
        await FirestoreService.createNotification(
          userId: widget.user.id,
          title: '⭐ Achievement Unlocked: Flawless Victory!',
          message: 'Incredible! You got a perfect score on a 5-question quiz!',
          type: 'achievement',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('⭐ Achievement Unlocked: Flawless Victory!'),
              duration: const Duration(seconds: 3),
              backgroundColor: AppTheme.goldColor,
            ),
          );
        }
      }

      // Create quiz completion notification
      await FirestoreService.createNotification(
        userId: widget.user.id,
        title: 'Quiz Completed!',
        message:
            'You scored $score out of ${questions.length}. ${hasFullMark ? "Perfect score!" : "Great job!"}',
        type: 'quiz',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving quiz result: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _restartQuiz() {
    // Reset animation controllers
    _progressController.reset();
    _questionController.reset();
    _confettiController.reset();
    _buttonController.reset();

    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      selectedAnswer = null;
      showResult = false;
      isQuizComplete = false;
      _resultSaved = false;
    });

    questions = QuizService.getRandomQuestions(5);

    // Restart animations
    _questionController.forward();
    _updateProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Nizwa Castle Quiz',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: isQuizComplete ? _buildQuizComplete() : _buildQuizContent(),
    );
  }

  Widget _buildQuizContent() {
    final question = questions[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / questions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: FadeTransition(
        opacity: _questionAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.1),
            end: Offset.zero,
          ).animate(_questionAnimation),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score and Progress Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.stars,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Score: $score',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${currentQuestionIndex + 1}/${questions.length}',
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Animated Progress Bar
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        FractionallySizedBox(
                          widthFactor: progress * _progressAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor,
                                  AppTheme.secondaryColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Question Card with Animation
              ScaleTransition(
                scale: _questionAnimation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, AppTheme.backgroundColor],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.secondaryColor,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.castle,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        question.question,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Answer Options with Staggered Animation
                      ...question.options.asMap().entries.map((entry) {
                        final index = entry.key;
                        final option = entry.value;
                        final isCorrect = index == question.correctAnswerIndex;
                        final isSelected = selectedAnswer == index;

                        return AppAnimations.staggeredFadeIn(
                          index: index,
                          baseDelay: 300,
                          child: _buildAnswerOption(
                            option: option,
                            index: index,
                            isCorrect: isCorrect,
                            isSelected: isSelected,
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      // Explanation with Animation
                      if (showResult)
                        TweenAnimationBuilder<double>(
                          duration: AppAnimations.mediumDuration,
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: AppAnimations.defaultCurve,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Opacity(
                                opacity: value,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.accentColor.withOpacity(0.1),
                                        AppTheme.accentColor.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppTheme.accentColor.withOpacity(
                                        0.3,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.lightbulb,
                                            color: AppTheme.accentColor,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Explanation:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: AppTheme.accentColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        question.explanation,
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontSize: 15,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Next Button with Animation
              if (showResult)
                ScaleTransition(
                  scale: _buttonAnimation,
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentQuestionIndex < questions.length - 1
                                ? 'Next Question'
                                : 'Finish Quiz',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            currentQuestionIndex < questions.length - 1
                                ? Icons.arrow_forward
                                : Icons.check_circle,
                            size: 24,
                          ),
                        ],
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

  Widget _buildAnswerOption({
    required String option,
    required int index,
    required bool isCorrect,
    required bool isSelected,
  }) {
    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey[300]!;
    Color textColor = Colors.black87;
    IconData? icon;

    if (showResult) {
      if (isCorrect) {
        backgroundColor = AppTheme.successColor.withOpacity(0.15);
        borderColor = AppTheme.successColor;
        textColor = AppTheme.successColor;
        icon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        backgroundColor = AppTheme.errorColor.withOpacity(0.15);
        borderColor = AppTheme.errorColor;
        textColor = AppTheme.errorColor;
        icon = Icons.cancel;
      } else {
        backgroundColor = Colors.grey[100]!;
        borderColor = Colors.grey[300]!;
        textColor = Colors.grey[600]!;
      }
    } else if (isSelected) {
      backgroundColor = AppTheme.primaryColor.withOpacity(0.15);
      borderColor = AppTheme.primaryColor;
      textColor = AppTheme.primaryColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: showResult ? null : () => _selectAnswer(index),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: isSelected || (showResult && isCorrect) ? 3 : 2,
              ),
              boxShadow: isSelected || (showResult && isCorrect)
                  ? [
                      BoxShadow(
                        color: borderColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Option Letter Badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: borderColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: TextStyle(
                        color: borderColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 12),
                  Icon(icon, color: borderColor, size: 28),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizComplete() {
    // Ensure questions list is not empty and calculate percentage safely
    final totalQuestions = questions.isNotEmpty ? questions.length : 5;
    if (totalQuestions == 0) {
      return const Center(child: CircularProgressIndicator());
    }

    // Ensure all values are safe before calculations
    final safeScore = score.clamp(0, totalQuestions);
    final safePercentage = totalQuestions > 0
        ? ((safeScore / totalQuestions) * 100).round().clamp(0, 100)
        : 0;
    final isPerfect = safeScore == totalQuestions && totalQuestions > 0;

    // Wrap in error boundary to prevent red flash
    return Builder(
      builder: (context) {
        try {
          return TweenAnimationBuilder<double>(
            key: ValueKey('quiz_complete_${safeScore}_$totalQuestions'),
            duration: AppAnimations.extraLongDuration,
            tween: Tween(begin: 0.0, end: 1.0),
            curve:
                Curves.easeOut, // Changed from elasticCurve to prevent errors
            builder: (context, value, child) {
              // Ensure value is valid
              final safeValue = value.clamp(0.0, 1.0);
              return Transform.scale(
                scale: safeValue,
                child: Opacity(
                  opacity: safeValue,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Trophy with Animation
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              if (isPerfect)
                                TweenAnimationBuilder<double>(
                                  duration:
                                      AppAnimations.trophyRotationDuration,
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  curve: AppAnimations.defaultCurve,
                                  builder: (context, rotation, child) {
                                    // Ensure rotation value is safe
                                    final safeRotation = rotation.clamp(
                                      0.0,
                                      1.0,
                                    );
                                    return Transform.rotate(
                                      angle: safeRotation * 2 * math.pi,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          gradient: RadialGradient(
                                            colors: [
                                              AppTheme.goldColor.withOpacity(
                                                0.3,
                                              ),
                                              AppTheme.goldColor.withOpacity(
                                                0.1,
                                              ),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: isPerfect
                                        ? [
                                            AppTheme.goldColor,
                                            AppTheme.secondaryColor,
                                          ]
                                        : [
                                            AppTheme.primaryColor,
                                            AppTheme.secondaryColor,
                                          ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (isPerfect
                                                  ? AppTheme.goldColor
                                                  : AppTheme.primaryColor)
                                              .withOpacity(0.4),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isPerfect ? Icons.emoji_events : Icons.star,
                                  color: Colors.white,
                                  size: 64,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Score Display with Counter Animation
                          TweenAnimationBuilder<int>(
                            key: ValueKey('score_${safeScore}_$totalQuestions'),
                            duration: AppAnimations.scoreCounterDuration,
                            tween: IntTween(begin: 0, end: safeScore),
                            curve: AppAnimations.defaultCurve,
                            builder: (context, animatedScore, child) {
                              final displayScore = animatedScore.clamp(
                                0,
                                totalQuestions,
                              );
                              return Text(
                                '$displayScore / $totalQuestions',
                                style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          // Percentage with Animation
                          TweenAnimationBuilder<int>(
                            key: ValueKey(
                              'percentage_${safePercentage}_$totalQuestions',
                            ),
                            duration: AppAnimations.scoreCounterDuration,
                            tween: IntTween(
                              begin: 0,
                              end: safePercentage.clamp(0, 100),
                            ),
                            curve: AppAnimations.defaultCurve,
                            builder: (context, animatedPercentage, child) {
                              final displayPercentage = animatedPercentage
                                  .clamp(0, 100);
                              return Text(
                                '$displayPercentage%',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.secondaryColor,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          // Message Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.accentColor.withOpacity(0.1),
                                  AppTheme.accentColor.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.accentColor.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              _getScoreMessage(safePercentage),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Action Buttons
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton.icon(
                              onPressed: _restartQuiz,
                              icon: const Icon(Icons.refresh, size: 24),
                              label: const Text(
                                'Try Again',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                                shadowColor: AppTheme.primaryColor.withOpacity(
                                  0.4,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.home, size: 24),
                              label: const Text(
                                'Back to Home',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        } catch (e, stackTrace) {
          // Log error for debugging
          debugPrint('Quiz completion error: $e');
          debugPrint('Stack trace: $stackTrace');

          // Fallback UI if animation fails
          return Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, size: 64, color: AppTheme.primaryColor),
                    const SizedBox(height: 24),
                    Text(
                      '$safeScore / $totalQuestions',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$safePercentage%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _getScoreMessage(safePercentage),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: _restartQuiz,
                        icon: const Icon(Icons.refresh, size: 24),
                        label: const Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.home, size: 24),
                        label: const Text(
                          'Back to Home',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
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
      },
    );
  }

  String _getScoreMessage(int percentage) {
    if (percentage >= 90) {
      return 'Excellent! You are a Nizwa Castle expert! 🏆';
    } else if (percentage >= 70) {
      return 'Very Good! You have good knowledge about Nizwa Castle! 👍';
    } else if (percentage >= 50) {
      return 'Not bad! Learn more about Nizwa Castle! 📚';
    } else {
      return 'Try again! Discover more about Oman\'s heritage! 🏰';
    }
  }
}
