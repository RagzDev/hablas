import 'package:Hablas/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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

  int _currentIndex = 0;
  PageController _pageController;

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
    _pageController = PageController();
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
    _pageController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
              body: SizedBox.expand(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  children: <Widget>[
                    Scaffold(
                      appBar: AppBar(
                        title: Text('Text To Speech'),
                        centerTitle: true,
                        backgroundColor: Colors.orange,
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return MyApp();
                            }));
                          },
                        ),
                        //                                                                 leading: IconButton(
                        //   icon: Icon(Icons.arrow_back),
                        //   onPressed: () {
                        // Navigator.push(context,
                        //                 MaterialPageRoute(
                        //               builder: (context) {
                        //                 return MyApp();
                        //               }
                        //   }
                        // ),
                      ),
                      floatingActionButton: _buildButtonColumn(
                          Colors.red, Colors.redAccent, Icons.mic, '', _speak),
                      floatingActionButtonLocation:
                          FloatingActionButtonLocation.centerFloat,
                      body: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(children: [
                            _inputSection(),
                            // _btnSection(),
                            SizedBox(
                              height: 50,
                            ),
                          ])),
                    ),
                    SpeechScreen(),
                    Scaffold(
                        appBar: AppBar(
                          title: Text('Settings'),
                          centerTitle: true,
                          backgroundColor: Colors.orange,
                        ),
                        backgroundColor: Colors.white,
                        body: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Container(
                              margin: EdgeInsets.only(top: 55),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(50.0),
                                      bottomRight: Radius.circular(50.0),
                                      bottomLeft: Radius.circular(50.0),
                                      topRight: Radius.circular(50.0))),
                              child: Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'Settings',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 40.0,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 45,
                                    ),
                                    Text('Change Language',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20.0,
                                            color: Colors.black)),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                        'The format is language-country, so for example, English US would be en-US.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 18.0,
                                            color: Colors.black)),
                                    _futureBuilder(),
                                    Visibility(
                                      visible: isAndroid,
                                      child: Text(
                                        "Is Selected Language Installed: $isCurrentLanguageInstalled",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20.0),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    _buildSliders(),
                                  ],
                                ),
                              )),
                        )),
                  ],
                ),
              ),
              bottomNavigationBar: BottomNavyBar(
                selectedIndex: _currentIndex,
                onItemSelected: (index) {
                  setState(() => _currentIndex = index);
                  _pageController.jumpToPage(index);
                },
                items: <BottomNavyBarItem>[
                  BottomNavyBarItem(
                      title: Text('Text'),
                      icon: Icon(Icons.text_fields),
                      activeColor: Colors.blue,
                      inactiveColor: Colors.orange),
                  BottomNavyBarItem(
                    title: Text('Speech'),
                    icon: Icon(Icons.mic),
                    activeColor: Colors.blue,
                    inactiveColor: Colors.orange,
                  ),
                  BottomNavyBarItem(
                    title: Text('Settings'),
                    icon: Icon(Icons.settings),
                    activeColor: Colors.blue,
                    inactiveColor: Colors.orange,
                  )
                ],
              ),
            )));
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
          hintText: 'Type to Dictate!',
          hintStyle: TextStyle(fontSize: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ));

  Widget _btnSection() {
    if (isAndroid) {
      return Container(
          padding: EdgeInsets.only(top: 50.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildButtonColumn(
                Colors.red, Colors.redAccent, Icons.mic, ' ', _speak),
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
                color: Colors.black)),
        _volume(),
        Text(
          'Pitch',
          style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 20.0,
              color: Colors.black),
        ),
        _pitch(),
        Text('Speed/Rate',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 20.0,
              color: Colors.black,
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

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  final Map<String, HighlightedWord> _highlights = {
    'Hablas': HighlightedWord(
      onTap: () => print('voice'),
      textStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
  };

  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech To Text'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Colors.red,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: RawMaterialButton(
            onPressed: _listen,
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              size: 32,
              color: Colors.white,
            ),
            fillColor: Colors.red,
            elevation: 2.0,
            padding: EdgeInsets.all(15.0),
            shape: CircleBorder(),
            constraints: BoxConstraints.tight(Size(64, 64)),
            splashColor: Colors.red),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
            padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  'AI Confidence Level: ${(_confidence * 100.0).toStringAsFixed(1)}%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                TextHighlight(
                  text: _text,
                  words: _highlights,
                  textAlign: TextAlign.center,
                  textStyle: const TextStyle(
                      fontSize: 32.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w400),
                ),
              ],
            )),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
}
