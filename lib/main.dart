import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './restful_key.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Search system',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '책 검색서비스'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final book_name = TextEditingController();
  ScrollController? _scrollController;
  int page = 1;
  List? result;
  List? data;

  @override
  void initState() {
    super.initState();
    data = new List.empty(growable: true);
    _scrollController = new ScrollController();

    _scrollController!.addListener(() {
      if (_scrollController!.offset >=
              _scrollController!.position.maxScrollExtent &&
          !_scrollController!.position.outOfRange) {
        print('bottom');
        page++;
        getJSONData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
          child: Column(
        children: [
          Row(
            children: [
              Padding(padding: EdgeInsets.only(left: 20)),
              Expanded(
                child: TextField(
                  controller: book_name,
                  keyboardType: TextInputType.text,
                  style: TextStyle(color: Colors.black),
                  maxLines: 1,
                  decoration: InputDecoration(hintText: '책 이름을 입력하세요'),
                ),
              ),
              IconButton(
                  onPressed: () {
                    data = new List.empty(growable: true);
                    page = 1;
                    data!.clear();
                    getJSONData();
                  },
                  icon: Icon(Icons.search), color: Colors.blue,)
            ],
          ),
          Expanded(
            child: data!.length == 0
                ? Text(
                    '데이터가 없습니다.',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  )
                : ListView.builder(
                    itemBuilder: (context, index) {
                      return Card(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Image.network(
                              data![index]['thumbnail'],
                              height: 100,
                              width: 100,
                              fit: BoxFit.contain,
                            ),
                            Column(
                              children: <Widget>[
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 150,
                                  child: Text(
                                    '책제목 : ${data![index]['title'].toString()}'
                                      ,textAlign: TextAlign.center,),
                                ),
                                Text('저자 : ${data![index]['authors'].toString()}'),
                                Text('판매가 : ${data![index]['sale_price'].toString()}'),
                                Text('상태 : ${data![index]['status'].toString()}'),
                              ],
                            )
                          ]
                        ),
                      );
                    },
                    itemCount: data!.length,
                    controller: _scrollController,
                  ),
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          data = new List.empty(growable: true);
          page = 1;
          data!.clear();
          getJSONData();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.search),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<String> getJSONData() async {
    var book_name_val = book_name.value.text.toString();
    var restfulkey = restful_key;
    var url =
        'https://dapi.kakao.com/v3/search/book?target=title&page&query=${book_name_val}';
    var response = await http.get(Uri.parse(url),
        headers: {"Authorization": "KakaoAK ${restfulkey}"});
    var response_body = response.body;
    var dataConvertedToJSON = json.decode(response_body);
    List result = dataConvertedToJSON['documents'];

    setState(() {
      data!.addAll(result);
    });
    return response_body;
  }
}
