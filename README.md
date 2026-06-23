# Tarefas Geo — Tarefas com Localização e Clima

> **Pós-Graduação em Desenvolvimento Mobile**
> **Disciplina:** Desenvolvimento Mobile com Flutter
> **Aluno:** Guilherme Queiroz Ribeiro

Aplicativo Flutter (Android e iOS) para gerenciar tarefas com **data/hora** e
**localização**. As tarefas são salvas no **Cloud Firestore** (sincronização em
tempo real) e, na tela de detalhe, o app mostra o **clima atual** no local da
tarefa (API REST do **OpenWeather**) e calcula a **distância** a partir da
posição do usuário (GPS).

> Este repositório nasceu como `App_Despesas_Pessoais` e foi **refatorado** para
> atender ao escopo desta entrega. A paleta (roxo + âmbar), a tipografia
> (OpenSans) e o design adaptativo iOS/Android foram preservados.

---

## Sumário

- [Requisitos atendidos](#requisitos-atendidos)
- [Arquitetura](#arquitetura)
- [Como executar](#como-executar)
- [Como testar (documentação da rubrica)](#como-testar)
  - [Testes e cobertura](#testes-e-cobertura)
  - [Firebase](#como-testar-a-solução-firebase)
  - [API externa (OpenWeather)](#como-testar-o-consumo-da-api-externa)
  - [Package interno (geo_tools)](#como-testar-o-package-interno)
  - [Testes de interface](#testes-de-interface)
- [Build iOS e Android](#build-ios-e-android)
- [Permissões nativas](#permissões-nativas)
- [Evidências](#evidências)

---

## Requisitos atendidos

| # | Requisito do enunciado | Como foi atendido |
|---|---|---|
| 1 | Responsividade iOS/Android | Widgets adaptativos (`Platform.isIOS` → Material/Cupertino) + `LayoutBuilder`/`ConstrainedBox` |
| 2 | Flutter ≥ 2.5 | Flutter 3.41 / Dart 3.11 (SDK `>=3.0.0`) |
| 3 | Rotas | Rotas nomeadas via `onGenerateRoute` em [`lib/routes/app_routes.dart`](lib/routes/app_routes.dart) (Home, Form, Detalhe, Sobre) |
| 4 | Gerenciamento de estado | `Provider` + `ChangeNotifier` em [`lib/providers/task_provider.dart`](lib/providers/task_provider.dart) |
| 5 | ≥ 50% de testes unitários | **56,5%** de cobertura no app + 24 testes no package (ver [Testes](#testes-e-cobertura)) |
| 6 | Testes de interface | Widget tests em [`test/widgets/`](test/widgets/) + [`integration_test/`](integration_test/) |
| 7 | API externa (REST) | Cliente **OpenWeather** em [`packages/geo_tools/lib/src/weather_client.dart`](packages/geo_tools/lib/src/weather_client.dart) |
| 8 | API do aparelho | GPS via `geolocator` em [`lib/services/location_service.dart`](lib/services/location_service.dart) |
| 9 | Firebase | **Cloud Firestore** como fonte de verdade (repositório + stream em tempo real) |
| 10 | Package interno | [`packages/geo_tools`](packages/geo_tools) (cliente OpenWeather + Haversine + formatação) |
| 11 | Compila iOS/Android | iOS validado no simulador; Android configurado (ver [Build](#build-ios-e-android)) |

---

## Arquitetura

Organização em camadas (domínio / dados / apresentação):

```
lib/
├── main.dart                       # Bootstrap: Firebase + Provider + MaterialApp/rotas
├── firebase_options.dart           # Gerado pelo flutterfire configure
├── config/app_config.dart          # Chave da API (via --dart-define)
├── models/task.dart                # Entidade Task (domínio puro, sem Firebase)
├── repositories/
│   ├── task_repository.dart        # Interface (contrato)
│   └── firestore_task_repository.dart  # Implementação Firestore
├── providers/task_provider.dart    # Estado (ChangeNotifier) que escuta o repositório
├── services/location_service.dart  # Acesso ao GPS
├── routes/app_routes.dart          # Rotas nomeadas (onGenerateRoute)
├── screens/                        # Home, Form, Detalhe (mapa+clima), Sobre
└── components/                     # Widgets adaptativos reutilizáveis

packages/
└── geo_tools/                      # PACKAGE INTERNO (Dart puro)
    ├── lib/src/weather_client.dart # Cliente REST OpenWeather (API externa)
    ├── lib/src/haversine.dart      # Distância entre coordenadas
    ├── lib/src/coordinate_format.dart
    └── lib/src/weather.dart / geo_point.dart
```

**Decisões-chave:**
- A entidade `Task` **não importa** `cloud_firestore`. A conversão
  `Task ↔ Firestore` (incluindo `DateTime ↔ Timestamp`) fica isolada no
  `FirestoreTaskRepository`. Isso desacopla o domínio do backend e mantém os
  testes da entidade independentes do Firebase.
- O repositório expõe um `Stream<List<Task>>` (`.snapshots()`); o `TaskProvider`
  escuta esse stream — qualquer alteração na nuvem reflete na UI automaticamente.
- O `TarefasGeoApp` **recebe o repositório por parâmetro**, o que permite injetar
  um Firestore em memória (`fake_cloud_firestore`) nos testes de integração.

---

## Como executar

**Pré-requisitos:** Flutter 3.x, um emulador/simulador ou device, e uma chave
gratuita do OpenWeather (https://openweathermap.org/api).

```bash
flutter pub get

# A chave da API é injetada em tempo de compilação (nunca é commitada):
flutter run --dart-define=OPENWEATHER_API_KEY=SUA_CHAVE_AQUI
```

> Sem a chave, o app funciona normalmente; apenas a seção de clima exibe um aviso
> amigável de que a chave não foi configurada.

> **Dica (emulador):** envie uma coordenada pelo painel de localização do
> emulador/simulador antes de tocar em "Usar minha localização".

---

## Como testar

### Testes e cobertura

```bash
# Testes do app (unitários + widget) com cobertura
flutter test --coverage

# Cobertura total (lib/ do app): 56,5%
# Relatório HTML (opcional, requer lcov):
genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html
```

| Camada | Arquivo de teste | Cobertura |
|---|---|---|
| Entidade `Task` | [`test/models/task_test.dart`](test/models/task_test.dart) | 100% |
| `TaskProvider` | [`test/providers/task_provider_test.dart`](test/providers/task_provider_test.dart) | 100% |
| Repositório Firestore | [`test/repositories/firestore_task_repository_test.dart`](test/repositories/firestore_task_repository_test.dart) | 100% |
| Telas e widgets | [`test/widgets/`](test/widgets/) | parcial |
| Rotas | [`test/routes/app_routes_test.dart`](test/routes/app_routes_test.dart) | — |

### Como testar a solução Firebase

A persistência usa **Cloud Firestore**. Os testes **não precisam de rede**: usam
`fake_cloud_firestore` (um Firestore em memória).

```bash
flutter test test/repositories/firestore_task_repository_test.dart
```

Esses testes cobrem `add`, `watchTasks` (stream), `update`, `delete` e o
*round-trip* de `DateTime ↔ Timestamp`.

**Para testar contra o Firebase real:**
1. O projeto já está conectado ao Firebase `despesas-pessoais-76cbd` (ver
   [`lib/firebase_options.dart`](lib/firebase_options.dart)).
2. O Firestore está habilitado (região `southamerica-east1`) com as regras de
   [`firestore.rules`](firestore.rules) (modo teste — ver aviso abaixo).
3. Rode o app, crie uma tarefa e verifique a coleção `tasks` no
   [Console do Firebase](https://console.firebase.google.com/project/despesas-pessoais-76cbd/firestore).

> ⚠️ **Regras de segurança:** a coleção `tasks` está em **modo teste**
> (`allow read, write: if true`), adequado para esta avaliação com dados não
> sensíveis. Para produção, exija autenticação (`if request.auth != null`).

### Como testar o consumo da API externa

O cliente da API REST do OpenWeather fica no package `geo_tools`. Os testes usam
um `MockClient` (do pacote `http`), então **validam o consumo da API sem fazer
chamadas reais**:

```bash
cd packages/geo_tools
dart test test/weather_client_test.dart
```

Cobrem: resposta HTTP 200 (com verificação dos parâmetros da query), 401 (chave
inválida), 500, falha de rede e decodificação UTF-8 dos acentos.

### Como testar o package interno

```bash
cd packages/geo_tools
dart pub get
dart test          # 24 testes cobrindo todos os módulos
```

Detalhes em [`packages/geo_tools/README.md`](packages/geo_tools/README.md).

### Testes de interface

```bash
# Widget tests (rodam sem device)
flutter test test/widgets/

# Integration test end-to-end (precisa de simulador/emulador)
flutter test integration_test/app_test.dart
```

O integration test executa o fluxo completo: criar → listar → abrir detalhe →
excluir, além da navegação para a tela "Sobre".

---

## Build iOS e Android

### iOS (validado)

```bash
flutter build ios --simulator        # build para simulador (sem assinatura)
flutter build ipa                    # build de distribuição (requer signing)
```

### Android (configurado)

O projeto está **configurado para Android** (Gradle 8 / AGP 8.11, plugin do
Firebase, `google-services.json`, manifesto e permissões). Para compilar, é
necessário o Android SDK instalado:

```bash
flutter build apk --release --dart-define=OPENWEATHER_API_KEY=SUA_CHAVE
flutter build appbundle --release --dart-define=OPENWEATHER_API_KEY=SUA_CHAVE
```

- **Application ID / Bundle ID:** `br.com.guilhermeribeiro.tarefasgeo` (iOS e Android)
- **minSdk:** 23 (exigido pelos plugins Firebase) · **iOS deployment target:** 13.0

---

## Permissões nativas

**Android** — [`android/app/src/main/AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

**iOS** — [`ios/Runner/Info.plist`](ios/Runner/Info.plist): `NSLocationWhenInUseUsageDescription`.

---

## Evidências

As capturas de tela ficam em [`docs/evidencias/`](docs/evidencias/). Veja o guia
[`docs/COMO_GERAR_EVIDENCIAS.md`](docs/COMO_GERAR_EVIDENCIAS.md) para reproduzir.

---

## Autor

**Guilherme Queiroz Ribeiro** — [github.com/GuiQueirozRibeiro](https://github.com/GuiQueirozRibeiro)
