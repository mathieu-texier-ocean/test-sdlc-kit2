#!/usr/bin/env bash
# credential.sh — détection de credentials en clair dans les lignes ajoutées d'un diff.
#
# Sourcé par .githooks/pre-commit (scan_credentials --cached) et par
# .github/scripts/sdlc-check.sh (scan_credentials <base> <head>).
#
# scan_credentials <arguments de git diff> : affiche une ligne par fichier et famille
# trouvés, sur la sortie standard, et retourne 1 s'il y en a. La valeur n'est jamais
# affichée. Ignorés : les lignes qui portent le marqueur credential-ok, les fichiers
# binaires et les fixtures de tests (tests/<nom>/fixtures/, à toute profondeur).

# Une famille par indice : nom affiché, motif grep -E, option de casse.
CREDENTIAL_FAMILLES=("clé privée" "jeton fournisseur" "affectation générique" "URL avec identifiants")
CREDENTIAL_MOTIFS=(
  '-----BEGIN ([A-Z0-9]+ )*PRIVATE KEY-----'
  'AKIA[A-Z0-9]{16}|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22,}|sk-ant-[A-Za-z0-9_-]{20,}|xox[abprs]-[A-Za-z0-9-]{10,}'
  "(password|secret|token|api_key)[[:space:]]*=[[:space:]]*[\"']?[^\"'\$<{[:space:]][^\"'[:space:]]{3,}"
  '[A-Za-z][A-Za-z0-9+.-]*://[^/:@[:space:]]+:[^/@[:space:]]+@'
)
CREDENTIAL_CASSE=("" "" "-i" "")

scan_credentials() {
  local rec ajouts chemin ancien lignes i trouve=0
  # -z : chemins bruts, sans les guillemets de core.quotePath. -M : un renommage donne
  # "<ajouts>\t<suppressions>\t" puis l'ancien et le nouveau chemin ; binaire : "-\t-".
  while IFS= read -r -d '' rec; do
    ajouts=${rec%%$'\t'*}
    chemin=${rec#*$'\t'}; chemin=${chemin#*$'\t'}
    ancien=$chemin
    if [ -z "$chemin" ]; then
      IFS= read -r -d '' ancien; IFS= read -r -d '' chemin
    fi
    [ "$ajouts" = - ] && continue
    # Le "/" en tête couvre tests/ à la racine.
    case "/$chemin" in */tests/*/fixtures/*) continue ;; esac
    # Les deux chemins gardent le renommage apparié : seules les lignes ajoutées sont lues.
    # « || true » : sans ligne restante, grep échoue, ce qui arrêterait un appelant en set -e.
    lignes=$(git diff -U0 -M --no-color --no-ext-diff "$@" -- "$ancien" "$chemin" \
      | awk '/^@@/ { h = 1; next } h && /^\+/' | grep -vF credential-ok) || true
    [ -n "$lignes" ] || continue
    for i in "${!CREDENTIAL_FAMILLES[@]}"; do
      if printf '%s\n' "$lignes" | grep -qE ${CREDENTIAL_CASSE[i]} -e "${CREDENTIAL_MOTIFS[i]}"; then
        echo "$chemin : credential en clair (${CREDENTIAL_FAMILLES[i]}). Retirez la valeur, remplacez-la par une référence (variable d'environnement, gestionnaire de secrets) et révoquez-la si elle est réelle. Faux positif : ajoutez credential-ok en commentaire sur la ligne."
        trouve=1
      fi
    done
  done < <(git diff --numstat -z -M --diff-filter=ACMR "$@")
  return $trouve
}
