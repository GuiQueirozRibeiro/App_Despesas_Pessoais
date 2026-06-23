# Ficha de Publicação — Tarefas Geo

Metadados para o formulário de upload nas lojas (Google Play / App Store).

## Identidade

| Campo | Valor |
|---|---|
| Nome do app | Tarefas Geo |
| Bundle ID / Application ID | `br.com.guilhermeribeiro.tarefasgeo` |
| Versão | 1.0.0 (build 1) |
| Categoria | Produtividade |
| Idioma padrão | Português (Brasil) |
| Classificação etária | Livre |
| Site/Contato | github.com/GuiQueirozRibeiro |

## Descrição curta (até 80 caracteres)

> Organize tarefas com data, local no mapa e o clima atual de onde elas acontecem.

## Descrição completa

> O **Tarefas Geo** ajuda você a planejar seu dia conectando cada tarefa a um
> lugar. Crie tarefas com data e hora, marque a localização usando o GPS do seu
> aparelho e visualize tudo em um mapa. Na tela de detalhe, o app mostra o
> **clima atual** no local da tarefa e calcula a **distância** a partir de onde
> você está.
>
> Suas tarefas são salvas na nuvem (Cloud Firestore) e sincronizam
> automaticamente. Interface adaptada para Android e iOS.
>
> **Recursos:**
> • Tarefas com data, hora e localização
> • Mapa interativo (OpenStreetMap)
> • Clima em tempo real (OpenWeather)
> • Cálculo de distância via GPS
> • Sincronização na nuvem (Firebase)

## Palavras-chave

tarefas, lista, geolocalização, mapa, clima, produtividade, lembretes, GPS

## Recursos de loja (checklist)

- [ ] Ícone 512×512 (Play) / 1024×1024 (App Store) — já incluído via `flutter_launcher_icons`
- [ ] Screenshots de telefone (mín. 2) — ver [`docs/evidencias/`](evidencias/)
- [ ] Política de privacidade (uso de localização)
- [ ] Build de release assinado (`flutter build appbundle` / `flutter build ipa`)

## Aviso de privacidade (uso de localização)

> Este app usa a localização do dispositivo **apenas** para registrar o local de
> uma tarefa e calcular distâncias. As coordenadas ficam associadas às suas
> tarefas no Firestore e não são compartilhadas com terceiros.

## Arquivos necessários para publicação (já presentes no projeto)

| Arquivo | Função |
|---|---|
| `android/app/build.gradle.kts` | `applicationId`, versão, `minSdk`, signing |
| `android/app/google-services.json` | Configuração Firebase (Android) |
| `ios/Runner/Info.plist` | Nome, permissões, deployment target |
| `ios/Runner/GoogleService-Info.plist` | Configuração Firebase (iOS) |
| `pubspec.yaml` | Versão (`version: 1.0.0+1`) e ícones |
