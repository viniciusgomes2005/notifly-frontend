# NotiFly Frontend (Flutter)

Repositório: **[viniciusgomes2005/notifly-frontend](https://github.com/viniciusgomes2005/notifly-frontend)**

Frontend em **Flutter** para o NotiFly: um app com navegação estilo “WhatsApp” (Home + Chat) integrado ao backend via HTTP, com autenticação persistida em **Hive** e rotas geradas por **auto_route**. :contentReference[oaicite:0]{index=0}

---

## Stack / Dependências principais

- **Flutter / Dart** (SDK `^3.10.3`) :contentReference[oaicite:1]{index=1}  
- **auto_route** + **auto_route_generator** (rotas e guards) :contentReference[oaicite:2]{index=2}  
- **Hive** (`hive_flutter`) para persistir `userData` (ex.: `id`, `role`) :contentReference[oaicite:3]{index=3}  
- **HTTP** (package `http`) para consumir o backend :contentReference[oaicite:4]{index=4}  
- **toastification**, **table_calendar**, **figma_squircle** :contentReference[oaicite:5]{index=5}

---

## Rotas e fluxo de autenticação

Rotas geradas (exemplos):

- `/login` → **LoginPage**
- `/register` → **RegisterPage**
- `/notifly` → **NavBarPage** (rota protegida por **AuthGuard**)
  - `home` (inicial)
  - `chat/:chatId` :contentReference[oaicite:6]{index=6}

O **AuthGuard** valida autenticação verificando `Hive.box("userData").get("id")`. Se estiver nulo, redireciona para `/login`. :contentReference[oaicite:7]{index=7}

---

## Pré-requisitos

- Flutter SDK instalado
- Node.js (se você roda o backend localmente)
- Backend do NotiFly rodando localmente (por padrão o app aponta para `http://localhost:4000/`). :contentReference[oaicite:8]{index=8}

---

## Configuração do backend (URL)

O `ApiManager` usa `_baseUrl = 'http://localhost:4000/'`. Se seu backend estiver em outro host/porta (ou em dispositivo físico), ajuste aqui:

- `lib/api/api_manager.dart` → `_baseUrl` :contentReference[oaicite:9]{index=9}

Sugestões comuns:
- **Android Emulator**: `http://10.0.2.2:4000/`
- **iOS Simulator**: normalmente `http://localhost:4000/`
- **Celular na mesma rede**: `http://SEU_IP_LOCAL:4000/`

---

## Como rodar (desenvolvimento)

```bash
# 1) instalar deps
flutter pub get

# 2) gerar arquivos do auto_route (app_router.gr.dart)
flutter pub run build_runner build --delete-conflicting-outputs

# 3) rodar
flutter run
````

> Observação: sempre que você alterar rotas em `lib/router/app_router.dart`, rode o `build_runner` novamente. ([GitHub][1])

---

## Estrutura (visão rápida)

* `lib/main.dart` – bootstrap do app
* `lib/router/` – rotas e configuração do auto_route ([GitHub][1])
* `lib/guards/` – guards (AuthGuard / AdminGuard) ([GitHub][2])
* `lib/api/` – `ApiManager` + APIs (auth/chat/message/task) ([GitHub][3])
* `lib/models/` – modelos (User/Chat/Message/Task) ([GitHub][4])
