import 'package:Hablas/ad_state.dart';
import 'package:Hablas/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Hablas extends StatefulWidget {
  @override
  _HablasState createState() => _HablasState();
}

enum TtsState { playing, stopped, paused, continued }

class _HablasState extends State<Hablas> {
  FlutterTts flutterTts;
  String language;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  String _newVoiceText;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWeb => kIsWeb;

  @override
  initState() {
    super.initState();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    if (isAndroid) {
      _getEngines();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    if (isWeb || isIOS) {
      flutterTts.setPauseHandler(() {
        setState(() {
          print("Paused");
          ttsState = TtsState.paused;
        });
      });

      flutterTts.setContinueHandler(() {
        setState(() {
          print("Continued");
          ttsState = TtsState.continued;
        });
      });
    }

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<dynamic> _getLanguages() => flutterTts.getLanguages;

  Future _getEngines() async {
    var engines = await flutterTts.getEngines;
    if (engines != null) {
      for (dynamic engine in engines) {
        print(engine);
      }
    }
  }

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        await flutterTts.awaitSpeakCompletion(true);
        await flutterTts.speak(_newVoiceText);
      }
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      dynamic languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      items.add(
          DropdownMenuItem(value: type as String, child: Text(type as String)));
    }
    return items;
  }

  void changedLanguageDropDownItem(String selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language);
      if (isAndroid) {
        flutterTts
            .isLanguageInstalled(language)
            .then((value) => isCurrentLanguageInstalled = (value as bool));
      }
    });
  }

  void _onChange(String text) {
    setState(() {
      _newVoiceText = text;
    });
  }

  BannerAd banner;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final adState = Provider.of<AdState>(context);
    adState.initialization.then((status) {
      setState(() {
        banner = BannerAd(
          adUnitId: adState.bannerAdUnitId,
          size: AdSize.banner,
          request: AdRequest(),
          listener: adState.adListener,
        )..load();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text('Hablas'),
              centerTitle: true,
              backgroundColor: Colors.orange,
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp()),
                    );
                  }),
            ),
            body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(children: [
                  if (banner == null)
                    SizedBox(
                      height: 50,
                    )
                  else
                    Container(
                      height: 50,
                      child: AdWidget(ad: banner),
                    ),
                  _inputSection(),
                  _btnSection(),
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    height: 380,
                    width: 500,
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50.0),
                            bottomRight: Radius.circular(50.0),
                            bottomLeft: Radius.circular(50.0),
                            topRight: Radius.circular(50.0))),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Text(
                          'Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 40.0,
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Text('Change Language',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 20.0,
                                color: Colors.white)),
                        _futureBuilder(),
                        SizedBox(
                          height: 20,
                        ),
                        _buildSliders()
                      ],
                    ),
                  ),
                ]))));
  }

  Widget _futureBuilder() => FutureBuilder<dynamic>(
      future: _getLanguages(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return _languageDropDownSection(snapshot.data);
        } else if (snapshot.hasError) {
          return Text('Error loading languages...');
        } else
          return Text('Loading Languages...');
      });

  Widget _inputSection() => Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
      child: TextField(
        onChanged: (String value) {
          _onChange(value);
        },
        obscureText: false,
        decoration: InputDecoration(
            border: OutlineInputBorder(), hintText: 'Type to Dictate!'),
      ));

  Widget _btnSection() {
    if (isAndroid) {
      return Container(
          padding: EdgeInsets.only(top: 50.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildButtonColumn(Colors.green, Colors.greenAccent,
                Icons.play_arrow, 'PLAY', _speak),
            _buildButtonColumn(
                Colors.red, Colors.redAccent, Icons.stop, 'STOP', _stop),
          ]));
    } else {
      return Container(
          padding: EdgeInsets.only(top: 50.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildButtonColumn(
                Colors.red, Colors.redAccent, Icons.mic, '', _speak),
          ]));
    }
  }

  Widget _languageDropDownSection(dynamic languages) => Container(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        DropdownButton(
          value: language,
          items: getLanguageDropDownMenuItems(languages),
          onChanged: changedLanguageDropDownItem,
          dropdownColor: Colors.white,
          iconEnabledColor: Colors.white,
          focusColor: Colors.white,
        ),
        Visibility(
          visible: isAndroid,
          child: Text("Is installed: $isCurrentLanguageInstalled"),
        ),
      ]));

  Column _buildButtonColumn(Color color, Color splashColor, IconData icon,
      String label, Function func) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RawMaterialButton(
              elevation: 2.0,
              fillColor: color,
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
              padding: EdgeInsets.all(15.0),
              shape: CircleBorder(),
              constraints: BoxConstraints.tight(Size(64, 64)),
              splashColor: splashColor,
              onPressed: () => func()),
          Container(
              margin: const EdgeInsets.only(top: 8.0),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: color)))
        ]);
  }

  Widget _buildSliders() {
    return Column(
      children: [
        Text('Volume',
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 20.0,
                color: Colors.white)),
        _volume(),
        Text(
          'Pitch',
          style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 20.0,
              color: Colors.white),
        ),
        _pitch(),
        Text('Rate',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 20.0,
              color: Colors.white,
            )),
        _rate()
      ],
    );
  }

  Widget _volume() {
    return Slider(
        value: volume,
        onChanged: (newVolume) {
          setState(() => volume = newVolume);
        },
        min: 0.0,
        max: 1.0,
        divisions: 10,
        label: "Volume: $volume");
  }

  Widget _pitch() {
    return Slider(
      value: pitch,
      onChanged: (newPitch) {
        setState(() => pitch = newPitch);
      },
      min: 0.5,
      max: 2.0,
      divisions: 15,
      label: "Pitch: $pitch",
      activeColor: Colors.red,
    );
  }

  Widget _rate() {
    return Slider(
      value: rate,
      onChanged: (newRate) {
        setState(() => rate = newRate);
      },
      min: 0.0,
      max: 1.0,
      divisions: 10,
      label: "Rate: $rate",
      activeColor: Colors.green,
    );
  }
}

// class TTS extends StatefulWidget {
//   @override
//   _TTSState createState() => _TTSState();
// }

// class _TTSState extends State {
//   bool isPlaying = false;
//   FlutterTts _flutterTts;
//   final textController = TextEditingController();
//   BannerAd banner;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final adState = Provider.of<AdState>(context);
//     adState.initialization.then((status) {
//       setState(() {
//         banner = BannerAd(
//           adUnitId: adState.bannerAdUnitId,
//           size: AdSize.banner,
//           request: AdRequest(),
//           listener: adState.adListener,
//         )..load();
//       });
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     initializeTts();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: Builder(
//       builder: (BuildContext context) {
//         return DefaultTabController(
//           length: 2,
//           child: Scaffold(
//             appBar: AppBar(
//               centerTitle: true,
//               title: Text('Hablas'),
//               backgroundColor: Colors.orange,
//               leading: IconButton(
//                   icon: Icon(Icons.arrow_back),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => MyApp()),
//                     );
//                   }),
//               bottom: TabBar(
//                 tabs: [
//                   Tab(icon: Icon(Icons.mic)),
//                   Tab(icon: Icon(Icons.settings)),
//                 ],
//               ),
//             ),
//             body: TabBarView(
//               children: [
//                 Scaffold(
//                     body: Container(
//                   alignment: Alignment.center,
//                   child: Column(
//                     children: <Widget>[
//                       if (banner == null)
//                         SizedBox(
//                           height: 50,
//                         )
//                       else
//                         Container(
//                           height: 50,
//                           child: AdWidget(ad: banner),
//                         ),
//                       Center(
//                           child: Container(
//                         padding: EdgeInsets.all(32),
//                         child: TextField(
//                           controller: textController,
//                           obscureText: false,
//                           decoration: InputDecoration(
//                               border: OutlineInputBorder(),
//                               hintText: 'Type to Dictate!'),
//                         ),
//                       )),
//                       RawMaterialButton(
//                         onPressed: () {
//                           if (isPlaying) {
//                             _stop();
//                           } else {
//                             _speak(textController.text);
//                           }
//                         },
//                         elevation: 2.0,
//                         fillColor: Colors.red,
//                         child: Icon(
//                           Icons.mic,
//                           size: 35.0,
//                           color: Colors.white,
//                         ),
//                         padding: EdgeInsets.all(15.0),
//                         shape: CircleBorder(),
//                       ),
//                       SizedBox(height: 20),
//                     ],
//                   ),
//                 )),

//                 Settings(),
//                 // Column(
//                 //   children: [
//                 //     // Image(
//                 //     //   image: AssetImage('assets/bug.png'),
//                 //     //   height: 350,
//                 //     //   width: 350,
//                 //     // ),
//                 //     // Text(
//                 //     //   'Still in Construction...',
//                 //     //   style:
//                 //     //       TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
//                 //     // ),
//                 //     // Text(
//                 //     //   'Created by Raghav Sarin',
//                 //     //   style: TextStyle(fontSize: 25),
//                 //     // ),
//                 //     // SizedBox(
//                 //     //   height: 50,
//                 //     // )
//                 //   ],
//                 // )
//               ],
//             ),
//           ),
//         );

//         // return
//       },
//     ));
//   }

//   //TEXT TO SPEECH functions

//   initializeTts() {
//     _flutterTts = FlutterTts();

//     _flutterTts.setStartHandler(() {
//       setState(() {
//         isPlaying = true;
//       });
//     });

//     _flutterTts.setCompletionHandler(() {
//       setState(() {
//         isPlaying = false;
//       });
//     });

//     _flutterTts.setErrorHandler((err) {
//       setState(() {
//         print("error occurred: " + err);
//         isPlaying = false;
//       });
//     });
//   }

//   Future _speak(String text) async {
//     if (text != null && text.isNotEmpty) {
//       var result = await _flutterTts.speak(textController.text);
//       if (result == 1)
//         setState(() {
//           isPlaying = true;
//         });
//     }
//     setTtsLanguage();
//     setPitch();
//     setVolume();
//   }

//   Future _stop() async {
//     var result = await _flutterTts.stop();
//     if (result == 1)
//       setState(() {
//         isPlaying = false;
//       });
//   }

//   void setTtsLanguage() async {
//     await _flutterTts.setLanguage("en-GB");
//   }

//   void setPitch() async {
//     await _flutterTts.setPitch(1);
//   }

//   void setVolume() async {
//     await _flutterTts.setVolume(1.0);
//     await _flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback,
//         [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker]);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _flutterTts.stop();
//   }
// }
