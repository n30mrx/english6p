// ignore_for_file: prefer_const_constructors

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          title: 'English for iraq 6th prep.',
          theme: ThemeData(
            colorScheme: lightDynamic,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkDynamic,
            useMaterial3: true,
          ),
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List file = [];
  bool loaded = false;
  bool playing = false;
  String? nowPlaying;
  final assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    _listofFiles();
  }

  void _listofFiles() async {
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    setState(() {
      file = assetManifest
          .listAssets()
          .where((string) => string.startsWith("assets/Track "))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nowPlaying ?? "English for Iraq"),
        actions: [
          IconButton(
            onPressed: () {
              showAboutDialog(
                  context: context,
                  applicationName: "Licenses and info",
                  applicationVersion: "version 1.0",
                  applicationLegalese:
                      """English for Iraq 6th prep. soundtrack
Copyright (C) 2023 Mr. X
This program is free software: 
you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
""",
                  children: [
                    GestureDetector(
                      child: Text(
                        "License",
                        style: TextStyle(
                          fontSize: 20,
                          decoration: TextDecoration.underline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      onTap: () {
                        launchUrlString(
                          "https://www.gnu.org/licenses/gpl-3.0.en.html",
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    )
                  ]);
            },
            icon: Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: file.length,
                itemBuilder: (BuildContext context, int index) {
                  // return Text(file[index].toString());
                  return SizedBox(
                    width: double.infinity,
                    child: Card(
                      shadowColor: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.all(0),
                        child: SizedBox(
                          height: 130,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    nowPlaying == file[index]
                                        ? Icons.music_note_rounded
                                        : Icons.music_note_outlined,
                                    size: 30,
                                  ),
                                  Text(
                                    file[index]
                                        .toString()
                                        .replaceAll("assets/", "")
                                        .replaceAll(".mp3", ""),
                                    style: TextStyle(fontSize: 30),
                                  ),
                                  Expanded(child: SizedBox()),
                                  IconButton(
                                    onPressed: () {
                                      if (playing) {
                                        if (file[index].toString() ==
                                            nowPlaying) {
                                          assetsAudioPlayer.pause();
                                          setState(() {
                                            playing = false;
                                            nowPlaying = file[index].toString();
                                          });
                                        } else {
                                          assetsAudioPlayer.open(
                                              Audio(file[index].toString()));
                                          assetsAudioPlayer.play();
                                          setState(() {
                                            playing = true;
                                            nowPlaying = file[index].toString();
                                          });
                                        }
                                      } else {
                                        if (nowPlaying ==
                                            file[index].toString()) {
                                          assetsAudioPlayer.play();
                                          setState(() {
                                            playing = true;
                                            nowPlaying = file[index].toString();
                                          });
                                        } else {
                                          assetsAudioPlayer.open(
                                              Audio(file[index].toString()));
                                          setState(() {
                                            playing = true;
                                            nowPlaying = file[index].toString();
                                          });
                                        }
                                      }
                                    },
                                    icon: Icon(
                                      nowPlaying == file[index].toString() &&
                                              playing == true
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      size: 50,
                                    ),
                                  ),
                                ],
                              ),
                              Visibility(
                                visible: nowPlaying == file[index].toString(),
                                child: SizedBox(
                                  height: 50,
                                  child: StreamBuilder(
                                      stream: assetsAudioPlayer.currentPosition,
                                      builder: (context, asyncSnapshot) {
                                        final totalTime = assetsAudioPlayer
                                            .current.value!.audio.duration;
                                        if (asyncSnapshot.hasData) {
                                          final Duration duration =
                                              asyncSnapshot.data!;
                                          return ProgressBar(
                                            progress: duration,
                                            total: totalTime,
                                            onDragUpdate: (details) {
                                              assetsAudioPlayer
                                                  .seek(details.timeStamp);
                                            },
                                          );
                                        }
                                        return (ProgressBar(
                                          progress: Duration(seconds: 0),
                                          total: totalTime,
                                        ));
                                      }),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
}
