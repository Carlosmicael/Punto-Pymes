import 'package:flutter/material.dart';

class ActionsSection extends StatelessWidget {
  final int currentPage;
  final double width;
  final double height;
  final bool isFinished;
  final Function() onNextPage;
  final Function() onPreviousPage;

  const ActionsSection({
    super.key,
    required this.currentPage,
    required this.width,
    required this.height,
    required this.isFinished,
    required this.onNextPage,
    required this.onPreviousPage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height * 0.025,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedOpacity(
            opacity: isFinished ? 0.0 : 1.0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: Row(
              children: [
                if (currentPage > 0 && currentPage < 4)
                  SizedBox(
                    width: width * 0.40,
                    height: height * 0.045,
                    child: TextButton(
                      onPressed: onPreviousPage,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black87,
                        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_back, color: Color.fromARGB(255, 255, 255, 255)),
                          SizedBox(width: width * 0.015),
                          Text(
                            "Anterior",
                            style: TextStyle(
                              fontSize: width * 0.04, 
                              color: const Color.fromARGB(221, 255, 255, 255)
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(width: width * 0.40),

                SizedBox(width: width * 0.02),
                SizedBox(
                  width: width * 0.40,
                  height: height * 0.045,
                  child: ElevatedButton(
                    onPressed: onNextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentPage < 4 ? "Siguiente" : "Finalizar", 
                          style: TextStyle(fontSize: width * 0.04),
                        ),
                        SizedBox(width: width * 0.015),
                        const Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
