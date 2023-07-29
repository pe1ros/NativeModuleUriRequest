import React, { useEffect } from 'react';

import { StyleSheet, View } from 'react-native';
import { RequestType, makeRequest } from 'native-uri-request';

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

const request = async (uri: string) => {
  try {
    const resultPostRequest = await makeRequest({
      uri,
      type: RequestType.GET,
      headers: { 'Content-Type': 'application/json' },
    });

    console.log('request:[SUCCESS] =>', resultPostRequest);
  } catch (error) {
    console.log('request:[ERROR] =>', error);
  }
};

export default function App() {
  useEffect(() => {
    // PROVIDE HERE URL FOR GET/POST REQUESTS
    request('https://dummyjson.com/products');
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
