import React, { useEffect } from 'react';

import { StyleSheet, View, Text } from 'react-native';
import { RequestType, makeRequest } from 'native-uri-request';

const someRequest = async (uri: string) => {
  try {
    const result = await makeRequest({
      uri,
      type: RequestType.GET,
      headers: { 'Content-Type': 'application/json' },
    });
    console.log('someRequest =>', result);
  } catch (error) {
    console.log('someRequest:ERRROR =>', error);
  }
};

export default function App() {
  useEffect(() => {
    someRequest('https://jsonplaceholder.typicode.com/todos/1');
  }, []);

  return (
    <View style={styles.container}>
      <Text>Result</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
