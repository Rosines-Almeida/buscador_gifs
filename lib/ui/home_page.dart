import 'dart:convert';
 
import 'package:buscador_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:buscador_gifs/ui/home_page.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String _search;
  int _offset = 0;
  // static const requestTrending =
  //     "https://api.giphy.com/v1/gifs/trending?api_key=RysRNOKSbW7dVRhpr6QrO0TcEgkWmUZY&limit=20&rating=g";
  // static const requestSearch =
  //     "https://api.giphy.com/v1/gifs/search?api_key=RysRNOKSbW7dVRhpr6QrO0TcEgkWmUZY&q=cats&limit=25&offset=25&rating=g&lang=en";

  Future<Map> _getGifs() async {
    http.Response response;
    if (_search == '' || _search.isEmpty){
      response = await http.get('https://api.giphy.com/v1/gifs/trending?api_key=RysRNOKSbW7dVRhpr6QrO0TcEgkWmUZY&limit=3&rating=g');
    }
    else {
      response = await http.get('https://api.giphy.com/v1/gifs/search?api_key=RysRNOKSbW7dVRhpr6QrO0TcEgkWmUZY&q=$_search&limit=3&offset=$_offset&rating=g&lang=en');
    }
    
    return json.decode(response.body);
  }

  @override
   void initState() {
    // TODO: implement initState
    super.initState();
 
    _getGifs().then((map) {});
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise aqui !",
                  labelStyle: TextStyle(color: Colors.white, fontSize: 15.0),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text){
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                        width: 200.00,
                        height: 200.00,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 5.0));
                  default:
                    if (snapshot.hasError)
                      return Container();
                    else
                      return _createGifTable(context, snapshot);
                }
              },
            ),
          )
        ],
      ),
    );
  }

 int _getCount(List data) { 
   if (_search == null) {
      return data.length; 
   }
   else {
      return data.length + 1; 
   }
}


  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    print(snapshot.data["data"]);
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, 
            crossAxisSpacing: 10.0, 
            mainAxisSpacing: 10.0),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          print('$index ${snapshot.data['data'].length}');
          if( _search == null || index < snapshot.data['data'].length)
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300.00,
              fit: BoxFit.cover,
            ),
            onTap: (){
              Navigator.push(context, 
              MaterialPageRoute(builder: (context)=> GifPage(snapshot.data["data"][index])),
              );
            },
            onLongPress: (){
              Share.share(  snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
            },
          );
          else
          return Container(
            child: GestureDetector(
              onTap: () {
                setState(() {
                    _offset +=3;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                  Icon(Icons.add, color: Colors.white, size: 70.0,),
                  Text('carregar mais ...', style: TextStyle( color: Colors.white, fontSize: 20 )), 
                 ],
              ),
            ),
          );
        });
  }
}
