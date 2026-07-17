# Beta local — sem lojas

Distribuição e testes **antes** ou **em paralelo** com a Play Store. Útil para testadores sideload (APK/Mac) enquanto preparas o teste interno na Play Console.

## Mac (release)

```bash
./scripts/install_local.sh    # build + instala em /Applications
./scripts/test_mac.sh         # valida saves
open -a "Phoenix Manager"
```

Partilhar a app: copia `/Applications/Phoenix Manager.app` para outro Mac (arrastar para `/Applications`).  
**Nota:** builds não assinadas com Apple Developer podem mostrar aviso de segurança — clicar com botão direito → Abrir.

## Android (sideload)

```bash
./scripts/build_mobile.sh android
./scripts/local_beta.sh       # ZIP com APK + instruções para testadores
```

No telemóvel do testador:

1. Transferir `phoenix-manager-beta.zip` (AirDrop, email, Drive…)
2. Descompactar → instalar `phoenix_manager.apk`
3. Definições → Segurança → permitir instalação de fontes desconhecidas (se pedido)
4. Abrir **Project Phoenix Manager**

> O APK é só para sideload. A Play Store usa o **AAB** (`phoenix_manager.aab`).

## iOS (simulador / dev)

Sem conta Apple Developer:

```bash
./scripts/run_dev.sh ios              # simulador
./scripts/capture_app_store_screenshots.sh   # screenshots App Store (prep)
```

Com conta Apple Developer → ver [`docs/STORE.md`](STORE.md) e `./scripts/app_store_brief.sh`.

## Roteiro QA manual

Corre em cada plataforma antes de enviar para lojas:

| # | Passo | OK? |
|---|-------|-----|
| 1 | Menu carreira → **Jogar agora** / **Continuar** | |
| 1b | Menu carreira → **Roteiro de teste (beta)** (checklist) | |
| 2 | Dashboard carrega (motor PSE boot) | |
| 3 | **Plantel** — lista, pesquisa, ordenação | |
| 4 | **Classificação** e calendário | |
| 5 | **Simular jornada (Express)** — animação e resultado | |
| 6 | **Guardar** → fechar app → reabrir → dados restaurados | |
| 7 | Definições → **Política de privacidade** abre | |
| 8 | Conquistas / palmarés (se aplicável) | |
| 9 | **Finanças** — resultado época, transferências | |
| 10 | **Calendário** — scroll ao próximo jogo, filtro «Só os meus» | |
| 11 | **Treino** — filtro margem, toque abre ficha do jogador | |
| 12 | **Detalhe do jogo** — «Ver relato completo» expande | |
| 13 | **Nova carreira / Jogar agora** — sheet «Primeiros passos» (modos, guardar, feedback) | |
| 14 | **Actualizar app** — diálogo «Novidades» (uma vez por versão) | |
| 15 | **Drawer** — «Roteiro de teste (beta)» (checklist + copiar) | |
| 16 | **Modo Diretor** — snack «Alterações por guardar» após avançar | |
| 16b | **Modo Diretor** — chip «Por guardar» no AppBar (tap → guardar) | |
| 16c | **Modo Diretor** — Menu principal / voltar com por guardar (3 opções) | |
| 16d | **Menu / drawer** — roteiro beta mostra progresso N/5 | |
| 16e | **Roteiro** — auto-marca ao jogar / guardar / plantel+tabela / feedback | |
| 16f | **Carregar save** com por guardar — 3 opções | |
| 17 | **Dashboard** — dicas rotativas (até 3 jogos; «Próxima dica» / «Entendi») | |
| 18 | **Drawer** — «Feedback / reportar bug» (modelo + progresso do roteiro) | |
| 19 | **Dashboard** — alertas «Antes do próximo jogo» (modo Diretor) | |
| 20 | **Dashboard** — «Forma recente» (vazia ou com V/E/D após jogos) | |
| 21 | **Android** — edge-to-edge: barras não tapam navegação/conteúdo ([`MOBILE.md`](../apps/phoenix_manager/MOBILE.md)) | |
| 22 | **Menu drawer** — rodapé mostra versão PSE | |
| 23 | **Desktop** — abre em fullscreen (Mac / Windows / Linux) | |
| 24 | **Desktop** — sair/voltar fullscreen (Mac: Esc · Win: Esc/F11 · Linux: Esc/F11) | |
| 25 | **Desktop** — «Sair do jogo» no menu carreira e no drawer | |
| 26 | **Desktop** — Ctrl/⌘+S guarda slot activo; Ctrl/⌘+Q pede sair | |

Automático (saves):

```bash
./scripts/test_mac.sh
./scripts/test_android.sh    # emulador ou USB
```

## Espaço em disco (builds)

Se `flutter` ou Gradle falharem com **No space left on device**:

```bash
./scripts/clean_dev_artifacts.sh   # flutter clean — mantém build/release/
CLEAN_GRADLE=1 ./scripts/clean_dev_artifacts.sh   # inclui ~/.gradle/caches (~5 GiB)
./scripts/repair_gradle.sh         # se Gradle falhar após limpeza (NoSuchFileException)
```

## Feedback de testadores

Envia bugs ou sugestões para **pakopt7@gmail.com** com:

- Dispositivo (Mac / Android / modelo)
- Versão da app (menu carreira → rodapé, ex. `PSE v0.8.38`)
- Passos para reproduzir
- Screenshot opcional

Privacidade: [`docs/PRIVACY.md`](PRIVACY.md)

## Play Store — teste fechado (12 × 14)

Contas pessoais novas precisam de **≥12 testadores opted-in** no teste fechado durante **14 dias** antes da produção.

1. Copia o **link de adesão** na Play Console (teste fechado → Testadores)
2. Gera a mensagem de convite:
   ```bash
   ./scripts/play_testers_invite.sh 'URL_DO_LINK'
   ```
3. Acompanha opted-in / dias:
   ```bash
   DAY=3 OPTED_IN=12 ./scripts/play_14day_tracker.sh --follow-up
   ```
4. Confirma na Console que aparecem como opted-in (lista de emails sozinha **não** chega)
5. Após 14 dias → Dashboard → candidatar acesso a produção
   ```bash
   ./scripts/play_production_apply.sh      # rascunhos PT
   ./scripts/play_production_apply.sh --en # EN
   ```

```bash
./scripts/qa_manual.sh   # roteiro para os testadores
```

Guia completo: [`docs/STORE.md`](STORE.md)
