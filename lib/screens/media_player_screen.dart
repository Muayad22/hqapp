import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:hqapp/services/firestore_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:hqapp/localization/app_localizations.dart';


class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key, required this.value,required this.url, required this.name});
  final Barcode? value;
  final String url;
  final String name;
  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late BetterPlayerController _controller;

  @override
  void initState() {
    _controller = BetterPlayerController(
        BetterPlayerConfiguration(
      autoPlay: true,
    ),
      betterPlayerDataSource: BetterPlayerDataSource(
          BetterPlayerDataSourceType.network, widget.url
      )

    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          l.t('video_player'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF6B4423),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.name.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20
            ),
          ),
          SizedBox(height: 50,),
          AspectRatio(
            aspectRatio: 16/9,
            child: BetterPlayer(controller: _controller),
          ),
          SizedBox(height: 90,),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

}

//--------------Audio Player Screen---------------

class AudioPlayerScreen extends StatefulWidget{
  const AudioPlayerScreen({super.key, required this.value, required this.url, required this.name});
  final Barcode? value;
  final String url;
  final String name;
  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> with WidgetsBindingObserver {
  final _player = AudioPlayer();
  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsFlutterBinding.ensureInitialized();
    _setupAudioPlayer();
  }
  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _player.stop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _player.stop(); // Stop audio when app is minimized or closed
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          l.t('audio_player'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF6B4423),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0
              ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(widget.name.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                  ),
                ),
                SizedBox(height: 40,),
                _progressBar(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  _playbackControlButton(),
                ],),
                SizedBox(height: 40,),
              ],
            ),
          )
      ),
    );
  }

  Future<void> _setupAudioPlayer() async{
    _player.playbackEventStream.listen((event) {},onError: (Object e, StackTrace stacktrace) {
      print("A stream error occurred: $e");
    });
    try {
      _player.setAudioSource(AudioSource.uri(Uri.parse(widget.url)));
    }catch(e){
      print("Error loading audio source: $e");
    }
  }

  Widget _progressBar(){
    return StreamBuilder<Duration>(
        stream: _player.positionStream,
        builder: (context, snapshot) {
          return ProgressBar(
            progressBarColor: Color(0xFF81512D),
            baseBarColor: Color(0xFF6B4423).withOpacity(0.24),
            bufferedBarColor: Color(0xFF6B4423).withOpacity(0.24),
            thumbColor: Color(0xFF82522D),
            progress: snapshot.data ?? Duration.zero,
            total: _player.duration ?? Duration.zero,
            onSeek: (duration){
              _player.seek(duration);
            },
            buffered: _player.bufferedPosition,
          );
        }
    );
  }


  Widget _playbackControlButton(){
    return StreamBuilder<PlayerState>(
        stream: _player.playerStateStream,
        builder: (context, snapshot) {
          final processingState = snapshot.data?.processingState;
          final playing = snapshot.data?.playing;
          if (processingState == ProcessingState.loading ||
              processingState == ProcessingState.buffering){
            return Container(
              margin: const EdgeInsets.all(8.0),
              width: 64,
              height: 64,
              child: const CircularProgressIndicator(),
            );
          } else if (playing != true){
            return IconButton(
              onPressed: _player.play,
              icon: const Icon(Icons.play_arrow),
              iconSize: 64,
            );
          } else if (processingState != ProcessingState.completed) {
            return IconButton(
              onPressed: _player.pause,
              icon: const Icon(Icons.pause),
              iconSize: 64,
            );
          }else {
            return IconButton(
              onPressed: () => _player.seek(Duration.zero),
              icon: const Icon(Icons.replay),
              iconSize: 64,
            );
          }
        }
    );
  }

}
