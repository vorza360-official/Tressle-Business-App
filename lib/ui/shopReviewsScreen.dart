// lib/UI/shopReviewsScreen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShopReviewsScreen extends StatefulWidget {
  @override
  _ShopReviewsScreenState createState() => _ShopReviewsScreenState();
}

class _ShopReviewsScreenState extends State<ShopReviewsScreen>
    with SingleTickerProviderStateMixin {
  String? shopId;
  bool isLoading = true;
  int? selectedStarFilter;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    fetchShopId();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> fetchShopId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pop(context);
      return;
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists && userDoc['shopId'] != null) {
      setState(() {
        shopId = userDoc['shopId'];
        isLoading = false;
      });
      _animController.forward();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
              ),
            )
          : shopId == null
          ? Center(child: Text("No shop found"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reviews')
                  .where('shopId', isEqualTo: shopId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorState();
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6C5CE7),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                var allDocs = snapshot.data!.docs;
                allDocs.sort((a, b) {
                  Timestamp? timeA = a['createdAt'] as Timestamp?;
                  Timestamp? timeB = b['createdAt'] as Timestamp?;
                  if (timeA == null || timeB == null) return 0;
                  return timeB.compareTo(timeA);
                });

                // Filter by star rating
                var filteredDocs = selectedStarFilter == null
                    ? allDocs
                    : allDocs.where((doc) {
                        int rating = (doc['shopRating'] as num?)?.toInt() ?? 0;
                        return rating == selectedStarFilter;
                      }).toList();

                // Calculate statistics
                Map<String, dynamic> stats = _calculateStats(allDocs);

                return CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            _buildStatsCard(stats, allDocs.length),
                            _buildFilterChips(),
                          ],
                        ),
                      ),
                    ),
                    filteredDocs.isEmpty
                        ? SliverFillRemaining(child: _buildNoResultsForFilter())
                        : SliverPadding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                return FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: SlideTransition(
                                    position:
                                        Tween<Offset>(
                                          begin: Offset(0, 0.1),
                                          end: Offset.zero,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: _animController,
                                            curve: Interval(
                                              (index / filteredDocs.length)
                                                  .clamp(0.0, 1.0),
                                              1.0,
                                              curve: Curves.easeOut,
                                            ),
                                          ),
                                        ),
                                    child: ReviewCard(
                                      review: filteredDocs[index],
                                    ),
                                  ),
                                );
                              }, childCount: filteredDocs.length),
                            ),
                          ),
                  ],
                );
              },
            ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 18,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: EdgeInsets.only(left: 72, bottom: 16),
        title: Text(
          'Reviews',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFFAFBFC)],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateStats(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return {
        'average': 0.0,
        'distribution': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      };
    }

    int total = 0;
    Map<int, int> distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (var doc in docs) {
      int rating = (doc['shopRating'] as num?)?.toInt() ?? 0;
      if (rating >= 1 && rating <= 5) {
        total += rating;
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }
    }

    double average = total / docs.length;

    return {'average': average, 'distribution': distribution};
  }

  Widget _buildStatsCard(Map<String, dynamic> stats, int totalReviews) {
    double average = stats['average'] ?? 0.0;
    Map<int, int> distribution = stats['distribution'] ?? {};
    int maxCount = distribution.values.fold(
      0,
      (max, val) => val > max ? val : max,
    );

    return Container(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C5CE7), Color(0xFF8B7FF4)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6C5CE7).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      average.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < average.round()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: Colors.white,
                          size: 24,
                        );
                      }),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '$totalReviews ${totalReviews == 1 ? 'review' : 'reviews'}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: List.generate(5, (i) {
                    int stars = 5 - i;
                    int count = distribution[stars] ?? 0;
                    double percentage = maxCount > 0 ? count / maxCount : 0;

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            '$stars',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: percentage,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '$count',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      margin: EdgeInsets.only(bottom: 8),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All', null),
          SizedBox(width: 8),
          _buildFilterChip('5 Stars', 5),
          SizedBox(width: 8),
          _buildFilterChip('4 Stars', 4),
          SizedBox(width: 8),
          _buildFilterChip('3 Stars', 3),
          SizedBox(width: 8),
          _buildFilterChip('2 Stars', 2),
          SizedBox(width: 8),
          _buildFilterChip('1 Star', 1),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int? stars) {
    bool isSelected = selectedStarFilter == stars;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (stars != null) ...[
            Icon(
              Icons.star_rounded,
              size: 16,
              color: isSelected ? Colors.white : Color(0xFF6C5CE7),
            ),
            SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedStarFilter = stars;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: Color(0xFF6C5CE7),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Color(0xFF6C5CE7),
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: isSelected ? 4 : 0,
      shadowColor: Color(0xFF6C5CE7).withOpacity(0.3),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Color(0xFF6C5CE7).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rate_review_outlined,
              size: 80,
              color: Color(0xFF6C5CE7),
            ),
          ),
          SizedBox(height: 24),
          Text(
            "No reviews yet",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              "Your customers will leave reviews after their appointments",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsForFilter() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            "No ${selectedStarFilter}-star reviews",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Try selecting a different filter",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, color: Colors.red, size: 48),
          ),
          SizedBox(height: 24),
          Text(
            "Failed to load reviews",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            "Check your internet connection",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final DocumentSnapshot review;

  const ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String userName = review['userName'] ?? 'Anonymous';
    String userPhoto = review['userProfilePicture'] ?? '';
    int shopRating = (review['shopRating'] as num?)?.toInt() ?? 0;
    String shopReview = review['shopReview'] ?? '';
    Timestamp? timestamp = review['createdAt'] as Timestamp?;
    String date = timestamp != null
        ? DateFormat('dd MMM yyyy').format(timestamp.toDate())
        : 'Unknown date';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF6C5CE7).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFFF5F7FA),
                  backgroundImage: userPhoto.isNotEmpty
                      ? NetworkImage(userPhoto)
                      : null,
                  child: userPhoto.isEmpty
                      ? Text(
                          userName[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C5CE7),
                          ),
                        )
                      : null,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        SizedBox(width: 4),
                        Text(
                          date,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFF8B7FF4)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF6C5CE7).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      shopRating.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (shopReview.isNotEmpty) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                shopReview,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
