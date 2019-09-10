# Iniciando o Projeto

Podemos inicializar e executar nosso projeto com muita facilidade utilizando o `react-native-cli`:

```bash
> react-native init CoZooMob
```

Abra a pasta do projeto no VS Code, em seguida ative o terminal: `Terminal -> New Termial`

Divida o terminal em dois: Split Terminals

Em um terminal entre com o comando:

```bash
> react-native start
```

E no outro:

```bash
> react-native run-android
```

Obs.: O comando `react-native run-android` deve ser executado após o emulador do Android estar em execução.

A aplicação deverá ser executada no emulador conforme o print abaixo:

![](assets/print-hello.png)

## Conhecendo a estrutura básica de um projeto React Native

- `__tests__`: Pasta de testes do projeto;
- `android`: Pasta do projeto nativo Android;
- `ios`: Pasta do projeto nativo iOS;
- `node_modules`: Pasta dependências JavaScript;
- `.buckconfig`: Configuração do sistema de build Buck;
- `.eslintrc.js`: Configuração do linter de código;
- `.flowconfig`: Configuração do checador de tipagem estática Flow;
- `.gitattributes`: Configurações do git;
- `.gitignore`: Configuração de arquivos ignorados pelo git;
- `.prettierrc.js`: Configuração do formatador de código Prettier;
- `.watchmanconfig`: Configuração da ferramenta de monitoração Watchman;
- `App.js`: A primeira tela (e componente) de nosso aplicativo!
- `app.json`: Algumas propriedades de nosso aplicativo;
- `babel.config.js`: Configuração do transpilador babel;
- `index.js`: Ponto de partida inicial de nossa aplicação;
- `metro.config.js`: Configuração do bundler metro;
- `package-lock.json`: Descritor da árvore de dependências completa do projeto;
- `package.json`: Descritor do projeto NPM;

## Ajustando a tela inicial

Vamos alterar o arquivo `App.js` para que tenha o seguinte conteúdo:

- `App.js`

```jsx
import React, {Component} from 'react';
import {Text, View} from 'react-native';

export default class App extends Component {
  render() {
    return (
      <View style={{flex: 1, justifyContent: 'center', alignItems: 'center'}}>
        <Text>Controle de Zoológico Mobile!</Text>
      </View>
    );
  }
}
```

Obs.: Caso ocorra um erro do tipo:

```
Error: ESLint configuration in .eslintrc.js » @react-native-community/eslint-config is invalid:
	- Property "overrides" is the wrong type (expected array but got `{"files":["**/__tests__/**/*.js","**/*.spec.js","**/*.test.js"],"env":{"jest":true,"jest/globals":true}}`).
```

Isto ocorre devido a uma incompatibilidade entre a versão mais nova do ESLint e a configuração do react (https://github.com/facebook/create-react-app/issues/7284), e pode ser resolvida através do _downgrade_ da versão do ESLint do projeto, alterando a seguinte linha no `package.json`:

```json
...
  "devDependencies": {
    "eslint": "5.16.0"
  }
...
```

Em seguida, devemos remover e reinstalar as dependências:

```bash
> rm -rf node_modules
> npm install
```

## Auto-formatação do Código

Para facilitar com que nosso time utilize o mesmo padrão de codificação, iremos configurar para que o VS Code formate automaticamente nosso código: File -> Preferences -> Settings -> User -> Format on Save: True

É necessário que os plugins ESLint e Prettier estejam instalados no VS Code.

Agora, sempre que algum arquivo for salvo, ele será automaticamente formatado.

## Conhecendo melhor o VS Code

![](assets/print-vscode.png)

## Conhecendo as Ferramentas de Desenvolvedor

![](assets/print-dev-tools.png)

## ES2015 (ES6) e JSX

Dois pontos importantes de serem notados é o uso de ES2015 e JSX. O ES2015 nos permite utilizar diversos recursos modernos da linguagem JavaScript que veremos no decorrer do treinamento. Já o JSX é uma extensão do JS que nos permite descrever elementos de forma similar ao XML diretamente no código de nossa aplicação, tornando a escrita de compoentes muito mais simples.

## Componentes

Componentes são a estrutura básica do React, basicamente tudo que vemos em tela são Componentes ou uma composição de diversos componentes. Criaremos muitos componentes no decorrer de nosso treinamento.

Um componente é uma classe simples, único método obrigatório de um componente é a função `render`, que define a exibição do mesmo.

## Melhorando a organização do código

Uma boa prática é já focar desde o começo de nosso projeto em sua organização. Para isso vamos mover nosso componente para uma subpasta que criaremos `src/components/App.js`.

## Exibindo algo mais interessante

Vamos começar exibindo os detalhes de um animal:

- `App.js`

```jsx
import React, {Component} from 'react';
import {Image, Text, View, Dimensions} from 'react-native';

export default class App extends Component {
  render() {
    const {width} = Dimensions.get('screen');

    return (
      <View>
        <Text style={{fontSize: 16}}>Leão</Text>
        <Image
          source={{
            uri:
              'https://upload.wikimedia.org/wikipedia/commons/4/40/Just_one_lion.jpg',
          }}
          style={{width, height: width}}
        />
      </View>
    );
  }
}
```

Repare na sintaxe de `const {width} = Dimensions.get('screen')`, esta é a chamada atribuição via desestruturação. A sintaxe de atribuição via desestruturação (destructuring assignment) é uma expressão JavaScript que possibilita extrair dados de arrays ou objetos em variáveis distintas (https://developer.mozilla.org/pt-BR/docs/Web/JavaScript/Reference/Operators/Atribuicao_via_desestruturacao)

Pensando na melhoria de código, seria mais eficiente que tivéssemos tanto as propriedades do CSS quanto os dados dos animais separados em variáveis:

- `App.js`

```jsx
const {width} = Dimensions.get('screen');

export default class App extends Component {
  render() {
    const animal = {
      nome: 'Leão',
      urlImagem:
        'https://upload.wikimedia.org/wikipedia/commons/4/40/Just_one_lion.jpg',
    };

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

## Vários Animais

Agora que já temos um animal sendo exibido, nosso próximo passo é passar a exibir uma lista de animais, para isso, utilizaremos um array de animais e a função `map`:

- `App.js`

```jsx
export default class App extends Component {
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
        {animais.map(animal => (
          <View>
            <Text style={styles.nomeAnimal}>{animal.nome}</Text>
            <Image
              source={{
                uri: animal.urlImagem,
              }}
              style={styles.imagemAnimal}
            />
          </View>
        ))}
      </View>
    );
  }
}
```

Alguns pontos merecem destaque aqui:

- Utilizamos o método `map` do objeto array do JavaScript para iterar sobre a lista de animais, perceba que no JSX não há uma sintaxe especial de template, utilizamos as construções do próprio JavaScript;

- É necessário envolver a resposta do `map` em um elemento raiz `<View>`, tente remover este elemento e veja o que ocorre;

Mas ainda faltam acertar alguns pontos, pois é exibido um _warning_ referente a _unique key prop_. Para este problema, basta que

---

### Criando componentes

Vamos colocar uma segunda frase em nossa tela:

```jsx
// App.js
// Código anterior omitido
export default class App extends React.Component {
  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.paragraph}>Olá Mundo!</Text>
        <Text style={styles.paragraph}>
          Vamos começar a aprender React Native?
        </Text>
      </View>
    );
  }
}
// Código posterior omitido
```

E se quiséssemos utilizar o mesmo estilo em outras partes de nosso sistema? Para que isso fique mais fácil podemos criar um componente.

Vamos criar uma pasta chamada components e dentro dela um arquivo chamado Mensagem.js:

```jsx
// components/Mensagem.js
import * as React from 'react';
import {StyleSheet, Text} from 'react-native';

export class Mensagem extends React.Component {
  render() {
    return (
      <Text style={styles.paragraph}>
        Nosso primeiro componente React Native!
      </Text>
    );
  }
}

const styles = StyleSheet.create({
  paragraph: {
    margin: 24,
    fontSize: 18,
    fontWeight: 'bold',
    textAlign: 'center',
  },
});
```

Agora, no arquivo App.js podemos importar o componente que foi criado anteriormente:

```jsx
// App.js
// Código anterior omitido

// Novidade aqui!
import {Mensagem} from './components/Mensagem';

export default class App extends React.Component {
  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.paragraph}>Olá Mundo!</Text>

        {/* Novidade aqui! */}
        <Mensagem />
      </View>
    );
  }
}
// Código posterior omitido
```

### Passando props

A maioria dos componentes pode ser personalizada quando eles são criados, com diferentes parâmetros. Esses parâmetros de criação são chamados de _props_.

Nosso componente está com o texto "Fixo", o ideal é que o texto da mensagem seja parametrizado, vamos fazer isso agora:

```jsx
// App.js
// Código anterior omitido
export default class App extends React.Component {
  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.paragraph}>Olá Mundo!</Text>

        {/* Novidade aqui! */}
        <Mensagem texto="Passando propriedades dinamicamente!" />
      </View>
    );
  }
}
// Código posterior omitido
```

```jsx
// components/Mensagem.js
// Código anterior omitido
export class Mensagem extends React.Component {
  render() {
    return (
      <Text style={styles.paragraph}>
        {/* Novidade aqui! */}
        {this.props.texto}
      </Text>
    );
  }
}
// Código posterior omitido
```

As _props_ permitem criar um único componente que é usado em muitos lugares diferentes do aplicativo, com propriedades ligeiramente diferentes em cada lugar. Basta se referir a `this.props` em sua função de renderização.

Será então que podemos tornar nosso código mais enxuto? Vamos utilizar mais nosso componente de mensagens:

```jsx
// App.js
// Código anterior omitido
export default class App extends React.Component {
  render() {
    return (
      <View style={styles.container}>
        {/* Novidade aqui! */}
        <Mensagem texto="Olá Mundo via props!" />
        <Mensagem texto="Passando propriedades dinamicamente!" />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    paddingTop: Constants.statusBarHeight,
    backgroundColor: '#ecf0f1',
    padding: 8,
  },
});
// Código posterior omitido
```

### Setando state

Existem dois tipos de dados que controlam um componente: _props_ e _state_. _props_ são definidas pelo componente pai e são fixas durante todo o tempo de vida de um componente. Para os dados que vão mudar, temos que usar o _state_.

Em geral, você deve inicializar o estado no construtor e, em seguida, chamar `setState` quando quiser alterá-lo.

Vamos fazer um simples contator de cliques em nossa aplicação:

```jsx
// App.js
// Código anterior omitido
// Novidade aqui!
import {Button, StyleSheet, View} from 'react-native';

export default class App extends React.Component {
  // Novidade aqui!
  constructor(props) {
    super(props);
    this.state = {clicks: 0};
  }

  // Novidade aqui!
  handleClick() {
    this.setState({
      clicks: this.state.clicks + 1,
    });
  }

  render() {
    return (
      <View style={styles.container}>
        {/* Novidade aqui! */}
        <Button
          title={`Clicou ${this.state.clicks} vezes`}
          onPress={this.handleClick.bind(this)}
        />
      </View>
    );
  }
}
// Código posterior omitido
```

Outra forma de fazer o bind:

```jsx
// App.js
// Código anterior omitido
export default class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {clicks: 0};

    // Novidade aqui!
    this.handleClick = this.handleClick.bind(this);
  }

  handleClick() {
    this.setState({
      clicks: this.state.clicks + 1,
    });
  }

  render() {
    return (
      <View style={styles.container}>
        {/* Novidade aqui! */}
        <Button
          title={`Clicou ${this.state.clicks} vezes`}
          onPress={this.handleClick}
        />
      </View>
    );
  }
}
// Código posterior omitido
```

E mais uma forma de fazer o bind:

```jsx
// App.js
// Código anterior omitido
export default class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {clicks: 0};
  }

  // Novidade aqui!
  handleClick = () => {
    this.setState({
      clicks: this.state.clicks + 1,
    });
  };

  render() {
    return (
      <View style={styles.container}>
        <Button
          title={`Clicou ${this.state.clicks} vezes`}
          onPress={this.handleClick}
        />
      </View>
    );
  }
}
// Código posterior omitido
```

setState também possui uma segunda forma onde é passada uma função como argumento:

```jsx
// App.js
// Código anterior omitido
export default class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {clicks: 0};
  }

  // Novidade aqui!
  handleClick = () => {
    this.setState(prevState => ({clicks: prevState.clicks + 1}));
  };

  render() {
    return (
      <View style={styles.container}>
        <Button
          title={`Clicou ${this.state.clicks} vezes`}
          onPress={this.handleClick}
        />
      </View>
    );
  }
}
// Código posterior omitido
```

### Ciclo de vida

<!-- https://code.likeagirl.io/understanding-react-component-life-cycle-49bf4b8674de -->

Cada componente React vem com vários métodos que permitem aos desenvolvedores atualizar o estado do aplicativo e refletir a alteração na interface do usuário. Existem três fases principais de um componente, incluindo mounting (montagem), updating (atualização) e unmounting (desmontagem).

#### Mounting

Esses métodos serão chamados quando uma instância de um componente React for criada e montada no DOM.

##### constuctor()

Esse método é chamado antes de um componente React ser montado. É essencial chamar `super(props)` antes de qualquer declaração no construtor. Isto ocorre pois nos permitirá chamar o construtor da classe pai e inicializar a si mesmo caso nossa classe estenda qualquer outra classe que tenha o próprio construtor.

O construtor é perfeito para inicializar o estado ou vincular os manipuladores de eventos à instância da classe. Por exemplo:

```jsx
constructor(props) {
  super(props);
  this.state = {
    count: 0,
    value: 'Hey There!',
  };
  this.handleClick = this.handleClick.bind(this);
};
```

O construtor não deve causar nenhum efeito colateral.

#### componentWillMount()

`componentWillMount` será chamado uma vez antes do componente ser montado e será executado antes da função de renderização.

#### componentDidMount()

Depois que um componente é montado, esse método é chamado. Este é o local certo para carregar qualquer dado do _endpoint_.

Chamar aqui `setState` irá disparar re-render, então use este método com cuidado.

### Updating

#### componentDidUpdate(prevProps, prevState, snapshot)

Este método será chamado após cada renderização ocorrer. Como esse método é chamado apenas uma vez após a atualização, é um local adequado para implementar quaisquer operações de efeitos colaterais.

### Unmounting

#### componentWillUnmount()

Quando um componente é desmontado ou destruído, este método será chamado. Este é um lugar para fazer alguma limpeza como:

- Invalidando temporizadores
- Cancelar qualquer pedido de rede
- Remover manipuladores de eventos
- Limpar todas as assinaturas

![React Life Cycle](reactlifecycle.jpeg)

### JSX

<!-- https://reactjs.org/docs/introducing-jsx.html -->

A sintaxe de tags curiosa que estamos utilizando não é JavaScript nem HTML.

É chamado de JSX e é uma extensão de sintaxe para JavaScript. Recomenda-se usá-lo com o React para descrever como deve ser a interface do usuário. O JSX pode lembrá-lo de uma linguagem de marcação, mas ela vem com todo o poder do JavaScript.

O JSX produz React "elements".

#### Por que o JSX?

O React adota o fato de que a lógica de renderização é inerentemente associada a outra lógica da interface do usuário: como os eventos são tratados, como o estado muda com o tempo e como os dados são preparados para exibição.

Em vez de separar artificialmente as tecnologias, colocando marcação e lógica em arquivos separados, o React separa as preocupações com unidades fracamente acopladas chamadas “componentes” que contêm ambos.

O React não exige o uso de JSX, mas a maioria das pessoas considera útil como um auxílio visual ao trabalhar com a interface do usuário dentro do código JavaScript.

#### Incorporando Expressões no JSX

No exemplo abaixo, nós declaramos uma variável chamada _nome_ e a usamos dentro do JSX, colocando-a entre chaves:

```jsx
// App.js
// Código anterior omitido
export default class App extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    const nome = 'José';

    return (
      <View style={styles.container}>
        <Text>Olá {nome}</Text>
      </View>
    );
  }
}
// Código posterior omitido
```

Você pode colocar qualquer expressão JavaScript válida dentro das chaves no JSX. Por exemplo, 2 + 2, usuario.nome ou formatMessage(message) são todas expressões JavaScript válidas.

No exemplo abaixo, incorporamos o resultado de chamar uma função JavaScript, formatMessage(message).

```jsx
// App.js
// Código anterior omitido
export default class App extends React.Component {
  constructor(props) {
    super(props);
  }

  formatMessage(message = '') {
    return message.toUpperCase();
  }

  render() {
    const nome = 'José';

    return (
      <View style={styles.container}>
        <Text>Olá {this.formatMessage(nome)}</Text>
      </View>
    );
  }
}
// Código posterior omitido
```

#### JSX é uma expressão também

Após a compilação, as expressões JSX se tornam chamadas de função JavaScript regulares e são avaliadas como objetos JavaScript.

Isso significa que você pode usar o JSX dentro de instruções if e for loops, atribuí-lo a variáveis, aceitá-lo como argumentos e retorná-lo de funções:

```jsx
// App.js
// Código anterior omitido
export default class App extends React.Component {
  constructor(props) {
    super(props);
  }

  formatMessage(message = '') {
    let el;
    if (message.length > 2) {
      el = <Text>{message.toUpperCase()}</Text>;
    } else {
      el = <Text>{message}</Text>;
    }
    return el;
  }

  render() {
    const nome = 'José';
    const saudacao = 'oi';

    return (
      <View style={styles.container}>
        {this.formatMessage(saudacao)}
        {this.formatMessage(nome)}
      </View>
    );
  }
}
// Código posterior omitido
```

#### Especificando Atributos com JSX

Você pode usar aspas para especificar literais de string como atributos:

```jsx
// App.js
// Código anterior omitido
export default class App extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <View style={styles.container}>
        <Mensagem texto="Olá José" />
      </View>
    );
  }
}
// Código posterior omitido
```

Você também pode usar chaves para incorporar uma expressão JavaScript em um atributo:

```jsx
// App.js
// Código anterior omitido
export default class App extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    const minhaMsg = 'Olá José';
    return (
      <View style={styles.container}>
        <Mensagem texto={minhaMsg} />
      </View>
    );
  }
}
// Código posterior omitido
```

### Componentes de Função e Classe

Já vimos como criar componentes a partir de uma classe (a classe Mensagem), porém, há uma forma simplificada de criar componentes através de funções:

```jsx
// App.js
// Código anterior omitido
function MensagemSimples(props) {
  return <Text>Um componente de função: {props.texto}</Text>;
}

export default class App extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    const minhaMsg = 'Olá José';
    return (
      <View style={styles.container}>
        <MensagemSimples texto={minhaMsg} />
      </View>
    );
  }
}
// Código posterior omitido
```

Essa função é um componente React válido porque aceita um único argumento de objeto "props" (que significa propriedades) com dados e retorna um elemento React. Chamamos esses componentes de "componentes de função" porque são literalmente funções JavaScript.

## Instalando Expo Client para desenvolvimento e debug da aplicação

O Expo Client permite que você teste o código diretamente em um dispositivo físico, para isso, ele deve ser instalado através da
[loja de aplicativos](https://play.google.com/store/apps/details?id=host.exp.exponent&referrer=www).

Uma grande vantagem do Expo Client é que podemos compilar o código em um computador Windows/Linux e executar em um iPhone.

## Analizando Expo Client & Dicas

Ao balançar o dispositivo, podemos acessar o menu do desenvolvedor do Expo Cli, onde podemos:

- Reload: Recarregar a aplicação
- Debug JS Remotely: Debugar a aplicação remotamente (Chrome remote debugging)
- Habilitar/Desabilitar o Live Reload
- Habilitar o Hot Reloading
- Ativar o "inspector"
- Exibir o monitor de performance
- Iniciar/Parar o profiler de JavaScript

## Buildando um APK ou IPA via Expo CLi

A construção do binário, em sua versão final que será entregue para a loja de aplicativos é realizada no servidor do Expo:

![](assets/expowf.png)

<!--
https://docs.expo.io/versions/latest/distribution/building-standalone-apps

https://docs.expo.io/versions/v24.0.0/expokit/detach
-->

Deve ser impostado o seguinte commando:

```bash
PS C:\Users\usuario\projects\HelloWorld> expo build:android
```
