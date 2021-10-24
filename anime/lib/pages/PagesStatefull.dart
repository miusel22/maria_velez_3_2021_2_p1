import 'dart:convert';
import 'package:anime/models/animeInfo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PageStatefull extends StatefulWidget {
  final String name;
  final String img;
  PageStatefull(this.name, this.img, {Key key}) : super(key: key);

  @override
  _PageStatefullState createState() => _PageStatefullState();
}

class _PageStatefullState extends State<PageStatefull> {
  Future<List<AnimeInfo>> _listAnimeInfo;
  Future<List<AnimeInfo>> _getAnimeInfo() async {
    final response = await http.get(Uri.parse(
        'https://anime-facts-rest-api.herokuapp.com/api/v1/${widget.name}'));

    List<AnimeInfo> animeInfo = [];
    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(body);

      for (var item in jsonData["data"]) {
        animeInfo.add(AnimeInfo(item["fact"]));
      }

      return animeInfo;
    } else {
      throw Exception("Falló la conexión");
    }
  }

  @override
  void initState() {
    super.initState();
    _listAnimeInfo = _getAnimeInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Info anime ${widget.name}"),
      ),
      body: FutureBuilder(
        future: _listAnimeInfo,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
                child: ListView(
              children: _dataAnime(snapshot.data, context),
            ));
          } else if (snapshot.hasError) {
            return Text("Error");
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  List<Widget> _dataAnime(List<AnimeInfo> data, context) {
    List<Widget> animeInfo = [];
    for (var anime in data) {
      animeInfo.add(Card(
          child: Column(
        children: [
          ListTile(title: Text(anime.fact), leading: Icon(Icons.label)),
        ],
      )));
    }
    return animeInfo;
  }
}
