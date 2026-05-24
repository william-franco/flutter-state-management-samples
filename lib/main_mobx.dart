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

sealed class AppState<S, E extends Exception> {
  const AppState();
}

final class InitialState<S, E extends Exception> extends AppState<S, E> {
  const InitialState();
}

final class LoadingState<S, E extends Exception> extends AppState<S, E> {
  const LoadingState();
}

final class SuccessState<S, E extends Exception> extends AppState<S, E> {
  final S data;

  const SuccessState({required this.data});
}

final class ErrorState<S, E extends Exception> extends AppState<S, E> {
  final E error;

  const ErrorState({required this.error});
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

class UserException implements Exception {
  final String message;

  const UserException(this.message);

  @override
  String toString() => 'UserException: $message';
}

class UserModel {
  final String? name;

  UserModel({this.name});

  UserModel copyWith({String? name}) {
    return UserModel(name: name ?? this.name);
  }
}

typedef UserResult = Result<UserModel, UserException>;

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
      return Error(error: UserException('An error occurred.'));
    }
  }
}

typedef UserState = AppState<UserModel, UserException>;

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
      onError: (error) => ErrorState(error: error),
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
      appBar: AppBar(
        title: const Text('User Info'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_outlined),
            onPressed: () async {
              await _getUserData();
            },
          ),
        ],
      ),
      body: Center(
        child: RefreshIndicator(
          onRefresh: () async {
            await _getUserData();
          },
          child: StateBuilderWidget(
            builder: (context) {
              return switch (userViewModel.userState) {
                InitialState() => const SizedBox.shrink(),
                LoadingState() => const CircularProgressIndicator(),
                SuccessState(data: final user) => Text('User: ${user.name}'),
                ErrorState(error: final e) => Text('Error: ${e.message}'),
              };
            },
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////

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
