# Um componente para favoritar

Uma das principais características do React é o foco na componentização. Até o momento, nossa aplicação possui apenas dois componentes, e o componente `Animal` possui uma lógica muito grande relacionada a funcionalidade de favoritar. Vamos melhorar isso, criando um componente exclusivo para o Botão Favoritar:

- `src\components\BotaoFavoritar.js`

```jsx
import {Icon} from 'native-base';
import React, {Component} from 'react';
import {TouchableOpacity} from 'react-native';

export default class BotaoFavoritar extends Component {
  constructor(props) {
    super(props);
    this.state = {
      animal: this.props.animal,
      usuarioLogado: this.props.usuarioLogado,
    };
  }

  isFavoritado(animal, usuarioLogado) {
    return !!animal.favoritoUsuarios.find(usuario => usuario === usuarioLogado);
  }

  favoritar = (animal, usuarioLogado) => {
    let novoAnimal = {...animal};

    novoAnimal.favoritoUsuarios = [
      ...novoAnimal.favoritoUsuarios,
      usuarioLogado,
    ];

    this.setState({animal: novoAnimal});
  };

  desfavoritar = (animal, usuarioLogado) => {
    let novoAnimal = {...animal};

    novoAnimal.favoritoUsuarios = novoAnimal.favoritoUsuarios.filter(
      usuario => usuario !== usuarioLogado,
    );

    this.setState({animal: novoAnimal});
  };

  render() {
    const {animal, usuarioLogado} = this.state;

    let favoritado = this.isFavoritado(animal, usuarioLogado);

    if (favoritado) {
      return (
        <TouchableOpacity
          onPress={() => this.desfavoritar(animal, usuarioLogado)}>
          <Icon name="star" />
        </TouchableOpacity>
      );
    } else {
      return (
        <TouchableOpacity onPress={() => this.favoritar(animal, usuarioLogado)}>
          <Icon name="star-outline" />
        </TouchableOpacity>
      );
    }
  }
}
```

Com este botão criado, podemos otimizar o componente `Animal` para que passe a utilizar o componente `BotaoFavoritar`:

- `Animal.js`

```jsx
export default class Animal extends Component {
  constructor(props) {
    super(props);
    this.state = {
      animal: this.props.animal,
    };
  }

  render() {
    const {animal} = this.state;
    const {usuarioLogado} = this.props;

    return (
      <Card>
        <CardItem header bordered>
          <Text style={styles.nomeAnimal}>{animal.nome}</Text>
        </CardItem>
        <CardItem bordered>
          <Body style={styles.imageContainer}>
            <Image
              source={{
                uri: animal.urlImagem,
              }}
              style={styles.imagemAnimal}
            />
          </Body>
        </CardItem>
        <CardItem footer bordered>
          <BotaoFavoritar animal={animal} usuarioLogado={usuarioLogado} />
          <Text>
            Este animal
            {animal.favoritoUsuarios.length > 0
              ? ` já foi favoritado por ${animal.favoritoUsuarios.length} usuário(s)`
              : ' ainda não foi favoritado'}
          </Text>
        </CardItem>
      </Card>
    );
  }
}
```

Agora o componente `Animal` ficou muito mais simples. A aplicação deve estar funcionando, porém, quando se favorita um animal a contagem de favoritos não está mais sendo atualizada, o que pode ter ocorrido?

O problema é que estamos "espalhando" o estado de nossa aplicação através de diversos componentes. Os objetos presentes na lista de animais que estão no componente `ListaAnimais` não são os mesmos objetos presentes em `Animal` e `BotaoFavoritar`.

Para resolver este problema existem diversas opções, a primeira é utilizar uma estratégia chamada de `Container Components` e `Presentational Components`. Esta estratégia baseia-se em manter o estado em um componente pai, os componentes filhos, quando desejam atualizar seu estado, devem fazer isso acionando eventos do componente pai.

Vamos começar a implantar esta estratégia entre o componente `Animal` e o `BotaoFavoritar`. O primeiro passo é manter o estado as funções que alteram o estado no componente `Animal`, passando somente referências ao `BotaoFavoritar`:

- `Animal.js`

```jsx
import {Body, Card, CardItem} from 'native-base';
import React, {Component} from 'react';
import {Dimensions, Image, StyleSheet, Text} from 'react-native';
import BotaoFavoritar from './BotaoFavoritar';

const {width} = Dimensions.get('screen');

export default class Animal extends Component {
  constructor(props) {
    super(props);
    this.state = {
      animal: this.props.animal,
    };
  }

  isFavoritado(animal, usuarioLogado) {
    return !!animal.favoritoUsuarios.find(usuario => usuario === usuarioLogado);
  }

  favoritar = () => {
    const {animal} = this.state;
    const {usuarioLogado} = this.props;

    let novoAnimal = {...animal};

    novoAnimal.favoritoUsuarios = [
      ...novoAnimal.favoritoUsuarios,
      usuarioLogado,
    ];

    this.setState({animal: novoAnimal});
  };

  desfavoritar = () => {
    const {animal} = this.state;
    const {usuarioLogado} = this.props;

    let novoAnimal = {...animal};

    novoAnimal.favoritoUsuarios = novoAnimal.favoritoUsuarios.filter(
      usuario => usuario !== usuarioLogado,
    );

    this.setState({animal: novoAnimal});
  };

  render() {
    const {animal} = this.state;
    const {usuarioLogado} = this.props;

    return (
      <Card>
        <CardItem header bordered>
          <Text style={styles.nomeAnimal}>{animal.nome}</Text>
        </CardItem>
        <CardItem bordered>
          <Body style={styles.imageContainer}>
            <Image
              source={{
                uri: animal.urlImagem,
              }}
              style={styles.imagemAnimal}
            />
          </Body>
        </CardItem>
        <CardItem footer bordered>
          <BotaoFavoritar
            favoritado={this.isFavoritado(animal, usuarioLogado)}
            favoritarCallback={this.favoritar}
            desfavoritarCallback={this.desfavoritar}
          />
          <Text>
            Este animal
            {animal.favoritoUsuarios.length > 0
              ? ` já foi favoritado por ${animal.favoritoUsuarios.length} usuário(s)`
              : ' ainda não foi favoritado'}
          </Text>
        </CardItem>
      </Card>
    );
  }
}

const styles = StyleSheet.create({
  nomeAnimal: {fontSize: 18, fontWeight: 'bold'},
  imagemAnimal: {width: width * 0.7, height: width * 0.7},
  imageContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});
```

Agora atualizamos o `BotaoFavoritar` para que não tenha mais um estado próprio e acione as funções que lhe foram passadas como callback:

- `BotaoFavoritar.js`

```jsx
import {Icon} from 'native-base';
import React, {Component} from 'react';
import {TouchableOpacity} from 'react-native';

export default class BotaoFavoritar extends Component {
  render() {
    const {favoritado, favoritarCallback, desfavoritarCallback} = this.props;

    if (favoritado) {
      return (
        <TouchableOpacity onPress={desfavoritarCallback}>
          <Icon name="star" />
        </TouchableOpacity>
      );
    } else {
      return (
        <TouchableOpacity onPress={favoritarCallback}>
          <Icon name="star-outline" />
        </TouchableOpacity>
      );
    }
  }
}
```
