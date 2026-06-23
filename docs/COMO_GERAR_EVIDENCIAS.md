# Como gerar as evidências de funcionamento

Este guia descreve como reproduzir e capturar as evidências exigidas pela
rubrica (funcionamento do app, Firebase, API externa e package).

## 1. Preparar o ambiente

```bash
flutter pub get
# Obtenha uma chave gratuita em https://openweathermap.org/api
flutter run --dart-define=OPENWEATHER_API_KEY=SUA_CHAVE
```

## 2. Telas a capturar (salvar em `docs/evidencias/`)

| Arquivo sugerido | Tela / ação |
|---|---|
| `01-lista-vazia.png` | App aberto, sem tarefas (estado vazio) |
| `02-form-nova.png` | Tela "Nova Tarefa" preenchida (nome, data, GPS) |
| `03-lista.png` | Lista com tarefas criadas |
| `04-detalhe-clima.png` | Tela de detalhe mostrando o **clima** (OpenWeather) |
| `05-detalhe-mapa.png` | Tela de detalhe com o **mapa** e coordenadas |
| `06-distancia.png` | Resultado do botão "Calcular" distância (GPS + Haversine) |
| `07-sobre.png` | Tela "Sobre" |
| `08-firestore-console.png` | Console do Firebase mostrando a coleção `tasks` |
| `09-testes.png` | Saída de `flutter test --coverage` (verde) |
| `10-cobertura.png` | Relatório de cobertura (56,5%) |

## 3. Como capturar a tela

**Simulador iOS:** `Cmd + S` (salva no Desktop) ou:
```bash
xcrun simctl io booted screenshot docs/evidencias/01-lista-vazia.png
```

**Emulador Android:** botão de câmera na barra lateral, ou:
```bash
adb exec-out screencap -p > docs/evidencias/01-lista-vazia.png
```

## 4. Evidência do Firebase

1. Crie 2–3 tarefas no app.
2. Abra o [Console do Firestore](https://console.firebase.google.com/project/despesas-pessoais-76cbd/firestore).
3. Capture a coleção `tasks` com os documentos criados (mostra a integração real).

## 5. Evidência dos testes

```bash
# App (unitários + widget) — mostrar "All tests passed!" e a cobertura
flutter test --coverage

# Package interno (24 testes)
cd packages/geo_tools && dart test
```

## 6. Evidência do integration test (interface)

```bash
flutter test integration_test/app_test.dart   # com simulador/emulador aberto
```
