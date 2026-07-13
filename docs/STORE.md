# Publicação nas lojas — Project Phoenix Manager

Guia para **Google Play** e App Store. Steam: ver [steam/README.md](../steam/README.md).

**Guia detalhado Play Store:** secção [Google Play — upload passo a passo](#google-play--upload-passo-a-passo) abaixo.

## Antes de submeter

| Item | Estado | Acção |
|------|--------|-------|
| Bundle ID | ✅ `com.phoenix.manager` | — |
| Ícones / splash | ✅ | `./scripts/regenerate_branding.sh` |
| Política privacidade | ✅ | [`docs/PRIVACY.md`](PRIVACY.md) + ecrã in-app |
| Saves testados | ✅ | `./scripts/test_release_saves.sh` |
| Keystore Android | ✅ | `./scripts/android_keystore.sh` (já configurado) |
| AAB release assinado | ✅ | `./scripts/build_mobile.sh android` |
| Site privacidade (HTML) | ✅ | [privacidade online](https://pakopt.github.io/PhoenixManager/privacy.html) |
| URL https privacidade | ✅ | [privacidade](https://pakopt.github.io/PhoenixManager/privacy.html) |
| Apple Developer | ⏳ | Xcode signing (App Store) |

---

## Google Play — upload passo a passo

### Resumo rápido

| Campo | Valor |
|-------|-------|
| **Package name** | `com.phoenix.manager` |
| **AAB para upload** | `build/release/mobile/android/phoenix_manager.aab` |
| **Versão actual** | `0.8.0-alpha` (`versionCode` **1**) |
| **Tipo** | Jogo, gratuito, offline |
| **Contacto** | pakopt7@gmail.com |

### 0. Pré-requisitos (uma vez)

1. **Conta Google Play Developer** — [play.google.com/console/signup](https://play.google.com/console/signup)  
   Taxa única (~25 USD). Verificação de identidade pode demorar 1–2 dias.

2. **Keystore de release** — já configurado neste projecto:
   ```bash
   ./scripts/mobile_doctor.sh    # secção "Android signing" deve estar OK
   ```

3. **Gerar o AAB assinado**
   ```bash
   ./scripts/launch_doctor.sh    # opcional — checklist geral
   ./scripts/build_mobile.sh android
   ls -lh build/release/mobile/android/phoenix_manager.aab
   ```
   Tamanho de referência: ~48–57 MB.

4. **URL pública da política de privacidade**  
   A Play Console exige um link **https** acessível sem login.

   **Já preparado no repo:**
   - HTML: [`docs/site/privacy.html`](site/privacy.html)
   - Repositório: [github.com/pakopt/PhoenixManager](https://github.com/pakopt/PhoenixManager)
   - Publicar: [`docs/site/README.md`](site/README.md) (GitHub Pages + workflow `.github/workflows/pages.yml`)
   - **URL privacidade:** [pakopt.github.io/PhoenixManager/privacy.html](https://pakopt.github.io/PhoenixManager/privacy.html)

   Fonte Markdown: [`docs/PRIVACY.md`](PRIVACY.md) — manter `privacy.html` em sync ao alterar.

### 0. Conta em verificação

Se a Play Console mostrar **conta em verificação** após o registo (~25 USD), é normal. O Google valida identidade e pagamento (1–7 dias úteis). Enquanto esperas:

```bash
./scripts/play_console_brief.sh    # textos copy-paste + checklist assets
./scripts/package_play_store.sh    # ZIP com AAB + gráficos
./scripts/mobile_doctor.sh
```

Responde a emails do Google e verifica notificações na consola. Quando a conta activar, segue a secção **1. Criar a app** abaixo.

### 1. Criar a app na Play Console

1. Abrir [Google Play Console](https://play.google.com/console)
2. **Criar app** (*Create app*)
3. Preencher:
   - **Nome:** Project Phoenix Manager
   - **Idioma predefinido:** Português (Portugal) — ou PT-BR se preferires
   - **App ou jogo:** Jogo
   - **Gratuita ou paga:** Gratuita
4. Aceitar as declarações (políticas, exportação EUA, etc.)

> O **package name** `com.phoenix.manager` fica fixo na primeira release. Não o alteres no código depois de publicar.

### 2. Painel — completar tarefas obrigatórias

A Play Console mostra um checklist. Ordem recomendada:

| # | Secção | O que fazer |
|---|--------|-------------|
| 1 | **Testadores** → Teste interno | Primeiro upload do AAB (ver passo 3) |
| 2 | **Presença na loja** → Ficha principal | Textos, ícone, capturas |
| 3 | **Presença na loja** → Gráficos | Ícone 512×512, feature graphic, screenshots |
| 4 | **Política** → Classificação de conteúdo | Questionário IARC |
| 5 | **Política** → Público-alvo | Idade / crianças |
| 6 | **Política** → Segurança dos dados | Formulário *Data safety* |
| 7 | **Política** → Política de privacidade | URL https |
| 8 | **Política** → Apps de notícias / Ads / etc. | Declarações rápidas |
| 9 | **Versão** → Produção (ou teste interno) | Enviar para revisão |

### 3. Upload do AAB (começar por teste interno)

Recomendado: **Teste interno** antes de produção — revisão mais rápida, até 100 testadores.

1. **Testar e lançar** → **Teste interno** → **Criar nova versão**
2. **Carregar** → seleccionar:
   ```
   build/release/mobile/android/phoenix_manager.aab
   ```
3. Aguardar processamento (1–5 min). Verificar:
   - Package: `com.phoenix.manager`
   - Version name: `0.8.0-alpha`
   - Version code: `1`
4. **Nome da versão:** `0.8.0-alpha (1)` (notas internas)
5. **Notas da versão** (visíveis aos testadores), exemplo:
   ```
   v0.8.0-alpha — primeira build pública de teste.
   - Modo Express e carreira completa
   - Saves locais offline
   - Motor Phoenix Simulation Engine v0.8
   ```
6. **Rever versão** → **Iniciar implementação para teste interno**

**Instalar no telemóvel (teste interno):**

1. **Testadores** → criar lista de emails (inclui o teu Gmail)
2. Copiar o **link de adesão** e abrir no telemóvel
3. Aceitar convite → instalar pela Play Store (não sideload)

> **APK** (`phoenix_manager.apk`) serve só para sideload local (`./scripts/install_android.sh`). A Play Store **só aceita AAB**.

### 4. Ficha da loja — textos sugeridos

Copia/adapta na secção **Presença na loja → Ficha principal da loja**.

**Título** (máx. 30 caracteres):

```
Project Phoenix Manager
```

**Descrição curta** (máx. 80 caracteres):

```
Gestão de futebol offline com motor Phoenix Simulation Engine.
```

**Descrição completa** (máx. 4000 caracteres):

```
Project Phoenix Manager é um jogo de gestão de futebol offline-first para telemóvel e tablet.

Assume o comando do teu clube: plantel, tácticas, mercado, finanças e calendário numa liga completa com taça. Tudo corre no dispositivo — sem conta, sem servidor, sem anúncios.

DESTAQUES
• Modo Express — simula jornadas rapidamente e vê resultados animados
• Carreira completa — temporadas, promoções, taças e estatísticas
• Motor Phoenix Simulation Engine (PSE v0.8) — partidas credíveis e finanças simuladas
• Saves locais — continua a carreira quando quiseres
• Política de privacidade transparente — não recolhemos dados pessoais

IDEAL PARA
• Fãs de manager games que querem jogar offline
• Sessões curtas no telemóvel ou partidas mais longas no tablet

Requisitos: Android 5.0+. Funciona sem ligação à Internet após instalação.

Contacto: pakopt7@gmail.com
```

**Categoria:** Jogos → Desporto (ou Simulação)

**Email de contacto:** pakopt7@gmail.com

**Site** (opcional): repositório GitHub ou site do projecto, se existir

### 5. Gráficos da loja

| Asset | Tamanho | Origem |
|-------|---------|--------|
| Ícone da loja | 512×512 PNG | Exportar de `apps/phoenix_manager/assets/branding/icon.png` |
| Feature graphic | 1024×500 PNG/JPEG | Criar banner (logo + fundo `#0A0E14`, verde `#2E7D32`) |
| Screenshots telemóvel | Mín. 2, máx. 8; ratio 16:9 ou 9:16 | Capturas do emulador ou dispositivo |
| Screenshots tablet 7"/10" | Opcional | Recomendado se quiseres destaque em tablets |

**Como capturar screenshots (Android):**

```bash
chmod +x scripts/capture_play_screenshots.sh scripts/export_feature_graphic.sh

# Modo guiado (recomendado) — instala APK + 5 ecrãs sugeridos
./scripts/capture_play_screenshots.sh --install --batch

# Feature graphic 1024×500
./scripts/export_feature_graphic.sh
```

Saída: `build/release/store/android/` — upload na Play Console → **Presença na loja → Gráficos**.

Modo interactivo: `./scripts/capture_play_screenshots.sh` (Enter entre capturas).

Ver também [`apps/phoenix_manager/BRANDING.md`](../apps/phoenix_manager/BRANDING.md).

### 6. Classificação de conteúdo (IARC)

Questionário típico para este jogo:

| Pergunta | Resposta sugerida |
|----------|-------------------|
| Violência | Desporto simulado / cartoon; sem violência realista |
| Sexualidade | Nenhuma |
| Linguagem | Nenhuma ou mínima |
| Drogas | Nenhuma |
| Jogo / apostas | Simulação desportiva; **sem** dinheiro real |
| Interacção utilizadores | Nenhuma (offline, sem chat) |
| Partilha de localização | Não |
| Compras digitais | Não (app gratuita sem IAP nesta versão) |

Guarda o certificado IARC — a Play Console associa-o automaticamente.

### 7. Público-alvo e conteúdo

- **Público-alvo:** 13+ (alinhado com [`docs/PRIVACY.md`](PRIVACY.md))
- **App dirigida a crianças:** Não
- Se perguntarem sobre **Families / Designed for children:** Não — não recolhemos dados de crianças

### 8. Segurança dos dados (*Data safety*)

Respostas alinhadas com [`docs/PRIVACY.md`](PRIVACY.md):

| Campo | Resposta |
|-------|----------|
| Recolhe ou partilha dados? | **Não** — nenhum dado recolhido ou partilhado |
| Dados encriptados em trânsito | N/A (sem transmissão a servidores) |
| Pedido de eliminação de dados | **Sim** — utilizador apaga dados da app (Definições → Apps → Limpar dados) |
| Tipo de dados | Nenhum (sem email, localização, IDs, analytics) |
| Finalidade | N/A |
| Partilha com terceiros | Não |
| Analytics / publicidade | Não |

**Nota:** saves de jogo ficam **só no dispositivo** (SharedPreferences). Não são "dados recolhidos" pela app no sentido Play Console — não saem do telemóvel.

### 9. Outras declarações

| Declaração | Resposta |
|------------|----------|
| **Acesso à app** | Todas as funcionalidades disponíveis sem login ou convite |
| **Anúncios** | Não contém anúncios |
| **Permissões sensíveis** | Nenhuma especial além do armazenamento local |
| **COVID-19 / apps de notícias** | Não aplicável |
| **Exportação EUA** | Geralmente "Não" para software de entretenimento offline — segue o assistente |

### 10. Enviar para revisão (produção)

Depois de validar em **teste interno** (1–7 dias de uso real):

1. **Testar e lançar** → **Produção** → **Criar nova versão**
2. **Promover release** desde teste interno *ou* voltar a carregar o mesmo AAB
3. Seleccionar **países** (ex.: Portugal, Brasil, ou todos)
4. **Enviar para revisão**

Tempos típicos: teste interno (minutos–horas); produção (1–7 dias na primeira submissão).

### 11. Actualizações futuras

Cada upload precisa de **`versionCode` maior** que o anterior.

1. Editar `apps/phoenix_manager/pubspec.yaml`:
   ```yaml
   version: 0.8.1+2   # nome visível + versionCode (número após +)
   ```
2. Rebuild e upload:
   ```bash
   ./scripts/build_mobile.sh android
   # Novo AAB em build/release/mobile/android/phoenix_manager.aab
   ```
3. Nova release na Play Console com notas de versão

**Importante:** guarda o keystore (`android/keystore/phoenix-manager-release.jks`) e passwords em local seguro (1Password, etc.). **Perder o keystore impede actualizações** da mesma app na Play Store.

### 12. Problemas comuns

| Erro / sintoma | Causa | Solução |
|----------------|-------|---------|
| `Upload failed: signed with wrong key` | AAB assinado com debug key | Confirma `key.properties` + keystore; `./scripts/mobile_doctor.sh` |
| `Version code X has already been used` | `versionCode` repetido | Aumenta o número após `+` no `pubspec.yaml` |
| Aviso debug symbols no build | cmdline-tools em falta | `./scripts/setup_android_cmdline_tools.sh` ou Android Studio SDK Manager |
| Rejeição Data safety | Formulário inconsistente com a app | Offline, sem analytics — marcar "não recolhe dados" |
| Rejeição política privacidade | URL inacessível | Testa o link em janela anónima |
| App não aparece para testadores | Lista de testadores vazia | Adiciona emails + link de adesão |
| "Alpha" no nome da versão | Aceite pela Play Store | OK para teste interno; considera `0.8.0` sem sufixo em produção |

### 13. Checklist final Play Store

```bash
./scripts/mobile_doctor.sh
SAVE_TEST=1 ./scripts/test_release_saves.sh   # opcional
./scripts/build_mobile.sh android
./scripts/test_all.sh
```

- [ ] Conta Play Developer activa
- [ ] AAB em `build/release/mobile/android/phoenix_manager.aab`
- [ ] URL https da política de privacidade
- [ ] Ficha da loja (textos + ícone 512 + feature graphic + ≥2 screenshots)
- [ ] Classificação IARC completa
- [ ] Data safety preenchido
- [ ] Teste interno instalado num dispositivo real
- [ ] Enviar produção

---

## App Store / TestFlight

### 1. Conta Apple Developer

1. [developer.apple.com](https://developer.apple.com) — inscrição anual  
2. Abrir `apps/phoenix_manager/ios/Runner.xcodeproj` no Xcode (SwiftPM — sem CocoaPods)  
3. **Signing & Capabilities** → Team + Bundle ID `com.phoenix.manager`  
4. Product → Archive → Distribute App

### 2. Build IPA (com provisioning)

```bash
cd apps/phoenix_manager
flutter build ipa
```

Build local sem signing: `./scripts/build_mobile.sh ios` (Runner.app).

### 3. App Privacy (App Store Connect)

- Dados não recolhidos  
- Política de privacidade: mesma URL ou texto de `docs/PRIVACY.md`

---

## macOS (Mac App Store — opcional)

Bundle ID: `com.phoenix.manager`. Distribuição directa actual: `./scripts/install_local.sh` → `/Applications`.

Mac App Store exige notarização Apple + sandbox — fora do scope v0.8 alpha.

---

## Contacto e suporte

**Email:** pakopt7@gmail.com (política de privacidade e suporte nas lojas)
