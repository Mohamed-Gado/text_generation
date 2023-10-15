import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:text_generation/bloc/home_bloc.dart';
import 'package:text_generation/screens/screen.dart';
import 'package:text_generation/utils/locator.dart';
import './ml/model_handler.dart';
import './screens/home_screen.dart';

void main() async {
  setupServiceLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  HomeBloc _homeBloc = HomeBloc();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Generation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocProvider.value(value: _homeBloc, child: Screen()),
    );
  }
}
