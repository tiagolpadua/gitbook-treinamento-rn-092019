# Cadastramento de Animais

Vamos dar mais vida ao nosso aplicativo permitindo que o usuário inclua novos animais.

O primeiro passo é fazer o básico, uma tela simples, só com uma mensagem mesmo para que o usuário efetue a inclusão.

Vamos à nossa tela:

- `src/components/IncluirAnimal.js`

```jsx
import {Content} from 'native-base';
import React, {Component} from 'react';
import {Text} from 'react-native';
import {connect} from 'react-redux';

class IncluirAnimal extends Component {
  render() {
    return (
      <Content padder>
        <Text>Tela de Cadastro de Animal</Text>
      </Content>
    );
  }
}

const mapStateToProps = () => ({});

const mapDispatchToProps = {};

export default connect(
  mapStateToProps,
  mapDispatchToProps,
)(IncluirAnimal);
```

Em seguida, devemos registrar esta nova tela em nosso fluxo, no `App.js`:

- `App.js`

```jsx
const AppNavigator = createStackNavigator(
  {
    Login,
    ListaAnimais,
    IncluirAnimal,
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

Agora temos que navegar para esta nova tela, podemos fazer isso adicionando um novo botão à lista de animais. Você já deve ter visto o padrão de _Floating Action Button_ em alguma app, é um botão flutuante que fica próximo ao canto inferior direito da tela. O NativeBase já nos fornece um botão neste estilo, vamos utilizá-lo:

- `ListaAnimais.js`

```jsx
render() {
  const {animais} = this.props;
  return (
    <View style={styles.container}>
      <Content padder>
        <FlatList
          data={animais}
          renderItem={({item}) => <Animal animal={item} />}
          keyExtractor={item => item.nome}
        />
      </Content>
      <Fab
        containerStyle={{}}
        style={styles.fab}
        position="bottomRight"
        onPress={() => this.props.navigation.navigate('IncluirAnimal')}>
        <Icon name="add" />
      </Fab>
    </View>
  );
}
```

A navegação para a próxima tela já deve estar funcionando, podemos voltar para a tela de listagem clicando no botão voltar da barra de status. Porém, estamos mais acostumados com um botão "voltar" na barra de título da aplicação. Além disso, também seria interessante que a barra de título fosse alterada informando que está ocorrendo uma inclusão, podemos conseguir tudo isso utilizando uma propriedade estática chamada `navigationOptions`:

- `src/components/IncluirAnimal.js`

```jsx
class IncluirAnimal extends Component {
  static navigationOptions = ({navigation}) => ({
    header: (
      <Header>
        <Left>
          <Button transparent onPress={() => navigation.goBack()}>
            <Icon name="arrow-back" />
          </Button>
        </Left>
        <Body>
          <Title>Incluir Animal</Title>
        </Body>
        <Right />
      </Header>
    ),
  });
  render() {
    return (
      <Content padder>
        <Text>Tela de Cadastro de Animal</Text>
      </Content>
    );
  }
}
```

Vamos passar agora para o formulário, ele é bem simples, permite que se inclua o nome do animal e uma URL:

```jsx
  render() {
    return (
      <Content padder>
        <Form>
          <Item>
            <Input placeholder="Nome" />
          </Item>
          <Item last>
            <Input placeholder="URL Imagem" />
          </Item>
          <Button
            full
            primary
            style={styles.botaoSalvar}
            onPress={() => console.warn('Salvar!')}>
            <Text>Salvar</Text>
          </Button>
        </Form>
      </Content>
    );
  }
}

// ...

const styles = StyleSheet.create({
  botaoSalvar: {marginTop: 10},
});
```

Ótimo, agora precisamos capturar os dados do formulário e submetermos para nossa API, poderíamos fazer isso de uma forma mais básica, mas optaremos por usar a biblioteca _Redux Form_, uma vez que já estamos utilizando o Redux em nosso projeto.

## Redux Form

O Redux Form irá oferecer uma forma padronizada de se trabalhar com formulários e suas validações em uma aplicação React Native que utiliza Redux.

Para utilizar a biblioteca devemos seguir alguns passos:

> Devido a uma incompatibilidade da versão mais recente do `react-redux` com o `redux-forms`, é necessário fazer o downgrade do `react-redux` para a versão 7.0.0 [https://github.com/erikras/redux-form/issues/4509](https://github.com/erikras/redux-form/issues/4509), para isso, apague a pasta `node_modules` e altere a versão do `react-redux` para 7.0.0, em seguida faça novamente o `npm install`;

- Instalar a biblioteca `redux-form`:

```bash
> npm install redux-form
```

- Vamos fazer a validação da URL da imagem utilizando a biblioteca `validator`, sendo assim instale-a também:

```bash
> npm install validator
```

> Como fizemos um downgrade, é interessante no próximo start de nossa aplicação, limpar o cache:

```bash
> react-native start --reset-cache
```

Agora chegou o momento de integrar o `redux-form` em nosso projeto.

Uma das exigências da biblioteca é que devemos separar a nossa tela entre o componente de tela e o formulário em si. Esta separação pode ser útil para que possamos por exemplo reutilizar o mesmo formulário numa funcionalidade de atualização do animal.

- `IncluirAnimal.js`

```jsx
import {Button, Header, Icon, Left, Right, Body, Title} from 'native-base';
import React, {Component} from 'react';
import {connect} from 'react-redux';
import MantemAnimalForm from './MantemAnimalForm';
import {incluirAnimal} from '../actions';
import {bindActionCreators} from 'redux';
import Alerta from '../util/Alerta';

class IncluirAnimal extends Component {
  static navigationOptions = ({navigation}) => ({
    header: (
      <Header>
        <Left>
          <Button transparent onPress={() => navigation.goBack()}>
            <Icon name="arrow-back" />
          </Button>
        </Left>
        <Body>
          <Title>Incluir Animal</Title>
        </Body>
        <Right />
      </Header>
    ),
  });

  render() {
    return <MantemAnimalForm />;
  }
}

const mapStateToProps = () => ({});

const mapDispatchToProps = {};

export default connect(
  mapStateToProps,
  mapDispatchToProps,
)(IncluirAnimal);
```

Agora vamos ao componente `MantemAnimalForm`. Para este componente, vamos seguir o manual da biblioteca `redux-form` que nos orienta a criar uma função de validação que deve retornar um objeto contendo os erros do formulário, além de uma função `renderInput` que irá renderizar os componentes em tela, apresentando as mensagens de erro adequadas:

- `src/components/MantemAnimalForm.js`

```jsx
import {Button, Content, Form, Input, Item, Label, Text} from 'native-base';
import React, {Component} from 'react';
import {StyleSheet} from 'react-native';
import {Field, reduxForm} from 'redux-form';
import validator from 'validator';

const validate = values => {
  const error = {};
  error.nome = '';
  error.urlImagem = '';
  const nome = values.nome || '';
  const urlImagem = values.urlImagem || '';

  if (!validator.isURL(urlImagem)) {
    error.urlImagem = 'URL inválida';
  }

  if (nome.length < 3 || nome.length > 15) {
    error.nome = 'Nome deve ter entre 3 e 15 caracteres';
  }

  return error;
};

class MantemAnimalForm extends Component {
  renderInput = ({input, label, meta: {touched, error}}) => {
    var hasError = false;
    if (error !== undefined) {
      hasError = true;
    }
    return (
      <Item floatingLabel error={hasError}>
        <Label>
          {label} {touched && hasError && ` - ${error}`}
        </Label>
        <Input {...input} />
      </Item>
    );
  };

  render() {
    const {invalid, handleSubmit} = this.props;

    return (
      <Content padder>
        <Form>
          <Field name="nome" label="Nome" component={this.renderInput} />
          <Field
            name="urlImagem"
            label="URL Imagem"
            component={this.renderInput}
          />
          <Button
            disabled={invalid}
            bordered={invalid}
            full
            primary
            style={styles.botaoSalvar}
            onPress={handleSubmit}>
            <Text>Salvar</Text>
          </Button>
        </Form>
      </Content>
    );
  }
}

export default reduxForm({
  form: 'mantemAnimal',
  validate,
})(MantemAnimalForm);

const styles = StyleSheet.create({
  botaoSalvar: {marginTop: 10},
});
```

A configuração de nosso rootReducer deve ser ajustada incluindo o reducer do `redux-forms`:

```jsx
import {combineReducers} from 'redux';
import animaisReducer from './animais';
import usuarioLogadoReducer from './usuarioLogado';
import loadingReducer from './loading';

// Novidade aqui
import {reducer as formReducer} from 'redux-form';

const rootReducer = combineReducers({
  animais: animaisReducer,
  usuarioLogado: usuarioLogadoReducer,
  loading: loadingReducer,

  // Novidade aqui
  form: formReducer,
});

export default rootReducer;
```

Mas para que nossa funcionalidade seja concluída, será necessário criar uma função que de fato irá incluir o animal na base, por enquanto vamos "mocá-la" no componente `IncluirAnimal`:

- `IncluirAnimal.js`

```jsx
class IncluirAnimal extends Component {
  // Código atual omitido

  handleIncluirAnimal = animal => {
    animal.favoritoUsuarios = [];
    console.warn('Animal a ser incluído: ', animal);
  };

  render() {
    return <MantemAnimalForm onSubmit={this.handleIncluirAnimal} />;
  }
}
```

## Acionando a API de inclusão

Nossa aplicação deve estar validanto o formulário e já tem um animal pronto para ser enviado à nossa API. O próximo passo é realizar esta integração.

- `constants.js`

```jsx
const LOGIN = 'LOGIN';
const FAVORITAR = 'FAVORITAR';
const DESFAVORITAR = 'DESFAVORITAR';
const CARREGAR_ANIMAIS = 'CARREGAR_ANIMAIS';
const SET_LOADING = 'SET_LOADING';

// Novidade aqui
const INCLUIR_ANIMAL = 'INCLUIR_ANIMAL';

export {
  LOGIN,
  FAVORITAR,
  DESFAVORITAR,
  CARREGAR_ANIMAIS,
  SET_LOADING,
  // Novidade aqui
  INCLUIR_ANIMAL,
};
```

Criamos uma função que irá disparar a ação para o reducer caso a API seja bem sucedida:

- `actions.js`

```jsx
export function incluirAnimal(animal) {
  return dispatch =>
    incluirAnimalAPI(animal).then(res => {
      dispatch({
        type: INCLUIR_ANIMAL,
        data: res.data,
      });
    });
}
```

Ajustamos nosso reducer para lidar com a inclusão do animal:

- `animais.js`

```jsx
export default function animaisReducer(state = initialState, action) {
  switch (action.type) {
    case CARREGAR_ANIMAIS:
      return action.data;

    case INCLUIR_ANIMAL:
      return [...state, action.data];

    // Código omitido
  }
}
```

Por fim, removemos o mock do componente `IncluirAnimal` para que ele acione a função correta de nossas actions, caso a inclusão seja bem sucedida, ele deve navegar para `ListaAnimais`, caso contrário irá mostrar a mensagem de erro:

- `IncluirAnimal`

```jsx
handleIncluirAnimal = animal => {
  animal.favoritoUsuarios = [];
  this.props
    .incluirAnimal(animal)
    .then(() => this.props.navigation.navigate('ListaAnimais'))
    .catch(err => Alerta.mensagem('Erro ao incluir animal: ' + err.message));
};
```

E aí, deu certo? Ainda não, mas falta pouco!

Recebemos a mensagem de erro com código 403, isso ocorre pois não enviamos o token de autenticação. Pra fazer isso é bem simples com o `axios`, basta salvarmos o token no momento da resposta da API de login:

- `src/api/index.js`

```jsx
export function loginAPI(usuario, senha) {
  return api.post('/login', {usuario, senha}).then(res => {
    api.defaults.headers.common.Authorization = res.data.token;
    return res;
  });
}
```

Agora nosso formulário de inclusão já está funcionando corretamente, foi trabalhoso mas valeu a pena.

## Uma última melhoria

Gostaríamos de exibir o indicador de loading enquanto estiver ocorrendo o processamento da API, voce se lembra de como fizemos no login? No entanto, podemos facilitar criando uma função wrapper para que exiba o loading em todos os nossos processamentos assíncronos:

- `actions.js`

```jsx
import {carregarAnimaisAPI, loginAPI, incluirAnimalAPI} from './api';
import {
  LOGIN,
  CARREGAR_ANIMAIS,
  DESFAVORITAR,
  FAVORITAR,
  SET_LOADING,
  INCLUIR_ANIMAL,
} from './constants';

// Uma função nova que funciona como um wrapper
function loadingWrapper(asyncFunc) {
  return dispatch => {
    dispatch({
      type: SET_LOADING,
      data: true,
    });
    return asyncFunc(dispatch).finally(() => {
      dispatch({
        type: SET_LOADING,
        data: false,
      });
    });
  };
}

export function login(usuario, senha) {
  return loadingWrapper(dispatch =>
    loginAPI(usuario, senha).then(res => {
      dispatch({
        type: LOGIN,
        data: {usuarioLogado: usuario, token: res.data.token},
      });
    }),
  );
}

export function carregarAnimais() {
  return loadingWrapper(dispatch =>
    carregarAnimaisAPI().then(res => {
      dispatch({
        type: CARREGAR_ANIMAIS,
        data: res.data,
      });
    }),
  );
}

export function incluirAnimal(animal) {
  return loadingWrapper(dispatch =>
    incluirAnimalAPI(animal).then(res => {
      dispatch({
        type: INCLUIR_ANIMAL,
        data: res.data,
      });
    }),
  );
}

// Código omitido
```

Nossa funcionalidade de inclusão de animais está concluída!
