# Cadastramento de Animais

Vamos dar mais vida ao nosso aplicativo permitindo que o usuário cadastre novos animais.

O primeiro passo é fazer o básico, uma tela simples, só com uma mensagem mesmo para que o usuário efetue o cadastramento.

Vamos à nossa tela:

- `src/components/CadastroAnimal.js`

```jsx
import {Content} from 'native-base';
import React, {Component} from 'react';
import {Text} from 'react-native';
import {connect} from 'react-redux';

class CadastroAnimal extends Component {
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
)(CadastroAnimal);
```

Em seguida, devemos registrar esta nova tela em nosso fluxo, no `App.js`:

- `App.js`

```jsx
const AppNavigator = createStackNavigator(
  {
    Login,
    ListaAnimais,
    CadastroAnimal,
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
        onPress={() => this.props.navigation.navigate('CadastroAnimal')}>
        <Icon name="add" />
      </Fab>
    </View>
  );
}
```

A navegação para a próxima tela já deve estar funcionando, podemos voltar para a tela de listagem clicando no botão voltar da barra de status. Porém, estamos mais acostumados com um botão "voltar" na barra de título da aplicação. Além disso, também seria interessante que a barra de título fosse alterada informando que está ocorrendo uma inclusão, podemos conseguir tudo isso utilizando uma propriedade estática chamada `navigationOptions`:

- `src/components/CadastroAnimal.js`

```jsx
class CadastroAnimal extends Component {
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

- Instalar a biblioteca:

```bash
>
```

<!-- https://docs.nativebase.io/docs/examples/ReduxFormExample.html -->

npm i validator

- http://bit.ly/rn-elefante
- http://bit.ly/rn-tigre
