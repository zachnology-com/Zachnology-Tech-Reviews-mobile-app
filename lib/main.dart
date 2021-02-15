import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'dart:async';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_settings/app_settings.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'sign_in.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:google_sign_in/google_sign_in.dart';
import "package:firebase_auth_oauth/firebase_auth_oauth.dart";
import 'package:firebase_core/firebase_core.dart' show Firebase;

bool boolValue;
bool _userLoggedIn;
String firstName;
String welcometext = "Hey there!";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // boolValue = prefs.getBool('userLoggedInSP');
  // if (boolValue == true) {
  //   firstName = prefs.getString('firstNameSP');
  //   _userLoggedIn = true;
  // }
  // if (boolValue != true) {
  //   firstName = prefs.getString('firstNameSP');
  //   _userLoggedIn = false;
  // }
  // print(_userLoggedIn);
  // print(firstName);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Color(0xff757575),
  ));

  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
        // Define the default brightness and colors.
        primaryColor: Color(0xff24527A),
        accentColor: Color(0xff4BBFD4),

        // Define the default font family.
        fontFamily: 'ZachnologyEuclid',

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      )));
}

class SlideRightRoute extends PageRouteBuilder {
  final Widget page;
  SlideRightRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    Firebase.initializeApp();
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  void _changeText() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      int firstSpace = name.indexOf(" "); // detect the first space character
      firstName = name.substring(
          0, firstSpace); // get everything upto the first space character
      String lastName = name.substring(firstSpace).trim();
      welcometext = "Hey, $firstName!";
      _userLoggedIn = true;
    });
  }

  @override
  QuickActions quickActions = QuickActions();
  void initState() {
    super.initState();
    _navigate(Widget screen) async {
      await Permission.microphone.request();
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    }

    quickActions.initialize((String shortcutType) {
      switch (shortcutType) {
        case 'voicemessage':
          return _navigate(MyWebView());
        default:
          return MaterialPageRoute(builder: (_) {
            return Scaffold(
              body: Center(
                child: Text('No Page defined for $shortcutType'),
              ),
            );
          });
      }
    });
    quickActions.setShortcutItems(<ShortcutItem>[
      ShortcutItem(
        type: 'voicemessage',
        icon: 'ic_shortcut_mic',
        localizedTitle: 'Voice Message',
      ),
      ShortcutItem(
        type: 'latestepisode',
        icon: 'ic_shortcut_headset',
        localizedTitle: 'Latest Episode',
      ),
    ]);
  }

  int _currentIndex = 0;
  final List<Widget> _children = [
    HomeWidget(),
    ListenWidget(),
    AboutWidget(),
    SettingsWidget(),
  ];

  final iconList = <IconData>[
    EvaIcons.homeOutline,
    EvaIcons.volumeUpOutline,
    EvaIcons.personOutline,
    EvaIcons.settings2Outline,
  ];

  _launchURL() async {
    const url = 'https://flutter.dev';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _children[_currentIndex], // new

      floatingActionButton: FloatingActionButton(
        child: Icon(CupertinoIcons.mic_solid, color: Colors.white),
        onPressed: () async {
          Firebase.initializeApp();
          Navigator.push(context, EnterExitRoute(enterPage: MyWebView()));
        },
        splashColor: Color(0xff24527A),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _currentIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        backgroundColor: Color(0xff757575),
        leftCornerRadius: 25,
        rightCornerRadius: 25,
        height: 70,
        onTap: (index) => setState(() => _currentIndex = index),
        activeColor: Colors.white,
        inactiveColor: Color(0xffc9c9c9),
        splashColor: Colors.white,
        //other params
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}

class OpenUrlExample extends StatelessWidget {
  const OpenUrlExample({Key key}) : super(key: key);

  _launchURL() async {
    const url = 'https://flutter.dev';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class MyWebView extends StatefulWidget {
  @override
  _MyWebViewState createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  InAppWebViewController _webViewController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            EvaIcons.close,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        elevation: 20.0,
        shadowColor: Color(0xff44bfd4),
        title: Text(
          "Voice Message",
          style: TextStyle(
            fontFamily: "ZachnologyEuclid",
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xff44bfd4),
        brightness: Brightness.dark,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () {
                final RenderBox box = context.findRenderObject();
                Share.share(
                    "Hey, you should check out this awesome podcast called Zachnology Tech Reviews at https://tech-reviews.zachnology.com!",
                    subject: "Awesome podcast!",
                    sharePositionOrigin:
                        box.localToGlobal(Offset.zero) & box.size);
              },
              child: Container(
                width: 50,
                child: Icon(
                  EvaIcons.shareOutline,
                  color: Colors.white,
                  size: 26.0,
                ),
              ),
            ),
          ),
        ],
      ),
      body: InAppWebView(
          initialUrl: "https://form.jotform.com/210047329927053",
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              mediaPlaybackRequiresUserGesture: false,
              debuggingEnabled: true,
            ),
          ),
          onWebViewCreated: (InAppWebViewController controller) {
            _webViewController = controller;
          },
          androidOnPermissionRequest: (InAppWebViewController controller,
              String origin, List<String> resources) async {
            return PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT);
          }),
    );
  }
}

class EnterExitRoute extends PageRouteBuilder {
  final Widget enterPage;
  final Widget exitPage;
  EnterExitRoute({this.exitPage, this.enterPage})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              enterPage,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              Stack(
            children: <Widget>[
              SlideTransition(
                position: new Tween<Offset>(
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(-1.0, 0.0),
                ).animate(animation),
                child: exitPage,
              ),
              SlideTransition(
                position: new Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: enterPage,
              )
            ],
          ),
        );
}

class MyInAppBrowser extends InAppBrowser {
  @override
  Future onLoadStart(String url) async {
    print("\n\nStarted $url\n\n");
  }

  @override
  Future onLoadStop(String url) async {
    print("\n\nStopped $url\n\n");
  }

  @override
  void onLoadError(String url, int code, String message) {
    print("\n\nCan't load $url.. Error: $message\n\n");
  }

  @override
  void onExit() {
    print("\n\nBrowser closed!\n\n");
  }
}

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  MyChromeSafariBrowser(browserFallback) : super(bFallback: browserFallback);

  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad() {
    print("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() {
    print("ChromeSafari browser closed");
  }
}

Future<Post> fetchPost() async {
  final response = await http.get(
      'https://zachnologytechreviews173012.web.app/app-resources/latest-episode-data.json');

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    return Post.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

Future<void> performLogin(String provider, List<String> scopes,
    Map<String, String> parameters) async {
  try {
    await FirebaseAuthOAuth().openSignInFlow(provider, scopes, parameters);
  } on PlatformException catch (error) {
    /**
     * The plugin has the following error codes:
     * 1. FirebaseAuthError: FirebaseAuth related error
     * 2. PlatformError: An platform related error
     * 3. PluginError: An error from this plugin
     */
    debugPrint("${error.code}: ${error.message}");
  }
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  Post({this.userId, this.id, this.title, this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  _launchURL() async {
    const url = 'https://flutter.dev';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _changeTextGoogle() async {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      int firstSpace = name.indexOf(" "); // detect the first space character
      firstName = name.substring(
          0, firstSpace); // get everything upto the first space character
      String lastName = name.substring(firstSpace).trim();
      welcometext = "Hey, $firstName!";
      _userLoggedIn = true;
      print(firstName);
    });
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setString('firstNameSP', firstName);
    // await prefs.setBool('userLoggedInSP', true);
  }

  Future<void> _changeTextTwitter() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setString('firstNameSP', null);
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      firstName = null;
      int firstSpace =
          twitterName.indexOf(" "); // detect the first space character
      firstName = twitterName.substring(
          0, firstSpace); // get everything upto the first space character
      String lastName = twitterName.substring(firstSpace).trim();
      welcometext = "Hey, $firstName!";
      _userLoggedIn = true;
    });
    // await prefs.setString('firstNameSP', firstName);
    // await prefs.setBool('userLoggedInSP', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 325,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0xff2e6a9e).withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                borderRadius: new BorderRadius.only(
                    bottomLeft: const Radius.circular(30.0),
                    bottomRight: const Radius.circular(30.0)),
                color: Color(0xff24527A),
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 70),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          child: Image.asset(
                        'assets/logo-transparent-inverted.png',
                        width: 70,
                      )),
                      SizedBox(width: 30),
                      Column(
                        children: <Widget>[
                          Container(
                            child: Column(
                              children: <Widget>[
                                if (_userLoggedIn != true) ...[
                                  Text(
                                    "Hey there!",
                                    style: TextStyle(
                                      fontFamily: "ZachnologyEuclid",
                                      letterSpacing: -1,
                                      fontSize: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                                if (_userLoggedIn == true) ...[
                                  Text(
                                    "Hey, $firstName",
                                    style: TextStyle(
                                      fontFamily: "ZachnologyEuclid",
                                      letterSpacing: -1,
                                      fontSize: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            child: Text(
                              "Welcome back",
                              style: TextStyle(
                                fontFamily: "Bungee",
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Latest episode:",
                          style: TextStyle(
                            fontFamily: "ProductSans",
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              transform: Matrix4.translationValues(0.0, -70.0, 0.0),
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(15.0),
              width: 330,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                color: Colors.white,
                border: Border.all(
                  width: 2.0,
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.all(Radius.circular(22.0)),
              ),
              child: InkWell(
                onTap: () {
                  print('hey');
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FutureBuilder<Post>(
                      future: fetchPost(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            snapshot.data.title,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: "Bungee",
                              letterSpacing: 0.5,
                              fontSize: 20,
                              color: Color(0xff24527A),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text("Can't load info, no Internet access");
                        }
                        // By default, show a loading spinner
                        return Text(" ");
                      },
                    ),
                    SizedBox(height: 10),
                    FutureBuilder<Post>(
                      future: fetchPost(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            snapshot.data.body,
                            style: TextStyle(
                              fontFamily: "ProductSans",
                              letterSpacing: 0.5,
                              fontSize: 20,
                              color: Color(0xff24527A),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text("");
                        }
                        // By default, show a loading spinner
                        return Text(" ");
                      },
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: <Widget>[
                if (_userLoggedIn != true) ...[
                  Text(
                    "Please sign in so we can provide the \nbest experience possible:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: Color(0xff24527A),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlatButton(
                        splashColor: Colors.grey.withOpacity(0.5),
                        onPressed: () {
                          signInWithGoogle().then((result) {
                            if (result != null) {
                              _changeTextGoogle();
                            }
                          });
                        },
                        color: Color(0xffDB4437),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image(
                                  image: AssetImage(
                                      "assets/white-google-logo.png"),
                                  height: 35.0),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      FlatButton(
                        splashColor: Colors.grey.withOpacity(0.5),
                        onPressed: () {
                          signInWithTwitter().then((result) {
                            if (result != null) {
                              _changeTextTwitter();
                            }
                            if (result == null) {
                              _changeTextTwitter();
                            }
                          });
                        },
                        color: Color(0xff1DA1F2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image(
                                  image: AssetImage(
                                      "assets/Twitter_logo_white.png"),
                                  height: 35.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (_userLoggedIn == true) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        transform: Matrix4.translationValues(0.0, -50.0, 0.0),
                        child: Text(
                          "Recommended for $firstName:",
                          style: TextStyle(
                            fontFamily: "ProductSans",
                            fontWeight: FontWeight.bold,
                            color: Color(0xff24527A),
                            letterSpacing: 0.5,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(15.0),
                        padding: const EdgeInsets.all(15.0),
                        transform: Matrix4.translationValues(0.0, -50.0, 0.0),
                        width: 150,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                          color: Colors.white,
                          border: Border.all(
                            width: 2.0,
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(22.0)),
                        ),
                        child: InkWell(
                          onTap: () {
                            print('hey');
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              FutureBuilder<Post>(
                                future: fetchPost(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      snapshot.data.title,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: "Bungee",
                                        letterSpacing: 0.5,
                                        fontSize: 17,
                                        color: Color(0xff24527A),
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text(
                                        "Can't load info, no Internet access");
                                  }
                                  // By default, show a loading spinner
                                  return Text(" ");
                                },
                              ),
                              SizedBox(height: 10),
                              FutureBuilder<Post>(
                                future: fetchPost(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      snapshot.data.body,
                                      style: TextStyle(
                                        fontFamily: "ProductSans",
                                        letterSpacing: 0.5,
                                        fontSize: 17,
                                        color: Color(0xff24527A),
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text("");
                                  }
                                  // By default, show a loading spinner
                                  return Text(" ");
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(15.0),
                        padding: const EdgeInsets.all(15.0),
                        transform: Matrix4.translationValues(0.0, -50.0, 0.0),
                        width: 150,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                          color: Colors.white,
                          border: Border.all(
                            width: 2.0,
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(22.0)),
                        ),
                        child: InkWell(
                          onTap: () {
                            print('hey');
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              FutureBuilder<Post>(
                                future: fetchPost(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      snapshot.data.title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: "Bungee",
                                        letterSpacing: 0.5,
                                        fontSize: 17,
                                        color: Color(0xff24527A),
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text(
                                        "Can't load info, no Internet access");
                                  }
                                  // By default, show a loading spinner
                                  return Text(" ");
                                },
                              ),
                              SizedBox(height: 10),
                              FutureBuilder<Post>(
                                future: fetchPost(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      snapshot.data.body,
                                      style: TextStyle(
                                        fontFamily: "ProductSans",
                                        letterSpacing: 0.5,
                                        fontSize: 17,
                                        color: Color(0xff24527A),
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text("");
                                  }
                                  // By default, show a loading spinner
                                  return Text(" ");
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ListenWidget extends StatefulWidget {
  final ChromeSafariBrowser browser =
      new MyChromeSafariBrowser(new MyInAppBrowser());

  @override
  _ListenWidgetState createState() => _ListenWidgetState();
}

class _ListenWidgetState extends State<ListenWidget> {
  InAppWebViewController webView;
  String url = "";
  double progress = 0;
  @override
  void initState() {
    widget.browser.addMenuItem(new ChromeSafariBrowserMenuItem(
        id: 1,
        label: 'Custom item menu 1',
        action: (url, title) {
          print('Custom item menu 1 clicked!');
          print(url);
          print(title);
        }));
    widget.browser.addMenuItem(new ChromeSafariBrowserMenuItem(
        id: 2,
        label: 'Custom item menu 2',
        action: (url, title) {
          print('Custom item menu 2 clicked!');
          print(url);
          print(title);
        }));
    super.initState();
  }

  InAppWebViewController _webViewController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        elevation: 20.0,
        centerTitle: true,
        backgroundColor: Color(0xff24527A),
        brightness: Brightness.dark,
        shadowColor: Color(0xff24527a),
        title: Text(
          'Listen to our Podcast',
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () {
                final RenderBox box = context.findRenderObject();
                Share.share(
                    "Hey, you should check out this awesome podcast called Zachnology Tech Reviews at https://tech-reviews.zachnology.com!",
                    subject: "Awesome podcast!",
                    sharePositionOrigin:
                        box.localToGlobal(Offset.zero) & box.size);
              },
              child: Container(
                width: 50,
                child: Icon(
                  EvaIcons.shareOutline,
                  color: Colors.white,
                  size: 26.0,
                ),
              ),
            ),
          ),
        ],
      ),
      body: InAppWebView(
        initialUrl:
            "https://castbox.fm/app/castbox/player/id3160536?v=8.22.11&autoplay=0",
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            supportZoom: false,
            mediaPlaybackRequiresUserGesture: false,
            debuggingEnabled: true,
            transparentBackground: true,
          ),
        ),
      ),
    );
  }
}

class SettingsWidget extends StatefulWidget {
  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  void _changeTextBack() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.

      firstName = null;
      _userLoggedIn = false;
      print(firstName);
      print(_userLoggedIn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        elevation: 20.0,
        shadowColor: Color(0xff24527a),
        title: Text(
          "App Settings/Info",
          style: TextStyle(
            fontFamily: "ZachnologyEuclid",
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xff24527A),
        brightness: Brightness.dark,
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 20),
          Image.asset(
            'assets/fulllogocircle.png',
            height: 120,
          ),
          SizedBox(height: 20),
          Text(
            "Zachnology Tech \nReviews",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "ZachnologyEuclid",
              fontSize: 30,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text('App Settings'),
                color: Colors.white,
                splashColor: Colors.grey,
                onLongPress: (AppSettings.openAppSettings),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: Color(0xff24527A))),
                onPressed: (AppSettings.openAppSettings),
              ),
              SizedBox(width: 10),
              RaisedButton(
                child: Text('Notification Settings'),
                color: Colors.white,
                splashColor: Colors.grey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: Color(0xff24527A))),
                onPressed: (AppSettings.openNotificationSettings),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              if (_userLoggedIn == true) ...[
                OutlineButton(
                  splashColor: Colors.grey,
                  onPressed: () {
                    return showDialog(
                      context: context,
                      builder: (ctx) => CupertinoAlertDialog(
                        title: Text(
                          "Sign out?",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontStyle: FontStyle.normal,
                            fontSize: 25,
                          ),
                        ),
                        content: Text(
                          "Are you sure you want to sign out?",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            onPressed: () async {
                              signOutGoogle();
                              // // SharedPreferences prefs = await SharedPreferences.getInstance();
                              // await prefs.setString('firstNameSP', null);
                              // await prefs.setBool('userLoggedInSP', false);
                              // await prefs.clear();
                              // firstName = null;
                              // print(prefs.getBool('userLoggedInSP'));
                              // print(prefs.getString('firstNameSP'));
                              _changeTextBack();
                              Navigator.of(ctx).pop();
                            },
                            child: Text(
                              "Yes",
                              style: TextStyle(
                                fontFamily: 'ProductSans',
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                          CupertinoDialogAction(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontFamily: 'ProductSans',
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  highlightElevation: 0,
                  borderSide: BorderSide(color: Color(0xff24527A)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            'Sign out',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "ProductSans",
                              color: Color(0xff24527A),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class AboutWidget extends StatelessWidget {
  _launchURL() async {
    const url = 'https://flutter.dev';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () {
                final RenderBox box = context.findRenderObject();
                Share.share(
                    "Hey, you should check out this awesome podcast called Zachnology Tech Reviews at https://tech-reviews.zachnology.com!",
                    subject: "Awesome podcast!",
                    sharePositionOrigin:
                        box.localToGlobal(Offset.zero) & box.size);
              },
              child: Container(
                width: 50,
                child: Icon(
                  EvaIcons.shareOutline,
                  color: Colors.white,
                  size: 26.0,
                ),
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        elevation: 20.0,
        shadowColor: Color(0xff24527a),
        title: Text(
          "Zachnology Tech Reviews",
          style: TextStyle(
            fontFamily: "ZachnologyEuclid",
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xff24527A),
        brightness: Brightness.dark,
      ),
      body: Text("settings"),
    );
  }
}

// child: FutureBuilder<Post>(
//                   future: fetchPost(),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasData) {
//                       return Text(
//                         snapshot.data.title,
//                         style: TextStyle(
//                           fontFamily: "Bungee",
//                           letterSpacing: 0.5,
//                           fontSize: 15,
//                           color: Color(0xff24527A),
//                         ),
//                       );
//                     } else if (snapshot.hasError) {
//                       return Text("error");
//                     }

//                     // By default, show a loading spinner
//                     return CircularProgressIndicator();
//                   },
//                 ),

class DividerWidget extends StatefulWidget {
  DividerWidget({Key key}) : super(key: key);

  @override
  _DividerWidgetState createState() => _DividerWidgetState();
}

class _DividerWidgetState extends State<DividerWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
