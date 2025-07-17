# 🏍️ Moto Black - Aplicativo Passageiro

Um aplicativo móvel desenvolvido em Flutter para solicitar serviços de moto táxi. O aplicativo permite aos usuários solicitar corridas, acompanhar o status em tempo real, avaliar o serviço e gerenciar seu perfil.

<a href="https://drive.google.com/file/d/1s8aDxcvFWrLBVcMQf-axb_SnoC36py0N/view?usp=sharing">Link demonstrativo</a>

## 📱 Funcionalidades

### 🚀 Principais Recursos
- **Solicitação de Corridas**: Interface intuitiva para selecionar origem e destino
- **Mapas Integrados**: Visualização da rota usando Google Maps
- **Acompanhamento em Tempo Real**: Status da corrida e localização do motociclista
- **Sistema de Avaliação**: Avaliação e feedback após cada corrida
- **Perfil do Usuário**: Gerenciamento de dados pessoais e histórico
- **Previsão do Tempo**: Informações meteorológicas em tempo real
- **Notícias**: Feed de notícias integrado via RSS
- **Autenticação**: Sistema de login e registro seguro

### 🎯 Funcionalidades Específicas
- **Seleção de Destino**: Autocomplete de endereços com API do Here
- **Geolocalização**: Detecção automática da localização atual
- **Histórico de Atividades**: Acompanhamento de corridas anteriores

## 🛠️ Tecnologias Utilizadas

### Frontend
- **Flutter**: Framework principal para desenvolvimento mobile
- **Dart**: Linguagem de programação
- **Material Design**: Design system do Google

### Backend & APIs
- **Firebase**:Banco de dados em tempo real
- **Google Maps API**: Mapas, geolocalização e navegação
- **HERE API**: Geocodificação e Autocomplete de endereços
- **G1 RSS Feed**: Feed de notícias
- **Open Weather API**: Informações de clima

### Dependências Principais
```yaml
google_maps_flutter: ^2.3.1
firebase_core: ^2.15.1
firebase_database: ^10.2.5
geolocator: ^9.0.2
http: ^1.1.0
provider: ^6.1.2
shared_preferences: ^2.2.2
```

## 📋 Pré-requisitos

- Instalação e configuração da <a href="https://github.com/AlbertoJr789/app-motoblack-site-api">API Moto Black</a> (IMPORTANTE)
- Flutter SDK (versão >=3.0.0), última versão que compilei foi a 3.24.5
- Dart SDK
- Android Studio / VS Code
- Conta para chave de <a href="https://console.cloud.google.com/welcome?hl=pt-br&pli=1&inv=1&invt=Ab1Gmg&project=moto-black"> API MAPS Google Cloud Platform </a>
- Conta <a href="https://console.firebase.google.com/u/0/?hl=pt-br"> Firebase </a>
- Conta para chave de <a href="https://developer.here.com/login"> API Here Technologies </a>
- Conta para chave de <a href="https://openweathermap.org/api"> API OpenWeather </a>
- Dispositivo Android/iOS ou emulador

## 🏗️ Estrutura do Projeto

```
lib/
├── controllers/          # Controladores de lógica de negócio
├── models/              # Modelos de dados
├── screens/             # Telas do aplicativo
├── widgets/             # Componentes reutilizáveis
├── theme/               # Configurações de tema
├── util/                # Utilitários e helpers
└── main.dart           # Ponto de entrada do app
```

## 🚀 Instalação

### Instale as dependências
   ```bash
   flutter pub get
   ```

### Configuração das APIs

1. Google Maps

   - [ANDROID] Adicione a chave de API em `android/app/src/main/AndroidManifest.xml`:
        ```xml
        <meta-data android:name="com.google.android.geo.API_KEY"
            android:value="{{YOUR_API_KEY}}"/>
        ```
    - [iOS] Adicione a chave de API em `ios/Runner/AppDelegate.swift`:

        ```swift
            GMSServices.provideAPIKey("YOUR_API_KEY")
        ```
2. HERE API

   - Procure a classe `hereAPIController.dart` e insira o token de api:
   ```dart
        ...
        class HereAPIController implements Geocoder {

        static String _apiKey = ''; 
        ....
   ```

3. OpenWeather

   - Procure a classe `weatherAPIController.dart` e insira o token de api:
   ```dart
        ...
        class WeatherAPIController {
        static const String _apiKey = '';
        ....
   ```

### Configuração do Firebase
1. Crie um projeto no Firebase Console
2. Dentro do projeto, crie um Realtime Database (isso caso já não o tenha criado no aplicativo do mototaxista, pois ambos utilizam o mesmo projeto).
3. Configure as regras do Realtime Database:

    ```json
    {
        "rules": {
            ".read": true,
            ".write": true,
            "availableAgents":{
            ".indexOn": ["type"]
            }
        }
    }
    ```
4. Utilize o <a href="https://firebase.google.com/docs/flutter/setup?hl=pt-br&platform=android"> Flutterfire e o Firebase CLI </a> para configurar o realtime database no projeto Flutter.

**Execute o aplicativo**
   ```bash
   flutter run
   ```
### API Laravel

- Procure a classe `controllers/apiClient.dart` e insira a url Base em que está hospeada a api Laravel na sua rede LAN (lembre-se de seguir as instruções de configuração no repositório da API também):

```dart
...
class ApiClient {

  ApiClient._(){
    dio.options.connectTimeout = const Duration(seconds: 2);
    dio.options.receiveTimeout = const Duration(seconds: 3);
    dio.options.baseUrl = 'http://{{IPV4}}:8000'; // Replace with your Laravel API IPV4
...
```

## 📱 Como Usar

### Primeiro Acesso
1. Abra o aplicativo
2. Faça login ou crie uma conta
3. Permita acesso à localização
4. Configure seu perfil

### Solicitar uma Corrida
1. Na tela inicial, toque no campo "Vai pra onde?"
2. Confirme sua localização de origem
3. Digite ou selecione o destino
4. Confirme a solicitação
5. Aguarde a confirmação do motociclista

### Durante a Corrida
- Acompanhe o status em tempo real
- Visualize a localização do motociclista
- Aguarde a chegada

### Após a Corrida
- Avalie o serviço (1-5 estrelas)
- Deixe um comentário (opcional)


