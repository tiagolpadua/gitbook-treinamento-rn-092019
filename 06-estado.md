# Atualizando o estado do componente

Para que um animal seja favoritado, o "estado" deverá ser atualizado (valor das variáveis).

Existem dois tipos de dados que controlam um componente: _props_ e _state_. _props_ são definidas pelo componente pai e são fixas durante todo o tempo de vida de um componente. Para os dados que vão mudar, temos que usar o _state_.

Em geral, você deve inicializar o estado, e chamar `setState` quando quiser alterá-lo.

Para começar vamos fazer um simples contador de cliques em nossa aplicação:

- `Animal.js`

```jsx
export default class Animal extends Component {
  state = {
    contador: 0,
  };

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
        <TouchableOpacity
          onPress={() => this.setState({contador: this.state.contador + 1})}>
          <Icon name="star" />
        </TouchableOpacity>
        <Text>Foi favoritado {this.state.contador} vezes</Text>
      </View>
    );
  }
}
```

> Desafio: Se substituirmos o código `this.state.contador + 1` por `this.state.contador++` ele continua funcionando como deveria? Porquê?

## Constructor

Um padrão comum de codificação é inicializarmos o `state` diretamente no construtor de nosso componente:

```jsx
export default class Animal extends Component {
  constructor(props) {
    super(props);
    this.state = {
      contador: 0,
    };
  }

  // Código omitido
}
```

É muito importante chamarmos `super(props)` na primeira linha do construtor para garantir que a classe `Component` do React inicialize corretamente as propriedades de nosso componente.

Outra melhoria que também podemos fazer é utilizarmos a desestruturação de objetos para o `state` de forma a simplificar o acesso a suas propriedades.

- `Animal.js`

```jsx
  render() {
    const {animal} = this.props;
    const {contador} = this.state;

    return (
      <View>
        <Text style={styles.nomeAnimal}>{animal.nome}</Text>
        <Image
          source={{
            uri: animal.urlImagem,
          }}
          style={styles.imagemAnimal}
        />

        {/* Novidades aqui */}
        <TouchableOpacity
          onPress={() => this.setState({contador: contador + 1})}>
          <Icon name="star" />
        </TouchableOpacity>
        <Text>Foi favoritado {contador} vezes</Text>

      </View>
    );
  }
```

## Desfavoritando

Tudo certo até agora, mas se pararmos para pensar, um usuário só pode favoritar um animal uma única vez, ou seja, esta é uma propriedade booleana e o animal será favoritado e desfavoritado se o usuário pressionar mais de uma vez o ícone. Vamos fazer esta implementação ajustando também o texto abaixo do ícone pois agora temos um valor booleano:

- `Animal.js`

```jsx
export default class Animal extends Component {
  constructor(props) {
    super(props);
    this.state = {
      favoritado: false,
    };
  }

  render() {
    const {animal} = this.props;
    const {favoritado} = this.state;

    return (
      <View>
        <Text style={styles.nomeAnimal}>{animal.nome}</Text>
        <Image
          source={{
            uri: animal.urlImagem,
          }}
          style={styles.imagemAnimal}
        />
        <TouchableOpacity
          onPress={() => this.setState({favoritado: !favoritado})}>
          <Icon name="star" />
        </TouchableOpacity>
        <Text>Foi favoritado: {favoritado + ''}</Text>
      </View>
    );
  }
}
```

> Desafio: Qual a finalidade de fazer `favoritado + ''`? O que acontece se não fizermos esta concatenação? Existe outra maneira de conseguir o mesmo efeito?

<!-- new String(favoritado) -->

O padrão de UX comum quando um item está favoritado ou não é o ícone estar preenchido ou vazio, para isso, podemos utilizar uma técnica de renderização condicional baseada em variáveis de elementos:

- `Animal.js`

```jsx
  render() {
    const {animal} = this.props;
    const {favoritado} = this.state;

    // Novidade aqui
    let iconeFavoritado;

    if (favoritado) {
      iconeFavoritado = <Icon name="star" />;
    } else {
      iconeFavoritado = <Icon name="star-outline" />;
    }

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
        <TouchableOpacity
          onPress={() => this.setState({favoritado: !favoritado})}>
          {iconeFavoritado}
        </TouchableOpacity>

        <Text>Foi favoritado: {favoritado + ''}</Text>
      </View>
    );
  }
```

## Passando props para um state

Se pararmos para analisar, `favoritado` é uma propriedade do animal, e não do componente como implementamos, deste modo, devemos atualizar o objeto `animal` que nos é passado via `props`. Mas aí há um problema, não podemos atualizar os `props` recebidos, esta é uma premissa do React, para valores mutáveis, devemos atualizar nosso objeto `state`. A solução é copiarmos a referência do objeto `animal` recebido via `props` para nosso `state` no momento da construção do objeto. Teremos que alterar também o funcionamento do `onPress` do componente `TouchableOpacity`, como nossa função de atualização de estado do animal ficará um pouco mais complicada, vamos isolar em um novo método de nosso componente:

- `Animal.js`

```jsx
export default class Animal extends Component {
  // Novidade aqui
  constructor(props) {
    super(props);
    this.state = {
      animal: this.props.animal,
    };
  }

  // Novidade aqui
  favoritar() {
    const {animal} = this.state;
    let novoAnimal = {...animal};
    novoAnimal.favoritado = !novoAnimal.favoritado;
    this.setState({animal: novoAnimal});
  }

  render() {
    const {animal} = this.state;

    let iconeFavoritado;

    if (animal.favoritado) {
      iconeFavoritado = <Icon name="star" />;
    } else {
      iconeFavoritado = <Icon name="star-outline" />;
    }

    return (
      <View>
        <Text style={styles.nomeAnimal}>{animal.nome}</Text>
        <Image
          source={{
            uri: animal.urlImagem,
          }}
          style={styles.imagemAnimal}
        />
        <TouchableOpacity onPress={this.favoritar}>
          {iconeFavoritado}
        </TouchableOpacity>
        <Text>Foi favoritado: {animal.favoritado + ''}</Text>
      </View>
    );
  }
}
```

## Métodos e Funções

Mas há algo errado, pois ao tentar favoritar o animal ocorre um erro: `undefined is not an object: evaluating 'this.state.animal')`. O motivo deste erro é que o escopo léxico da palavra `this` é alterado dinamicamente dependendo do momento da execução da função que a encapsula.

Veremos alguns meios de resolver este problema.

### Primeira forma `bind`

O método `bind()` cria uma nova função que, quando chamada, tem sua palavra-chave `this` definida com o valor fornecido, com uma sequência determinada de argumentos precedendo quaisquer outros que sejam fornecidos quando a nova função é chamada. (https://developer.mozilla.org/pt-BR/docs/Web/JavaScript/Reference/Global_Objects/Function/bind)

- `Animal.js`

```jsx
  render() {
    const {animal} = this.state;

    let iconeFavoritado;

    if (animal.favoritado) {
      iconeFavoritado = <Icon name="star" />;
    } else {
      iconeFavoritado = <Icon name="star-outline" />;
    }

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
        <TouchableOpacity onPress={this.favoritar.bind(this)}>
          {iconeFavoritado}
        </TouchableOpacity>

        <Text>Foi favoritado: {animal.favoritado + ''}</Text>
      </View>
    );
  }
```

Esta solução não é recomendada, pois há um overhead de performance, você consegue visualizar o motivo? A cada chamada do método `render` uma nova função é criada, pressionando o motor JavaScript.

Para resolver isso, podemos realizar o `bind` uma única vez no construtor do componente:

- `Animal.js`

```jsx
export default class Animal extends Component {
  constructor(props) {
    super(props);

    // Novidade aqui
    this.favoritar = this.favoritar.bind(this);

    this.state = {
      animal: this.props.animal,
    };
  }

  favoritar() {
    const {animal} = this.state;
    let novoAnimal = {...animal};
    novoAnimal.favoritado = !novoAnimal.favoritado;
    this.setState({animal: novoAnimal});
  }

  render() {
    const {animal} = this.state;

    let iconeFavoritado;

    if (animal.favoritado) {
      iconeFavoritado = <Icon name="star" />;
    } else {
      iconeFavoritado = <Icon name="star-outline" />;
    }

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
        <TouchableOpacity onPress={this.favoritar}>
          {iconeFavoritado}
        </TouchableOpacity>

        <Text>Foi favoritado: {animal.favoritado + ''}</Text>
      </View>
    );
  }
}
```

O ponto negativo desta estratégia é que precisamos "lembrar" de fazer o `bind` no construtor de todos nosso métodos que acessam `this`.

### Segunda forma `arrow functions`

Uma expressão arrow function possui uma sintaxe mais curta quando comparada a uma expressão de função (_function expression_) e não tem seu próprio `this` (https://developer.mozilla.org/pt-BR/docs/Web/JavaScript/Reference/Functions/Arrow_functions), pois utiliza a referência `this` de seu contexto de invocação:

- `Animal.js`

```jsx
export default class Animal extends Component {
  constructor(props) {
    super(props);
    this.state = {
      animal: this.props.animal,
    };
  }

  favoritar() {
    const {animal} = this.state;
    let novoAnimal = {...animal};
    novoAnimal.favoritado = !novoAnimal.favoritado;
    this.setState({animal: novoAnimal});
  }

  render() {
    const {animal} = this.state;

    let iconeFavoritado;

    if (animal.favoritado) {
      iconeFavoritado = <Icon name="star" />;
    } else {
      iconeFavoritado = <Icon name="star-outline" />;
    }

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
        <TouchableOpacity onPress={() => this.favoritar()}>
          {iconeFavoritado}
        </TouchableOpacity>

        <Text>Foi favoritado: {animal.favoritado + ''}</Text>
      </View>
    );
  }
}
```

Há ainda uma forma alternativa de utilizarmos `arrow functions` alterando a declaração da função para um atributo que referencia uma arrow function:

- `Animal.js`

```jsx
export default class Animal extends Component {
  constructor(props) {
    super(props);
    this.state = {
      animal: this.props.animal,
    };
  }

  // Novidade aqui
  favoritar = () => {
    const {animal} = this.state;
    let novoAnimal = {...animal};
    novoAnimal.favoritado = !novoAnimal.favoritado;
    this.setState({animal: novoAnimal});
  };

  render() {
    const {animal} = this.state;

    let iconeFavoritado;

    if (animal.favoritado) {
      iconeFavoritado = <Icon name="star" />;
    } else {
      iconeFavoritado = <Icon name="star-outline" />;
    }

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
        <TouchableOpacity onPress={this.favoritar}>
          {iconeFavoritado}
        </TouchableOpacity>
        <Text>Foi favoritado: {animal.favoritado + ''}</Text>
      </View>
    );
  }
}
```

Todas as formas apresentadas são válidas, porém a única de fato não recomendada é realizar o `bind` na função render devido ao custo computacional mais elevado.

Durante o treinamento daremos preferência a última forma por simplicidade.

> Desafio: Você conseguiria transformar a função `favoritar` em uma função de duas linhas?

<!--
  favoritar = () => {
    const {animal} = this.state;
    this.setState({...animal, favoritado: !animal.favoritado});
  };
-->

## Reduzindo a complexidade do método `render`

Uma boa prática de código é manter a complexidade do método `render` a menor possível, isso irá facilitar um eventual refatoramento do componente.

Agora que já aprendemos a trabalhar com métodos em nosso componente, podemos ter um método que retorne o ícone de favorito isolando o código da função render:

- `Animal.js`

```jsx
export default class Animal extends Component {
  constructor(props) {
    super(props);
    this.state = {
      animal: this.props.animal,
    };
  }

  favoritar = () => {
    const {animal} = this.state;
    let novoAnimal = {...animal};
    novoAnimal.favoritado = !novoAnimal.favoritado;
    this.setState({animal: novoAnimal});
  };

  // Novidade aqui
  botaoFavorito(animal) {
    let iconeFavorito;

    if (animal.favoritado) {
      iconeFavorito = <Icon name="star" />;
    } else {
      iconeFavorito = <Icon name="star-outline" />;
    }

    return (
      <TouchableOpacity onPress={this.favoritar}>
        {iconeFavorito}
      </TouchableOpacity>
    );
  }

  render() {
    const {animal} = this.state;

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
        {this.botaoFavorito(animal)}

        <Text>Foi favoritado: {animal.favoritado + ''}</Text>
      </View>
    );
  }
}
```

Você deve ter notado que optamos por passar o objeto `animal` como um parâmetro para a função, isso foi feito para que a função dependa menos do estado do componente e será importante quando fizermos mais refatorações.

> Desafio: Não utilizamos a notação de `arrow function` na declaração do método `botaoFavorito` nem no seu acionamento e há uma referência a `this`, porquê não ocorre um erro?

<!-- Pois a função é acionada no momento da renderização -->
