import React from 'react';
import { ActivityIndicator, View } from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { NavigationContainer, LinkingOptions } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { useFonts } from 'expo-font';
import { PlusJakartaSans_800ExtraBold } from '@expo-google-fonts/plus-jakarta-sans';
import { Inter_400Regular, Inter_600SemiBold, Inter_700Bold } from '@expo-google-fonts/inter';
import { DMSans_400Regular, DMSans_700Bold } from '@expo-google-fonts/dm-sans';
import { RobotoMono_400Regular } from '@expo-google-fonts/roboto-mono';
import { CrimsonText_400Regular } from '@expo-google-fonts/crimson-text';
import { Outfit_300Light } from '@expo-google-fonts/outfit';

import type { RootStack } from './src/navigation';
import { AuthProvider } from './src/AuthContext';
import { FiltersProvider } from './src/FiltersContext';
import { home } from './src/theme';
import HomeScreen from './src/screens/HomeScreen';
import MapScreen from './src/screens/MapScreen';
import ListScreen from './src/screens/ListScreen';
import ActivityScreen from './src/screens/ActivityScreen';
import FiltersScreen from './src/screens/FiltersScreen';
import { SignInScreen, SignUpScreen } from './src/screens/AuthScreens';

const Stack = createNativeStackNavigator<RootStack>();

// URL paths on web match the section names in your Figma file.
const linking: LinkingOptions<RootStack> = {
  prefixes: [],
  config: {
    screens: { Home: '', Map: 'map', List: 'list', Activity: 'activity/:id', Filters: 'filters', SignIn: 'signin', SignUp: 'signup' },
  },
};

export default function App() {
  const [fontsLoaded] = useFonts({
    PlusJakartaSans_800ExtraBold,
    Inter_400Regular,
    Inter_600SemiBold,
    Inter_700Bold,
    DMSans_400Regular,
    DMSans_700Bold,
    RobotoMono_400Regular,
    CrimsonText_400Regular,
    Outfit_300Light,
  });

  if (!fontsLoaded) {
    return (
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: home.bg }}>
        <ActivityIndicator color={home.lavender} />
      </View>
    );
  }

  return (
    <SafeAreaProvider>
      <AuthProvider>
      <FiltersProvider>
        <NavigationContainer linking={linking} documentTitle={{ formatter: (_, route) => (route?.name && route.name !== 'Home' ? `NeoQuest · ${route.name}` : 'NeoQuest') }}>
          <StatusBar style="auto" />
          <Stack.Navigator screenOptions={{ headerShown: false, animation: 'slide_from_right' }}>
            <Stack.Screen name="Home" component={HomeScreen} />
            <Stack.Screen name="Map" component={MapScreen} />
            <Stack.Screen name="List" component={ListScreen} />
            <Stack.Screen name="Activity" component={ActivityScreen} />
            <Stack.Screen name="Filters" component={FiltersScreen} />
            <Stack.Screen name="SignIn" component={SignInScreen} />
            <Stack.Screen name="SignUp" component={SignUpScreen} />
          </Stack.Navigator>
        </NavigationContainer>
      </FiltersProvider>
      </AuthProvider>
    </SafeAreaProvider>
  );
}
