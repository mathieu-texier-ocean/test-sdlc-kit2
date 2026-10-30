#!/usr/bin/env bash
# Hook Claude Code PreToolUse sur Bash : refuse une commande qui contient « git commit » tant que
# les hooks git sont inactifs. Détection volontairement large, sur toute l'entrée JSON.
. "$(dirname "$0")/hooks-git-actifs.sh"
entree=$(cat)
case $entree in
  *"git commit"*) ;;
  *) exit 0 ;;
esac
hooks_git_actifs && exit 0
echo 'Commit refusé : les hooks git ne sont pas actifs, ce commit ne serait pas contrôlé. Demandez à l'"'"'humain de lancer `git config core.hooksPath .githooks`.' >&2
exit 2
