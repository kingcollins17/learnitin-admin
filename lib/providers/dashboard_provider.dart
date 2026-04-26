import 'package:jaspr_riverpod/jaspr_riverpod.dart';

// ─── Data Models ────────────────────────────────────────────────

class StatItem {
  final String label;
  final String value;
  final String trend;
  final bool isPositive;
  final String icon;
  final String subtitle;
  final String? to;

  const StatItem({
    required this.label,
    required this.value,
    required this.trend,
    required this.isPositive,
    required this.icon,
    required this.subtitle,
    this.to,
  });
}

class RecentUser {
  final int? id;
  final String name;
  final String email;
  final String initials;
  final String role;
  final String joinedAgo;
  final String status;

  const RecentUser({
    this.id,
    required this.name,
    required this.email,
    required this.initials,
    required this.role,
    required this.joinedAgo,
    required this.status,
  });
}

class CourseItem {
  final String title;
  final String category;
  final int enrollments;
  final double rating;
  final double completionRate;

  const CourseItem({
    required this.title,
    required this.category,
    required this.enrollments,
    required this.rating,
    required this.completionRate,
  });
}

class ActivityItem {
  final String description;
  final String timestamp;
  final String type; // 'enrollment', 'completion', 'payment', 'support'
  final String user;

  const ActivityItem({
    required this.description,
    required this.timestamp,
    required this.type,
    required this.user,
  });
}

class RevenueDataPoint {
  final String month;
  final double amount;

  const RevenueDataPoint({required this.month, required this.amount});
}

class DashboardData {
  final List<StatItem> stats;
  final List<RecentUser> recentUsers;
  final List<CourseItem> topCourses;
  final List<ActivityItem> recentActivity;
  final List<RevenueDataPoint> revenueChart;
  final Map<String, double> userDistribution;
  final double serverUptime;
  final int activeNow;

  const DashboardData({
    required this.stats,
    required this.recentUsers,
    required this.topCourses,
    required this.recentActivity,
    required this.revenueChart,
    required this.userDistribution,
    required this.serverUptime,
    required this.activeNow,
  });
}

// ─── Mock Data Provider ─────────────────────────────────────────

final dashboardProvider = Provider<DashboardData>((ref) {
  return const DashboardData(
    stats: [
      StatItem(
        label: 'Total Users',
        value: '25,431',
        trend: '+12.5%',
        isPositive: true,
        icon: '👥',
        subtitle: 'vs last month',
      ),
      StatItem(
        label: 'Active Courses',
        value: '432',
        trend: '+3.1%',
        isPositive: true,
        icon: '📚',
        subtitle: '18 new this week',
      ),
      StatItem(
        label: 'Revenue',
        value: '\$128,430',
        trend: '+22.4%',
        isPositive: true,
        icon: '💰',
        subtitle: 'Monthly recurring',
      ),
      StatItem(
        label: 'Completion Rate',
        value: '67.8%',
        trend: '+4.2%',
        isPositive: true,
        icon: '🎯',
        subtitle: 'Avg. across courses',
      ),
    ],
    recentUsers: [
      RecentUser(
        name: 'Sarah Chen',
        email: 'sarah.chen@email.com',
        initials: 'SC',
        role: 'Learner',
        joinedAgo: '2 minutes ago',
        status: 'active',
      ),
      RecentUser(
        name: 'Marcus Johnson',
        email: 'marcus.j@email.com',
        initials: 'MJ',
        role: 'Instructor',
        joinedAgo: '15 minutes ago',
        status: 'active',
      ),
      RecentUser(
        name: 'Aisha Patel',
        email: 'aisha.p@email.com',
        initials: 'AP',
        role: 'Learner',
        joinedAgo: '1 hour ago',
        status: 'active',
      ),
      RecentUser(
        name: 'David Kim',
        email: 'david.kim@email.com',
        initials: 'DK',
        role: 'Learner',
        joinedAgo: '2 hours ago',
        status: 'pending',
      ),
      RecentUser(
        name: 'Elena Rodriguez',
        email: 'elena.r@email.com',
        initials: 'ER',
        role: 'Admin',
        joinedAgo: '3 hours ago',
        status: 'active',
      ),
      RecentUser(
        name: 'James Wright',
        email: 'james.w@email.com',
        initials: 'JW',
        role: 'Learner',
        joinedAgo: '5 hours ago',
        status: 'inactive',
      ),
    ],
    topCourses: [
      CourseItem(
        title: 'Python for Machine Learning',
        category: 'Data Science',
        enrollments: 3241,
        rating: 4.9,
        completionRate: 0.78,
      ),
      CourseItem(
        title: 'React & Next.js Masterclass',
        category: 'Web Dev',
        enrollments: 2856,
        rating: 4.8,
        completionRate: 0.65,
      ),
      CourseItem(
        title: 'Cloud Architecture with AWS',
        category: 'DevOps',
        enrollments: 2190,
        rating: 4.7,
        completionRate: 0.59,
      ),
      CourseItem(
        title: 'UI/UX Design Fundamentals',
        category: 'Design',
        enrollments: 1965,
        rating: 4.8,
        completionRate: 0.72,
      ),
      CourseItem(
        title: 'Mobile Development with Flutter',
        category: 'Mobile',
        enrollments: 1720,
        rating: 4.6,
        completionRate: 0.61,
      ),
    ],
    recentActivity: [
      ActivityItem(
        description: 'enrolled in Python for ML',
        timestamp: '2 min ago',
        type: 'enrollment',
        user: 'Sarah Chen',
      ),
      ActivityItem(
        description: 'completed React Masterclass',
        timestamp: '8 min ago',
        type: 'completion',
        user: 'Alex Turner',
      ),
      ActivityItem(
        description: 'purchased Premium Plan',
        timestamp: '15 min ago',
        type: 'payment',
        user: 'Marcus Johnson',
      ),
      ActivityItem(
        description: 'submitted a support ticket',
        timestamp: '22 min ago',
        type: 'support',
        user: 'Priya Sharma',
      ),
      ActivityItem(
        description: 'enrolled in AWS Architecture',
        timestamp: '34 min ago',
        type: 'enrollment',
        user: 'Tom Baker',
      ),
      ActivityItem(
        description: 'completed Flutter Development',
        timestamp: '45 min ago',
        type: 'completion',
        user: 'Nina Costa',
      ),
      ActivityItem(
        description: 'upgraded to Team Plan',
        timestamp: '1 hr ago',
        type: 'payment',
        user: 'Raj Patel',
      ),
      ActivityItem(
        description: 'enrolled in UI/UX Fundamentals',
        timestamp: '1.5 hr ago',
        type: 'enrollment',
        user: 'Mia Chen',
      ),
    ],
    revenueChart: [
      RevenueDataPoint(month: 'Jul', amount: 64200),
      RevenueDataPoint(month: 'Aug', amount: 72800),
      RevenueDataPoint(month: 'Sep', amount: 68500),
      RevenueDataPoint(month: 'Oct', amount: 84100),
      RevenueDataPoint(month: 'Nov', amount: 96400),
      RevenueDataPoint(month: 'Dec', amount: 105000),
      RevenueDataPoint(month: 'Jan', amount: 98200),
      RevenueDataPoint(month: 'Feb', amount: 110500),
      RevenueDataPoint(month: 'Mar', amount: 118900),
      RevenueDataPoint(month: 'Apr', amount: 128430),
    ],
    userDistribution: {
      'Learners': 72.0,
      'Instructors': 15.0,
      'Enterprise': 8.0,
      'Admins': 5.0,
    },
    serverUptime: 99.97,
    activeNow: 1247,
  );
});
