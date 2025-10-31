import 'package:auth_company/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) setState(() => _showContent = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          child: !_showContent ? Column(
                  key: const ValueKey(1),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('lib/assets/animaciones/Welcome.json',controller: _controller,width: width * 0.6,height: height * 0.35,fit: BoxFit.contain,
                      onLoaded: (composition) => _controller..duration = composition.duration..forward()
                    ),
                  ],
                )
              // Segunda columna (logo + texto + botón)
              : Column(
                  key: const ValueKey(2),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedOpacity(
                    opacity: _showContent ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 700),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('lib/assets/images/logoTalenTrack.png', width: width * 0.25,height: height * 0.12,fit: BoxFit.contain,),
                        SizedBox(height: height * 0.015),
                        Text("TalentTrack",style: TextStyle(fontSize: width * 0.075,fontWeight: FontWeight.bold,color: const Color.fromRGBO(235, 87, 87, 1),letterSpacing: 1.5,),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: height * 0.10),

                  AnimatedOpacity(
                      opacity: _showContent ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 700),
                      child: SizedBox(width: width * 0.75,height: height * 0.08,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(width * 0.30),),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Start',style: TextStyle(fontSize: width * 0.05,color: Colors.white,fontWeight: FontWeight.bold,),),
                              SizedBox(width: width * 0.03),
                              Icon(Icons.double_arrow,color: Colors.white,size: width * 0.06,),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
}
