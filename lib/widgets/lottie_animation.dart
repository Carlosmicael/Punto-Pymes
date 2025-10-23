
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieAnimationWidget extends StatelessWidget {
  final String animationPath;
  final bool repeat;

  const LottieAnimationWidget({
    super.key,
    required this.animationPath,
    this.repeat = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final animationWidth = screenWidth * 0.6;
    final animationHeight = screenHeight * 0.4;

    return SizedBox(
      width: animationWidth,
      height: animationHeight,
      child: Lottie.asset(
        animationPath,
        repeat: repeat,
        fit: BoxFit.contain,
      ),
    );
  }
}



/*import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String url;       
  final bool isAsset;     
  final bool loop;        
  final bool autoPlay;    

  const VideoPlayerWidget({
    super.key,
    required this.url,
    this.isAsset = false,
    this.loop = true,
    this.autoPlay = true,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    _controller = widget.isAsset
        ? VideoPlayerController.asset(widget.url)
        : VideoPlayerController.networkUrl(Uri.parse(widget.url));

    _controller.setLooping(widget.loop);
    _controller.initialize().then((_) {
      setState(() => _isInitialized = true);
      if (widget.autoPlay) _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return _isInitialized
      ? Center(
          child: Container(
            width: screenWidth,     // ocupa todo el ancho
            height: screenHeight,   // ocupa todo el alto disponible
            decoration: const BoxDecoration(color: Colors.black),
            child: FittedBox(
              fit: BoxFit.contain,  // puedes usar cover, contain, fill, según necesites
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(_controller),
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      padding: const EdgeInsets.only(bottom: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      : const Center(child: CircularProgressIndicator());
}

}
*/





