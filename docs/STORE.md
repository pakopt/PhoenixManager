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
| **Versão actual** | `0.8.8` (`versionCode` **9**) |
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

### 0. Conta em verificação (concluído)

Se acabaste de registar a conta, o Google pode demorar 1–7 dias úteis. **Conta aprovada?** Segue directamente a secção **1. Criar a app** abaixo.

Enquanto esperavas, estes comandos preparavam assets (já prontos):

```bash
./scripts/play_console_brief.sh    # textos copy-paste + checklist assets
./scripts/package_play_store.sh    # ZIP com AAB + gráficos
./scripts/mobile_doctor.sh
./scripts/play_console_day1.sh     # guia dia 1 — teste interno
```

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

#### Gratuita vs paga (decisão permanente)

| Escolha na criação | Efeito |
|--------------------|--------|
| **Gratuita** ✅ (recomendado) | Download 0 €; podes acrescentar **IAP/subscrições** mais tarde |
| **Paga** | Utilizador paga para instalar; **não podes mudar para gratuita** depois |

**Não podes** converter uma app **gratuita** em **paga à entrada** na mesma ficha Play Store.

**Project Phoenix Manager (v0.8.8+):** escolhe **Gratuita** — sem anúncios, sem compras in-app, sem billing. A «receita» no jogo é simulação (finanças do clube), não monetização real.

Monetização futura (opcional, requer código novo): IAP ou subscrição **mantendo a app gratuita**; ou nova app com outro package name se quiseres modelo «só paga para instalar».

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
   - Version name: `0.8.8` (ou a versão actual do `pubspec.yaml`)
   - Version code: `9` (número após `+` no pubspec)
4. **Nome da versão:** `0.8.8 (9)` (notas internas)
5. **Notas da versão** (visíveis aos testadores) — ver também `./scripts/play_console_brief.sh`:
   ```
   v0.8.8 — gestão offline com PSE, polish UX e Android 15.
   - Modo Express e Diretor · liga, taça, mercado, finanças
   - Edge-to-edge Android 15 · datas legíveis · acessibilidade
   - Saves locais · sem conta · sem anúncios
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
Gestor de futebol offline: liga, taça, mercado, plantel, treinos e finanças.
```

**Descrição completa** (máx. 4000 caracteres — a Google exige funcionalidades claras):

```
Project Phoenix Manager é um jogo de gestão de futebol para Android. Conduz um clube numa liga completa com taça eliminatória, temporadas, promoções e estatísticas. Tudo funciona no telemóvel ou tablet, sem conta de utilizador e sem ligação à Internet após a instalação.

O QUE PODES FAZER NO JOGO

• Escolher ou continuar uma carreira — vários slots de save locais
• Gerir o plantel — ver jogadores, atributos, forma, lesões e contratos
• Planear treinos e academia de jovens
• Negociar no mercado de transferências e renovar contratos
• Acompanhar finanças do clube — salários, receitas, resultado de época
• Ver calendário de jogos, classificação da liga e taça
• Jogar em Modo Express — simular jornadas rapidamente com resultados animados
• Jogar em Modo Diretor — gestão completa com alertas antes de cada jogo
• Ler relatos completos das partidas e acompanhar a simulação

COMO FUNCIONA

O jogo usa o motor Phoenix Simulation Engine (PSE) para simular partidas, economia do clube e progressão da temporada. Os dados da carreira ficam guardados apenas no teu dispositivo — não enviamos informação para servidores externos.

CARACTERÍSTICAS

• Gratuito, sem anúncios
• Sem compras dentro da app
• Sem registo ou login
• Offline-first — joga em viagem ou sem Wi‑Fi
• Política de privacidade: não recolhemos dados pessoais

PARA QUEM É

Ideal para fãs de jogos de gestão desportiva (football manager) que preferem uma experiência simples, rápida e totalmente offline.

REQUISITOS

Android 5.0 ou superior.

CONTACTO

Questões ou feedback: pakopt7@gmail.com
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

> Se instalaste pelo **teste interno Play Store**, o APK local pode falhar (`assinaturas diferentes`). Para capturas: `adb uninstall com.phoenix.manager` ou `./scripts/capture_play_screenshots.sh --install --batch` (desinstala automaticamente).

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

### 9b. Teste interno — após enviar

1. **Vista geral da publicação** — estado «Em revisão» (teste interno: minutos a ~24 h)
2. Email da Google quando aprovado
3. **Testadores** → copiar **link de adesão** → abrir no telemóvel (conta Gmail da lista)
4. Instalar pela **Play Store** (não sideload)
5. QA rápido: [`docs/BETA.md`](BETA.md) passos 1–6 (menu, dashboard, Express, save)
6. Problemas → pakopt7@gmail.com com versão (ex. `0.8.8 (9)`) e modelo do telemóvel

Quando estiveres satisfeito (1–7 dias de teste real):

- **Promover** a produção (§10), ou
- **Teste fechado** com mais emails antes de produção

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
   version: 0.8.8+9   # nome visível + versionCode (número após +)
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
| Rejeição ficha da loja | Descrição vaga («não descreve recursos») | Usa descrição completa com secção «O QUE PODES FAZER» — ver §4 ou `./scripts/play_console_brief.sh` |
| App não aparece para testadores | Lista de testadores vazia | Adiciona emails + link de adesão |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | App Play Store + APK local (assinaturas diferentes) | `adb uninstall com.phoenix.manager` → `./scripts/install_android.sh` ou capturas com `--install` |
| Aviso «edge-to-edge» / SDK 35 | targetSdk 35 sem inserções | Ver `apps/phoenix_manager/MOBILE.md` § Android 15; rebuild AAB |
| Screenshots iguais | Batch sem mudar ecrã no emulador | Navega a cada Enter no modo `--batch`; mín. 2 ecrãs diferentes |
| "Alpha" no nome da versão | Aceite pela Play Store | OK para teste interno; usa `0.8.x` em produção |

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
