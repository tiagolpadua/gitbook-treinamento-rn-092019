# Alterando Animais

Muito da estrutura para realizar a alteração de um animal já está pronta pois reutilizaremos o formulário de cadastramento de animais. Mas haverão algumas alterações funcamentais, por exemplo, o componente `AlterarAnimal` deve receber por parâmetro da navegação o animal a ser alterado:

- `AlterarAnimal.js`

```jsx
import {Body, Button, Header, Icon, Left, Right, Title} from 'native-base';
import React, {Component} from 'react';
import {Text} from 'react-native';
import {connect} from 'react-redux';

class AlterarAnimal extends Component {
  static navigationOptions = ({navigation}) => ({
    header: (
      <Header>
        <Left>
          <Button transparent onPress={() => navigation.goBack()}>
            <Icon name="arrow-back" />
          </Button>
        </Left>
        <Body>
          <Title>Alterar Animal</Title>
        </Body>
        <Right />
      </Header>
    ),
  });

  handleAlterarAnimal = animal => {
    console.warn('Atualizar animal: ', animal);
  };

  render() {
    const {navigation} = this.props;
    const animal = navigation.getParam('animal');
    return <Text>{animal.nome}</Text>;
  }
}

const mapStateToProps = () => ({});

const mapDispatchToProps = {};

export default connect(
  mapStateToProps,
  mapDispatchToProps,
)(AlterarAnimal);
```

Devemos registrar no componente `App` nossa nova tela:

- `App.js`

```jsx
import {Body, Container, Header, Left, Title} from 'native-base';
import React, {Component} from 'react';
import {StyleSheet} from 'react-native';
import {createAppContainer} from 'react-navigation';
import {createStackNavigator} from 'react-navigation-stack';
import {Provider} from 'react-redux';
import Carregando from './components/Carregando';
import IncluirAnimal from './components/IncluirAnimal';
import AlterarAnimal from './components/AlterarAnimal';
import ListaAnimais from './components/ListaAnimais';
import Login from './components/Login';
import configureStore from './configureStore';

const store = configureStore();

const AppNavigator = createStackNavigator(
  {
    Login,
    ListaAnimais,
    IncluirAnimal,
    // Novidade aqui
    AlterarAnimal,
  },
  {
    initialRouteName: 'Login',
    defaultNavigationOptions: {
      header: () => (
        <Header style={styles.header}>
          <Left />
          <Body>
            <Title>Controle de Animais</Title>
          </Body>
        </Header>
      ),
    },
  },
);

// Código omitido
```

O componente `Animal` deverá exibir um ícone que permita que o usuário edite aquele animal:

- `Animal.js`

```jsx
import {Body, Card, CardItem, Right, Icon} from 'native-base';
import React, {Component} from 'react';
import {
  Dimensions,
  Image,
  StyleSheet,
  Text,
  TouchableOpacity,
} from 'react-native';
import {connect} from 'react-redux';
import BotaoFavoritar from './BotaoFavoritar';
import {favoritar, desfavoritar} from '../actions';
import {bindActionCreators} from 'redux';

const {width} = Dimensions.get('screen');

class Animal extends Component {
  isFavoritado(animal, usuarioLogado) {
    return !!animal.favoritoUsuarios.find(usuario => usuario === usuarioLogado);
  }

  render() {
    const {animal, navigation} = this.props;

    return (
      <Card>
        <CardItem header bordered>
          <Text style={styles.nomeAnimal}>{animal.nome}</Text>

          {/* Novidade aqui */}
          <Right>
            <TouchableOpacity
              onPress={() => navigation.navigate('AlterarAnimal', {animal})}>
              <Icon name="create" style={styles.icone} />
            </TouchableOpacity>
          </Right>
        </CardItem>
        {/* Código omitido */}
      </Card>
    );
  }
}

// Código omitido

const styles = StyleSheet.create({
  // Novidades aqui
  nomeAnimal: {fontSize: 18, fontWeight: 'bold', flex: 1},
  icone: {fontSize: 30, color: 'black'},

  imagemAnimal: {width: width * 0.7, height: width * 0.7},
  imageContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});
```

Porém, para que o objeto `navigation` esteja disponível em `Animal`, ele deve ser passado via props por `ListaAnimal`:

- `ListaAnimal`

```jsx
class ListaAnimais extends Component {
  componentDidMount() {
    this.props.carregarAnimais();
  }

  render() {
    // Novidade aqui
    const {animais, navigation} = this.props;
    return (
      <View style={styles.container}>
        <Content padder>
          {/* Novidade aqui */}
          <FlatList
            data={animais}
            renderItem={({item}) => (
              <Animal navigation={navigation} animal={item} />
            )}
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
}

// Código omitido
```

Neste ponto o ícone de edição já deve estar funcionando e a tela de edição deve estar exibindo apenas o nome do animal.

## Ajustes no formulário

Vamos ajustar agora nosso componente de formulário para que preencha os valores padrão do animal sendo alterado, para isso, podemos criar uma função chamada `componentDidMount` (que está ligada ao ciclo de vida do React) e acionar o método `initialize` que é fornecido pelo `Redux Form`:

- `MantemAnimalForm`

```jsx
  componentDidMount() {
    let {animal, initialize} = this.props;
    animal = animal || {};
    initialize({
      nome: animal.nome,
      urlImagem: animal.urlImagem,
      _id: animal._id,
      favoritoUsuarios: animal.favoritoUsuarios || [],
    });
  }
```

O componente `AlterarAnimal` deverá agora montar o componente `MantemAnimalForm` passando o animal que está sendo alterado como uma prop:

- `AlterarAnimal`

```jsx
class AlterarAnimal extends Component {
  // Código omitido

  handleAlterarAnimal = animal => {
    console.warn('Atualizar animal: ', animal);
  };

  render() {
    const {navigation} = this.props;
    const animal = navigation.getParam('animal');

    // Novidade aqui
    return (
      <MantemAnimalForm animal={animal} onSubmit={this.handleAlterarAnimal} />
    );
  }
}

// Código omitido
```

Observe que o warn exibido contém todos os dados do animal, não somente os que foram alterados, isso é importante para nossa API de atualização.

## Acionando a API

Já podemos passar agora para a última parte que é a integração com a nossa API.

Primeiro criamos uma nova constante:

- `constants.js`

```jsx
const LOGIN = 'LOGIN';
const FAVORITAR = 'FAVORITAR';
const DESFAVORITAR = 'DESFAVORITAR';
const CARREGAR_ANIMAIS = 'CARREGAR_ANIMAIS';
const SET_LOADING = 'SET_LOADING';
const INCLUIR_ANIMAL = 'INCLUIR_ANIMAL';

// Novidade aqui
const ALTERAR_ANIMAL = 'ALTERAR_ANIMAL';

export {
  LOGIN,
  FAVORITAR,
  DESFAVORITAR,
  CARREGAR_ANIMAIS,
  SET_LOADING,
  INCLUIR_ANIMAL,
  // Novidade aqui
  ALTERAR_ANIMAL,
};
```

Em seguida ajustamos nossa API:

- `api/index.js`

```jsx
export function atualizarAnimalAPI(animal) {
  return api.put(`/animais/${animal._id}`, animal);
}
```

O reducer de animais também deve ser atualizado para suportar a nova ação:

- `animais.js`

```jsx
const initialState = [];

function atualizaAnimal(listaAnimais, animal) {
  return listaAnimais.map(a => (a._id === animal._id ? animal : a));
}

export default function animaisReducer(state = initialState, action) {
  switch (action.type) {
    case CARREGAR_ANIMAIS:
      return action.data;

    case INCLUIR_ANIMAL:
      return [...state, action.data];

    case ALTERAR_ANIMAL:
      return atualizaAnimal(state, action.data);

    // Código omitido
  }
}
```

Criaremos também uma função que irá disparar nossa ação de alteração de animal:

- `actions.js`

```jsx
export function alterarAnimal(animal) {
  return loadingWrapper(dispatch =>
    alterarAnimalAPI(animal).then(res => {
      dispatch({
        type: ALTERAR_ANIMAL,
        data: res.data,
      });
    }),
  );
}
```

O último passo é atualizar o componente `AlterarAnimal` para chamar nossa nova ação:

- `AlterarAnimal.js`

```jsx
  // Código Omitido

  // Novidade aqui
  handleAlterarAnimal = animal => {
    this.props
      .alterarAnimal(animal)
      .then(() => this.props.navigation.navigate('ListaAnimais'))
      .catch(err => Alerta.mensagem('Erro ao alterar animal: ' + err.message));
  };

  render() {
    const {navigation} = this.props;
    const animal = navigation.getParam('animal');
    return (
      <MantemAnimalForm animal={animal} onSubmit={this.handleAlterarAnimal} />
    );
  }
}

const mapStateToProps = () => ({});

// Novidade aqui
const mapDispatchToProps = dispatch =>
  bindActionCreators({alterarAnimal}, dispatch);

// Código Omitido
```

Tudo pronto, nosso aplicativo já está cadastrando e alterando animais.
