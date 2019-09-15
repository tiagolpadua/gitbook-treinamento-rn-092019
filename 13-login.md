# Login

Agora que já estamos conseguindo nos conectar com a API do sistema, é hora de criarmos uma tela de login para identificar o usuário atual.

## Login.js

Primeiro, vamos fazer toda a parte visual:

- `src/screens/Login.js`

```jsx
import {Button, Form, Input, Item as FormItem, Label, Text} from 'native-base';
import React, {Component} from 'react';
import {StyleSheet} from 'react-native';
import {connect} from 'react-redux';
import {bindActionCreators} from 'redux';
import {carregarAnimais} from '../actions';

class Login extends Component {
  render() {
    return (
      <Form>
        <FormItem floatingLabel>
          <Label>Usuario</Label>
          <Input />
        </FormItem>
        <FormItem floatingLabel last>
          <Label>Senha</Label>
          <Input secureTextEntry={true} />
        </FormItem>

        <Button full primary style={styles.botaoLogin}>
          <Text>Logar</Text>
        </Button>
      </Form>
    );
  }
}

const mapStateToProps = () => ({});

const mapDispatchToProps = {};

export default connect(
  mapStateToProps,
  mapDispatchToProps,
)(Login);

const styles = StyleSheet.create({
  botaoLogin: {marginTop: 10},
});
```

Em seguida, vamos trocar o componente principal de `App.js` para nossa tela de `Login`:

- `App.js`

```jsx
export default class App extends Component {
  render() {
    return (
      <Provider store={store}>
        <Container>
          <Header style={styles.header}>
            <Title>Controle de Animais</Title>
          </Header>
          <Content padder>
            {/* Novidade aqui */}
            <Login />
          </Content>
        </Container>
      </Provider>
    );
  }
}
```

Vamos agora capturar o input do usuário ajustando o estado do componente e associar uma fução à ação de login:

- `src/screens/Login.js`

```jsx
class Login extends Component {
  constructor(props) {
    super(props);

    // Novidade aqui
    this.state = {
      usuario: '',
      senha: '',
    };
  }

  // Novidade aqui
  login = () => {
    console.warn(this.state.usuario + ' ' + this.state.senha);
  };

  render() {
    return (
      <Form>
        <FormItem floatingLabel>
          <Label>Usuario</Label>
          {/* Novidades aqui */}
          <Input
            onChangeText={text => this.setState({usuario: text})}
            value={this.state.text}
          />
        </FormItem>
        <FormItem floatingLabel last>
          <Label>Senha</Label>
          {/* Novidades aqui */}
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
    );
  }
}
```

Para melhorar a experiência do usuário, podemos desabilitar a capitalização automática da primeira letra no campo de input de texto:

```jsx
<Input
  onChangeText={text => this.setState({usuario: text})}
  autoCapitalize="none"
  value={this.state.text}
/>
```

Agora que já temos todo o front-end pronto, temos que criar as ações do Redux necessárias para o Login:

- `constants.js`

```jsx
const LOGIN = 'LOGIN';
const FAVORITAR = 'FAVORITAR';
const DESFAVORITAR = 'DESFAVORITAR';
const CARREGAR_ANIMAIS = 'CARREGAR_ANIMAIS';

export {LOGIN, FAVORITAR, DESFAVORITAR, CARREGAR_ANIMAIS};
```

Criar a ação de login:

- `actions.js`

```jsx
import {carregarAnimaisAPI, loginAPI} from './api';
import {LOGIN, CARREGAR_ANIMAIS, DESFAVORITAR, FAVORITAR} from './constants';

export function login(usuario, senha) {
  return dispatch => {
    loginAPI(usuario, senha)
      .then(res => {
        console.warn(res);
        dispatch({
          type: LOGIN,
          data: {usuarioLogado: usuario, token: res.data.token},
        });
      })
      .catch(error => {
        console.warn(error.message);
      });
  };
}
```

A chamada de API correspondente:

- `/api/index.js`

```jsx
import axios from 'axios';

// ...

export function loginAPI(usuario, senha) {
  return api.post('/login', {usuario, senha});
}
```

E por fim ajustar o reducer:

- `usuarioLogado.js`

```jsx
import {LOGIN} from '../constants';

const initialState = null;

export default function usuarioLogadoReducer(state = initialState, action) {
  switch (action.type) {
    case LOGIN:
      return action.data;

    default:
      return state;
  }
}
```

Com todo o fluxo pronto, podemos ajustar nosso componente para utilizar a nova ação:

- `Login.js`

```jsx
class Login extends Component {
  // ...

  // Novidade aqui
  login = () => {
    this.props.login(this.state.usuario, this.state.senha);
  };

  // ...
}

const mapStateToProps = () => ({});

const mapDispatchToProps = dispatch => bindActionCreators({login}, dispatch);

// ...
```

A operação foi realizada, porém após o login ainda não estamos navegando para a tela de listagem de animais. Esta é nossa próxima missão.
