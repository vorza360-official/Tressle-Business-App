import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EmployeePortfolioScreen extends StatefulWidget {
  final String employeeId;

  const EmployeePortfolioScreen({Key? key, required this.employeeId})
    : super(key: key);

  @override
  _EmployeePortfolioScreenState createState() =>
      _EmployeePortfolioScreenState();
}

class _EmployeePortfolioScreenState extends State<EmployeePortfolioScreen> {
  Map<String, dynamic>? employeeData;
  List<Map<String, dynamic>> reviews = [];
  double averageRating = 0.0;
  int reviewCount = 0;
  int clientCount = 0;

  List<String> _portfolioImages = [];
  List<String> _portfolioTitles = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Fetch employee data
    DocumentSnapshot employeeDoc = await FirebaseFirestore.instance
        .collection('employees')
        .doc(widget.employeeId)
        .get();

    if (employeeDoc.exists) {
      employeeData = employeeDoc.data() as Map<String, dynamic>;

      // Extract portfolio images and titles
      if (employeeData!['portfolio'] != null &&
          employeeData!['portfolio'] is List) {
        var portfolioList = employeeData!['portfolio'] as List;
        for (var item in portfolioList) {
          if (item is Map && item['imageUrl'] != null) {
            _portfolioImages.add(item['imageUrl']);
            _portfolioTitles.add(item['title'] ?? '');
          }
        }
      }
    }

    // Fetch reviews
    QuerySnapshot reviewSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('staffId', isEqualTo: widget.employeeId)
        .get();

    reviews = reviewSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    // Compute stats
    if (reviews.isNotEmpty) {
      double totalRating = 0;
      Set<String> uniqueClients = {};
      for (var review in reviews) {
        totalRating += (review['barberRating'] as num).toDouble();
        uniqueClients.add(review['userId']);
      }
      averageRating = totalRating / reviews.length;
      reviewCount = reviews.length;
      clientCount = uniqueClients.length;
    }

    setState(() {});
  }

  // Function to show full-screen image viewer
  void _showFullScreenImage(int startIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          images: _portfolioImages,
          titles: _portfolioTitles,
          initialIndex: startIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (employeeData == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            // Header Section
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6B73FF), Color(0xFF9DD5EA)],
                ),
              ),
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      //const Icon(Icons.menu, color: Colors.white, size: 24),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Profile Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 30),
                      CircleAvatar(
                        radius: 35,
                        backgroundImage:
                            employeeData!['profileImageUrl'] != null
                            ? NetworkImage(employeeData!['profileImageUrl'])
                            : null,
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employeeData!['name'] ?? 'Unknown',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow[600],
                                  size: 16,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  averageRating.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Specialist: ${employeeData!['designation'] ?? ''}',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Stats Row
                  Row(
                    spacing: 25,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatColumn(
                        averageRating.toStringAsFixed(1),
                        'Ratings',
                      ),
                      Container(width: 1, height: 40, color: Colors.white),
                      _buildStatColumn(reviewCount.toString(), 'Reviews'),
                      Container(width: 1, height: 40, color: Colors.white),
                      _buildStatColumn(clientCount.toString(), 'Clients'),
                    ],
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),

            // Content Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // About Section - UPDATED with better UI
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue[50]!,
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue[50],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.lightBlue[700],
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'About Information',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.lightBlue[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Personal Info Section
                          _buildAboutSection(
                            title: 'Personal Information',
                            icon: Icons.person_outline,
                            items: [
                              _buildInfoItem(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value: employeeData!['email'] ?? 'Not provided',
                                iconColor: Colors.lightBlue,
                              ),
                              _buildInfoItem(
                                icon: Icons.phone_outlined,
                                label: 'Phone',
                                value: employeeData!['phone'] ?? 'Not provided',
                                iconColor: Colors.lightBlue,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Professional Info Section
                          _buildAboutSection(
                            title: 'Professional Information',
                            icon: Icons.work_outline,
                            items: [
                              _buildInfoItem(
                                icon: Icons.badge_outlined,
                                label: 'Designation',
                                value:
                                    employeeData!['designation'] ??
                                    'Not specified',
                                iconColor: Colors.lightBlue,
                              ),
                              _buildInfoItem(
                                icon: Icons.calendar_today_outlined,
                                label: 'Joining Date',
                                value:
                                    employeeData!['joiningDate'] ??
                                    'Not specified',
                                iconColor: Colors.lightBlue,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Schedule Info Section
                          _buildAboutSection(
                            title: 'Schedule',
                            icon: Icons.schedule_outlined,
                            items: [
                              _buildInfoItem(
                                icon: Icons.calendar_view_week_outlined,
                                label: 'Working Days',
                                value: _formatWorkingDays(
                                  employeeData!['workingDays'],
                                ),
                                iconColor: Colors.lightBlue,
                              ),
                              if (employeeData!['shiftStart'] != null &&
                                  employeeData!['shiftEnd'] != null)
                                _buildInfoItem(
                                  icon: Icons.access_time_outlined,
                                  label: 'Working Hours',
                                  value:
                                      '${employeeData!['shiftStart']} - ${employeeData!['shiftEnd']}',
                                  iconColor: Colors.lightBlue,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Portfolio Section (renamed to Gallery)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Gallery',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 170,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _portfolioImages.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _showFullScreenImage(index),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: _buildPortfolioItem(
                                _portfolioImages[index],
                                _portfolioTitles[index],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Reviews Section
                    const Text(
                      'Reviews',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        var review = reviews[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: _buildReviewItem(
                            review['userName'],
                            review['userProfilePicture'],
                            review['barberRating'],
                            review['createdAt'].toDate().toString(),
                            review['barberReview'],
                          ),
                        );
                      },
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

  Widget _buildAboutSection({
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[100]!,
                  blurRadius: 1,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatWorkingDays(dynamic workingDays) {
    if (workingDays == null) return 'Not specified';

    if (workingDays is String) {
      return workingDays;
    } else if (workingDays is List) {
      return workingDays.join(', ');
    }

    return 'Not specified';
  }

  Widget _buildStatColumn(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildPortfolioItem(String? imageUrl, String title) {
    return Container(
      width: 130,
      height: 170,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(
    String userName,
    String? userProfile,
    num rating,
    String timeAgo,
    String reviewText,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: userProfile != null
                    ? NetworkImage(userProfile)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              Icons.star,
                              size: 14,
                              color: index < rating
                                  ? Colors.amber
                                  : Colors.grey[300],
                            );
                          }),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reviewText,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final List<String> titles;
  final int initialIndex;

  const FullScreenImageViewer({
    Key? key,
    required this.images,
    required this.titles,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _FullScreenImageViewerState createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PageView for swipe navigation
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                panEnabled: true,
                scaleEnabled: true,
                minScale: 0.5,
                maxScale: 3.0,
                child: Center(
                  child: Image.network(
                    widget.images[index],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 60,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // Close button
          Positioned(
            top: 40,
            left: 20,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),

          // Image title (if available)
          if (widget.titles[_currentIndex].isNotEmpty)
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Text(
                    widget.titles[_currentIndex],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),

          // Bottom indicator
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.images.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
