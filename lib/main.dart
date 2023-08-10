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

const people1Url = 'http://172.20.10.5:5500/api/people1.json';
const people2Url = 'http://172.20.10.5:5500/api/people2.json';

Future<Iterable<Person>> parseJson(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((request) => request.close())
    .then((response) => response.transform(utf8.decoder).join())
    .then((string) => json.decode(string) as List<dynamic>)
    .then((json) => json.map((e) => Person.fromJson(e)));

extension EmptyOnError<E> on Future<List<Iterable<E>>> {
  Future<List<Iterable<E>>> emptyOnError() => catchError(
        (_, __) => List<Iterable<E>>.empty(),
      );
}

extension EmptyOnErrorOnFuture<E> on Future<Iterable<E>> {
  Future<Iterable<E>> emptyOnError() => catchError(
        (_, __) => Iterable<E>.empty(),
      );
}

void testIt() async {
  await for (final persons in getPersons()) {
    persons.log();
  }
}

Stream<Iterable<Person>> getPersons() async* {
  for (final url in Iterable.generate(
      2, (i) => 'http://172.20.10.5:5500/api/people${i + 1}.json')) {
    yield await parseJson(url);
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
