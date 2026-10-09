#!/usr/bin/env bash
# ==========================================================
#  Robô do curso "Minha primeira entrega"
# ==========================================================
#  Roda a cada commit, a cada publicação do GitHub Pages e a cada
#  comentário na issue (ver .github/workflows/curso.yml).
#
#  COMO ELE SABE EM QUE PASSO O ALUNO ESTÁ?
#    Pela etiqueta (label) da issue do curso: passo-1, passo-2, passo-3, passo-4
#    ou concluido.
#
#  O QUE ELE FAZ
#    1. Se ainda não existe a issue do curso, cria (boas-vindas + passo 1).
#    2. Confere a tarefa do passo atual.
#       - Cumprida: comenta o parabéns + o próximo passo e troca a etiqueta.
#         Se o aluno já adiantou o passo seguinte, avança de novo (loop).
#       - Não cumprida, mas com um erro que dá para explicar: comenta uma dica.
#    3. Depois do passo 4: mensagem final e fecha a issue como concluída.
#
#  Os textos de cada passo ficam em .github/passos/*.md
#  Neles, {{usuario}}, {{repo}} e {{site}} são trocados pelos dados do aluno.
# ==========================================================
set -euo pipefail

REPO="$GITHUB_REPOSITORY"                        # ex.: maria-silva/minha-primeira-entrega
USUARIO="${REPO%%/*}"                            # tudo antes da barra
NOME_REPO="${REPO#*/}"                           # tudo depois da barra
USUARIO_MIN="$(echo "$USUARIO" | tr '[:upper:]' '[:lower:]')"   # o link do Pages usa minúsculas
SITE="https://${USUARIO_MIN}.github.io/${NOME_REPO}/"
PASSOS=".github/passos"
TITULO="⭐ Minha primeira entrega"
ULTIMO_PASSO=4

# PARA EDITAR: o "cabeçalho" de todo comentário do robô (memoji + "Stela diz:")
CABECALHO='<img src="https://maristelaoliveira.github.io/curso-github/assets/memoji.png" width="48" align="left" alt="">

**Stela diz:**
<br clear="left">

'

# PARA EDITAR: a frase de parabéns de cada passo concluído
FEITO[1]="✅ **Passo 1 concluído!** Seu README agora tem a sua cara. 😎"
FEITO[2]="✅ **Passo 2 concluído!** Sua página \`index.html\` está no repositório. 🌐"
FEITO[3]="✅ **Passo 3 concluído!** Seu site está no ar: **${SITE}** 🚀 Abra o link para ver!"
FEITO[4]="✅ **Passo 4 concluído!** Link do site no README, como em toda entrega. 🔗"

# ---------- funções auxiliares ----------

# lê um arquivo de passo trocando {{usuario}}, {{repo}} e {{site}}
renderizar() {
  sed -e "s|{{usuario}}|${USUARIO}|g" -e "s|{{repo}}|${NOME_REPO}|g" -e "s|{{site}}|${SITE}|g" "$1"
}

# o arquivo do passo N (ex.: passo 2 -> .github/passos/2-index.md)
arquivo_do_passo() { ls "$PASSOS"/"$1"-*.md | head -1; }

comentar() { gh issue comment "$ISSUE" --repo "$REPO" --body "${CABECALHO}$1" >/dev/null; }

# ---------- as conferências de cada passo ----------
# Cada função devolve 0 (passou) ou 1 (ainda não). Quando dá para explicar
# o que está errado, ela coloca a explicação em DICA.

conferir_1() {   # README sem os textos modelo
  if grep -q "SEU NOME AQUI" README.md; then DICA="Ainda encontrei \`SEU NOME AQUI\` no README. Troque pelo seu nome e faça o commit de novo."; return 1; fi
  if grep -q "SEU CURSO AQUI" README.md; then DICA="O nome já está lá! 👏 Só falta trocar \`SEU CURSO AQUI\` pelo seu curso."; return 1; fi
}

conferir_2() {   # index.html na raiz, com um <h1>
  if [ ! -f index.html ]; then
    local achado
    achado="$(find . -iname 'index.html' -not -path './.git/*' | head -1)"
    if [ -n "$achado" ]; then DICA="Encontrei o arquivo em \`${achado#./}\`, mas ele precisa ficar **na raiz** do repositório (fora de pastas) e se chamar exatamente \`index.html\`, tudo em minúsculas."; fi
    return 1
  fi
  if ! grep -qi "<h1" index.html; then DICA="O \`index.html\` está lá, mas não achei o título \`<h1>\`. Confira se você colou o código inteiro."; return 1; fi
}

conferir_3() {   # GitHub Pages publicado
  local status
  status="$(gh api "repos/${REPO}/pages" --jq '.status' 2>/dev/null || true)"
  if [ "$status" = "errored" ]; then DICA="O GitHub tentou publicar, mas deu erro. Confira em **Settings → Pages** se a branch é **main** e a pasta é **/ (root)**."; return 1; fi
  [ "$status" = "built" ]
}

conferir_4() {   # link do próprio site no README
  if grep -qiF "${USUARIO_MIN}.github.io/${NOME_REPO}" README.md; then return 0; fi
  if grep -qi "github.io" README.md; then DICA="Achei um link do GitHub Pages no README, mas não é o deste repositório. O seu é: ${SITE}"; fi
  return 1
}

# ---------- 1. a issue do curso existe? ----------
ISSUE="$(gh issue list --repo "$REPO" --label curso --state all --json number --jq '.[0].number // empty')"

if [ -z "$ISSUE" ]; then
  # primeira vez: cria as etiquetas e a issue com as boas-vindas + passo 1
  gh label create curso     --repo "$REPO" --color 3fb950 --description "Curso prático" --force >/dev/null
  gh label create concluido --repo "$REPO" --color 7ee2b8 --force >/dev/null
  for n in $(seq 1 "$ULTIMO_PASSO"); do gh label create "passo-$n" --repo "$REPO" --color e3c26b --force >/dev/null; done
  corpo="${CABECALHO}$(renderizar "$PASSOS/0-boas-vindas.md")

---

$(renderizar "$(arquivo_do_passo 1)")"
  url="$(gh issue create --repo "$REPO" --title "$TITULO" --label curso --label passo-1 --body "$corpo")"
  echo "Issue do curso criada: $url"
  exit 0
fi

# ---------- 2. em que passo o aluno está? ----------
ETIQUETAS="$(gh issue view "$ISSUE" --repo "$REPO" --json labels --jq '[.labels[].name] | join(" ")')"
if [[ " $ETIQUETAS " == *" concluido "* ]]; then echo "Curso já concluído."; exit 0; fi
PASSO="$(echo "$ETIQUETAS" | grep -o 'passo-[0-9]*' | head -1 | cut -d- -f2)"
PASSO="${PASSO:-1}"
echo "Issue #$ISSUE · passo atual: $PASSO · evento: ${EVENTO:-?}"

# ---------- 3. confere e avança enquanto as tarefas estiverem cumpridas ----------
AVANCOU=0
while [ "$PASSO" -le "$ULTIMO_PASSO" ]; do
  DICA=""
  if "conferir_$PASSO"; then
    if [ "$PASSO" -lt "$ULTIMO_PASSO" ]; then
      comentar "${FEITO[$PASSO]}

---

$(renderizar "$(arquivo_do_passo $((PASSO + 1)))")"
      gh issue edit "$ISSUE" --repo "$REPO" --remove-label "passo-$PASSO" --add-label "passo-$((PASSO + 1))" >/dev/null
    else
      comentar "${FEITO[$PASSO]}

---

$(renderizar "$PASSOS/5-fim.md")"
      gh issue edit "$ISSUE" --repo "$REPO" --remove-label "passo-$PASSO" --add-label concluido >/dev/null
      gh issue close "$ISSUE" --repo "$REPO" --reason completed >/dev/null
      gh api -X POST "repos/${REPO}/issues/${ISSUE}/reactions" -f content=hooray >/dev/null || true   # 🎉 na issue
    fi
    PASSO=$((PASSO + 1))
    AVANCOU=1
  else
    # só dá dica quando o aluno acabou de fazer algo (commit ou comentário),
    # e não quando o Pages terminou de publicar (aí ele não fez nada errado)
    if [ "$AVANCOU" = 0 ] && [ -n "$DICA" ] && [ "${EVENTO:-}" != "workflow_run" ] && [ "${EVENTO:-}" != "page_build" ]; then
      comentar "🤔 **Quase!** $DICA"
    fi
    break
  fi
done
