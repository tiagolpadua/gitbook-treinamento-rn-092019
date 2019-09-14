# Uma lista de usuários

Se analisarmos com mais profundidade nossa estrutura de dados veremos que há uma falha pois nosso sistema será multiusuário, e como podemos saber se foi o usuário atual que de fato favoritou a foto? Para corrigir isso, devemos transformar a propriedade "favoritado" em uma lista de nomes de usuários que favoritaram a foto.

Esta alteração é bem impactante, a primeira alteração é ajustar nosso componente `ListaAnimais` para que os animais tenham uma nova propriedade e também haja o estado `usuarioLogado`:

- `ListaAnimais.js`

```jsx
export default class ListaAnimais extends Component {
  constructor(props) {
    super(props);

    // Novidades aqui
    this.state = {
      animais: [
        {
          nome: 'Leão',
          urlImagem:
            'https://upload.wikimedia.org/wikipedia/commons/4/40/Just_one_lion.jpg',
          favoritoUsuarios: [],
        },
        {
          nome: 'Girafa',
          urlImagem:
            'https://upload.wikimedia.org/wikipedia/commons/9/97/Namibie_Etosha_Girafe_02.jpg',
          favoritoUsuarios: ['maria'],
        },
        {
          nome: 'Gato',
          urlImagem:
            'https://upload.wikimedia.org/wikipedia/commons/b/b2/WhiteCat.jpg',
          favoritoUsuarios: ['maria', 'paulo'],
        },
      ],
      usuarioLogado: 'jose',
    };
  }

  render() {
    const {animais, usuarioLogado} = this.state;
    return (
      <View>
        {/* Novidades aqui */}
        <FlatList
          data={animais}
          renderItem={({item}) => (
            <Animal animal={item} usuarioLogado={usuarioLogado} />
          )}
          keyExtractor={item => item.nome}
        />
      </View>
    );
  }
}
```

Agora ajustaremos o componente `Animal` para as novas `props`. A lógica de identificar se o usuário atual já favoritou ou não um animal está mais complicada, por isso será isolada em uma função `isFavoritado`. Também teremos dois métodos distintos, um fara `favoritar` e outro para `desfavoritar`:

- `Animal.js`

```jsx
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

  botaoFavorito(animal, usuarioLogado) {
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

  render() {
    const {animal} = this.state;
    const {usuarioLogado} = this.props;

    return (
      <View>
        <Text style={styles.nomeAnimal}>{animal.nome}</Text>
        <Image
          source={{
            uri: animal.urlImagem,
          }}
          style={styles.imagemAnimal}
        />
        {this.botaoFavorito(animal, usuarioLogado)}
        <Text>
          Foi favoritado: {this.isFavoritado(animal, usuarioLogado) + ''}
        </Text>
      </View>
    );
  }
}
```

Vamos deixar o texto do rodapé da imagem um pouco mais interessante informando quantas vezes o animal já foi favoritado, caso ele não tenha sido favoritado nenhuma vez, devemos exibir "Este animal ainda não foi favoritado":

- `Animal.js`

```jsx
  render() {
    const {animal} = this.state;
    const {usuarioLogado} = this.props;

    return (
      <View>
        <Text style={styles.nomeAnimal}>{animal.nome}</Text>
        <Image
          source={{
            uri: animal.urlImagem,
          }}
          style={styles.imagemAnimal}
        />
        {this.botaoFavorito(animal, usuarioLogado)}

        {/* Novidade aqui */}
        <Text>
          Este animal
          {animal.favoritoUsuarios.length > 0
            ? ` já foi favoritado por ${animal.favoritoUsuarios.length} usuário(s)`
            : ' ainda não foi favoritado'}
        </Text>

      </View>
    );
  }
```

> Desafio 1: Será que podemos substituir `animal.favoritoUsuarios.length > 0` por `animal.favoritoUsuarios.length`? Qual o motivo?

> Desafio 2: Você consegue escrever ajustar o código que sensibilize corretamente a exibição da palavra usuário em singular/plural? Ex: `Este animal já foi favoritado por 1 usuário` e `Este animal já foi favoritado por 2 usuários`.
