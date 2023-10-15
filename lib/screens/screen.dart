import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_generation/bloc/home_bloc.dart';

class Screen extends StatefulWidget {
  const Screen({Key? key}) : super(key: key);

  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  HomeBloc? _homeBloc;
  bool initialBlocEventsCalled = false;
  late bool isIos;

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_homeBloc != null) {
        _homeBloc!.add(HomeInitEvent());
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _homeBloc = BlocProvider.of<HomeBloc>(context);
    if (!initialBlocEventsCalled) {
      _homeBloc!.add(HomeInitEvent());
      isIos = Theme.of(context).platform == TargetPlatform.iOS;
      initialBlocEventsCalled = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Text Generation'),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        bloc: _homeBloc,
        builder: (ctx, state) {
          if (state is HomeInitState) {
            return screenWidget(state.prompt, state.completion);
          } else if (state is HomeTextGenerationState) {
            return screenWidget(state.prompt, state.completion);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget screenWidget(String prompt, String completion) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FlatButton(
            onPressed: () {
              _homeBloc!.add(HomeChangePrompt());
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shuffle,
                  color: Theme.of(context).primaryColor,
                ),
                Text(
                  'SHUFFLE PROMPT TEXT',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
        ),
        FlatButton(
          color: Theme.of(context).primaryColor,
          onPressed: () {
            _homeBloc!.add(HomeTextGenerationEvent());
          },
          child: Text(
            'TRIGGER AUTOCOMPLETE',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 10,
            left: 16.0,
            right: 16.0,
          ),
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                text: '$prompt ',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: completion,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ]),
          ),
        ),
      ],
      mainAxisSize: MainAxisSize.max,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
