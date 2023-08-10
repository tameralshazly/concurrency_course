import 'dart:async';
import 'dart:developer' as devtools show log;
import 'dart:io';
import 'dart:convert';
import 'dart:math';

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

const names = ['foo', 'bar', 'baz'];

extension RandomElement<T> on Iterable<T> {
  T getRandomElement() => elementAt(Random().nextInt(length));
}

class UpperCaseSink implements EventSink<String> {
  final EventSink<String> _sink;

  const UpperCaseSink(this._sink);

  @override
  void add(String event) => _sink.add(event.toUpperCase());

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _sink.addError(error, stackTrace);

  @override
  void close() => _sink.close();
}

class StreamTransformUpperCaseString
    extends StreamTransformerBase<String, String> {
  @override
  Stream<String> bind(
    Stream<String> stream,
  ) =>
      Stream<String>.eventTransformed(
        stream,
        (sink) => UpperCaseSink(sink),
      );
}

void testIt() async {
  await for (var name in Stream.periodic(
    const Duration(seconds: 1),
    (_) => names.getRandomElement(),
  ).transform(StreamTransformUpperCaseString())) {
    name.log();
  }
}
// void testIt() async {
//   await for (final people
//       in Stream.periodic(const Duration(seconds: 3)).asyncExpand(
//     (_) => GetPeople()
//         .getPeople('http://172.20.10.5:5500/api/people1.json')
//         .asStream(),
//   )) {
//     people.log();
//   }
// }

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
