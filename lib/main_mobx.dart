import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

part 'main_mobx.g.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobx Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: const UserView(),
    );
  }
}

sealed class AppState<T> {
  const AppState();
}

final class InitialState<T> extends AppState<T> {
  const InitialState();
}

final class LoadingState<T> extends AppState<T> {
  const LoadingState();
}

final class SuccessState<T> extends AppState<T> {
  final T data;

  const SuccessState({required this.data});
}

final class ErrorState<T> extends AppState<T> {
  final String message;

  const ErrorState({required this.message});
}

sealed class Result<S, E extends Exception> {
  const Result();

  T fold<T>({
    required T Function(S value) onSuccess,
    required T Function(E error) onError,
  }) {
    switch (this) {
      case Success(value: final v):
        return onSuccess(v);
      case Error(error: final e):
        return onError(e);
    }
  }
}

final class Success<S, E extends Exception> extends Result<S, E> {
  final S value;

  const Success({required this.value});
}

final class Error<S, E extends Exception> extends Result<S, E> {
  final E error;

  const Error({required this.error});
}

class UserModel {
  final String? name;

  UserModel({this.name});
}

typedef UserResult = Result<UserModel, Exception>;

abstract interface class UserRepository {
  Future<UserResult> findOneUser();
}

class UserRepositoryImpl implements UserRepository {
  @override
  Future<UserResult> findOneUser() async {
    try {
      await Future.delayed(Duration(seconds: 4));
      return Success(value: UserModel(name: 'John Doe'));
    } catch (error) {
      return Error(error: Exception('An error occurred.'));
    }
  }
}

typedef UserState = AppState<UserModel>;

class UserViewModel = UserViewModelBase with _$UserViewModel;

abstract class UserViewModelBase with Store {
  final UserRepository userRepository;

  UserViewModelBase({required this.userRepository});

  @observable
  UserState userState = const InitialState();

  @action
  Future<void> getUserData() async {
    userState = const LoadingState();
    _debug();

    final result = await userRepository.findOneUser();

    userState = result.fold<UserState>(
      onSuccess: (value) => SuccessState(data: value),
      onError: (error) => ErrorState(message: '$error'),
    );

    _debug();
  }

  void _debug() {
    debugPrint('User state: $userState');
  }
}

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  late final UserRepository userRepository;
  late final UserViewModel userViewModel;

  @override
  void initState() {
    super.initState();
    userRepository = UserRepositoryImpl();
    userViewModel = UserViewModel(userRepository: userRepository);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getUserData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getUserData() async {
    await userViewModel.getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Info')),
      body: Center(
        child: RefreshIndicator(
          onRefresh: () async {
            await _getUserData();
          },
          child: StateBuilderWidget(
            builder: (context) {
              return switch (userViewModel.userState) {
                InitialState() => const Text('Aguardando ação...'),
                LoadingState() => const CircularProgressIndicator(),
                SuccessState(data: final user) => Text('Usuário: ${user.name}'),
                ErrorState(message: final message) => Text('Erro: $message'),
              };
            },
          ),
        ),
      ),
    );
  }
}

@protected
typedef StateBuilder = Widget Function(BuildContext context);

class StateBuilderWidget extends StatelessWidget {
  final StateBuilder builder;

  const StateBuilderWidget({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) => builder(context));
  }
}
