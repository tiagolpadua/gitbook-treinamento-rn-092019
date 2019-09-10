# Montando o Ambiente

Para começarmos nosso desenvolvimento, necessitaremos das seguintes ferramentas:

Ferramentas instaladas no computador:

- Android Studio: https://developer.android.com/studio/
- Java JDK: https://www.oracle.com/java/technologies/jdk8-downloads.html
- NodeJS (8.3+) e NPM: https://nodejs.org/en/download/
- React Native CLI: `npm install -g react-native-cli`
- Reactotron: https://github.com/infinitered/reactotron/releases
- VSCode - https://code.visualstudio.com/

São recomendados os seguintes plugins para o VSCode:

- EditorConfig;
- ESLint;
- Prettier;
- vscode-icons;

Algumas variáveis de ambiente devem ser configuradas nos arquivos `$HOME/.bash_profile` ou `$HOME/.bashrc`:

```bash
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

## Testando instalação

Podemos testar a instalação de algumas das ferramentas:

```bash
> node --version
v10.16.0
> npm --version
6.9.0
> react-native --version
react-native-cli: 2.0.1
react-native: n/a - not inside a React Native project directory
...
```
