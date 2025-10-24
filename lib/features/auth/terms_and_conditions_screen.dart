import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y Política de Privacidad'),
        backgroundColor: const Color(0xFF398AD5),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'TÉRMINOS Y CONDICIONES DE USO',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Esta aplicación está dirigida a estudiantes con fines educativos y de bienestar emocional. Al utilizar la aplicación, usted acepta los siguientes términos y condiciones:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                '1. Recopilación de datos personales: Se recopila información como el nombre, foto de perfil, dirección de correo electrónico y progreso en las actividades. Estos datos se utilizan exclusivamente para mejorar la experiencia del usuario y personalizar el contenido.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                '2. Uso de servicios externos: Esta aplicación utiliza servicios de terceros como Firebase Authentication, Firestore y APIs externas para el manejo seguro de información y almacenamiento de datos.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                '3. Confidencialidad: La información proporcionada por el usuario no será compartida con terceros, salvo en casos exigidos por ley.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                '4. Consentimiento: El uso de esta aplicación implica la aceptación expresa de estos términos y condiciones. Si el usuario no está de acuerdo, se recomienda no utilizar la aplicación.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                '5. Eliminación de datos: El usuario puede solicitar la eliminación de sus datos personales en cualquier momento mediante una solicitud formal al correo institucional del desarrollador.',
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 30),
              Text(
                'POLÍTICA DE PRIVACIDAD',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Esta aplicación respeta y protege la privacidad de sus usuarios. A continuación se describen las prácticas de tratamiento de información:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                '- Finalidad: Los datos personales recolectados se utilizan para autenticar usuarios, mostrar contenido personalizado, registrar avances y brindar soporte técnico.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                '- Seguridad: Se implementan medidas de seguridad para proteger la información contra accesos no autorizados, uso indebido o divulgación.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                '- Acceso y control: El usuario podrá revisar, actualizar o eliminar su información personal previa solicitud.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                '- Retención de datos: Los datos se conservarán mientras el usuario mantenga una cuenta activa o hasta que solicite su eliminación.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 30),
              Text(
                'Gracias por utilizar esta aplicación. Su privacidad es importante para nosotros.',
                style: TextStyle(fontSize: 16),
              )
            ],
          ),
        ),
      ),
    );
  }
}
