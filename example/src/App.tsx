import React, { useEffect } from 'react';

import { StyleSheet, View } from 'react-native';
import { RequestType, makeRequest } from 'native-uri-request';

// const resultPostRequest = await makeRequest({
//   uri,
//   type: RequestType.POST,
//   headers: { 'Content-Type': 'application/json' },
//   body: { id: 1, ddd: 'adad' },
// });

// const resultGetRequest = await makeRequest({
//   uri,
//   type: RequestType.GET,
//   headers: { 'Content-Type': 'application/json' },
// });

const doRequest = async (uri: string) => {
  try {
    const resultGetRequest = await makeRequest({
      uri,
      type: RequestType.GET,
      headers: { 'Content-Type': 'application/json' },
    });
    console.log('someRequest =>', resultGetRequest);
  } catch (error) {
    console.log('someRequest:[ERRROR] =>', error);
  }
};

export default function App() {
  useEffect(() => {
    // PROVIDE SOME URL FOR REQUESTS
    doRequest('https://my-json-server.typicode.com/typicode/demo/db');
  }, []);

  return <View style={styles.container} />;
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
