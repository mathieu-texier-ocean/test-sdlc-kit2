# Plan : {{ID}}

<!--
  Gabarit copié par `git sdlc claim {{ID}} build`, puis rempli par le skill
  generation-plan, en plan mode, sur la branche need/{{ID}}/build, une fois spec.md
  fusionnée sur main. Commitez le plan rempli seul, avant tout code ; une étape = un
  commit. Si l’implémentation diverge, mettez le plan à jour dans la même PR. Pas de
  champ « Statut » : la fusion de la PR fait foi.
-->

- Spec : [spec.md](spec.md) · Intent : [intent.md](intent.md)
- Auteur : {{AUTHOR}}
- À risque : <oui | non>
- Base : <commit de main au départ>

<!-- « À risque » : oui si l’intent porte « Risk: élevé » ou si le développeur l’estime d’après ce que le changement peut casser. Oui → avis d’un tech lead sur le plan avant le code. -->

## Prérequis

<!-- Intent et spec fusionnés sur main, besoins dont celui-ci dépend, base de départ. -->

## Fichiers touchés

<!-- Nature : nouveau | modifié | supprimé. Étape : numéro de l’étape qui touche le fichier. -->

| Fichier | Nature | Étape |
|---|---|---|
| <chemin> | <nouveau \| modifié \| supprimé> | <n> |

## Étapes

<!-- Numérotées dans l’ordre d’exécution. Une étape = un commit. Chaque étape cite les numéros C, L et A de la spec qu’elle couvre. Au-delà de 7 étapes, ou avec des étapes indépendantes, l’intent est peut-être à découper. -->

### 1. <titre>

Couvre : <C, L, A>.

## Tests à écrire

<!-- Tests qui prouvent le changement (automatisés et manuels), avec la commande qui les lance. -->

## Couverture de la spec

<!-- Chaque numéro C, L et A de la spec rattaché à au moins une étape. -->

| Réf. | Étape |
|---|---|
| <C1–Cn> | <n> |

## Risques

<!-- Ce que le changement peut casser, l’étape la plus risquée, et la parade prévue. Une question restée sans réponse reste visible ici. Puis les options écartées. -->

## Hors périmètre

<!-- Ce que le plan ne fait volontairement pas. -->
