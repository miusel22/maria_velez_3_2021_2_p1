import 'dart:convert';
import 'package:anime/models/anime.dart';
import 'package:anime/pages/pagesStatefull.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<List<Anime>> _listAnime;
  Future<List<Anime>> filteredAnime;
  Future<List<Anime>> _getAnimes() async {
    final response = await http
        .get(Uri.parse("https://anime-facts-rest-api.herokuapp.com/api/v1"));

    List<Anime> animes = [];
    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(body);

      for (var item in jsonData["data"]) {
        animes.add(
            Anime(item["anime_id"], item["anime_name"], item["anime_img"]));
      }

      return animes;
    } else {
      throw Exception("Falló la conexión");
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _listAnime = _getAnimes();
      filteredAnime = _listAnime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Material App Bar'),
        ),
        body: FutureBuilder(
          future: _listAnime,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: _dataAnime(snapshot.data, context),
              );
            } else if (snapshot.hasError) {
              return Text("Error");
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _dataAnime(List<Anime> data, context) {
    List<Widget> animes = [];

    for (var anime in data) {
      animes.add(Card(
          child: Column(
        children: [
          Image.network(anime.img),
          Padding(padding: const EdgeInsets.all(8.0), child: Text(anime.name)),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PageStatefull(anime.name, anime.img)));
            },
            child: Text("More information"),
          )
        ],
      )));
    }
    return animes;
  }
}
