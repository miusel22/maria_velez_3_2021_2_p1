import 'dart:convert';
import 'package:anime/models/anime.dart';
import 'package:anime/pages/pagesStatefull.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Kindacode.com',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Anime> _listAnime = [];
  List<Anime> animes = [];
  Future<List<Anime>> _getAnimes() async {
    final response = await http
        .get(Uri.parse("https://anime-facts-rest-api.herokuapp.com/api/v1"));

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
    getAllAnimes();
  }

  getAllAnimes() async {
    _listAnime = await _getAnimes();
    setState(() {
      _listAnime;
    });
  }

  void _runFilter(String enteredKeyword) async {
    List<Anime> results;
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      setState(() {
        results = _listAnime;
      });
    } else {
      results = animes
          .where((a) =>
              a.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _listAnime = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Kindacode.com'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  onChanged: (value) => _runFilter(value),
                  decoration: const InputDecoration(
                      labelText: 'Search', suffixIcon: Icon(Icons.search)),
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: _listAnime.isNotEmpty
                      ? ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: _listAnime.length,
                          itemBuilder: (BuildContext context, int index) {
                            Anime anime = _listAnime[index];

                            return _dataAnime(anime, context);
                          },
                        )
                      : const Center(
                          child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                  color: Colors.orange))),
                ),
              ],
            )));
  }

  Widget _dataAnime(Anime anime, context) {
    return Card(
        child: Column(children: [
      Image.network(anime.img),
      Padding(padding: const EdgeInsets.all(8.0), child: Text(anime.name)),
      ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PageStatefull(anime.name, anime.img)));
        },
        child: Text("More information"),
      )
    ]));
  }
}
