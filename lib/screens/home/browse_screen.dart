import 'package:flutter/material.dart';

class BrowsePage extends StatelessWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scaleFactor = screenWidth < 360 ? 0.9 : 1.0;

    final List<Map<String, String>> feedItems = [
      {
        'image': 'assets/images/workout1.jpg',
        'caption': 'Morning routine done! Feeling unstoppable',
        'username': 'MikeFit',
        'time': '5 mins ago',
        'category': '#workout',
      },
      {
        'image': 'assets/images/fitness2.jpg',
        'caption': 'New personal best on deadlifts today! 💪',
        'username': 'FritzStrong',
        'time': '15 mins ago',
        'category': '#fitness',
      },
      {
        'image': 'assets/images/yoga.jpg',
        'caption': 'Starting the day with some yoga vibes 🧘‍♀️',
        'username': 'LenaZennith',
        'time': '30 mins ago',
        'category': '#workout',
      },
      {
        'image': 'assets/images/gym.jpg',
        'caption': 'Leg day at the gym was intense! 🏋️‍♂️',
        'username': 'JakePower',
        'time': '1 hour ago',
        'category': '#fitness',
      },
    ];

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.05 * scaleFactor,
                screenHeight * 0.05 * scaleFactor,
                screenWidth * 0.05 * scaleFactor,
                screenHeight * 0.03 * scaleFactor,
              ),
              child: Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: screenWidth * 0.06 * scaleFactor,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.04,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _buildCategoryTag('#fitness', true),
                  _buildCategoryTag('#workout'),
                  _buildCategoryTag('#nutrition'),
                  _buildCategoryTag('#wellness'),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: feedItems.length,
                itemBuilder: (context, index) {
                  final item = feedItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildFeedCard(item, screenWidth, screenHeight, scaleFactor),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
        ),
      ),
    );
  }

  Widget _buildCategoryTag(String text, [bool isSelected = false]) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black54,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFeedCard(Map<String, String> item, double screenWidth, double screenHeight, double scaleFactor) {
    return Container(
      width: screenWidth * 0.45 * scaleFactor,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.asset(
              item['image']!,
              height: screenHeight * 0.25 * scaleFactor,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['caption']!,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04 * scaleFactor,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      item['username']!,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035 * scaleFactor,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  item['time']!,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03 * scaleFactor,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}