# Navegando entre telas

npm install react-navigation react-native-gesture-handler react-navigation-stack

- `App.js`

```jsx
import {Container, Content, Header, Title} from 'native-base';
import React, {Component} from 'react';
import {StyleSheet, Text} from 'react-native';
import {createAppContainer} from 'react-navigation';
import {createStackNavigator} from 'react-navigation-stack';
import {Provider} from 'react-redux';
import configureStore from './configureStore';
import Login from './screens/Login';

const store = configureStore();

const AppNavigator = createStackNavigator(
  {
    Login,
  },
  {
    initialRouteName: 'Login',
  },
);

const Navigation = createAppContainer(AppNavigator);

export default class App extends Component {
  render() {
    return (
      <Provider store={store}>
        <Container>
          <Header style={styles.header}>
            <Title>Controle de Animais</Title>
          </Header>
          <Navigation />
        </Container>
      </Provider>
    );
  }
}

// ...
```

O componente `Content` do Native Base apresenta uma incompatibilidade com o React Navigation, por isso foi necessário migrá-lo para o componente inferior:

- `Login.js`

```jsx
  render() {
    return (
      <Content padder>
        <Form>
          <FormItem floatingLabel>
            <Label>Usuario</Label>
            <Input
              onChangeText={text => this.setState({usuario: text})}
              autoCapitalize="none"
              value={this.state.text}
            />
          </FormItem>
          <FormItem floatingLabel last>
            <Label>Senha</Label>
            <Input
              secureTextEntry={true}
              onChangeText={text => this.setState({senha: text})}
              value={this.state.text}
            />
          </FormItem>

          <Button full primary style={styles.botaoLogin} onPress={this.login}>
            <Text>Logar</Text>
          </Button>
        </Form>
      </Content>
    );
  }
// ...
```
