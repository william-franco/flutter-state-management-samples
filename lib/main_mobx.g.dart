// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main_mobx.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserViewModel on UserViewModelBase, Store {
  late final _$userStateAtom = Atom(
    name: 'UserViewModelBase.userState',
    context: context,
  );

  @override
  AppState<UserModel, UserException> get userState {
    _$userStateAtom.reportRead();
    return super.userState;
  }

  @override
  set userState(AppState<UserModel, UserException> value) {
    _$userStateAtom.reportWrite(value, super.userState, () {
      super.userState = value;
    });
  }

  late final _$getUserDataAsyncAction = AsyncAction(
    'UserViewModelBase.getUserData',
    context: context,
  );

  @override
  Future<void> getUserData() {
    return _$getUserDataAsyncAction.run(() => super.getUserData());
  }

  @override
  String toString() {
    return '''
userState: ${userState}
    ''';
  }
}
