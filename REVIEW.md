# Consignes de revue

Ce fichier guide la revue de chaque pull request `need/<id>/<étape>`, qu’elle soit faite par Claude (Code Review ou `@claude`) ou par un humain. Le tech lead en est propriétaire et l’ajuste une fois par mois à partir des constats jugés utiles ou inutiles.

## À lire avant de commenter

- `intent/<id>/intent.md` et, pour une PR build, `intent/<id>/spec.md` sur `main` : ce qui a été demandé et décidé.
- `intent/<id>/plan.md` dans la PR build : ce qui devait être fait.
- Le diff de la PR et le résultat du check `sdlc-conventions` et des tests.

Le check `sdlc-conventions` vérifie déjà les trailers, le périmètre des fichiers et la présence des artefacts. Ne le recommentez pas.

## Selon l’étape

**PR intent** (fusion : product owner). Le problème est compréhensible sans contexte, le résultat attendu est observable, les contraintes et le hors-périmètre sont explicites, les questions ouvertes sont listées. La priorité vient du product owner, jamais déduite ; un intent qui juxtapose plusieurs problèmes indépendants est à découper (skill `controle-taille-intent`).

**PR spec** (fusion : product owner). La spec répond à l’intent, les questions ouvertes sont tranchées ou reportées, les points d’attention signalés par Claude ont chacun été arbitrés avec le propriétaire de la politique concernée. Chaque critère de succès de l’intent a au moins un critère d’acceptation `A`, au résultat observable ; aucun critère n’a été inventé. Une révision ajoute des numéros C, L, A sans renuméroter.

**PR build** (fusion : tech lead). Quatre passes, détaillées ci-dessous.

## Passes d’une PR build

Étiquetez chaque constat avec sa passe.

**Bugs** : erreurs de logique, cas limites non traités, régressions subtiles, gestion d’erreur absente, concurrence.

**Sécurité** : injection, authentification ou autorisation manquante, données personnelles dans les logs ou les messages d’erreur, secrets dans le diff, dépendances ajoutées sans justification.

**Conformité** : le diff réalise `spec.md` et respecte `plan.md`. Chaque numéro C, L, A de la spec est couvert par une étape du plan. Tout écart au plan est reflété dans `plan.md` dans la même PR.

**Preuve** : les tests couvrent les critères de succès de l’intent ; pour une correction de bug, le test qui reproduit le bug a été commité avant le correctif et n’a pas été modifié ensuite.

## Format des constats

Commentez en ligne, sur la ligne concernée, au format :

```
[Important|Nit] [Bugs|Sécurité|Conformité|Preuve] Constat. Correction proposée.
```

Terminez par une revue de synthèse :

- au moins un **Important** non résolu → *Request changes* ;
- sinon → *Comment*. La décision n’est pas une approbation : c’est la fusion de la PR.

## Ce que veut dire « Important »

Réservez **Important** aux constats qui casseraient un comportement, exposeraient des données, enfreindraient une politique ou rendraient la preuve insuffisante. Le style, le nommage et les préférences sont des **Nit**.

## Limiter le bruit

- Au plus cinq Nit par revue ; résumez le reste par un décompte.
- Ne commentez pas ce que la CI ou le linter vérifie déjà.
- Ne rapportez rien sur les fichiers générés ni sur `vendor/`.
- Quand un même défaut est signalé pour la deuxième fois sur des besoins différents, proposez la ligne à ajouter dans `CLAUDE.md`.

## Ce que la revue ne fait pas

La revue de Claude informe la décision ; elle ne la prend pas. La gate est la fusion, faite par un humain : le PO pour intent et spec, le tech lead pour le build.
