# Design: Microsoft Store (MSIX) — Project Phoenix Manager

**Data:** 2026-07-18  
**Estado:** implementado (scripts + docs + índices) · build Windows real + upload Partner Center pendentes  
**Âmbito:** Opção A — packaging MSIX + scripts + guia Partner Center (espelho Play Store)

---

## 1. Objectivo

Permitir publicar o cliente **Windows** do Phoenix Manager na **Microsoft Store**, com:

- Pacote **MSIX** alinhado à identidade Partner Center
- Scripts de build/empacotamento no estilo Play Store
- Guia passo a passo em `docs/STORE.md`
- Checklist no roadmap / plano vivo

Quem instalar pela Store recebe **actualizações automáticas** quando se publica um novo MSIX com versão maior.

**Fora de âmbito (esta entrega):**

- Conta Steamworks / upload Steam (já documentado, adiado)
- CI Windows na cloud (opcional depois)
- Alterações de gameplay ou UI

---

## 2. Identidade Partner Center (fixa)

| Campo MSIX / Store | Valor |
|--------------------|--------|
| `Package/Identity/Name` (`identity_name`) | `PhoenixManager.PhoenixManager` |
| `Package/Identity/Publisher` (`publisher`) | `CN=4402D5F1-A78E-42D6-B8A3-BAEBB8F0513B` |
| `Package/Properties/PublisherDisplayName` | `Phoenix Manager` |
| Display name da app (`display_name`) | `Project Phoenix Manager` — deve coincidir com o **nome reservado** da ficha no Partner Center; se a ficha usar só `Phoenix Manager`, ajustar o `msix_config` antes do primeiro upload |

Privacidade (igual às outras lojas):  
https://pakopt.github.io/PhoenixManager/privacy.html

Package name Android/iOS (`com.phoenix.manager`) **não** tem de coincidir com `identity_name` da Store Windows — usamos o valor do Partner Center.

---

## 3. Abordagem técnica

### 3.1 Pacote `msix`

- Dev dependency: [`msix`](https://pub.dev/packages/msix) em `apps/phoenix_manager/pubspec.yaml`
- Bloco `msix_config:` com identidade acima e `store: true` para builds de publicação
- `logo_path`: `assets/branding/icon.png` (já usado noutros stores)
- Capabilities: mínimas (jogo offline; sem rede obrigatória). Preferir o default do Flutter/`msix` para desktop full-trust; **não** declarar localização, microfone, etc.
- Idiomas no MSIX: `pt-pt`, `en-us` (PT-BR fica na ficha da loja se quiseres; não exige capability extra)

### 3.2 Versão MSIX (`msix_version`)

Formato obrigatório: `Major.Minor.Build.Revision` (quatro partes).  
Regra Microsoft: **Major ≥ 1** (não pode ser `0.x.y.z`).

O `pubspec` actual usa `version: 0.8.48+49`. Mapeamento proposto:

| Flutter (`name+code`) | `msix_version` |
|-----------------------|----------------|
| `0.8.48+49` | `1.8.48.49` |

Regra geral: se o major Flutter for `0`, prefixar `1.` e usar `minor.patch.versionCode`; senão `major.minor.patch.versionCode`.

O script de build deve **sincronizar** `msix_version` a partir de `read_app_version.sh` (ou passar `--version` ao `msix:create`) para não haver drift manual.

Cada upload na Store exige `msix_version` **estritamente maior** que o anterior.

### 3.3 Build e artefactos

| Passo | Onde | Resultado |
|-------|------|-----------|
| `flutter build windows --release` + `dart run msix:create --store` | **Máquina Windows** (VS Build Tools) | `.msix` |
| Copiar para `build/release/store/windows/` | Repo root | Artefacto estável |
| ZIP + README | `package_msix_store.sh` | Upload manual Partner Center |

**macOS/Linux:** os scripts **não** geram MSIX; validam `msix_config` / identidade e imprimem os comandos a correr no Windows (espelho do aviso Steam “corre em cada OS”).

Nota: MSIX com `store: true` é para **Partner Center**, não para sideload local fiável. Sideload/teste local pode usar build sem `--store` (certificado de teste) — documentar a diferença em `BETA.md`.

### 3.4 Scripts novos

| Script | Função |
|--------|--------|
| `scripts/build_msix.sh` | Em Windows: release + `msix:create --store` → `build/release/store/windows/`. Noutros OS: doctor + instruções. |
| `scripts/package_msix_store.sh` | ZIP com MSIX + README (versão, privacidade, passos Partner Center). |
| `scripts/msix_doctor.sh` | Verifica pubspec (`msix`, identidade, logo), OS, ferramentas Windows se aplicável. |
| `scripts/msix_partner_brief.sh` | Textos copy-paste: descrição, notas de versão, checklist assets (espelho `play_console_brief.sh`). |

Reutilizar `scripts/read_app_version.sh` e o padrão de saída de `package_play_store.sh`.

### 3.5 Documentação

| Ficheiro | Alteração |
|----------|-----------|
| `docs/STORE.md` | Nova secção **Microsoft Store** (Partner Center: criar app se necessário, Product identity, upload MSIX, screenshots desktop, age rating, privacy URL, submission, updates). |
| `docs/BETA.md` | Secção Windows: ZIP/exe manual vs MSIX Store vs sideload MSIX de teste. |
| `docs/README.md` | Linha na tabela a apontar Microsoft Store em `STORE.md`. |
| `docs/plano.md` + `docs/roadmap/master-roadmap-v1.md` | Checklist “Microsoft Store / MSIX” (estado: scripts/docs prontos; publicação ⏳). |
| `README.md` (raiz) | Comando `./scripts/build_msix.sh` na lista de builds, se existir secção equivalente. |
| `apps/phoenix_manager/MOBILE.md` | Uma linha a apontar Microsoft Store → `docs/STORE.md` (fonte canónica). |

### 3.6 Assets Partner Center

Reutilizar screenshots desktop existentes (`./scripts/capture_desktop_screenshots.sh` → `build/release/store/desktop/screenshots/`) e branding (`icon.png`). Documentar requisitos típicos (capturas 1366×768 ou superiores, ícone Store). Não é obrigatório gerar novos HTML templates nesta entrega.

---

## 4. Fluxo do utilizador (amigo no Windows)

1. Instala pela Microsoft Store (link da ficha).
2. Tu publicas um MSIX novo no Partner Center com `msix_version` maior.
3. A Store actualiza o cliente automaticamente (sem ZIP manual).

Alternativa beta sem Store: continuar a partilhar pasta/ZIP do `flutter build windows` (sem updates automáticos) — já discutido; `BETA.md` deixa isso explícito.

---

## 5. Critérios de sucesso

- [x] `msix` + `msix_config` no `pubspec` com a identidade Partner Center exacta
- [x] Scripts `build_msix` / `package_msix_store` / `msix_doctor` no repo
- [x] Secção Microsoft Store em `docs/STORE.md` utilizável sem conhecimento prévio
- [x] Roadmap/plano/README actualizados
- [ ] Em máquina Windows: comando documentado produz `.msix` em `build/release/store/windows/`
- [x] Sem regressão: `dart analyze` / testes existentes continuam verdes (mudança só packaging/docs)

---

## 6. Riscos e notas

| Risco | Mitigação |
|-------|-----------|
| Build só em Windows | Scripts em Mac só validam; doc clara |
| `msix_version` Major = 0 rejeitado | Mapeamento `0.x → 1.x` |
| Identidade desalinhada com Partner Center | Valores fixos desta spec; doctor verifica strings |
| Certificado local vs Store | `store: true` só para upload; sideload documentado à parte |
| Nome display vs nome reservado na ficha | Antes do 1.º upload: alinhar `display_name` ao nome da ficha Partner Center |

---

## 7. Decisão registada

- Âmbito **A** (completo, estilo Play Store)
- Conta Partner Center **já existe**
- Identidade fornecida pelo publisher (secção 2)
- Abordagem: pacote **`msix`** + scripts + `STORE.md` (não `makeappx` manual)
