import 'dart:developer' as devtools show log;
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';

extension Log on Object {
  void log() => devtools.log(toString());
}

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    ),
  );
}

@immutable
class Person {
  final String name;
  final int age;
  const Person({
    required this.name,
    required this.age,
  });

  Person.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        age = json['age'] as int;

  @override
  String toString() => 'Person ($name, $age years old)';
}

mixin ListOfThingsAPI<T> {
  Future<Iterable<T>> get(String url) => HttpClient()
      .getUrl(Uri.parse(url))
      .then((request) => request.close())
      .then((response) => response.transform(utf8.decoder).join())
      .then((string) => json.decode(string) as List<dynamic>)
      .then((list) => list.cast());
}

class GetApiEndPoints with ListOfThingsAPI<String> {}

class GetPeople with ListOfThingsAPI<Map<String, dynamic>> {
  Future<Iterable<Person>> getPeople(String url) => get(url).then(
        (jsons) => jsons.map(
          (json) => Person.fromJson(json),
        ),
      );
}

void testIt() async {
  await for (final people
      in Stream.periodic(const Duration(seconds: 3)).asyncExpand(
    (_) => GetPeople()
        .getPeople('http://172.20.10.5:5500/api/people1.json')
        .asStream(),
  )) {
    people.log();
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    testIt();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
    );
  }
}
