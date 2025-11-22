import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FutureBuilder Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: UsuariosPage(),
    );
  }
}

// ============================================
// MODELO DE DATOS
// ============================================

/// Modelo simple de Usuario
/// Representa la estructura de datos que recibiremos
class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String rol;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  // Factory constructor para crear Usuario desde JSON
  // Útil cuando recibimos datos de una API real
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      rol: json['rol'],
    );
  }
}

// ============================================
// SERVICIO DE API (SIMULADO)
// ============================================

class ApiService {
  /// Simula una llamada a API que tarda 3 segundos
  /// En una app real, aquí usaríamos http.get() o dio
  ///
  /// Future.delayed() crea un Future que se completa después
  /// del tiempo especificado, perfecto para simular latencia de red
  static Future<List<Usuario>> fetchUsuarios() async {
    // Simulamos un delay de red (3 segundos)
    await Future.delayed(Duration(seconds: 3));

    // Simular posible error (20% de probabilidad)
    // Esto nos permite probar el manejo de errores
    if (DateTime.now().second % 5 == 0) {
      throw Exception('Error de conexión: No se pudo conectar al servidor');
    }

    // Retornamos datos simulados
    // En una app real, esto vendría de una API
    return [
      Usuario(
        id: 1,
        nombre: 'Ana García',
        email: 'ana@ejemplo.com',
        rol: 'Desarrolladora Flutter',
      ),
      Usuario(
        id: 2,
        nombre: 'Carlos Ruiz',
        email: 'carlos@ejemplo.com',
        rol: 'Diseñador UI/UX',
      ),
      Usuario(
        id: 3,
        nombre: 'María López',
        email: 'maria@ejemplo.com',
        rol: 'Product Manager',
      ),
      Usuario(
        id: 4,
        nombre: 'Juan Pérez',
        email: 'juan@ejemplo.com',
        rol: 'Backend Developer',
      ),
    ];
  }

  /// Versión que siempre falla - útil para probar manejo de errores
  static Future<List<Usuario>> fetchUsuariosConError() async {
    await Future.delayed(Duration(seconds: 2));
    throw Exception('Error intencional para demostrar manejo de errores');
  }
}

// ============================================
// PÁGINA PRINCIPAL CON FUTUREBUILDER
// ============================================

class UsuariosPage extends StatefulWidget {
  @override
  _UsuariosPageState createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  // IMPORTANTE: Declaramos el Future como variable de instancia
  // Si lo creamos dentro de build(), se ejecutaría en cada rebuild
  // causando múltiples llamadas innecesarias a la API
  late Future<List<Usuario>> _futureUsuarios;

  @override
  void initState() {
    super.initState();
    // Inicializamos el Future UNA SOLA VEZ cuando el widget se crea
    // Este Future será observado por el FutureBuilder
    _futureUsuarios = ApiService.fetchUsuarios();
  }

  /// Método para recargar los datos
  /// Crea un nuevo Future y llama a setState para reconstruir el widget
  void _recargarDatos() {
    setState(() {
      _futureUsuarios = ApiService.fetchUsuarios();
    });
  }

  /// Método para simular un error
  void _simularError() {
    setState(() {
      _futureUsuarios = ApiService.fetchUsuariosConError();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FutureBuilder Demo'),
        actions: [
          // Botón para recargar datos
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _recargarDatos,
            tooltip: 'Recargar',
          ),
          // Botón para simular error
          IconButton(
            icon: Icon(Icons.error_outline),
            onPressed: _simularError,
            tooltip: 'Simular Error',
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner informativo
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Text(
              'Esta app demuestra cómo FutureBuilder maneja estados asíncronos',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // FutureBuilder - ¡AQUÍ ESTÁ LA MAGIA!
          Expanded(
            child: FutureBuilder<List<Usuario>>(
              // Propiedad 1: future
              // Le pasamos el Future que queremos observar
              future: _futureUsuarios,

              // Propiedad 2: builder
              // Esta función se llama cada vez que cambia el estado del Future
              // Recibe el contexto y un AsyncSnapshot con el estado actual
              builder: (context, snapshot) {
                // ============================================
                // ESTADO 1: ESPERANDO (ConnectionState.waiting)
                // ============================================
                // El Future aún no ha terminado, mostramos loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Cargando usuarios...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'ConnectionState.waiting',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // ============================================
                // ESTADO 2: ERROR (snapshot.hasError)
                // ============================================
                // El Future se completó pero con un error
                // Siempre debemos manejar este caso
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '¡Ups! Algo salió mal',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            // Mostramos el mensaje de error
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'snapshot.hasError == true',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                              fontFamily: 'monospace',
                            ),
                          ),
                          SizedBox(height: 24),
                          // Botón para reintentar
                          ElevatedButton.icon(
                            onPressed: _recargarDatos,
                            icon: Icon(Icons.refresh),
                            label: Text('Reintentar'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // ============================================
                // ESTADO 3: DATOS CARGADOS (snapshot.hasData)
                // ============================================
                // El Future se completó exitosamente y tenemos datos
                if (snapshot.hasData) {
                  // Extraemos la lista de usuarios del snapshot
                  // Usamos ! porque ya verificamos que hasData es true
                  final usuarios = snapshot.data!;

                  // Si la lista está vacía, mostramos un mensaje
                  if (usuarios.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No hay usuarios',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Mostramos los datos en una lista
                  return Column(
                    children: [
                      // Header con contador
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        color: Colors.green.shade50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${usuarios.length} usuarios cargados',
                              style: TextStyle(
                                color: Colors.green.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Lista de usuarios
                      Expanded(
                        child: ListView.builder(
                          // itemCount determina cuántos elementos mostrar
                          itemCount: usuarios.length,

                          // itemBuilder construye cada elemento
                          itemBuilder: (context, index) {
                            final usuario = usuarios[index];
                            return Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              elevation: 2,
                              child: ListTile(
                                // Avatar circular con inicial
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    usuario.nombre[0].toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // Nombre del usuario
                                title: Text(
                                  usuario.nombre,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                // Email y rol como subtítulo
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    Text(usuario.email),
                                    SizedBox(height: 2),
                                    Text(
                                      usuario.rol,
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                                // Icono de flecha
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Aquí podrías navegar a una página de detalle
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Clic en ${usuario.nombre}',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                // ============================================
                // ESTADO 4: ESTADO INICIAL (ConnectionState.none)
                // ============================================
                // Esto solo ocurre si el Future es null o no se ha iniciado
                // En nuestro caso, no debería llegar aquí porque
                // inicializamos el Future en initState()
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Sin datos',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'ConnectionState.none',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Botón flotante para recargar
      floatingActionButton: FloatingActionButton(
        onPressed: _recargarDatos,
        child: Icon(Icons.refresh),
        tooltip: 'Recargar datos',
      ),
    );
  }
}
