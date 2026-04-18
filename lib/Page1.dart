import 'package:flutter/material.dart';

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  // Example data: dynamic images and corresponding text
  final List<Map<String, String>> items = [
    {
      "image":
          "https://www.shutterstock.com/image-photo/retro-golden-microphone-headphones-on-600nw-694098472.jpg",
      "text": "Item 1"
    },
    {
      "image":
          "https://www.shutterstock.com/image-photo/retro-golden-microphone-headphones-on-600nw-694098472.jpg",
      "text": "Item 2"
    },
    {
      "image":
          "https://www.shutterstock.com/image-photo/retro-golden-microphone-headphones-on-600nw-694098472.jpg",
      "text": "Item 3"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Aligns children to the start
          children: [
            buildHorizontalList(context),
            buildHorizontalListItem2(context),
            buildHorizontalListItem2(context),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: buildGridList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHorizontalList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, top: 20),
          child: Text(
            "ITEM 1",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.16,
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return CardItem(
                  imageUrl: items[index]['image']!,
                  text: items[index]['text']!,
                  size: 120);
            },
          ),
        ),
      ],
    );
  }

  Widget buildHorizontalListItem2(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, top: 20),
          child: Text(
            "ITEM 2",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.20,
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return CardItem(
                  imageUrl: items[index]['image']!,
                  text: items[index]['text']!,
                  size: 280);
            },
          ),
        ),
      ],
    );
  }

  Widget buildGridList(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columns
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      padding: const EdgeInsets.all(8.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                items[index]['image']!,
                height: 130,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 8),
              Text(
                items[index]['text']!,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

class CardItem extends StatelessWidget {
  final String imageUrl;
  final String text;
  final double size;
  const CardItem(
      {super.key,
      required this.imageUrl,
      required this.text,
      required this.size});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        width: size, // Adjust width
        child: Stack(
          children: [
            // Card with dynamic image
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                imageUrl,
                width: size,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // Overlay text
            Positioned(
              bottom: 10,
              left: 10,
              child: SizedBox(
                width: 70,
                height: 30,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black,
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}