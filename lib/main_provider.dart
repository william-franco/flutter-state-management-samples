import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Provider Example',
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

typedef _ViewModel = ChangeNotifier;

typedef UserState = AppState<UserModel>;

abstract interface class UserViewModel extends _ViewModel {
  UserState get userState;

  Future<void> getUserData();
}

class UserViewModelImpl extends _ViewModel implements UserViewModel {
  final UserRepository userRepository;

  UserViewModelImpl({required this.userRepository});

  UserState _userState = InitialState();

  @override
  UserState get userState => _userState;

  @override
  Future<void> getUserData() async {
    _emit(LoadingState());

    final result = await userRepository.findOneUser();

    final state = result.fold<UserState>(
      onSuccess: (value) => SuccessState(data: value),
      onError: (error) => ErrorState(message: '$error'),
    );

    _emit(state);
  }

  void _emit(UserState newValue) {
    if (_userState != newValue) {
      _userState = newValue;
      notifyListeners();
      debugPrint('User state: $_userState');
    }
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
    userViewModel = UserViewModelImpl(userRepository: userRepository);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getUserData();
    });
  }

  @override
  void dispose() {
    userViewModel.dispose();
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
          child: StateBuilderWidget<UserViewModel>(
            viewModel: userViewModel,
            builder: (context, state) {
              return switch (state.userState) {
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
typedef StateBuilder<S> = Widget Function(BuildContext context, S state);

class StateBuilderWidget<T extends ChangeNotifier> extends StatelessWidget {
  final T viewModel;
  final StateBuilder<T> builder;

  const StateBuilderWidget({
    super.key,
    required this.builder,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>.value(
      value: viewModel,
      child: Consumer<T>(
        builder: (context, notifier, child) {
          return builder(context, notifier);
        },
      ),
    );
  }
}
