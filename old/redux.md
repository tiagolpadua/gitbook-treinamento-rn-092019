## Redux

O Redux é um contêiner de estado previsível para aplicativos JavaScript.

Ele ajuda escrever aplicativos que se comportam de maneira consistente, executados em diferentes ambientes (cliente, servidor e nativo) e são fáceis de testar. Além disso, proporciona uma ótima experiência de desenvolvedor, como edição de código ao vivo combinada com um depurador de viagem no tempo.

O Redux pode ser utilizado junto com o React ou com qualquer outra biblioteca de visualizações. E é uma biblioteca pequena (2kB, incluindo dependências).

### Conceitos centrais

Imagine que o estado de um aplicativo é descrito como um objeto simples. Por exemplo, o estado de um aplicativo todo pode ter esta aparência:

```jsx
{
  todos: [{
    text: 'Eat food',
    completed: true
  }, {
    text: 'Exercise',
    completed: false
  }],
  visibilityFilter: 'SHOW_COMPLETED'
}
```

Este objeto é como um "modelo", exceto que não há "setters". Isso acontece para que diferentes partes do código não alterem o estado arbitrariamente, causando bugs difíceis de reproduzir.

Para mudar algo no estado, você precisa despachar uma ação. Uma ação é um objeto JavaScript simples (observe como não introduzimos nenhuma mágica?) Que descreva o que aconteceu. Aqui estão algumas ações de exemplo:

```jsx
{ type: 'ADD_TODO', text: 'Go to swimming pool' }
{ type: 'TOGGLE_TODO', index: 1 }
{ type: 'SET_VISIBILITY_FILTER', filter: 'SHOW_ALL' }
```

Obrigando que todas as alterações são descritas como uma ação nos permite ter uma compreensão clara do que está acontecendo no aplicativo. Se algo mudou, sabemos porque mudou. Ações são como rastros do que aconteceu. Finalmente, para amarrar estados e ações juntos, escrevemos uma função chamada "reducer". Novamente, nada de mágico - é apenas uma função que toma o estado e a ação como argumentos e retorna o próximo estado do aplicativo. Seria difícil escrever uma função desse tipo para um aplicativo grande, por isso escrevemos funções menores gerenciando partes do estado:

```jsx
function visibilityFilter(state = 'SHOW_ALL', action) {
  if (action.type === 'SET_VISIBILITY_FILTER') {
    return action.filter
  } else {
    return state
  }
}
​
function todos(state = [], action) {
  switch (action.type) {
    case 'ADD_TODO':
      return state.concat([{ text: action.text, completed: false }])
    case 'TOGGLE_TODO':
      return state.map(
        (todo, index) =>
          action.index === index
            ? { text: todo.text, completed: !todo.completed }
            : todo
      )
    default:
      return state
  }
}
```

E escrevemos outro redutor que gerencia o estado completo do nosso aplicativo chamando esses dois redutores para as chaves de estado correspondentes:

```jsx
function todoApp(state = {}, action) {
  return {
    todos: todos(state.todos, action),
    visibilityFilter: visibilityFilter(state.visibilityFilter, action),
  };
}
```

Esta é basicamente a ideia do Redux. Observe que não usamos nenhuma API do Redux. Ele vem com alguns utilitários para facilitar esse padrão, mas a idéia principal é que se descreva como o estado é atualizado ao longo do tempo em resposta a objetos de ação, e 90% do código que você escreve é ​​simplesmente JavaScript, sem uso do Redux em si, suas APIs ou qualquer "mágica".

### Os três princípios

#### Única fonte de verdade

_O estado de todo o aplicativo é armazenado em uma árvore de objetos em um único local de armazenamento._

Isso facilita a criação de aplicativos universais, já que o estado do servidor pode ser serializado e implantado no cliente sem nenhum esforço extra de codificação. Uma única árvore de estado também facilita a depuração ou inspeção de um aplicativo; Ele também permite que você persista o estado do seu aplicativo em desenvolvimento, para um ciclo de desenvolvimento mais rápido. Algumas funcionalidades que têm sido tradicionalmente difíceis de implementar - Desfazer/Refazer, por exemplo - podem subitamente tornar-se triviais de implementar, se todo o seu estado estiver armazenado em uma única árvore.

// FIXME

```jsx
console.log(store.getState())
​
/* Prints
{
  visibilityFilter: 'SHOW_ALL',
  todos: [
    {
      text: 'Consider using Redux',
      completed: true,
    },
    {
      text: 'Keep all state in a single tree',
      completed: false
    }
  ]
}
*/
```

#### Estado é somente leitura

_A única maneira de mudar o estado é emitir uma ação, um objeto descrevendo o que aconteceu._

Isso garante que nem as exibições nem os retornos de chamada da rede jamais serão gravados diretamente no estado. Em vez disso, eles expressam a intenção de transformar o estado. Como todas as mudanças são centralizadas e acontecem uma a uma em uma ordem estrita, não há condições corrida a serem observadas. Como as ações são apenas objetos simples, elas podem ser registradas, serializadas, armazenadas e, posteriormente, reproduzidas para fins de depuração ou teste.

```jsx
store.dispatch({
  type: 'COMPLETE_TODO',
  index: 1
})
​
store.dispatch({
  type: 'SET_VISIBILITY_FILTER',
  filter: 'SHOW_COMPLETED'
})
```

#### As alterações são feitas com funções puras

_Para especificar como a árvore de estados é transformada por ações, você escreve redutores puros._

Redutores são apenas funções puras que tomam o estado anterior e uma ação, e retornam o próximo estado. Lembre-se de retornar novos objetos de estado, em vez de alterar o estado anterior. Você pode começar com um único redutor e, à medida que seu aplicativo cresce, divida-o em redutores menores que gerenciam partes específicas da árvore de estados. Como os redutores são apenas funções, você pode controlar a ordem na qual eles são chamados, passar dados adicionais ou até mesmo fazer reduções reutilizáveis ​​para tarefas comuns, como paginação.

```jsx
function visibilityFilter(state = 'SHOW_ALL', action) {
  switch (action.type) {
    case 'SET_VISIBILITY_FILTER':
      return action.filter
    default:
      return state
  }
}
​
function todos(state = [], action) {
  switch (action.type) {
    case 'ADD_TODO':
      return [
        ...state,
        {
          text: action.text,
          completed: false
        }
      ]
    case 'COMPLETE_TODO':
      return state.map((todo, index) => {
        if (index === action.index) {
          return Object.assign({}, todo, {
            completed: true
          })
        }
        return todo
      })
    default:
      return state
  }
}
​
import { combineReducers, createStore } from 'redux'
const reducer = combineReducers({ visibilityFilter, todos })
const store = createStore(reducer)
```

## Introdução ao Expo Platform

https://expo.io/

Expo é um conjunto de ferramentas gratuitas e de código aberto criadas em torno do React Native para ajudá-lo a criar projetos iOS e Android nativos usando JavaScript e React.

Os aplicativos Expo são aplicativos React Native que contêm o Expo SDK. O SDK é uma biblioteca nativa e JS que fornece acesso à funcionalidade do sistema do dispositivo (como câmera, contatos, armazenamento local e outros hardwares). Isso significa que você não precisa usar o Xcode ou o Android Studio ou escrever qualquer código nativo, além de tornar seu projeto puro JavaScript, ou seja, muito portável, pois pode ser executado em qualquer ambiente nativo que contenha o Expo SDK.

O Expo também fornece componentes de interface do usuário para lidar com uma variedade de casos de uso que quase todos os aplicativos cobrirão, mas não serão integrados ao núcleo React Native, por exemplo, ícones, desfocar visões e muito mais.

Finalmente, o Expo SDK fornece acesso a serviços que normalmente são difíceis de gerenciar, mas são exigidos por quase todos os aplicativos. O mais popular entre estes: o Expo pode gerenciar os assets, pode cuidar de notificações push, e pode construir binários nativos que estão prontos para implantar na loja de aplicativos.

# Criando o projeto React Native

Baixar a aplicação Expo para o seu celular (Android ou iOs)

Acessar o endereço https://snack.expo.io/ e inserir o código abaixo:

```jsx
import * as React from 'react';
import {Text, View} from 'react-native';

export default class App extends React.Component {
  render() {
    return (
      <View style={{marginTop: 50}}>
        <Text>Olá Mundo!</Text>
      </View>
    );
  }
}
```

Clicar em "Run", selecionar QR Code e escanear o QR Code com o App Expo do Celular.
