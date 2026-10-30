# Spec : {{ID}}

<!--
  Gabarit copié par `git sdlc claim {{ID}} spec`, puis rempli par le skill
  generation-spec, sur la branche need/{{ID}}/spec, une fois intent.md fusionné sur main.
  Le product owner relit la PR et la fusionne : pas de champ « Statut », l’étape se
  déduit de git (`git sdlc status {{ID}}`).
  Numéros C, L et A stables : une révision ajoute un nouveau numéro, elle ne renumérote
  jamais. Le plan et la recette s’y réfèrent.
-->

- Intent : [intent.md](intent.md)
- Auteur : {{AUTHOR}}

## Périmètre

<!-- Ce que la spec couvre, en un paragraphe. -->

## Comportements

<!-- Règles numérotées C1, C2… groupées par résultat attendu de l’intent. Chaque résultat a au moins un comportement. -->

### <résultat>

- **C1.** <règle>

## Cas limites

<!-- Situations aux bords et comportement attendu, en citant la règle C concernée. -->

| # | Cas | Comportement attendu |
|---|---|---|
| L1 | <cas> | <comportement> |

## Contrats

<!-- Entrées, sorties, codes de retour et formats échangés (API, CLI, fichiers). « Sans objet » si rien n’est exposé. -->

## Critères d’acceptation

<!-- Une ligne = un scénario, lu par la recette. Chaque critère de succès de l’intent a au moins une ligne. Type : Automatisé | Manuel | Humain. -->

| # | Critère | Étant donné | Quand | Alors | Type |
|---|---|---|---|---|---|
| A1 | <critère> | <situation de départ> | <action> | <résultat observable> | <Automatisé \| Manuel \| Humain> |

## Points d’attention

<!-- Contradictions, risques et arbitrages à trancher avant le build, chacun avec le décideur attendu. « Aucun » s’il n’y en a pas. -->

## Hors périmètre

<!-- Ce que la spec ne couvre volontairement pas. -->

## Questions ouvertes

<!-- Questions de l’intent non tranchées, et informations manquantes. Peut rester vide. -->
