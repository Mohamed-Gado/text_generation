// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../ml/model_handler.dart';

// class HomeScreen extends StatefulWidget {
//   HomeScreen({Key key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // bool _isInit = true;
//   // @override
//   // void didChangeDependencies() {
//   //   if (_isInit) {
//   //     Provider.of<ModelHandler>(context, listen: false).init().then((value) {
//   //       // Provider.of<ModelHandler>(context, listen: false)
//   //       //     .stream
//   //       //     .listen((event) {
//   //       //   completion = event;
//   //       // });
//   //       setState(() {
//   //         _isInit = false;
//   //       });
//   //     });
//   //   }
//   //   super.didChangeDependencies();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     final _handler = Provider.of<ModelHandler>(context, listen: false);
//     final prompt = Provider.of<ModelHandler>(context).prompt;
//     final completion = Provider.of<ModelHandler>(context).completion;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Text Generation'),
//       ),
//       body: _isInit
//           ? Center(
//               child: CircularProgressIndicator(),
//             )
//           : Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: FlatButton(
//                     onPressed: _handler.refreshPrompt,
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.shuffle,
//                           color: Theme.of(context).primaryColor,
//                         ),
//                         Text(
//                           'SHUFFLE PROMPT TEXT',
//                           style:
//                               TextStyle(color: Theme.of(context).primaryColor),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 FlatButton(
//                   color: Theme.of(context).primaryColor,
//                   onPressed: _handler.launchAutocomplete,
//                   child: Text(
//                     'TRIGGER AUTOCOMPLETE',
//                     style: TextStyle(
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.only(
//                     top: 10,
//                     left: 16.0,
//                     right: 16.0,
//                   ),
//                   child: RichText(
//                     text: TextSpan(children: [
//                       TextSpan(
//                         text: '$prompt ',
//                         style: TextStyle(
//                           fontSize: 20,
//                           color: Colors.black,
//                         ),
//                       ),
//                       TextSpan(
//                         text: completion,
//                         style: TextStyle(
//                           fontSize: 20,
//                           color: Colors.white,
//                           backgroundColor: Theme.of(context).primaryColor,
//                         ),
//                       ),
//                     ]),
//                   ),
//                 ),
//               ],
//               mainAxisSize: MainAxisSize.max,
//             ),
//     );
//   }
// }
