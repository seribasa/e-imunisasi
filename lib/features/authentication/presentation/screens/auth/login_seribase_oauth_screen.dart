import '../../../../../core/widgets/button_custom.dart';
import '../../../../../injection.dart';
import '../../../logic/cubit/login_cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class LoginSeribaseOauthScreen extends StatelessWidget {
  const LoginSeribaseOauthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginCubit>(),
      child: const _LoginSeribaseOauthScaffold(),
    );
  }
}

class _LoginSeribaseOauthScaffold extends StatelessWidget {
  const _LoginSeribaseOauthScaffold();

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                ),
                const SizedBox(height: 30.0),
                const Text(
                  "Silahkan masuk dengan akun Seribase Anda",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20.0),
          child: const _LoginButton(),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    return ButtonCustom(
      onPressed: () {
        context.read<LoginCubit>().logInWithSeribaseOauth();
      },
      child: const Text(
        key: Key('login_with_seribase_button'),
        'Masuk dengan Seribase',
        style: TextStyle(fontSize: 15.0, color: Colors.white),
      ),
    );
  }
}
