// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class FriendPage extends StatelessWidget {
  const FriendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(198, 218, 231, 100),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(198, 218, 231, 100),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Row(
            children: [
              Text('Friend Page'),
              Spacer(),
              Image.asset(
                "images/logo.png",
                fit: BoxFit.contain,
                height: 60,
              ),
              SizedBox(width: 8), // Adjust the spacing as needed
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: MySearchDelegate(),
                );
              },
            ),
            SizedBox(width: 20),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Color.fromRGBO(198, 218, 231, 100),
                title: TabBar(
                  tabs: [
                    Tab(text: 'Friends'),
                    Tab(text: 'Requests'),
                  ],
                ),
                floating: true,
                pinned: true,
                snap: false,
              ),
            ];
          },
          body: TabBarView(
            children: [
              // Content for 'Friends' tab
              Center(
                child: Text('Friends Tab Content'),
              ),
              // Content for 'Requests' tab
              Center(
                child: Text('Requests Tab Content'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MySearchDelegate extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      scaffoldBackgroundColor: Color.fromRGBO(198, 218, 231, 100),
    );
  }

  List<String> searchResults = [
    "Apple",
    "Banana",
    "Orange",
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (query.isEmpty) {
              close(context, null);
            } else {
              query = '';
            }
          },
        )
      ];

  @override
  Widget buildResults(BuildContext context) => Center(
        child: Text(
          query,
          style: const TextStyle(fontSize: 64, fontWeight: FontWeight.normal),
        ),
      );

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> suggestions = searchResults.where((searchResult) {
      final result = searchResult.toLowerCase();
      final input = query.toLowerCase();

      return result.contains(input);
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];

        return ListTile(
            title: Text(suggestion),
            onTap: () {
              query = suggestion;

              showResults(context);
            });
      },
    );
  }
}