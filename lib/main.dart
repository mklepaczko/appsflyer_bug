import 'dart:async';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';

import 'package:flutter/material.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';

void main() async {

  AppsFlyerUtils().initAppsFlyer();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FlutterWebFrame(
      builder: (context) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // TRY THIS: Try running your application with "flutter run". You'll see
            // the application has a blue toolbar. Then, without quitting the app,
            // try changing the seedColor in the colorScheme below to Colors.green
            // and then invoke "hot reload" (save your changes or press the "hot
            // reload" button in a Flutter-supported IDE, or press "r" if you used
            // the command line to start the app).
            //
            // Notice that the counter didn't reset back to zero; the application
            // state is not lost during the reload. To reset the state, use hot
            // restart instead.
            //
            // This works for code too, not just values: Most code changes can be
            // tested with just a hot reload.
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'Flutter Demo Home Page'),
        );
      },
      maximumSize: const Size(800, 800),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    AppsFlyerUtils().generateLink(source: LinkSource.post, id: '1234');
  }



  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    debugPrint('Screen is of $height height and $width width');
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

enum LinkSource { post, publisher }

class AppsFlyerConsts {
  static const String oneLinkId = 'X55i';
  static const String devKey = '';
  static const String appId = '6504837429';
  static const String channel = 'user_share';
  static const String brandDomain = 'pukpuk.onelink.me';
  static const String postShare = 'post_share';
  static const String publisherShare = 'publisher_share';
}

class AppsFlyerUtils {
  AppsflyerSdk appsflyerSdk = AppsflyerSdk(appsFlyerOptions);

  Future initAppsFlyer() async {
    await _initAppsFlyer();
    onDeepLinking();
    appsflyerSdk.startSDK();
  }

  Future _initAppsFlyer() async {
    await appsflyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );
  }

  static AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
    afDevKey: AppsFlyerConsts.devKey,
    appId: AppsFlyerConsts.appId,
    showDebug: false,
    timeToWaitForATTUserAuthorization: 50, // for iOS 14.5
    appInviteOneLink: AppsFlyerConsts.oneLinkId, // Optional field
    disableAdvertisingIdentifier: false, // Optional field
    disableCollectASA: false, //Optional field
    manualStart: true,
  ); // Optional field

  Future<String?> generateLink({
    required LinkSource source,
    required String id,
  }) async {


    // Create a Completer
    Completer<String?> completer = Completer<String?>();

    appsflyerSdk.generateInviteLink(
      AppsFlyerInviteLinkParams(
        brandDomain: AppsFlyerConsts.brandDomain,
        channel: AppsFlyerConsts.channel,
      ),
      (result) {
        debugPrint('generateInviteLink callback: $result');
        String userInviteURL = result['payload']['userInviteURL'];
        debugPrint('generateInviteLink userInviteURL: $userInviteURL');

        // Complete the Future with the userInviteURL
        completer.complete(userInviteURL);
      },
      (error) {
        debugPrint('generateInviteLink error: $error');

        // Complete the Future with null in case of an error
        completer.complete(null);
      },
    );

    // Await the Future completion
    return completer.future;
  }

  onDeepLinking() {
    appsflyerSdk.onDeepLinking((DeepLinkResult dp) {
      switch (dp.status) {
        case Status.FOUND:
          debugPrint(dp.deepLink?.toString());
          _ClickEvent link = _ClickEvent((dp.deepLink?.clickEvent));
          String? deepLinkValue = link.deepLinkValue;
          String? id = link.deepLinkSub1;
          debugPrint("deep link value: $deepLinkValue id: $id");
          if (deepLinkValue != null && id != null) {
          }
          break;
        case Status.NOT_FOUND:
          debugPrint("deep link not found");
          break;
        case Status.ERROR:
          debugPrint("deep link error: ${dp.error}");
          break;
        case Status.PARSE_ERROR:
          debugPrint("deep link status parsing error");
          break;
      }
    });
  }


}

class _ClickEvent {
  final Map<String, dynamic>? data;
  _ClickEvent(this.data);

  String? get deepLinkValue => data?['deep_link_value'];
  String? get deepLinkSub1 => data?['deep_link_sub1'];
}

class NavigationService {
  String? _postId;
  String? _publisherId;

  set postRedirect(String postId) {
    _postId = postId;
  }

  set publisherRedirect(String publisher) {
    _publisherId = publisher;
  }

  void reset() {
    _postId = null;
    _publisherId = null;
  }

  String? get postId => _postId;
  String? get publisherId => _publisherId;
}

