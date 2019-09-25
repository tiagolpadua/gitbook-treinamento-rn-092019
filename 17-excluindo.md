# Excluindo Animais

Esta é a última funcionalidade de nosso CRUD.

Para começar a implementá-la, devemos primeiro adicionar um botão em tela que permita acionar a funcionalidade:

- `Animal.js`

```jsx
class Animal extends Component {
  isFavoritado(animal, usuarioLogado) {
    return !!animal.favoritoUsuarios.find(usuario => usuario === usuarioLogado);
  }

  // Novidade aqui
  excluir(animal) {
    console.warn(animal);
  }

  render() {
    const {animal, navigation} = this.props;

    return (
      <Card>
        <CardItem header bordered>
          <Text style={styles.nomeAnimal}>{animal.nome}</Text>
          <Right>
            {/* Novidades aqui */}
            <View style={styles.actionIconsContainter}>
              <TouchableOpacity
                style={styles.iconAlterar}
                onPress={() => navigation.navigate('AlterarAnimal', {animal})}>
                <Icon name="create" style={styles.icone} />
              </TouchableOpacity>
              <TouchableOpacity onPress={() => this.excluir(animal)}>
                <Icon name="trash" style={styles.icone} />
              </TouchableOpacity>
            </View>
          </Right>
        </CardItem>
        {/* Código omitido */}
      </Card>
    );
  }
}

// Código omitido

const styles = StyleSheet.create({
  nomeAnimal: {fontSize: 18, fontWeight: 'bold', flex: 1},
  icone: {fontSize: 30, color: 'black'},
  imagemAnimal: {width: width * 0.7, height: width * 0.7},
  actionIconsContainter: {flexDirection: 'row'},
  iconAlterar: {marginRight: 10},
  imageContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});
```

O botão deve funcionar e exibir um `warning` quando o usuário clicá-lo.

## Confirmação

Num caso de exclusão, é sempre bom perguntarmos ao usuário se ele realmente deseja concluir aquela ação, pra isso, o componente `Alert` do React Native pode ser útil:

- `Animal.js`

```jsx
  excluir(animal) {
    Alert.alert(
      'Atenção!',
      'Confirma a exclusão do animal ' + animal.nome + '?',
      [
        {text: 'OK', onPress: () => console.warn('Remover!')},
        {
          text: 'Cancelar',
          style: 'cancel',
        },
      ],
      {cancelable: true},
    );
  }
```

## Integração com a API

Agora temos que repetir o passo a passo para integração com a API e o Redux:

Primeiro criaremos a constante `EXCLUIR_ANIMAL`:

- `constants.js`

```jsx
const LOGIN = 'LOGIN';
const FAVORITAR = 'FAVORITAR';
const DESFAVORITAR = 'DESFAVORITAR';
const CARREGAR_ANIMAIS = 'CARREGAR_ANIMAIS';
const SET_LOADING = 'SET_LOADING';
const INCLUIR_ANIMAL = 'INCLUIR_ANIMAL';
const ALTERAR_ANIMAL = 'ALTERAR_ANIMAL';

// Novidade aqui
const EXCLUIR_ANIMAL = 'EXCLUIR_ANIMAL';

export {
  LOGIN,
  FAVORITAR,
  DESFAVORITAR,
  CARREGAR_ANIMAIS,
  SET_LOADING,
  INCLUIR_ANIMAL,
  ALTERAR_ANIMAL,
  // Novidade aqui
  EXCLUIR_ANIMAL,
};
```

Agora uma ação correspondente que irá acionar a API e disparar a action para o reducer:

- `actions.js`

```jsx
export function excluirAnimal(animal) {
  return loadingWrapper(dispatch =>
    excluirAnimalAPI(animal).then(res => {
      dispatch({
        type: EXCLUIR_ANIMAL,
        data: animal,
      });
    }),
  );
}
```

A chamada da API deve ter esta forma:

- `src/api/index.js`

```jsx
export function excluirAnimalAPI(id) {
  return api.delete(`/animais/${id}`);
}
```

O reducer deve ser capaz de processar a nova action que está sendo disparada:

- `src/reducers/animais.js`

```jsx
export default function animaisReducer(state = initialState, action) {
  switch (action.type) {
    case CARREGAR_ANIMAIS:
      return action.data;

    case INCLUIR_ANIMAL:
      return [...state, action.data];

    // Novidade aqui
    case EXCLUIR_ANIMAL:
      return state.filter(animal => animal._id !== action.data._id);

    case ALTERAR_ANIMAL:
      return atualizaAnimal(state, action.data);

    // Código omitido

    default:
      return state;
  }
}
```

Por fim é só ajustar o componente para que chame a função correta:

- `Animal.js`

```jsx
  excluir(animal) {
    Alert.alert(
      'Atenção!',
      'Confirma a exclusão do animal ' + animal.nome + '?',
      [
        {text: 'OK', onPress: () => this.props.excluirAnimal(animal)},
        {
          text: 'Cancelar',
          style: 'cancel',
        },
      ],
      {cancelable: true},
    );
  }
```

Pronto, nossa aplicação está completa com todas as funcionalidades do CRUD implementadas!
