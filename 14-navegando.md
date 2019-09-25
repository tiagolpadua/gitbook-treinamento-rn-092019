# Navegando entre telas

Para efetuar a navegação utilizaremos a biblioteca _React Navigation_.

O React Navigation nasceu da necessidade da comunidade React Native de uma solução de navegação extensível e fácil de usar, escrita inteiramente em JavaScript (para que você possa ler e entender toda o fonte), com poderosas primitivas nativas. [https://reactnavigation.org/docs/en/getting-started.html](https://reactnavigation.org/docs/en/getting-started.html)

Para começar a utilizá-la, devemos primeiramente instalar as dependências necessárias:

```bash
> npm install react-navigation react-native-gesture-handler react-navigation-stack
```

Agora vamos ajustar nosso componente principal da aplicação inicializando o React Navigation e descrevendo quais são as telas de nossa aplicação:

- `App.js`

```jsx
import {Container, Content, Header, Title} from 'native-base';
import React, {Component} from 'react';
import {StyleSheet, Text} from 'react-native';
import {createAppContainer} from 'react-navigation';
import {createStackNavigator} from 'react-navigation-stack';
import {Provider} from 'react-redux';
import configureStore from './configureStore';
import Login from './components/Login';

const store = configureStore();

// Novidade aqui
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
          {/* Novidade aqui */}
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

Você deve ter percebido que há uma barra de título "sobrando" na tela, isso ocorre pois o React Navigation também controla esta barra, vamos então ajustá-la:

- `App.js`

```jsx
const AppNavigator = createStackNavigator(
  {
    Login,
  },
  {
    initialRouteName: 'Login',
    defaultNavigationOptions: {
      header: () => (
        <Header style={styles.header}>
          <Title>Controle de Animais</Title>
        </Header>
      ),
    },
  },
);

const Navigation = createAppContainer(AppNavigator);

export default class App extends Component {
  render() {
    return (
      <Provider store={store}>
        <Container>
          <Navigation />
        </Container>
      </Provider>
    );
  }
}
```

Nossa aplicação deve estar funcionando normalmente, porém está "parada" na tela de Login, mas agora chegou o momento de realizarmos a navegação "de fato". Primeiro, vamos incluir a tela `ListaAnimais` na lista de telas do sistema:

- `App.js`

```jsx
const AppNavigator = createStackNavigator(
  {
    Login,

    // Novidade aqui
    ListaAnimais,
  },
  {
    initialRouteName: 'Login',
    defaultNavigationOptions: {
      header: () => (
        <Header style={styles.header}>
          <Title>Controle de Animais</Title>
        </Header>
      ),
    },
  },
);
```

O próximo passo é ajustar a action de login:

- `actions.js`

```jsx
export function login(usuario, senha) {
  return dispatch => {
    // Este return é necessário para que haja uma promessa na resposta do acionamento da action
    return loginAPI(usuario, senha).then(res => {
      dispatch({
        type: LOGIN,
        data: {usuarioLogado: usuario, token: res.data.token},
      });
    });
  };
}
```

Por fim, a tela de login deve realizar a navegação através de um objeto `navigation` que é fornecido diretamente nas props do componente:

- `Login.js`

```jsx
login = () => {
  this.props
    .login(this.state.usuario, this.state.senha)
    .then(() => this.props.navigation.navigate('ListaAnimais'))
    .catch(error => console.warn(error));
};
```

## Alertas

Neste momento podemos fazer uma melhoria de usabilidade, definindo uma forma de exibição de erros em nossa aplicação.

No entanto, o componente de exibição de mensagens de alerta nativo é diferente para o Android e para o IOS, assim, possuem implementações diferentes de exibição.

Para resolver este problema podemos utilizar uma técnica de criação de arquivos com a extenção `.android.js` e `.ios.js`. Arquivos com o nome da plataforma em sua extensão serão aplicados corretamente dependendo da plataforma de execução do aplicativo:

- `src/util/Alerta.android.js`

```jsx
import {ToastAndroid} from 'react-native';

export default class Alerta {
  static mensagem(texto) {
    ToastAndroid.show(texto, ToastAndroid.LONG);
  }
}
```

- `src/util/Alerta.ios.js`

```jsx
import {AlertIOS} from 'react-native';

export default class Alerta {
  static mensagem(texto) {
    AlertIOS.alert('Atenção', texto);
  }
}
```

Agora podemos utilizar os métodos estáticos para exibir a mensagem correta de acordo com a plataforma de execução:

- `Login.js`

```jsx
login = () => {
  this.props
    .login(this.state.usuario, this.state.senha)
    .then(() => this.props.navigation.navigate('ListaAnimais'))

    // Novidade aqui
    .catch(() =>
      Alerta.mensagem('Verifique o usuário e senha e tente novamente.'),
    );
};
```

## Loading

A resposta visual de nossa aplicação ainda está deixando a desejar. A API de login pode demorar um pouco a responder e o usuário não possui nenhum feedback visual disso. Para resolver, vamos implementar um efeito de Loading nas telas. Faremos isso utilizando um estado do Redux:

- `constants.js`

```jsx
const LOGIN = 'LOGIN';
const FAVORITAR = 'FAVORITAR';
const DESFAVORITAR = 'DESFAVORITAR';
const CARREGAR_ANIMAIS = 'CARREGAR_ANIMAIS';

// Novidade aqui
const SET_LOADING = 'SET_LOADING';

export {LOGIN, FAVORITAR, DESFAVORITAR, CARREGAR_ANIMAIS, SET_LOADING};
```

Criaremos agora um novo reducer para o estado de loading:

- `src/reducers/loading.js`

```jsx
import {SET_LOADING} from '../constants';

const initialState = false;

export default function loadingReducer(state = initialState, action) {
  switch (action.type) {
    case SET_LOADING:
      return action.data;

    default:
      return state;
  }
}
```

O novo reducer deve ser incluído na lista de reducers:

- `src/reducers/index.js`

```jsx
import {combineReducers} from 'redux';
import animaisReducer from './animais';
import usuarioLogadoReducer from './usuarioLogado';

// Novidade
import loadingReducer from './loading';

const rootReducer = combineReducers({
  animais: animaisReducer,
  usuarioLogado: usuarioLogadoReducer,

  // Novidade
  loading: loadingReducer,
});

export default rootReducer;
```

Vamos ajustar nossa action de Login para que também controle o estado de loading da tela:

- `actions.js`

```jsx
export function login(usuario, senha) {
  return dispatch => {
    // Novidade aqui
    dispatch({
      type: SET_LOADING,
      data: true,
    });

    return (
      loginAPI(usuario, senha)
        .then(res => {
          dispatch({
            type: LOGIN,
            data: {usuarioLogado: usuario, token: res.data.token},
          });
        })

        // Novidade aqui
        .finally(() => {
          dispatch({
            type: SET_LOADING,
            data: false,
          });
        })
    );
  };
}
```

Criaremos agora nosso componente `Carregando` que exibirá um spinner indicando que uma operação demorada está ocorrendo:

- `src/components/Carregando.js`

```jsx
import React, {Component} from 'react';
import {ActivityIndicator, StyleSheet, View} from 'react-native';
import {connect} from 'react-redux';

class Carregando extends Component {
  render() {
    return (
      this.props.loading && (
        <View style={styles.loading}>
          <ActivityIndicator size="large" />
        </View>
      )
    );
  }
}

const mapStateToProps = state => {
  return {
    loading: state.loading,
  };
};

const mapDispatchToProps = {};

export default connect(
  mapStateToProps,
  mapDispatchToProps,
)(Carregando);

const styles = StyleSheet.create({
  loading: {
    position: 'absolute',
    left: 0,
    right: 0,
    top: 0,
    bottom: 0,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
```

Agora basta inserir este novo componente em nosso componente principal:

- `App.js`

```jsx
export default class App extends Component {
  render() {
    return (
      <Provider store={store}>
        <Container>
          <Navigation />

          {/* Novidade aqui */}
          <Carregando />
        </Container>
      </Provider>
    );
  }
}
```

## Restringindo o "Voltar"

Talvez você não tenha percebido, mas após o usuário navegar para a tela de listagem, se ele pressionar o botão "voltar" do dispositivo ele retornará para a tela de login, isso não faz muito sentido, vamos corrigir este comportamento emitindo uma comando especial para a navegação:

- `Login.js`

```jsx
login = () => {
  this.props
    .login(this.state.usuario, this.state.senha)
    .then(() => {
      // Novidade aqui
      const resetAction = StackActions.reset({
        index: 0,
        actions: [NavigationActions.navigate({routeName: 'ListaAnimais'})],
      });
      this.props.navigation.dispatch(resetAction);
    })
    .catch(() =>
      Alerta.mensagem('Verifique o usuário e senha e tente novamente.'),
    );
};
```

Nossa aplicação já possui uma ótima estrutura básica e está pronta para a inclusão de novas funcionalidades!
