# Mais componentes

Já temos um componente funcional em nossa tela, mas vamos componentizar ainda mais.

Nosso primeiro passo é nomear corretamente o nosso componente inicial, daremos o nome de `ListaAnimais`, para isso, iremos renomear o arquivo `App.js` para `ListaAnimais.js` e a classe para `ListaAnimais`:

- `ListaAnimais.js`

```jsx
export default class ListaAnimais extends Component {
  // Código omitido
}
```

- `index.js`

```jsx
AppRegistry.registerComponent(appName, () => ListaAnimais);
```

Em seguida iremos decompor nosso componente, criando um componente específico para representar cada animal na listagem. Criaremos o arquivo `Animal.js` dentro da pasta `components`:

- `Animal.js`

```jsx
import React, {Component} from 'react';
import {Dimensions, Image, StyleSheet, Text, View} from 'react-native';

const {width} = Dimensions.get('screen');

export default class Animal extends Component {
  render() {
    const animal = {};
    return (
      <View>
        <Text style={styles.nomeAnimal}>{animal.nome}</Text>
        <Image
          source={{
            uri: animal.urlImagem,
          }}
          style={styles.imagemAnimal}
        />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  nomeAnimal: {fontSize: 16},
  imagemAnimal: {width, height: width},
});
```

Nosso próximo passo é utilizar este componente para compor a lista de animais:

- `ListaAnimais.js`

```jsx
import React, {Component} from 'react';
import {FlatList, View} from 'react-native';
import Animal from './Animal';

export default class ListaAnimais extends Component {
  render() {
    const animais = [
      {
        nome: 'Leão',
        urlImagem:
          'https://upload.wikimedia.org/wikipedia/commons/4/40/Just_one_lion.jpg',
      },
      {
        nome: 'Girafa',
        urlImagem:
          'https://upload.wikimedia.org/wikipedia/commons/9/97/Namibie_Etosha_Girafe_02.jpg',
      },
      {
        nome: 'Gato',
        urlImagem:
          'https://upload.wikimedia.org/wikipedia/commons/b/b2/WhiteCat.jpg',
      },
    ];

    return (
      <View>
        <FlatList
          data={animais}
          renderItem={({item}) => <Animal />}
          keyExtractor={item => item.nome}
        />
      </View>
    );
  }
}
```

Mas agora temos um problema, o array `animais` está no componente `ListaAnimais`, como podemos torná-lo disponível no componente `Animal`?

## Props

A maioria dos componentes pode ser personalizada quando eles são criados, com diferentes parâmetros. Esses parâmetros de criação são chamados de _props_.

As _props_ permitem criar um único componente que é usado em muitos lugares diferentes do aplicativo, com propriedades ligeiramente diferentes em cada lugar. Basta se referir a `this.props` em sua função de renderização.

- `Animal.js`

```jsx
export default class Animal extends Component {
  render() {
    return (
      <View>
        <Text style={styles.nomeAnimal}>{this.props.animal.nome}</Text>
        <Image
          source={{
            uri: this.props.animal.urlImagem,
          }}
          style={styles.imagemAnimal}
        />
      </View>
    );
  }
}
```

Para que este código funcione, devemos passar a propriedade `animal` a partir do componente superior, neste caso `ListaAnimais`:

- `ListaAnimais.js`

```jsx
return (
  <View>
    <FlatList
      data={animais}
      renderItem={({item}) => <Animal animal={animal} />}
      keyExtractor={item => item.nome}
    />
  </View>
);
```

Mas perceba que estamos repetindo várias vezes o trecho `this.props`, para tornar nosso código menos verboso, podemos nos valer da sintaxe de desestruturação de objetos do ES6:

- `Animal.js`

```jsx
export default class Animal extends Component {
  render() {
    const {animal} = this.props;
    return (
      <View>
        <Text style={styles.nomeAnimal}>{animal.nome}</Text>
        <Image
          source={{
            uri: animal.urlImagem,
          }}
          style={styles.imagemAnimal}
        />
      </View>
    );
  }
}
```

## Um pouco de interatividade

Vamos permitir que o usuário possa "favoritar" um animal da listagem, para isso, vamos precisar de um ícone clicável.

Existem várias alternativas para incluir ícones em nossa aplicação, uma das mais populares é utilizar a biblioteca _NativeBase_ (https://nativebase.io/) que, além de ícones, nos trará uma série de componentes amigáveis que poderemos utilizar futuramente.

A instalação do _NativeBase_ está descrita em https://docs.nativebase.io/docs/GetStarted.html e pode ser resumida nos seguintes passos:

- Encerre a execução do script `react-native start` (`CTRL+C`) e em seguida:

```bash
> npm install native-base
> react-native link
```

- Desinstale a aplicação do emulador (clique e segure na aplicação e arraste para lixeira);

- Reinstale novamente a aplicação no emulador através dos seguintes comandos:

```bash
> react-native start
> react-native run-android
```

Agora vamos incluir um ícone de "favoritar" em nossa aplicação:

- `Animal.js`

```jsx
import React, {Component} from 'react';
import {Dimensions, Image, StyleSheet, Text, View} from 'react-native';

// Novidade aqui
import {Icon} from 'native-base';

const {width} = Dimensions.get('screen');

export default class Animal extends Component {
  render() {
    const {animal} = this.props;
    return (
      <View>
        <Text style={styles.nomeAnimal}>{animal.nome}</Text>
        <Image
          source={{
            uri: animal.urlImagem,
          }}
          style={styles.imagemAnimal}
        />

        {/* Novidade aqui */}
        <Icon name="star" />
      </View>
    );
  }
}
```

## Tornando o ícone clicável

Para tornar o ícone clicável, podemos utilizar o componente _TouchableOpacity_ (https://facebook.github.io/react-native/docs/touchableopacity), que irá associar uma área da tela envolvendo componentes a uma função que será executada ao se clicar nesta área:

- `Animal.js`

```jsx
export default class Animal extends Component {
  render() {
    const {animal} = this.props;
    return (
      <View>
        <Text style={styles.nomeAnimal}>{animal.nome}</Text>
        <Image
          source={{
            uri: animal.urlImagem,
          }}
          style={styles.imagemAnimal}
        />
        <TouchableOpacity onPress={console.warn('Favoritado!')}>
          <Icon name="star" />
        </TouchableOpacity>
      </View>
    );
  }
}
```

`console.warn` irá exibir uma caixa amarela de texto no rodapé da tela da aplicação, e é uma forma bem simples de conseguirmos uma depuração básica.

Mas o resultado obtido é diferente do que esperávamos, pois as mensagens de console são exibidas imediatamente após o carregamento da tela. Isso ocorre pois quando ocorre a renderização do componente, todas as expressões entre chaves são executadas. A propriedade `onPress` irá associar o resultado desta execução ao evento de `clique`, deste modo, o resultado da expressão deve ser uma referência a uma função.

Para corrigir isso, vamos alterar nossa função `onPress`:

```jsx
export default class Animal extends Component {
  render() {
    const {animal} = this.props;
    return (
      <View>
        <Text style={styles.nomeAnimal}>{animal.nome}</Text>
        <Image
          source={{
            uri: animal.urlImagem,
          }}
          style={styles.imagemAnimal}
        />
        <TouchableOpacity onPress={() => console.warn('Favoritado!')}>
          <Icon name="star" />
        </TouchableOpacity>
      </View>
    );
  }
}
```
