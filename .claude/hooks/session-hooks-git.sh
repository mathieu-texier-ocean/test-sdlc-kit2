#!/usr/bin/env bash
# Hook Claude Code SessionStart : signale des hooks git inactifs à l'humain et à l'agent.
# N'empêche jamais l'ouverture de la session (code 0 dans tous les cas).
. "$(dirname "$0")/hooks-git-actifs.sh"
hooks_git_actifs && exit 0
msg='Hooks git inactifs : les contrôles de commit (trailers Need:/Stage:, sections d’intent, credentials en clair) ne jouent pas. Activez-les avec `git config core.hooksPath .githooks`.'
printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$msg" "$msg"
exit 0
