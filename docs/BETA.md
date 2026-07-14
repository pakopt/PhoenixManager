# Beta local — sem lojas

Distribuição e testes **antes** da Play Store ou App Store. Útil enquanto a conta Play Console está em verificação.

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
| 13 | **Dashboard** — dica «Primeiros passos» (carreira nova) | |
| 14 | **Dashboard** — alertas «Antes do próximo jogo» (modo Diretor) | |

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
```

## Feedback de testadores

Envia bugs ou sugestões para **pakopt7@gmail.com** com:

- Dispositivo (Mac / Android / modelo)
- Versão da app (menu carreira → rodapé, ex. `PSE v0.8.5`)
- Passos para reproduzir
- Screenshot opcional

Privacidade: [`docs/PRIVACY.md`](PRIVACY.md)

## Quando a Play Store activar

```bash
./scripts/play_console_day1.sh
```

Guia completo: [`docs/STORE.md`](STORE.md)
