import type { NativeStackScreenProps } from '@react-navigation/native-stack';

export type RootStack = {
  Home: undefined;
  Map: { focusId?: number } | undefined;
  List: undefined;
  Activity: { id: number };
  Filters: undefined;
  SignIn: undefined;
  SignUp: undefined;
};

export type ScreenProps<T extends keyof RootStack> = NativeStackScreenProps<RootStack, T>;
