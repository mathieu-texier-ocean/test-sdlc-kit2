#!/usr/bin/env bash
# Sourcé par les hooks Claude Code de .claude/hooks/. hooks_git_actifs réussit si core.hooksPath
# désigne le dossier .githooks/ du dépôt : .githooks, ./.githooks ou son chemin absolu. Lecture seule, n'écrit rien.
hooks_git_actifs() {
  local racine valeur cible attendu
  racine=$(git -C "${CLAUDE_PROJECT_DIR:-.}" rev-parse --show-toplevel 2>/dev/null) || return 1
  valeur=$(git -C "$racine" config --get core.hooksPath) || return 1
  case $valeur in
    /*) cible=$valeur ;;
    *) cible=$racine/$valeur ;;
  esac
  cible=$(cd "$cible" 2>/dev/null && pwd -P) || return 1
  attendu=$(cd "$racine/.githooks" 2>/dev/null && pwd -P) || return 1
  [ "$cible" = "$attendu" ]
}
