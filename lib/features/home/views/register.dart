import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegistroEmpleados extends StatefulWidget {
  const RegistroEmpleados({super.key});

  @override
  State<RegistroEmpleados> createState() => _RegistroState();
}

class _RegistroState extends State<RegistroEmpleados> {
  bool showGradient = false;

  void toggleGradient(bool value) {
    setState(() => showGradient = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: CustomRegisterAppBar(showGradient: showGradient),
      body: RegisterBody(onScroll: toggleGradient),
    );
  }
}

// 🔹 APPBAR SEPARADO

class CustomRegisterAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool showGradient;

  const CustomRegisterAppBar({super.key, required this.showGradient});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    final bottomPadding = height * 0.03;
    final iconSize = width * 0.075;
    final fontSize = width * 0.045;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient:
            showGradient
                ? const LinearGradient(
                  colors: [Color(0xFF370B12), Color(0xFFE41335)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : null,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.only(
              left: width * 0.05, // 5% del ancho
              bottom: bottomPadding, // 🔹 ahora responsivo
            ),
            child: Row(
              children: [
                SizedBox(width: width * 0.08),
                SvgPicture.asset(
                  'lib/assets/images/Registro.svg',
                  width: iconSize,
                  height: iconSize,
                ),
                SizedBox(width: width * 0.04),
                Text(
                  'Registro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    letterSpacing: width * 0.01,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🔹 BODY SEPARADO
class RegisterBody extends StatelessWidget {
  final void Function(bool) onScroll;

  const RegisterBody({super.key, required this.onScroll});

  @override
  Widget build(BuildContext context) {
    final dias = ['L', 'M', 'Mi', 'J', 'V', 'S', 'D'];
    final numeros = ['1', '2', '3', '4', '5', '6', '7'];

    final horarios = [
      {'entrada': '08:00', 'salida': '12:00'},
      {'entrada': '13:00', 'salida': '17:00'},
      {'entrada': '18:00', 'salida': '21:00'},
    ];

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        onScroll(scroll.metrics.pixels > 50);
        return true;
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 🔸 Cabecera con degradado
            ClipPath(
              clipper: _CurvedBottomClipper(),
              child: Container(
                width: width,
                height: height * 0.45,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF370B12), Color(0xFFE41335)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: height * 0.13,
                      right: 0,
                      child: SvgPicture.asset(
                        'lib/assets/images/huella2.svg',
                        width: width * 0.45,
                        height: width * 0.45,
                      ),
                    ),
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: height * 0.08),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children:
                                dias
                                    .map(
                                      (d) => Text(
                                        d,
                                        style: TextStyle(
                                          fontSize: width * 0.04,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                          SizedBox(height: height * 0.01),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children:
                                numeros
                                    .map(
                                      (n) => Text(
                                        n,
                                        style: TextStyle(
                                          fontSize: width * 0.045,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                          SizedBox(height: height * 0.04),
                          Text(
                            'Total de Registros',
                            style: TextStyle(
                              fontSize: width * 0.055,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: height * 0.01),
                          Text(
                            '24',
                            style: TextStyle(
                              fontSize: width * 0.15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔸 Cuerpo inferior
            Padding(
              padding: EdgeInsets.only(
                left: width * 0.07,
                right: width * 0.07,
                top: height * 0,
                bottom: height * 0.02,
              ),
              child: Column(
                children:
                    horarios.map((horario) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: height * 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: height * 0.01),
                            Text(
                              'Registro ${horarios.indexOf(horario) + 1}',
                              style: TextStyle(
                                fontSize: width * 0.05,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: height * 0.02),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(width * 0.04),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromARGB(64, 0, 0, 0),
                                    blurRadius: 20,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                      vertical: height * 0.018,
                                      horizontal: width * 0.03,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            children: [
                                              Text(
                                                'Hora de entrada',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: width * 0.035,
                                                ),
                                              ),
                                              SizedBox(height: height * 0.005),
                                              Text(
                                                horario['entrada']!,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: width * 0.06,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: width * 0.01),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            children: [
                                              Text(
                                                'Hora de salida',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: width * 0.035,
                                                ),
                                              ),
                                              SizedBox(height: height * 0.005),
                                              Text(
                                                horario['salida']!,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: width * 0.06,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Center(
                                            child: SvgPicture.asset(
                                              'lib/assets/images/Dia.svg',
                                              width: width * 0.07,
                                              height: width * 0.07,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: height * 0.02),
                                  Row(
                                    children: [
                                      Text(
                                        'Entrada: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          fontSize: width * 0.035,
                                        ),
                                      ),
                                      Text(
                                        'Registrado',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: width * 0.035,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.01),
                                  Row(
                                    children: [
                                      Text(
                                        'Salida: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          fontSize: width * 0.035,
                                        ),
                                      ),
                                      Text(
                                        'Sin registrar',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: width * 0.035,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.03),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 8,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.06,
                                        vertical: height * 0.018,
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Registrar',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: width * 0.04,
                                          ),
                                        ),
                                        SizedBox(width: width * 0.05),
                                        Container(
                                          width: width * 0.09,
                                          height: width * 0.09,
                                          decoration: const BoxDecoration(
                                            color: Color.fromARGB(
                                              133,
                                              255,
                                              255,
                                              255,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              'lib/assets/images/Siguiente.svg',
                                              width: width * 0.04,
                                              height: width * 0.04,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
            SizedBox(height: height * 0.12),
          ],
        ),
      ),
    );
  }
}

// 🔹 CLIPPER DEL SEMICÍRCULO
class _CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 120);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 40,
      size.width,
      size.height - 120,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
