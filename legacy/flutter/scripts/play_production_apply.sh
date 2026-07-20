#!/usr/bin/env bash
# Rascunhos PT/EN para o questionário «Apply for production access» (Play Console).
# Preencher [PLACEHOLDERS] com números reais da Console e feedback dos testadores.
# Uso:
#   ./scripts/play_production_apply.sh
#   ./scripts/play_production_apply.sh --en
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=read_app_version.sh
source "$ROOT/scripts/read_app_version.sh"

CONTACT="pakopt7@gmail.com"
PACKAGE="com.phoenix.manager"
LANG="pt"

for arg in "$@"; do
  case "$arg" in
    --en|-e) LANG="en" ;;
    --help|-h)
      echo "Uso: ./scripts/play_production_apply.sh [--en]"
      exit 0
      ;;
  esac
done

echo "════════════════════════════════════════"
echo "  Play — candidatura a produção"
echo "  Versão: $VERSION_FULL  ·  $PACKAGE"
echo "════════════════════════════════════════"
echo ""
echo "Quando: Dashboard → Apply for production access (após ≥12 opted-in × 14 dias)."
echo "Ajuda: https://support.google.com/googleplay/android-developer/answer/14151465"
echo "Local: docs/STORE.md §9c–10"
echo ""
echo "IMPORTANTE: substitui [PLACEHOLDERS] por factos reais. Respostas vagas = risco de rejeição."
echo ""

if [[ "$LANG" == "en" ]]; then
  cat <<EOF
────────────────────────────────────────
PART 1 — About your closed test
────────────────────────────────────────

Q1 — How did you recruit testers?
I recruited testers from my personal network (friends, family and colleagues who own Android phones) and invited them via WhatsApp/email with the official Play Console opt-in link for closed testing. I invited [14–16] people as a buffer so at least 12 would remain opted-in for 14 continuous days. Testers had to open the link, tap “Become a tester”, and install/update only from the Play Store (no sideload APK). Contact for issues: $CONTACT.

Q2 — How easy was it to recruit testers?
[Moderately difficult / Difficult]. Many contacts use iOS, so I needed a larger invite list to net ≥12 Android opted-in testers. Coordinating opt-in confirmations and keeping people from leaving the program added overhead. Using a buffer of [14–16] invites made the 12-tester floor more reliable.

Q3 — Tester engagement and feedback summary
During the 14-day closed test, [N] testers stayed opted-in. Engagement matched a casual football-management session: starting/continuing a career, simulating matchdays (Express), checking squad/standings/finances, and saving locally. Feedback channels: email to $CONTACT (in-app “Feedback / report bug” copies version + device template), WhatsApp, and Play Console tester comments where available.

Key themes from testers:
1. [e.g. First-launch confusion] — addressed with first-run help / dashboard tips (shipped in closed track as $VERSION_NAME).
2. [e.g. Hard to report bugs] — in-app feedback template with version and slot.
3. [e.g. Other issue or “no crashes reported; X polish requests”] — [what you changed / versionCode].

We also pushed closed-track updates during the window (e.g. $VERSION_NAME / versionCode $VERSION_CODE) so testers validated the latest build from Play Store.

────────────────────────────────────────
PART 2 — About your app / game
────────────────────────────────────────

Q4 — Intended audience
Fans of football management / sports simulation games who want a lightweight offline experience on Android (phones and tablets). Primary audience: adults who enjoy career mode, leagues, cups, transfers and club finances without accounts, ads or always-online requirements. Not directed at children under 13; no personal data collection.

Q5 — Value / what makes it stand out
Project Phoenix Manager is a free, offline-first football manager built on the Phoenix Simulation Engine (PSE). Players run a club through league and cup seasons with squad, training, academy, transfer market, finances and achievements. Express mode speeds matchdays; Director mode offers fuller management. Differentiator: no login, no ads, no IAP, saves stay on-device — play without a network after install.

Q6 — Expected first-year installs (if asked)
[Honest estimate, e.g. 1 000–10 000]. Soft launch focus on Portuguese-speaking markets (Portugal, Brazil) then broader Android. No paid UA planned for year one; organic and store listing only.

────────────────────────────────────────
PART 3 — Production readiness
────────────────────────────────────────

Q7 — Changes based on testing feedback
Based on closed testing feedback we: (1) [change 1 + version], (2) [change 2 + version], (3) [change 3 + version]. Examples already in recent closed builds: first-run onboarding, rotating dashboard tips, in-app feedback template, “What’s new” after updates, accessibility and empty-state polish. Crash/ANR: [none material / describe fixes]. Privacy: offline-first; policy at https://pakopt.github.io/PhoenixManager/privacy.html.

Q8 — Why ready for production
Closed test met Google’s criteria (≥12 opted-in for 14 continuous days). Core loops (career, simulate matches, save/load, squad, standings, finances) were exercised without blocking crashes. Store presence (listing, Data safety, content rating, privacy URL) is complete. We will continue iterating via production updates with rising versionCodes. Support: $CONTACT.

EOF
else
  cat <<EOF
────────────────────────────────────────
PARTE 1 — Sobre o teste fechado
────────────────────────────────────────

Q1 — Como recrutaste os testadores?
Recrutei testadores na minha rede pessoal (amigos, família e colegas com Android) e enviei o link oficial de adesão do teste fechado da Play Console por WhatsApp/email. Convidei [14–16] pessoas como margem para manter ≥12 opted-in durante 14 dias contínuos. Cada pessoa teve de abrir o link, tocar em «Tornar-me testador» e instalar/actualizar só pela Play Store (sem APK sideload). Contacto para problemas: $CONTACT.

Q2 — Quão fácil foi recrutar testadores?
[Moderadamente difícil / Difícil]. Muitos contactos usam iOS, por isso precisei de uma lista maior para chegar a ≥12 opted-in em Android. Coordenar confirmações e evitar saídas do programa deu trabalho. O buffer de [14–16] convites tornou o mínimo de 12 mais estável.

Q3 — Engagement e resumo do feedback
Durante os 14 dias, [N] testadores mantiveram-se opted-in. O uso correspondeu a uma sessão casual de gestão de futebol: iniciar/continuar carreira, simular jornadas (Express), ver plantel/classificação/finanças e guardar localmente. Canais de feedback: email $CONTACT (no jogo, «Feedback / reportar bug» copia modelo com versão e slot), WhatsApp e comentários de testadores na Console quando disponíveis.

Temas principais:
1. [ex. Confusão no arranque] — first-run + dicas no dashboard (enviado no teste fechado como $VERSION_NAME).
2. [ex. Difícil reportar bugs] — modelo de feedback in-app com versão.
3. [ex. Outro / «sem crashes; pedidos de polish X»] — [o que mudaste / versionCode].

Também publiquei updates na faixa fechada durante a janela (ex. $VERSION_NAME / versionCode $VERSION_CODE) para validarem o build actual pela Play Store.

────────────────────────────────────────
PARTE 2 — Sobre a app / jogo
────────────────────────────────────────

Q4 — Público-alvo
Fãs de gestão de futebol / simulação desportiva que querem uma experiência leve e offline no Android (telemóvel e tablet). Público principal: adultos que gostam de carreira, liga, taça, mercado e finanças sem conta, anúncios ou exigir Internet. Não dirigido a menores de 13 anos; sem recolha de dados pessoais.

Q5 — Valor / o que destaca
Project Phoenix Manager é um gestor de futebol gratuito e offline-first sobre o Phoenix Simulation Engine (PSE). O jogador gere um clube ao longo de épocas com plantel, treino, academia, mercado, finanças e conquistas. Modo Express acelera jornadas; Modo Diretor dá gestão completa. Diferencial: sem login, sem anúncios, sem IAP, saves só no dispositivo — jogável sem rede após instalar.

Q6 — Instalações esperadas no 1.º ano (se perguntarem)
[Estimativa honesta, ex. 1 000–10 000]. Foco inicial em mercados lusófonos (Portugal, Brasil) e depois Android mais amplo. Sem UA paga no primeiro ano; orgânico + ficha da loja.

────────────────────────────────────────
PARTE 3 — Prontidão para produção
────────────────────────────────────────

Q7 — Alterações com base no feedback
Com o feedback do teste fechado: (1) [mudança 1 + versão], (2) [mudança 2 + versão], (3) [mudança 3 + versão]. Exemplos já na faixa fechada: primeiros passos, dicas no dashboard, feedback in-app, «Novidades» ao actualizar, polish de acessibilidade. Crashes/ANR: [nenhum material / descrever]. Privacidade: offline-first; política em https://pakopt.github.io/PhoenixManager/privacy.html.

Q8 — Porque está pronta para produção
O teste fechado cumpriu o critério Google (≥12 opted-in × 14 dias contínuos). Os loops principais (carreira, simular jogos, guardar/carregar, plantel, tabela, finanças) foram exercitados sem crashes bloqueantes. Presença na loja (ficha, Data safety, classificação etária, URL de privacidade) está completa. Continuaremos a iterar em produção com versionCodes crescentes. Suporte: $CONTACT.

EOF
fi

echo "────────────────────────────────────────"
echo "Checklist antes de submeter"
cat <<EOF
  [ ] ≥12 opted-in contínuos há 14 dias (Console)
  [ ] Pelo menos 1 update na faixa fechada durante os 14 dias (recomendado)
  [ ] Respostas com números reais — sem «tudo ok, sem problemas»
  [ ] Privacidade e Data safety alinhados com a app
  [ ] Após aprovação → Produção → promover / criar versão (docs/STORE.md §10)
EOF
echo ""
echo "Relacionado: ./scripts/play_14day_tracker.sh · ./scripts/play_testers_invite.sh"
