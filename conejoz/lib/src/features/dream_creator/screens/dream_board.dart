import 'package:conejoz/src/features/dream_creator/screens/dream_audio_entry.dart';
import 'package:conejoz/src/features/dream_creator/screens/dream_image_creator.dart';
import 'package:conejoz/src/features/dream_creator/screens/dream_text_entry.dart';
import 'package:flutter/material.dart';

class DreamBoard extends StatefulWidget {
  const DreamBoard({super.key});

  @override
  State<DreamBoard> createState() => _DreamBoardState();
}

class _DreamBoardState extends State<DreamBoard> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      appBar: AppBar(
        leading: const Icon(Icons.code_rounded),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Conejoz Dashboard"),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          TextEntry(),
          AudioEntry(),
          ImageCreator(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                },
                icon: const Icon(Icons.notes_outlined),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                },
                icon: const Icon(Icons.mic),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 2;
                  });
                },
                icon: const Icon(Icons.donut_large_sharp),
              ),
            ],
          )),
      floatingActionButton:
          const FloatingActionButton(onPressed: null, child: Icon(Icons.save)),
    );
  }
}
