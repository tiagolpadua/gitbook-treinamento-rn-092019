# Publicando na Google Play Store

O Android exige que todos os aplicativos sejam assinados digitalmente com um certificado antes de poderem ser instalados. Para distribuir seu aplicativo Android pela Google Play Store, ele precisa ser assinado com uma chave de liberação que precisa ser usada para todas as atualizações futuras. Desde 2017, é possível que o Google Play gerencie assinaturas automaticamente graças à funcionalidade de assinatura do aplicativo pelo Google Play. No entanto, antes do upload do binário do aplicativo para o Google Play, ele precisa ser assinado com uma chave de upload. [https://facebook.github.io/react-native/docs/signed-apk-android](https://facebook.github.io/react-native/docs/signed-apk-android)

## Gerando uma chave de upload

Você pode gerar uma chave de assinatura privada usando keytool. No Windows o keytool deve ser executado a partir de `C:\Program Files\Java\jdkx.x.x_x\bin`.

```bash
keytool -genkeypair -v -keystore upload-key.keystore -alias key-alias -keyalg RSA -keysize 2048 -validity 10000
```

Este comando gera o keystore como um arquivo chamado `upload-key.keystore`.

O keystore contém uma única chave, válida por 10.000 dias. O alias é um nome que você usará mais tarde ao assinar seu aplicativo. Lembre-se de anotar o alias.

## Configurando variáveis ​​Gradle

1. Coloque o arquivo `upload-key.keystore` no diretório `android/app` em sua pasta do projeto.

2. Edite o arquivo `android/gradle.properties` e adicione o seguinte:

```properties
MYAPP_UPLOAD_STORE_FILE=upload-key.keystore
MYAPP_UPLOAD_KEY_ALIAS=key-alias
MYAPP_UPLOAD_STORE_PASSWORD=123456
MYAPP_UPLOAD_KEY_PASSWORD=123456
```

Essas serão variáveis ​​globais do Gradle, que poderemos usar posteriormente em nossa configuração do Gradle para assinar nosso aplicativo.

## Adicionando a configuração de assinatura à configuração Gradle do seu aplicativo

A última etapa da configuração que precisa ser feita é definir as compilações de versão a serem assinadas usando a chave de upload. Edite o arquivo `android/app/build.gradle` na pasta do projeto e adicione a configuração de assinatura,

```gradle
...
android {
    ...
    defaultConfig { ... }
    signingConfigs {
        release {
            if (project.hasProperty('MYAPP_UPLOAD_STORE_FILE')) {
                storeFile file(MYAPP_UPLOAD_STORE_FILE)
                storePassword MYAPP_UPLOAD_STORE_PASSWORD
                keyAlias MYAPP_UPLOAD_KEY_ALIAS
                keyPassword MYAPP_UPLOAD_KEY_PASSWORD
            }
        }
    }
    buildTypes {
        release {
            ...
            signingConfig signingConfigs.release
        }
    }
}
...
```

## Gerando a APK de release

Basta executar o seguinte em um terminal:

```bash
> cd android
> ./gradlew.bat bundleRelease
```

O comando agrupará todo o JavaScript necessário para executar seu aplicativo no AAB (Android App Bundle).

O AAB gerado pode ser encontrado em `android/app/build/outputs/bundle/release/app.aab` e está pronto para ser carregado no Google Play.

## Testando a versão do seu aplicativo

Antes de fazer upload da versão compilada na Play Store, certifique-se de testá-la completamente. Primeiro desinstale qualquer versão anterior do aplicativo que você já instalou. Instale-o no dispositivo usando:

```bash
> react-native run-android --variant=release
```

Observe que `--variant=release` funciona se você configurou a assinatura conforme descrito acima.

Você pode eliminar qualquer instância do empacotador em execução, pois toda a sua estrutura e código JavaScript serão agrupados nos ativos do APK.
