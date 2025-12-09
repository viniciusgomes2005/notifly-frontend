part of 'api_manager.dart';

extension AuthApi on ApiManager {
  Future<dynamic> login(String email, String password) async {
    try {
      final resp = await post('auth/login', {
        'email': email,
        'password': password,
      });

      if (resp is! Map || resp['ok'] != true) {
        throw Exception(
          'Login falhou: ${resp is Map ? resp['error'] : 'resposta_inválida'}',
        );
      }

      final rawUser = resp['user'] as Map<String, dynamic>?;
      final tok = resp['token'] as String?;

      if (rawUser == null || tok == null) {
        throw Exception('Login retornou dados incompletos (user/token null)');
      }

      _isAuthenticated = true;

      final user = UserModel.fromLoginJson(rawUser);

      final box = Hive.box('userData');
      box.put('id', user.id);
      box.put('name', user.name);
      box.put('email', user.email);
      box.put('token', tok);

      return resp;
    } catch (error) {
      throw Exception('Erro ao fazer login: $error');
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;

    final box = Hive.box('userData');
    await box.delete('id');
    await box.delete('name');
    await box.delete('email');
    await box.delete('token');
  }

  Future<dynamic> register(
    String name,
    String email,
    String password, {
    String? photoUrl,
  }) async {
    try {
      final resp = await post('auth/signup', {
        'name': name,
        'email': email,
        'password': password,
        'photo_url': photoUrl,
      });

      if (resp is! Map || resp['ok'] != true) {
        throw Exception(
          'Registro falhou: ${resp is Map ? resp['error'] : 'resposta_inválida'}',
        );
      }

      final rawUser = resp['user'] as Map<String, dynamic>?;
      final tok = resp['token'] as String?;

      if (rawUser == null || tok == null) {
        throw Exception(
          'Registro retornou dados incompletos (user/token null)',
        );
      }

      _isAuthenticated = true;

      final user = UserModel.fromSignUpJson(rawUser);

      final box = Hive.box('userData');
      box.put('id', user.id);
      box.put('name', user.name);
      box.put('email', user.email);
      box.put('token', tok);

      return resp;
    } catch (error) {
      throw Exception('Erro ao fazer registro: $error');
    }
  }
}
