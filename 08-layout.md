# Melhorando o Layout

Nossa aplicação já está lidando bem com as `props` e o `state`, mas algo que falta melhorarmos é o visual. É o que faremos agora com o auxílio dos componentes da biblioteca _NativeBase_.

## Anatomia básica da tela

O componente inicial de um layout utilizando o `NativeBase` é o container, dentro do container podemos ter mais três componentes, um _header_, um _content_ e um _footer_. Inicialmente definiremos apenas um cabeçalho básico e o conteúdo:

- `ListaAnimais`

```jsx
import {Container, Content, Header, Title} from 'native-base';
import React, {Component} from 'react';
import {FlatList, StyleSheet} from 'react-native';
import Animal from './Animal';

export default class ListaAnimais extends Component {
  //...

  render() {
    const {animais, usuarioLogado} = this.state;
    return (
      <Container>
        <Header style={styles.header}>
          <Title>Controle de Animais</Title>
        </Header>
        <Content padder>
          <FlatList
            data={animais}
            renderItem={({item}) => (
              <Animal animal={item} usuarioLogado={usuarioLogado} />
            )}
            keyExtractor={item => item.nome}
          />
        </Content>
      </Container>
    );
  }
}

const styles = StyleSheet.create({
  header: {height: 30},
});
```

Já que estamos melhorando o componente de `ListaAnimais`, podemos refatorá-lo para consumir os dados fixos a partir de um json de dados que será fornecido. Para isso, crie um arquivo `data.json` na raiz do projeto:

- `data.json`

```json
{
  "animais": [
    {
      "nome": "Leão",
      "urlImagem": "https://upload.wikimedia.org/wikipedia/commons/4/40/Just_one_lion.jpg",
      "favoritoUsuarios": []
    },
    {
      "nome": "Girafa",
      "urlImagem": "https://upload.wikimedia.org/wikipedia/commons/9/97/Namibie_Etosha_Girafe_02.jpg",
      "favoritoUsuarios": ["maria"]
    },
    {
      "nome": "Gato",
      "urlImagem": "https://upload.wikimedia.org/wikipedia/commons/b/b2/WhiteCat.jpg",
      "favoritoUsuarios": ["maria", "paulo"]
    }
  ],
  "usuarioLogado": "jose"
}
```

Agora, vamos ajustar o componente `ListaAnimais` para consumir este json:

- `ListaAnimais.js`

```jsx
import {Container, Content, Header, Title} from 'native-base';
import React, {Component} from 'react';
import {FlatList, StyleSheet} from 'react-native';
import Animal from './Animal';
import {
  animais as animaisData,
  usuarioLogado as usuarioLogadoData,
} from '../../data.json';

export default class ListaAnimais extends Component {
  constructor(props) {
    super(props);

    this.state = {
      animais: animaisData,
      usuarioLogado: usuarioLogadoData,
    };
  }

  //...
}

const styles = StyleSheet.create({
  header: {height: 30},
});
```

Perceba como nosso componente ficou bem mais limpo agora!

## Melhorando a exibição do Animal

Passaremos agora para o componente Animal, para um layout melhor, utilizaremos o componente _Card_ da biblioteca NativeBase: (https://docs.nativebase.io/Components.html#card-def-headref)

- `Animal.js`

```jsx
import {Body, Card, CardItem, Icon} from 'native-base';
import React, {Component} from 'react';
import {
  Dimensions,
  Image,
  StyleSheet,
  Text,
  TouchableOpacity,
} from 'react-native';

const {width} = Dimensions.get('screen');

export default class Animal extends Component {
  //...

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
          {this.botaoFavorito(animal, usuarioLogado)}
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
