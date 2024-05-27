import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Services'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildServiceItem(
            title: 'Music Production',
            description:
            'We offer professional music production services, including recording, mixing, and mastering.',
            imageUrls: [
              'assets/medium-shot-man-wearing-headphones.jpg',
              'assets/pexels-cristian-rojas-7586689.jpg',
              'assets/pexels-ann-h-45017-2573957.jpg',
            ],
          ),
          _buildServiceItem(
            title: 'Instrument Lessons',
            description:
            'Learn to play your favorite instrument with our experienced instructors. We offer lessons for guitar, piano, drums, and more.',
            imageUrls: [
              'assets/pexels-cottonbro-9643922.jpg',
              'assets/pexels-sasha-kim-8432498.jpg',
              'assets/pexels-boris-pavlikovsky-7714278.jpg',

            ],
          ),
          _buildServiceItem(
            title: 'Live Performances',
            description:
            'Experience live music performances at our studio. We host concerts, showcases, and open mic nights.',
            imageUrls: [
              'assets/perfomance_3.jpg',
              'assets/perfomance_2.jpg',
              'assets/perfomance_1.jpg',
            ],
          ),
        ].map((widget) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: widget,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildServiceItem({
    required String title,
    required String description,
    required List<String> imageUrls,
  }) {
    return Card(
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: _loadImage(imageUrls.first),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Row(
            children: imageUrls
                .map(
                  (url) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: _loadImage(url),
                  ),
                ),
              ),
            )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _loadImage(String imageUrl) {
    return Image.asset(
      imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      height: 200,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300], // Placeholder color
          width: double.infinity,
          height: 200,
          child: const Center(
            child: Icon(
              Icons.error,
              color: Colors.red,
              size: 40,
            ),
          ),
        );
      },
    );
  }
}
