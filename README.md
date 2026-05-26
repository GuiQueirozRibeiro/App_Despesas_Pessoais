# Tarefas Geo — App de Lista de Tarefas com Geolocalização

> **Pós-Graduação em Desenvolvimento Mobile**
> **Disciplina:** Desenvolvimento Mobile com Flutter
> **Aluno:** Guilherme Queiroz Ribeiro
> **Professor:** Thiago Aguiar

Aplicativo Flutter (Android e iOS) que gerencia uma lista de tarefas. Cada tarefa
possui **nome**, **data e hora** e, opcionalmente, uma **geolocalização** capturada
do GPS do dispositivo. O armazenamento é feito **em memória**, conforme o
enunciado do trabalho.

> Este repositório nasceu como `App_Despesas_Pessoais` (um trabalho anterior em
> Flutter) e foi **refatorado** para atender ao escopo de gestão de tarefas com
> geolocalização. O design adaptativo iOS/Android (Material + Cupertino), a
> paleta de cores (roxo + âmbar) e a tipografia OpenSans foram preservados.

---

## Sumário

- [Funcionalidades](#funcionalidades)
- [Capturas de Tela](#capturas-de-tela)
- [Cobertura dos Critérios da Rubrica](#cobertura-dos-critérios-da-rubrica)
- [Arquitetura](#arquitetura)
- [Como Executar](#como-executar)
- [Dependências](#dependências)
- [Permissões Nativas](#permissões-nativas)

---

## Funcionalidades

- **Criar tarefa** com nome, data, hora e (opcionalmente) localização do GPS.
- **Listar tarefas** ordenadas por data/hora mais próxima.
- **Editar tarefa** existente reabrindo o mesmo formulário.
- **Excluir tarefa** via *swipe* (Dismissible) com confirmação.
- **Capturar GPS** do dispositivo (alta precisão, com tratamento de permissões).
- **Pré-visualizar localização** em mapa interativo (OpenStreetMap, sem chave de API).
- **UI adaptativa**: Material no Android e Cupertino no iOS.
- **Responsivo**: layout se ajusta a celular, tablet e orientação paisagem.
- **Localização pt-BR** para datas e *pickers* nativos.

---

## Capturas de Tela

> As imagens abaixo ficam em [`assets/screenshots/`](assets/screenshots/) e devem
> ser geradas executando o app antes da entrega.

| Lista vazia | Lista preenchida | Formulário de criação |
|---|---|---|
| ![Vazio](assets/screenshots/01-empty.png) | ![Lista](assets/screenshots/02-list.png) | ![Form](assets/screenshots/03-form.png) |

| Captura de GPS | Mapa pré-visualizado | Excluir tarefa |
|---|---|---|
| ![GPS](assets/screenshots/04-gps.png) | ![Mapa](assets/screenshots/05-map.png) | ![Excluir](assets/screenshots/06-delete.png) |

---

## Cobertura dos Critérios da Rubrica

A disciplina avalia **16 critérios** distribuídos em 4 grupos. A tabela abaixo
mapeia cada critério à(s) tela(s)/arquivo(s) que comprovam o atendimento.

### 1 — Apps Flutter simples (4 critérios)

| Critério | Onde está |
|---|---|
| Interface de criação | [`lib/components/task_form.dart`](lib/components/task_form.dart) (aberta via `_openTaskFormModal`) |
| Interface de exclusão | [`lib/components/task_list.dart`](lib/components/task_list.dart) (Dismissible + diálogo) e [`lib/components/task_item.dart`](lib/components/task_item.dart) |
| Interface de edição | [`lib/components/task_form.dart`](lib/components/task_form.dart) reaproveitado com parâmetro `existing` |
| Interface de listagem | [`lib/components/task_list.dart`](lib/components/task_list.dart) e [`lib/components/task_item.dart`](lib/components/task_item.dart) |

### 2 — Layouts responsivos (4 critérios)

| Critério | Onde está |
|---|---|
| Layout responsivo na criação | [`lib/components/task_form.dart`](lib/components/task_form.dart) usa `SingleChildScrollView` + `viewInsets.bottom` para teclado |
| Layout responsivo na exclusão | [`lib/components/task_item.dart`](lib/components/task_item.dart) alterna entre `TextButton` (largo) e `IconButton` (estreito) via `LayoutBuilder` |
| Layout responsivo na edição | mesmo formulário responsivo de criação |
| Layout responsivo na listagem | [`lib/components/task_list.dart`](lib/components/task_list.dart) com `LayoutBuilder` + `ConstrainedBox(maxWidth: 720)` |

### 3 — Gerenciamento de estado (4 critérios)

`Provider` (ChangeNotifier) centraliza o estado e a UI reage automaticamente.

| Critério | Onde está |
|---|---|
| Estado na criação | [`lib/providers/task_provider.dart`](lib/providers/task_provider.dart) → `add()` |
| Estado na exclusão | [`lib/providers/task_provider.dart`](lib/providers/task_provider.dart) → `remove()` |
| Estado na edição | [`lib/providers/task_provider.dart`](lib/providers/task_provider.dart) → `update()` |
| Estado na listagem | `Consumer<TaskProvider>` em [`lib/components/task_list.dart`](lib/components/task_list.dart) |

### 4 — Geolocalização e mapas (4 critérios)

| Critério | Onde está |
|---|---|
| GPS do dispositivo | [`lib/services/location_service.dart`](lib/services/location_service.dart) usando `geolocator` |
| Inserção do GPS na criação | [`lib/components/adaptative_location_picker.dart`](lib/components/adaptative_location_picker.dart) embutido no form |
| Inserção do GPS na edição | mesmo picker, reaproveitado pelo `TaskForm` |
| Visualização em mapa na listagem | [`lib/components/adaptative_location_picker.dart`](lib/components/adaptative_location_picker.dart) com `flutter_map` (OpenStreetMap) — exibido no form e o item da lista mostra rótulo + coordenadas |

---

## Arquitetura

```
lib/
├── main.dart                            # Bootstrap, tema, locale, Provider
├── models/
│   └── task.dart                        # Entidade Task (id, nome, data, lat, lng)
├── providers/
│   └── task_provider.dart               # ChangeNotifier (in-memory CRUD)
├── services/
│   └── location_service.dart            # Camada de acesso ao GPS
└── components/
    ├── adaptative_button.dart           # Botão iOS/Android
    ├── adaptative_text_field.dart       # Campo de texto iOS/Android
    ├── adaptative_date_time_picker.dart # Picker de data e hora adaptativo
    ├── adaptative_location_picker.dart  # Picker de GPS + preview em mapa
    ├── task_form.dart                   # Form único de criação/edição
    ├── task_item.dart                   # Card de uma tarefa
    └── task_list.dart                   # Lista responsiva com swipe-to-delete
```

- **Padrão adaptativo**: cada widget verifica `Platform.isIOS` e troca entre
  Material e Cupertino. Mantém uma única árvore de widgets para os dois sistemas.
- **Persistência**: somente em memória (`List<Task>` no `TaskProvider`). Reiniciar
  o app limpa as tarefas — comportamento intencional, conforme enunciado.
- **Sem backend**: o mapa usa *tiles* públicos do OpenStreetMap, então o app
  funciona sem nenhuma chave de API.

---

## Como Executar

Pré-requisitos: Flutter 3.0+ e um dispositivo/emulador Android ou iOS com GPS.

```bash
flutter pub get
flutter run
```

Para gerar APK de release:

```bash
flutter build apk --release
```

> **Dica para o emulador**: no Android Studio, abra *Extended Controls* →
> *Location* e envie uma coordenada manualmente antes de tocar em
> "Usar localização atual" no app.

---

## Dependências

| Pacote | Uso |
|---|---|
| `provider` | Gerenciamento de estado |
| `geolocator` | Captura de coordenadas GPS + permissões |
| `flutter_map` + `latlong2` | Mapa interativo (OpenStreetMap) |
| `flutter_localizations` + `intl` | Localização pt-BR e formatação de datas |

---

## Permissões Nativas

**Android** — [`android/app/src/main/AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

**iOS** — [`ios/Runner/Info.plist`](ios/Runner/Info.plist)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Precisamos da sua localização para registrar o local da tarefa.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Precisamos da sua localização para registrar o local da tarefa.</string>
```

---

## Autor

| [<img src="https://avatars.githubusercontent.com/u/70274921?s=400&u=c1688d6fcd13223bfe1093c6d16b3b6b646545fe&v=4" width=115><br><sub>Guilherme Queiroz Ribeiro</sub>](https://github.com/GuiQueirozRibeiro) |
| :---: |
