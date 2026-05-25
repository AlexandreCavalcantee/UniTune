# UniTune

Aplicativo mobile de descoberta de músicas feito com Flutter para uma rádio universitária, com dados da **iTunes Search API**.

---

## Arquitetura

O UniTune segue uma **Arquitetura em Camadas** com três camadas principais:

```
lib/
├── data/
│   └── services/
│       ├── itunes_service.dart       # iTunes Search API (http)
│       ├── database_service.dart     # Armazenamento de playlists em SQLite (sqflite)
│       └── preferences_service.dart  # Configurações de busca (SharedPreferences)
├── domain/
│   ├── entities/
│   │   ├── song.dart                 # Entidade Música + mapeamento iTunes/DB
│   │   ├── artist.dart               # Entidade Artista
│   │   ├── album.dart                # Entidade Álbum + mapeamento iTunes
│   │   └── playlist.dart             # Entidade Playlist (nome + lista de músicas)
│   └── repositories/
│       └── playlist_repository.dart  # Contrato de Playlist
└── presentation/
    ├── providers/
    │   ├── search_provider.dart       # Estado de busca (ChangeNotifier)
    │   ├── playlist_provider.dart     # Estado CRUD de playlists (ChangeNotifier)
    │   ├── now_playing_provider.dart  # Estado global de reprodução de áudio
    │   ├── recommendation_provider.dart # Estado de recomendações de álbuns
    │   └── theme_provider.dart        # Alternância de tema claro/escuro
    ├── screens/
    │   ├── home_screen.dart           # Home com recomendações + prévia de playlist
    │   ├── search_screen.dart         # Interface de busca
    │   ├── details_screen.dart        # Detalhe da faixa + player de áudio de 30s
    │   ├── album_details_screen.dart  # Detalhe do álbum + listagem de faixas + prévia
    │   ├── playlist_screen.dart       # Gerenciamento de playlists locais
    │   └── playlist_details_screen.dart # Visão individual de playlist
    ├── widgets/
    │   ├── mini_player_bar.dart       # Barra de mini player persistente
    │   ├── app_bottom_nav.dart        # Barra de navegação inferior
    │   └── playlist_selection_dialog.dart # Diálogo para escolher playlist ao salvar uma faixa
    └── theme/
        └── app_theme.dart             # Tema Material 3 + gradientes de cabeçalho
```

## Stack de Tecnologias

| Responsabilidade | Pacote |
|---|---|
| Interface | Flutter / Material 3 |
| HTTP | `http` |
| SQLite | `sqflite` + `path` |
| Preferências | `shared_preferences` |
| Gerenciamento de Estado | `provider` |
| Player de Áudio | `just_audio` |
| IDs de Playlist | `uuid` |

## Funcionalidades

### Tela Home
- Barra superior persistente com o nome do app
- Campo de busca inline que navega para a tela de Busca
- **"Recomendados para Hoje"** — carrossel horizontal de álbuns baseado nas músicas salvas pelo usuário
- **"Top Playlists"** — prévia das primeiras 6 faixas salvas; ao tocar, navega para a tela de Playlist
- Barra de navegação inferior (Home / Busca / Biblioteca)
- Botão de ação flutuante como atalho para a busca
- **Mini Player Bar** visível acima da navegação inferior sempre que uma faixa estiver tocando

### Tela de Busca
- Campo de busca livre com botão de envio
- **Botões de rádio** para alternar entre busca por *Música*, *Artista* e *Álbum*
- **Filtro de conteúdo explícito** para ocultar conteúdo inapropriado
- Configurações persistidas via `SharedPreferences`
- Resultados exibidos em uma `ListView` rolável de widgets `Card`

### Tela de Detalhes
- Arte do álbum grande (300×300 do CDN do iTunes)
- Nome da faixa, artista, álbum, gênero e selo de conteúdo explícito
- Player de **prévia de áudio de 30 segundos** com barra de progresso
- Adicionar faixa a uma playlist local via diálogo de seleção

### Tela de Detalhes do Álbum
- Cabeçalho paralaxe recolhível com arte do álbum e fundo gradiente
- Chips de metadados: gênero, data de lançamento, número de faixas, preço
- Listagem completa de faixas obtida da API do iTunes
- Toque em qualquer faixa para alternar a prévia de 30 segundos, com barra de progresso exibida para a faixa ativa
- Botão de alternância de tema claro/escuro na barra do app

### Tela de Playlists
- Todas as playlists salvas localmente (SQLite)
- Checkbox **"Sugerir à rádio"** por faixa (persistido)
- Deletar faixas individuais
- Toque em qualquer playlist para abrir sua visão detalhada

### Tela de Detalhes da Playlist
- Cabeçalho paralaxe recolhível com arte da playlist e fundo gradiente
- Nome da playlist e contagem de faixas
- Listagem completa de faixas com miniaturas de capa
- Toque em qualquer faixa para abrir sua tela de Detalhes
- Botão de alternância de tema claro/escuro na barra do app

### Mini Player Bar
- Aparece acima da barra de navegação inferior sempre que uma faixa estiver tocando
- Exibe miniatura da capa do álbum, nome da faixa e nome do artista
- Botão de play / pause
- Barra de progresso fina na parte inferior da barra (toque para avançar)

### Tema
- Suporte a modo claro e escuro, alternado nas telas de Detalhes do Álbum e Detalhes da Playlist

## Instalação

**Pré-requisitos:** Flutter SDK 3.0+ e um emulador ou dispositivo conectado.

```bash
# 1. Clone o repositório
git clone https://github.com/marcusviniciusend/UniTune.git
cd UniTune

# 2. Instale as dependências
flutter pub get

# 3. Execute o app
flutter run
```

## Executando os Testes

```bash
flutter test
```
