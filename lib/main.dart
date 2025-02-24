import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Maze Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MazePage(title: 'Maze Game'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CompletionPage extends StatelessWidget {
  const CompletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            for (int i = 0; i < 50; i++)
              Positioned(
                left: Random().nextDouble() * MediaQuery.of(context).size.width,
                top: Random().nextDouble() * MediaQuery.of(context).size.height,
                child: const Icon(Icons.star, color: Colors.yellow, size: 10),
              ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'You Won!',
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const MazePage(title: 'Flutter Maze Game'),
                        ),
                      );
                    },
                    child: const Text('Restart'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}

class MazePage extends StatefulWidget {
  const MazePage({super.key, required this.title});
  final String title;

  @override
  State<MazePage> createState() => _MazePageState();
}

class _MazePageState extends State<MazePage> {
  bool gameFinished = false;
  List<String> maze = [
    "###################",
    "#S          ###   #",
    "# ######### # # ###",
    "#       # #   #   #",
    "##### # # ####### #",
    "#     #           #",
    "# ##### ######### #",
    "#   #   #       # #",
    "# ### ### ##### # #",
    "# #           # # #",
    "# ########### #####",
    "#           #    F#",
    "###################",
  ];
  List<int> playerPosition = [1, 1];

  int _seconds = 20;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _audioPlayer2 = AudioPlayer();

  @override
  void initState() {
    super.initState();
    startTimer();
    _playBackGroundMusic('bgm2.mp3');
  }

  Future<void> _playBackGroundMusic(String soundName) async {
    _audioPlayer.setVolume(0.2);
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource(soundName));
  }

  Future<void> _playSoundEffect(String soundName) async {
    _audioPlayer2.setVolume(0.3);
    await _audioPlayer2.play(AssetSource(soundName));
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds--;
      });
      if (_seconds == 0) {
        _playSoundEffect('bomb.mp3');
        gameOver();
        _timer?.cancel();
      }
    });
  }

  void resetTimer() {
    _seconds = 20;
    _timer?.cancel();
    startTimer();
  }

  void resetPlayer() {
    resetTimer();
    playerPosition = [1, 1];
    setState(() {});
  }

  void resetPlayerWithoutTimer() {
    playerPosition = [1, 1];
    setState(() {});
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: const Text('You have reached the end of the maze!'),
          actions: <Widget>[
            TextButton(
              child: const Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  gameFinished = false;
                  resetPlayerWithoutTimer();
                  resetTimer();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void gameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over!'),
          content: const Text('Time is up!'),
          actions: <Widget>[
            TextButton(
              child: const Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  gameFinished = false;
                  resetPlayer();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void movePlayer(int dx, int dy) {
    int newRow = playerPosition[0] + dy;
    int newCol = playerPosition[1] + dx;
    if (maze[newRow][newCol] != '#') {
      playerPosition = [newRow, newCol];
      setState(() {});
      if (maze[newRow][newCol] == 'F') {
        _playSoundEffect('finish.wav');
        _showWinDialog();
        setState(() => gameFinished = true);
        _timer?.cancel();
      }
    }
  }

  Widget directionButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(4),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.stop(); // 停止背景音乐
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (gameFinished) {
      return const CompletionPage();
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Text('$_seconds'),
      ),
      body: Center(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/background.png', fit: BoxFit.cover),
            ),
            Positioned(
              top: 40,
              left: 20,
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 5,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < maze.length; i++)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int j = 0; j < maze[i].length; j++)
                          Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color:
                                  (i == playerPosition[0] &&
                                          j == playerPosition[1])
                                      ? Colors.blue
                                      : (maze[i][j] == '#'
                                          ? Colors.black
                                          : (maze[i][j] == 'F'
                                              ? Colors.red
                                              : Colors.white)),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  directionButton(Icons.arrow_upward, () => movePlayer(0, -1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      directionButton(
                        Icons.arrow_back,
                        () => movePlayer(-1, 0),
                      ),
                      const SizedBox(width: 80),
                      directionButton(
                        Icons.arrow_forward,
                        () => movePlayer(1, 0),
                      ),
                    ],
                  ),
                  directionButton(Icons.arrow_downward, () => movePlayer(0, 1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
