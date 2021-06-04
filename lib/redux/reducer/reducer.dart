import 'package:redux/redux.dart';

import '../action/action.dart';
import '../state/state.dart';

final Reducer<AppState> appReducer = combineReducers([
  _appReducer,
  TypedReducer(_initializedReducer),
]);

AppState _appReducer(AppState state, dynamic action) => state.copyWith(
      user: userReducer(state.user, action),
    );

AppState _initializedReducer(AppState state, InitializedAction action) =>
    state.copyWith(isInitialized: true);

final Reducer<UserState> userReducer = combineReducers([
  TypedReducer(_loginReducer),
]);

UserState _loginReducer(UserState state, LoginAction action) => state.copyWith(
      campusId: action.campusId,
      password: action.password,
    );