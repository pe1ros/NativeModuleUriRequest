/* eslint-disable react-native/no-inline-styles */
import React, { useEffect, useState } from 'react';

import { StyleSheet, Text, View } from 'react-native';
import { NativeRequest, NativeEvents } from 'native-uri-request';

/**
 * GET request
 * @param uri = 'https://dummyjson.com/products'
 */
// const resultGetRequest = await makeRequest({
//   uri,
//   type: RequestType.GET,
//   headers: { 'Content-Type': 'application/json' },
// });

/**
 * POST request
 * @param uri = 'https://dummyjson.com/products/add'
 */
// const resultPostRequest = await makeRequest({
//   uri,
//   type: RequestType.POST,
//   headers: { 'Content-Type': 'application/json' },
//   body: { title: 'TITLE', description: 'DESCRIPTION' },
// });

export default function App() {
  const [motion, setMotion] = useState();
  const [magnet, setMagnet] = useState(0);
  // const width = Dimensions.get('screen').width;
  // const height = Dimensions.get('screen').height;
  // const ref = useRef(new Animated.Value(-width)).current;

  useEffect(() => {
    NativeRequest.getInstance().on(NativeEvents.ERROR_EVENT, (e: any) =>
      console.log('ERROR =>', e)
    );
    NativeRequest.getInstance().on(NativeEvents.MAGNETOMETER_EVENT, setMagnet);
    NativeRequest.getInstance().on(NativeEvents.MOTION_EVENT, setMotion);
    NativeRequest.getInstance().getMagneticField();
  }, []);

  // const moveLeft = () =>
  //   Animated.timing(ref, {
  //     toValue: 0,
  //     duration: 200,
  //     useNativeDriver: false,
  //   }).start();

  // const moveRight = () =>
  //   Animated.timing(ref, {
  //     toValue: -width,
  //     duration: 200,
  //     useNativeDriver: false,
  //   }).start();

  // useEffect(() => {
  //   if (magnet > width) {
  //     moveLeft();
  //   } else {
  //     moveRight();
  //   }
  // }, [magnet, width]);

  return (
    <View style={styles.container}>
      <Text style={styles.text}>MAGNET</Text>
      <Text style={styles.text}>X: {`${Math.ceil(magnet?.X_MAGNET)}`}</Text>
      <Text style={styles.text}>Y: {`${Math.ceil(magnet?.Y_MAGNET)}`}</Text>
      <Text style={styles.text}>Z: {`${Math.ceil(magnet?.Z_MAGNET)}`}</Text>
      <View style={styles.separator} />
      <Text style={styles.text}>MOTION</Text>
      <Text style={styles.text}>X: {`${Math.ceil(motion?.YAW_MOTION)}`}</Text>
      <Text style={styles.text}>Y: {`${Math.ceil(motion?.ROLL_MOTION)}`}</Text>
      <Text style={styles.text}>Z: {`${Math.ceil(motion?.PITCH_MOTION)}`}</Text>
      {/* <Animated.Image
        style={[
          {
            height,
            width,
            position: 'absolute',
            top: 0,
            bottom: 0,
            right: 0,
            resizeMode: 'contain',
          },
          { left: ref },
        ]}
        source={require('./sun.png')}
      /> */}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white',
    justifyContent: 'center',
  },
  text: {
    alignSelf: 'center',
    lineHeight: 28,
    fontSize: 28,
    color: 'black',
    fontWeight: '600',
  },
  separator: {
    width: '100%',
    height: 3,
    backgroundColor: 'black',
  },
});
