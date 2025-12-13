import 'package:auth_company/features/home/home_layout.dart';
import 'package:auth_company/features/home/views/home_screen.dart';
import 'package:auth_company/features/user/views/user_perfil.dart';
import 'package:auth_company/routes/app_routes.dart';
import 'package:flutter/material.dart';

class NavItem {
  final String label;
  final String iconPath;

  NavItem(this.label, this.iconPath);
}

final List<NavItem> _navItems = [
  NavItem('Home', 'lib/assets/icons/iconHome.png'),
  NavItem('User', 'lib/assets/icons/iconUser.png'),
  NavItem('Capas', 'lib/assets/icons/iconCapas.png'),
];



//esta funcion este widget nos devuelve la pantalla a donde queremos ir
Widget _getScreenWidget(String routeName, String? uid) {
  switch (routeName) {
    case AppRoutes.home:
      return const HomeScreen();
    case AppRoutes.profile:
      // Comprobar que el uid no sea nulo antes de usarlo.
      if (uid == null) {
          return const Center(child: Text('Error: UID de usuario no disponible para el perfil.'));
      }
      // Pasar el argumento requerido 'uid'
      return ProfileScreen(uid: uid);
    // Agrega Capas
    // case AppRoutes.capas:
    //   return const CapasScreen(); 
    default:
      return const HomeScreen(); 
  }
}



//esta lista contiene las rutas de los iconos
final List<String> _navItemsRoutes = [AppRoutes.home,AppRoutes.profile,AppRoutes.capas,];


class AnimatedFloatingFooter extends StatefulWidget {
  final int initialIndex; 
  final String? uid;
  const AnimatedFloatingFooter({super.key, this.initialIndex = 0, this.uid});

  @override
  State<AnimatedFloatingFooter> createState() => _AnimatedFloatingFooterState();
}




class _AnimatedFloatingFooterState extends State<AnimatedFloatingFooter> {
  late int _selectedIndex;
  int _tappedIndex = -1;
  
  final Duration _fadeDuration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; 
  }
  

  //funcion sirve para seleccionar un item
  void _onItemTapped(int index) async {
    if (_selectedIndex == index || _tappedIndex != -1) return;

    setState(() {_tappedIndex = index;});

    setState(() {
      _selectedIndex = index;
      _tappedIndex = -1; 
    });

    //rutas de direccion de los 3 iconos 
    final String route = _navItemsRoutes[index];

    // Pasar widget.uid a la función _getScreenWidget
    final Widget destinationScreen = _getScreenWidget(route, widget.uid);

    //aqui no utilizo el Navigator.pushNamed por que necesito meterle una transicion de cmabio de pantallas
    //por lo mimso debo crear el widget manualmente como el siguiente:
    final Widget wrappedScreen = HomeLayout(initialIndex: index,child: destinationScreen,);

    //aqui navego con una transicion Fade de 300 milisegundos y llamao a la pantalla wrappedScreen que es el HomeLayout
    //pero dentro del HomeLayout la pantalla a renderizar es destinationScreen y esta variable guarda HomeScreen() o ProfileScreen() etc..
    await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300), 
        pageBuilder: (context, animation, secondaryAnimation) => wrappedScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {return FadeTransition(opacity: animation,child: child,);
        },
      ),
    );
    
  }



  Widget _buildNavItem(int index, double iconSize, double iconAreaWidth, double width) {
    final NavItem item = _navItems[index];
    final bool isSelected = _selectedIndex == index;
    
    final double targetOpacity = _tappedIndex == index ? 0.0 : 1.0;

    final double extraMargin = width * 0.025;

    final Widget leftSpacer = (index == 0) ? SizedBox(width: extraMargin) : const SizedBox.shrink();
    final Widget rightSpacer = (index == 2) ? SizedBox(width: extraMargin) : const SizedBox.shrink();


    return InkWell(
      onTap: () => _onItemTapped(index),

      child: Container(
        width: iconAreaWidth,
        height: iconAreaWidth,
        alignment: Alignment.center,
        child: isSelected
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  leftSpacer, 

                  Container(width: iconSize * 0.8,height: iconSize * 0.8, child: Image.asset(item.iconPath, color: Colors.black, fit: BoxFit.contain),),

                  SizedBox(width: width * 0.012),
                  Text(item.label,style: TextStyle(color: Colors.black,fontSize: iconSize * 0.5,fontWeight: FontWeight.w600,),),

                  SizedBox(width: width * 0.008),
                  Container(width: width * 0.018, height: width * 0.018,decoration: const BoxDecoration(color: Colors.green,shape: BoxShape.circle,),),

                  rightSpacer,
                ],
              )

            : AnimatedOpacity(
                duration: _fadeDuration, 
                curve: Curves.easeInOut, 
                opacity: targetOpacity,
                child: Container( width: iconSize,height: iconSize,child: Image.asset(item.iconPath, color: Colors.white, fit: BoxFit.contain),),
            ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    // Aquí puedes detectar si el teclado está visible.
    // 'viewInsets.bottom' es el espacio ocupado por el teclado.
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    // Si bottomInset > 0, el teclado está visible.
    final bool isKeyboardVisible = bottomInset > 0.0;

    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    // Si el teclado está visible, devuelve un Container vacío o un SizedBox.shrink().
    // Esto oculta el footer. Puedes usar una animación para que la transición sea suave.
    if (isKeyboardVisible) {
      return SizedBox.shrink(); 
      // O si deseas una transición con altura:
      // return AnimatedContainer(
      //   duration: const Duration(milliseconds: 200),
      //   height: 0,
      // );
    }

    

    //tamaño de los iconos y calculos de responsividad//
    final double iconSize = height * 0.028; 
    final double containerHeight = height * 0.065;
    final double navBarWidth = width * 0.62;     //AQUI
    final double pointerHeight = containerHeight * 0.6; 
    final double pointerWidth = navBarWidth * 0.38;   
    final double iconAreaWidth = navBarWidth / _navItems.length;

    final double _POSITION_OFFSET = width * 0.035;

    final double center0 = iconAreaWidth / 2;
    final double center1 = iconAreaWidth * 1.5;
    final double center2 = iconAreaWidth * 2.5;

    final double left0 = center0 - (pointerWidth / 2) + _POSITION_OFFSET; 
    
    final double left1 = center1 - (pointerWidth / 2);
    
    final double left2 = center2 - (pointerWidth / 2) - _POSITION_OFFSET;




    //este seria el movimiento que hace el cuadro blanco calculado dinamicamente y pasado al animate
    final double targetLeft = _selectedIndex == 0 ? left0 : _selectedIndex == 1 ? left1 : left2;

    return Container(
      height: height * 0.15,
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.10, vertical: height * 0.01),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              alignment: Alignment.centerLeft,
              children: [


                //cuadro negro apilado como base
                Container(
                  width: navBarWidth,
                  height: containerHeight,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(height * 0.04),
                    boxShadow: const [BoxShadow(color: Colors.black38,offset: Offset(0, 4),blurRadius: 10,),],
                  ),
                ),


                //cuadro blanco que se mueve segunda base
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300), 
                  curve: Curves.easeInOutQuart,
                  left: targetLeft, 
                  top: (containerHeight - pointerHeight) / 2,
                  width: pointerWidth,
                  height: pointerHeight,
                  child: Container(decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(height * 0.025),),),
                ),




                //ultima base los iconos los 3 iconos incluyendo el texto y circulo verde
                Container(
                  width: navBarWidth,
                  height: containerHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem( 0, iconSize, iconAreaWidth, width),
                      _buildNavItem( 1, iconSize, iconAreaWidth, width),
                      _buildNavItem( 2, iconSize, iconAreaWidth, width),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: width * 0.03),


            //circulo negro con icono de camara
            Container(
              width: containerHeight, 
              height: containerHeight,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(color: Colors.black38,offset: Offset(0, 4),blurRadius: 10,),],
              ),
              child: Center(
                child: Container(
                  width: iconSize * 0.9, 
                  height: iconSize * 0.9,
                  child: Image.asset('lib/assets/icons/iconCapture.png',color: Colors.white,fit: BoxFit.contain,),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}