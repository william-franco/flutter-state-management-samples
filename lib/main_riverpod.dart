import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riverpod Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: const UserView(),
    );
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl();
});

final userViewModelProvider = NotifierProvider<UserViewModel, UserState>(
  UserViewModelImpl.new,
);

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

typedef _ViewModel = Notifier<UserState>;

typedef UserState = AppState<UserModel>;

abstract interface class UserViewModel extends _ViewModel {
  UserState get userState;

  Future<void> getUserData();
}

class UserViewModelImpl extends _ViewModel implements UserViewModel {
  late final UserRepository userRepository;

  @override
  UserState build() {
    userRepository = ref.read(userRepositoryProvider);
    return const InitialState();
  }

  @override
  UserState get userState => state;

  @override
  Future<void> getUserData() async {
    _emit(LoadingState());

    final result = await userRepository.findOneUser();

    final userState = result.fold<UserState>(
      onSuccess: (value) => SuccessState(data: value),
      onError: (error) => ErrorState(message: '$error'),
    );

    _emit(userState);
  }

  void _emit(UserState newState) {
    state = newState;
    debugPrint('User state: $state');
  }
}

class UserView extends ConsumerStatefulWidget {
  const UserView({super.key});

  @override
  ConsumerState<UserView> createState() => _UserViewState();
}

class _UserViewState extends ConsumerState<UserView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getUserData();
    });
  }

  Future<void> _getUserData() async {
    await ref.read(userViewModelProvider.notifier).getUserData();
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
          child: StateBuilderWidget<UserState>(
            provider: userViewModelProvider,
            builder: (context, userState) {
              return switch (userState) {
                InitialState() => const SizedBox.shrink(),
                LoadingState() => const CircularProgressIndicator(),
                SuccessState(data: final user) => Text('User: ${user.name}'),
                ErrorState(message: final message) => Text('Error: $message'),
              };
            },
          ),
        ),
      ),
    );
  }
}

@protected
typedef StateBuilder<T> = Widget Function(BuildContext context, T state);

class StateBuilderWidget<T> extends StatelessWidget {
  final ProviderListenable<T> provider;
  final StateBuilder<T> builder;

  const StateBuilderWidget({
    super.key,
    required this.provider,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(provider);
        return builder(context, state);
      },
    );
  }
}
