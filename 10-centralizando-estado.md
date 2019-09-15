# Centralizando o Estado

Podemos melhorar ainda mais deixando também o componente `Animal` sem um estado próprio, e mantendo o componente `ListaAnimais` como nossa único Container Component e única fonte da verdade.

Primeiramente vamos adicionar uma nova propriedade aos nossos dados, um `_id` para cada animal:

- `data.json`

```json
{
  "animais": [
    {
      "_id": "1",
      "nome": "Leão",
      "urlImagem": "https://upload.wikimedia.org/wikipedia/commons/4/40/Just_one_lion.jpg",
      "favoritoUsuarios": []
    },
    {
      "_id": "2",
      "nome": "Girafa",
      "urlImagem": "https://upload.wikimedia.org/wikipedia/commons/9/97/Namibie_Etosha_Girafe_02.jpg",
      "favoritoUsuarios": ["maria"]
    },
    {
      "_id": "3",
      "nome": "Gato",
      "urlImagem": "https://upload.wikimedia.org/wikipedia/commons/b/b2/WhiteCat.jpg",
      "favoritoUsuarios": ["maria", "paulo"]
    }
  ],
  "usuarioLogado": "jose"
}
```

Agora vamos ajustar o componente `Animal` para ser um _Presentational Component_:

- `Animal.js`

```jsx
const {width} = Dimensions.get('screen');

export default class Animal extends Component {
  isFavoritado(animal, usuarioLogado) {
    return !!animal.favoritoUsuarios.find(usuario => usuario === usuarioLogado);
  }

  render() {
    const {
      animal,
      usuarioLogado,
      favoritarCallback,
      desfavoritarCallback,
    } = this.props;

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
            favoritarCallback={() => favoritarCallback(animal)}
            desfavoritarCallback={() => desfavoritarCallback(animal)}
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
```

Toda a lógica e estado agora ficará concentrada no componente `ListaAnimais`:

- `ListaAnimais.js`

```jsx
export default class ListaAnimais extends Component {
  constructor(props) {
    super(props);

    this.state = {
      animais: animaisData,
      usuarioLogado: usuarioLogadoData,
    };
  }

  favoritar = animal => {
    const {usuarioLogado} = this.state;

    let novoAnimal = {...animal};

    novoAnimal.favoritoUsuarios = [
      ...novoAnimal.favoritoUsuarios,
      usuarioLogado,
    ];

    const novosAnimais = this.state.animais.map(a =>
      a._id === novoAnimal._id ? novoAnimal : a,
    );

    this.setState({animais: novosAnimais});
  };

  desfavoritar = animal => {
    const {usuarioLogado} = this.state;

    let novoAnimal = {...animal};

    novoAnimal.favoritoUsuarios = novoAnimal.favoritoUsuarios.filter(
      usuario => usuario !== usuarioLogado,
    );

    const novosAnimais = this.state.animais.map(a =>
      a._id === novoAnimal._id ? novoAnimal : a,
    );

    this.setState({animais: novosAnimais});
  };

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
              <Animal
                animal={item}
                usuarioLogado={usuarioLogado}
                favoritarCallback={this.favoritar}
                desfavoritarCallback={this.desfavoritar}
              />
            )}
            keyExtractor={item => item.nome}
          />
        </Content>
      </Container>
    );
  }
}
```

> Desafio: Você consegue centralizar o código que atualiza os animais em uma única função? Deste modo teríamos algo como:

```jsx
  favoritar = animal => {
    const {usuarioLogado} = this.state;

    let novoAnimal = {...animal};

    novoAnimal.favoritoUsuarios = [
      ...novoAnimal.favoritoUsuarios,
      usuarioLogado,
    ];

    this.atualizarAnimal(novoAnimal);
  };

  desfavoritar = animal => {
    const {usuarioLogado} = this.state;

    let novoAnimal = {...animal};

    novoAnimal.favoritoUsuarios = novoAnimal.favoritoUsuarios.filter(
      usuario => usuario !== usuarioLogado,
    );

    this.atualizarAnimal(novoAnimal);
  };

  atualizarAnimal(animal) {
      // TODO
  }
```

<!--
  atualizarAnimal = novoAnimal => {
    const novosAnimais = this.state.animais.map(a =>
      a._id === novoAnimal._id ? novoAnimal : a,
    );

    this.setState({animais: novosAnimais});
  };
-->
