import 'package:flutter/material.dart';
import 'package:naari_nivesh/utils/BottomNavigation.dart';

class InvestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
         title: Center(
            child: const Text('Nari Nivesh'),
          ),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.mic),
              onPressed: () {
                // TODO: Implement voice assistance
              },
              tooltip: 'Voice Assistance',
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPortfolioOverview(),
                SizedBox(height: 24),
                Text(
                  'Start Your Financial Journey',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Small steps towards a brighter future',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
                _buildInvestmentOption(
                  title: 'Mahila Bachat Samooh (Women\'s Savings Group)',
                  description: 'Join a community of women savers and support each other',
                  minAmount: '₹50',
                  returnRate: '5-7% p.a.',
                  icon: Icons.group,
                  riskLevel: 'Low',
                ),
                _buildInvestmentOption(
                  title: 'Sona Nivesh (Gold Investment)',
                  description: 'Invest in digital gold - safe and traditional',
                  minAmount: '₹10',
                  returnRate: 'Based on gold prices',
                  icon: Icons.diamond,
                  riskLevel: 'Medium',
                ),
                _buildInvestmentOption(
                  title: 'Khet Mein Nivesh (Farm Investment)',
                  description: 'Support local farmers and grow your money',
                  minAmount: '₹100',
                  returnRate: '8-10% p.a.',
                  icon: Icons.agriculture,
                  riskLevel: 'Medium',
                ),
                _buildInvestmentOption(
                  title: 'Mahila Udyam Kosh (Women\'s Business Fund)',
                  description: 'Invest in women-led businesses in your community',
                  minAmount: '₹200',
                  returnRate: '10-15% p.a.',
                  icon: Icons.business_center,
                  riskLevel: 'High',
                ),
                SizedBox(height: 24),
                _buildCommunitySection(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigation(currentIndex: 0),
      ),
    );
  }

  Widget _buildPortfolioOverview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Investment Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProgressItem('Total Invested', '₹1,000', Colors.blue),
                _buildProgressItem('Current Value', '₹1,080', Colors.green),
                _buildProgressItem('Growth', '8%', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildInvestmentOption({
    required String title,
    required String description,
    required String minAmount,
    required String returnRate,
    required IconData icon,
    required String riskLevel,
  }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: Colors.teal),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Minimum Amount',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      minAmount,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Expected Returns',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      returnRate,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Risk Level: $riskLevel',
                  style: TextStyle(fontSize: 14, color: _getRiskColor(riskLevel)),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement investment action
                  },
                  child: Text('Invest Now'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.teal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  Widget _buildCommunitySection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Community & Mentorship',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage("https://imgs.search.brave.com/IABBfQi357pz-gKF-sMovZPJzBs6pJARG19g-0-phiM/rs:fit:500:0:0:0/g:ce/aHR0cHM6Ly9jZG4t/aWNvbnMtcG5nLmZs/YXRpY29uLmNvbS8x/MjgvNjg1NC82ODU0/NjA3LnBuZw"),
              ),
              title: Text('Connect with a Mentor'),
              subtitle: Text('Get guidance from experienced investors'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Implement mentor connection
              },
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.chat_bubble_outline),
              title: Text('Join Investment Discussion'),
              subtitle: Text('Learn from other women investors'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Implement community discussion
              },
            ),
          ],
        ),
      ),
    );
  }
}