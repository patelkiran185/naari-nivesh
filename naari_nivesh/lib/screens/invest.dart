import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:animations/animations.dart';

import '../utils/BottomNavigation.dart';


class InvestScreen extends StatefulWidget {
  @override
  _InvestScreenState createState() => _InvestScreenState();
}

class _InvestScreenState extends State<InvestScreen> with TickerProviderStateMixin {
  final List<Color> gradientColors = [
    const Color(0xFF1DE9B6),
    const Color(0xFF0097A7),
  ];

  double _riskTolerance = 2;
  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

   late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isPortfolioVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();

    // Trigger portfolio visibility after a delay
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isPortfolioVisible = true;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAnimatedAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPortfolioSection(),
                    SizedBox(height: 24),
                    _buildTabSection(),
                    SizedBox(height: 24),
                    _buildAnimatedRecommendations(),
                    SizedBox(height: 24),
                    _buildInteractiveRiskAssessment(),
                    SizedBox(height: 24),
                    _buildAnimatedQuickActions(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildAnimatedFAB(),
      bottomNavigationBar: const BottomNavigation(currentIndex: 0,), 
    );
  }


PreferredSizeWidget _buildAnimatedAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: gradientColors[1],
        automaticallyImplyLeading: false,  // Remove the back arrow
    title: FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        'Dashboard',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,  // Set text color to white
        ),
      ),
    ),
      actions: [
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(_animationController),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined),
                onPressed: () {
                  _showNotificationOverlay(context);
                },
              ),
              IconButton(
                icon: Icon(Icons.language),
                onPressed: () {
                  _showProfileDialog(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }


Widget _buildTabSection() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: gradientColors[1],
          unselectedLabelColor: Colors.grey,
          indicatorColor: gradientColors[0],
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Performance'),
            Tab(text: 'Holdings'),
          ],
        ),
        SizedBox(
          height: 200,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildPerformanceTab(),
              _buildHoldingsTab(),
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildOverviewTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Portfolio Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.7,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(gradientColors[0]),
            ),
            SizedBox(height: 8),
            Text('70% of your goal achieved',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

   Widget _buildPerformanceTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  FlSpot(0, 3),
                  FlSpot(2.6, 2),
                  FlSpot(4.9, 5),
                  FlSpot(6.8, 3.1),
                  FlSpot(8, 4),
                  FlSpot(9.5, 3),
                  FlSpot(11, 4),
                ],
                isCurved: true,
                gradient: LinearGradient(colors: gradientColors),
                barWidth: 5,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: gradientColors
                        .map((color) => color.withOpacity(0.3))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


Widget _buildAnimatedQuickActions() {
  return AnimatedOpacity(
    duration: Duration(milliseconds: 800),
    opacity: _isPortfolioVisible ? 1.0 : 0.0,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildQuickActionButton(
                'Add Money',
                Icons.add_circle_outline,
                () => _showAddMoneyDialog(),
              ),
              _buildQuickActionButton(
                'Withdraw',
                Icons.remove_circle_outline,
                () => _showWithdrawDialog(),
              ),
              _buildQuickActionButton(
                'Analysis',
                Icons.analytics_outlined,
                () => _showAnalysisSheet(),
              ),
              _buildQuickActionButton(
                'History',
                Icons.history,
                () => _showTransactionHistory(),
              ),
              _buildQuickActionButton(
                'Goals',
                Icons.flag_outlined,
                () => _showGoalsDialog(),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

void _showAddMoneyDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Add Money'),
      content: Text('Add money dialog content goes here.'),
      actions: [
        TextButton(
          child: Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

void _showWithdrawDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Withdraw'),
      content: Text('Withdraw dialog content goes here.'),
      actions: [
        TextButton(
          child: Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

void _showAnalysisSheet() {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: EdgeInsets.all(16),
      child: Text('Analysis sheet content goes here.'),
    ),
  );
}

void _showTransactionHistory() {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: EdgeInsets.all(16),
      child: Text('Transaction history content goes here.'),
    ),
  );
}

void _showGoalsDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Goals'),
      content: Text('Goals dialog content goes here.'),
      actions: [
        TextButton(
          child: Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

Widget _buildQuickActionButton(String label, IconData icon, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.only(right: 16.0),
    child: InkWell(
      onTap: onTap,
      child: TweenAnimationBuilder(
        duration: Duration(milliseconds: 300),
        tween: Tween<double>(begin: 0.8, end: 1.0),
        builder: (context, double scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Container(
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: gradientColors[1],
                  size: 28,
                ),
              ),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildInteractiveRiskAssessment() {
  return AnimatedContainer(
    duration: Duration(milliseconds: 500),
    curve: Curves.easeInOut,
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Risk Assessment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () => _showRiskInfoDialog(),
              color: gradientColors[1],
            ),
          ],
        ),
        SizedBox(height: 20),
        Text(
          'What is your risk tolerance?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Text('Conservative'),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: gradientColors[0],
                  inactiveTrackColor: Colors.grey[300],
                  thumbColor: gradientColors[1],
                  overlayColor: gradientColors[0].withOpacity(0.2),
                  trackHeight: 4.0,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 20.0),
                ),
                child: Slider(
                  value: _riskTolerance,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (value) {
                    setState(() {
                      _riskTolerance = value;
                    });
                    _animateRiskChange();
                  },
                ),
              ),
            ),
            Text('Aggressive'),
          ],
        ),
        SizedBox(height: 20),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: Column(
            key: ValueKey(_riskTolerance),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getRiskIcon(_riskTolerance),
                    color: _getRiskColor(_riskTolerance),
                  ),
                  SizedBox(width: 8),
                  Text(
                    _getRiskLabel(_riskTolerance),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getRiskColor(_riskTolerance),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                _getRecommendation(_riskTolerance),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Helper methods for Risk Assessment
IconData _getRiskIcon(double value) {
  if (value <= 1) return Icons.shield_outlined;
  if (value <= 2) return Icons.security_outlined;
  if (value <= 3) return Icons.balance_outlined;
  if (value <= 4) return Icons.trending_up;
  return Icons.rocket_launch_outlined;
}

Color _getRiskColor(double value) {
  if (value <= 1) return Colors.blue;
  if (value <= 2) return Colors.green;
  if (value <= 3) return Colors.orange;
  if (value <= 4) return Colors.deepOrange;
  return Colors.red;
}

void _showRiskInfoDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Understanding Risk Tolerance'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your risk tolerance helps us recommend appropriate investments:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          _buildRiskLevelInfo('Conservative (1-2)', 'Lower risk, stable returns'),
          _buildRiskLevelInfo('Moderate (3)', 'Balanced risk and returns'),
          _buildRiskLevelInfo('Aggressive (4-5)', 'Higher risk, potential for higher returns'),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Got it'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}

Widget _buildRiskLevelInfo(String level, String description) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.arrow_right, size: 20),
        SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(level, style: TextStyle(fontWeight: FontWeight.w500)),
              Text(description, style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    ),
  );
}

void _animateRiskChange() {
  // Add haptic feedback
  HapticFeedback.selectionClick();
  
  // Trigger animation controller if you want to add custom animations
  // _animationController.forward(from: 0.0);
}


Widget _buildHoldingsTab() {
    return Card(
      child: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: gradientColors[index % 2],
              child: Icon(Icons.show_chart, color: Colors.white),
            ),
            title: Text('Investment ${index + 1}'),
            subtitle: Text('₹${(10000 * (index + 1)).toString()}'),
            trailing: Text('+${(5 + index).toString()}%',
                style: TextStyle(color: Colors.green)),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedFAB() {
    return OpenContainer(
      transitionDuration: Duration(milliseconds: 500),
      openBuilder: (context, _) => AIChatScreen(),
      closedBuilder: (context, openContainer) => FloatingActionButton(
        backgroundColor: gradientColors[0],
        child: Icon(Icons.chat_outlined),
        onPressed: openContainer,
      ),
    );
  }

  Widget _buildAnimatedRecommendations() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(_animationController),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI-Powered Recommendations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildInteractiveRecommendationCard(
            'Increase SIP Investment',
            'Based on your savings pattern, you can increase your SIP by ₹2,000',
            Icons.trending_up,
            'Modify SIP',
          ),
          SizedBox(height: 12),
          _buildInteractiveRecommendationCard(
            'New Investment Opportunity',
            'Consider investing in IT sector mutual funds for better returns',
            Icons.lightbulb_outline,
            'Learn More',
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveRecommendationCard(
      String title, String description, IconData icon, String actionText) {
    return InkWell(
      onTap: () => _showRecommendationDetails(context, title, description),
      child: Hero(
        tag: title,
        child: Card(
          elevation: 2,
          child: RecommendationCard(
            title: title,
            description: description,
            icon: icon,
            actionText: actionText,
            gradientColors: gradientColors,
          ),
        ),
      ),
    );
  }

  void _showRecommendationDetails(
      BuildContext context, String title, String description) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(16),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text(description, style: TextStyle(fontSize: 16)),
              // Add more detailed content here
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationOverlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 3,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(Icons.notifications, color: gradientColors[0]),
                title: Text('Notification ${index + 1}'),
                subtitle: Text('This is a notification message'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: gradientColors[0],
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            SizedBox(height: 16),
            Text('John Doe',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('john.doe@example.com'),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Investment',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              currencyFormat.format(150000),
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeaderStat('Returns', '+12.5%', Icons.trending_up),
                _buildHeaderStat('Risk Level', 'Moderate', Icons.shield_outlined),
                _buildHeaderStat('Goals', '2/4', Icons.flag_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildPortfolioSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Portfolio Allocation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.70,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: gradientColors[0],
                      value: 40,
                      title: 'Equity',
                      radius: 50,
                      titleStyle: TextStyle(color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: gradientColors[1],
                      value: 30,
                      title: 'Debt',
                      radius: 50,
                      titleStyle: TextStyle(color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.blue[300],
                      value: 30,
                      title: 'Gold',
                      radius: 50,
                      titleStyle: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI-Powered Recommendations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        RecommendationCard(
          title: 'Increase SIP Investment',
          description: 'Based on your savings pattern, you can increase your SIP by ₹2,000',
          icon: Icons.trending_up,
          actionText: 'Modify SIP',
          gradientColors: gradientColors,
        ),
        SizedBox(height: 12),
        RecommendationCard(
          title: 'New Investment Opportunity',
          description: 'Consider investing in IT sector mutual funds for better returns',
          icon: Icons.lightbulb_outline,
          actionText: 'Learn More',
          gradientColors: gradientColors,
        ),
      ],
    );
  }

  Widget _buildRiskAssessmentSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Risk Assessment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text('What is your risk tolerance?'),
            SizedBox(height: 8),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: gradientColors[0],
                inactiveTrackColor: Colors.grey[300],
                thumbColor: gradientColors[1],
                overlayColor: gradientColors[0].withOpacity(0.2),
              ),
              child: Slider(
                value: _riskTolerance,
                min: 1,
                max: 5,
                divisions: 4,
                label: _getRiskLabel(_riskTolerance),
                onChanged: (value) {
                  setState(() {
                    _riskTolerance = value;
                  });
                },
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Recommendation: ${_getRecommendation(_riskTolerance)}',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickActionButton('Add Money', Icons.add_circle_outline, () => _showAddMoneyDialog()),
            _buildQuickActionButton('Withdraw', Icons.remove_circle_outline, () => _showWithdrawDialog()),
            _buildQuickActionButton('Analysis', Icons.analytics_outlined, () => _showAnalysisSheet()),
            _buildQuickActionButton('History', Icons.history, () => _showTransactionHistory()),
          ],
        ),
      ],
    );
  }

 

  String _getRiskLabel(double value) {
    if (value <= 1) return 'Very Low';
    if (value <= 2) return 'Low';
    if (value <= 3) return 'Moderate';
    if (value <= 4) return 'High';
    return 'Very High';
  }

  String _getRecommendation(double value) {
    if (value <= 1) return 'Fixed Deposits, Savings Accounts';
    if (value <= 2) return 'Government Bonds, PPF';
    if (value <= 3) return 'Balanced Mutual Funds';
    if (value <= 4) return 'Equity Mutual Funds';
    return 'Direct Equity Investments';
  }
}

class RecommendationCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String actionText;
  final List<Color> gradientColors;

  const RecommendationCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.actionText,
    required this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: gradientColors[0].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: gradientColors[0],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(
                    actionText,
                    style: TextStyle(
                      color: gradientColors[1],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



class AIChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Investment Assistant'),
        backgroundColor: const Color(0xFF0097A7),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: 1,
              itemBuilder: (context, index) {
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Assistant',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0097A7),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Hello! How can I help you with your investments today?',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type your question...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  child: Icon(Icons.send),
                  backgroundColor: const Color(0xFF1DE9B6),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Keep your existing RecommendationCard class