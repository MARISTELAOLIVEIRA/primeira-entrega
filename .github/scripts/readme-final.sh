#!/usr/bin/env bash
# ==========================================================
#  Põe o certificado no README do aluno, quando o curso termina
# ==========================================================
#  Por quê: ao concluir, a issue do curso fecha e a aba Issues fica vazia. O aluno que não baixou o
#  certificado na hora não tem por onde voltar. O README é a primeira coisa que ele vê no repositório.
#
#  Uso: bash readme-final.sh <usuario> <id-do-curso> "<nome do curso>"
#    ex.: bash readme-final.sh maria-silva equipe "Trabalho em equipe"
#
#  Não apaga nada do aluno: o bloco do certificado entra no TOPO do README.md, entre duas marcas, e se o
#  robô rodar de novo ele só troca o que está entre as marcas.
set -euo pipefail

USUARIO="$1"
CURSO_ID="$2"
NOME="$3"
ARQUIVO="${README:-README.md}"
SITE="https://maristelaoliveira.github.io/curso-github/certificado.html"
CERTIFICADO="$SITE?aluno=$USUARIO&curso=$CURSO_ID"
TODOS="$SITE?aluno=$USUARIO"

BLOCO="<!-- certificado:inicio -->
> ## 🎓 Curso concluído!
>
> **@$USUARIO** concluiu o curso prático **$NOME**, da Profª Maristela Oliveira · Faculdade de Tecnologia e Inovação Senac DF.
>
> ### 👉 [Ver o meu certificado]($CERTIFICADO)
>
> O certificado **fica sempre neste endereço**: lá você baixa a imagem e compartilha no LinkedIn. Todos os seus certificados: [Meus certificados]($TODOS).
<!-- certificado:fim -->"

[ -f "$ARQUIVO" ] || : > "$ARQUIVO"

if grep -q '<!-- certificado:inicio -->' "$ARQUIVO"; then
  # já tem: troca só o que está entre as marcas
  BLOCO="$BLOCO" awk '
    /<!-- certificado:inicio -->/ { print ENVIRON["BLOCO"]; dentro = 1; next }
    /<!-- certificado:fim -->/ { dentro = 0; next }
    !dentro { print }
  ' "$ARQUIVO" > "$ARQUIVO.novo"
else
  # primeira vez: o bloco entra no topo, e o resto do README fica como estava
  { printf '%s\n\n' "$BLOCO"; cat "$ARQUIVO"; } > "$ARQUIVO.novo"
fi
mv "$ARQUIVO.novo" "$ARQUIVO"
