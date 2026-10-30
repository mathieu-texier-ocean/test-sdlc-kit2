# Spec : 2026-10-30-demo-factory2

<!--
  Gabarit copié par `git sdlc claim 2026-10-30-demo spec`, puis rempli par le skill
  generation-spec, sur la branche need/2026-10-30-demo/spec, une fois intent.md fusionné sur main.
  Le product owner relit la PR et la fusionne : pas de champ « Statut », l’étape se
  déduit de git (`git sdlc status 2026-10-30-demo`).
  Numéros C, L et A stables : une révision ajoute un nouveau numéro, elle ne renumérote
  jamais. Le plan et la recette s’y réfèrent.
-->

- Intent : [intent.md](intent.md)
- Auteur : Mathieu Texier

## Périmètre

Un outil en ligne de commande, dans ce dépôt, qui lit un CSV d’export de positions GPS d’un seul trajet (horodatage, latitude, longitude) et affiche la distance parcourue à vol d’oiseau entre points successifs, après avoir écarté les sauts GPS, ainsi que le nombre de points lus et écartés. Il refuse un fichier mal formé en indiquant la ligne fautive, sans jamais exposer de coordonnée, sans copie du fichier ni appel réseau.

## Comportements

<!-- Règles numérotées C1, C2… groupées par résultat attendu de l’intent. Chaque résultat a au moins un comportement. -->

### Distance totale du trajet

- **C1.** L’outil prend en entrée un fichier CSV et calcule la distance à vol d’oiseau (orthodromique) entre chaque paire de points successifs retenus, puis en fait la somme (intent, « Hors périmètre » : pas de calage routier).
- **C2.** La distance totale est affichée en kilomètres, arrondie à 0,01 km (intent, « Résultat attendu »).
- **C3.** Un fichier sans point ou d’un seul point donne une distance de 0,00 km, sans erreur (intent, « Critères de succès »).
- **C4.** Les points écartés comme sauts GPS (C6) ne participent pas au calcul : la distance passe directement du point précédent au point suivant.

### Points lus et points écartés

- **C5.** L’outil affiche le nombre de points lus (toutes les lignes de données du fichier, points écartés compris) et le nombre de points écartés.
- **C6.** Un point est un saut GPS, et donc écarté, quand il est à plus de 2 km du point précédent **et** à plus de 2 km du point suivant, alors que ces deux points sont à moins de 200 m l’un de l’autre (intent, « Critères de succès »). Les comparaisons sont strictes : « plus de » et « moins de ».
- **C7.** Chaque point écarté est signalé par son numéro de ligne dans le fichier.

### Fichier mal formé

- **C8.** Un fichier mal formé est refusé : l’outil affiche un message d’erreur qui indique le numéro de la ligne fautive, sort avec un code non nul et n’affiche aucune distance, même partielle.
- **C9.** Est mal formée une ligne de données dont la latitude est hors de [-90, 90] ou la longitude hors de [-180, 180] (bornes incluses dans l’intervalle valide).
- **C10.** Est aussi mal formée une ligne qui ne respecte pas le format d’entrée : nombre de colonnes différent de 3, latitude ou longitude non numérique, horodatage qui n’est pas en ISO 8601, contenu qui n’est pas de l’UTF-8 valide (intent, « Contraintes » : compatibilité).
- **C11.** Le fichier peut commencer ou non par une ligne d’en-tête ; sa présence ne change ni la distance ni le nombre de points lus.

### Données personnelles

- **C12.** Aucune coordonnée (latitude, longitude) n’apparaît dans la sortie de l’outil, ni dans ses messages d’erreur, ni dans un journal (intent, « Contraintes » : RGPD). Une ligne fautive est désignée par son seul numéro, jamais par son contenu.
- **C13.** L’outil ne garde aucune copie du fichier (ni fichier temporaire, ni cache) et ne fait aucun appel réseau.

### Performance

- **C14.** Un trajet de 100 000 points est traité en moins d’une seconde sur un poste développeur (intent, « Contraintes » et « Résultat attendu »).

## Cas limites

<!-- Situations aux bords et comportement attendu, en citant la règle C concernée. -->

| # | Cas | Comportement attendu |
|---|---|---|
| L1 | Fichier vide (0 octet) | 0,00 km, 0 point lu, 0 écarté, sans erreur (C3) |
| L2 | Fichier avec une ligne d’en-tête seule | 0,00 km, 0 point lu, sans erreur (C3, C11) |
| L3 | Un seul point | 0,00 km, 1 point lu, sans erreur (C3) |
| L4 | Latitude exactement à 90 ou -90, longitude exactement à 180 ou -180 | Acceptée (C9) |
| L5 | Latitude 90.0001 ou longitude -180.0001 | Fichier refusé, numéro de ligne, code non nul, aucune distance (C8, C9) |
| L6 | Erreur sur la dernière ligne d’un fichier par ailleurs valide | Fichier refusé ; aucune distance partielle des lignes précédentes (C8) |
| L7 | Point à exactement 2 km du précédent et du suivant, ou voisins à exactement 200 m | Non écarté : comparaisons strictes (C6) |
| L8 | Premier ou dernier point du fichier très éloigné de son seul voisin | Non couvert par la règle C6 (un seul voisin) : voir « Questions ouvertes » |
| L9 | Deux sauts GPS consécutifs | Non couvert par la règle C6 (le voisin d’un saut est lui-même un saut) : voir « Questions ouvertes » |
| L10 | Horodatages non croissants | Comportement non tranché : voir « Questions ouvertes » |
| L11 | Message d’erreur sur une coordonnée hors bornes | Le message cite le numéro de ligne, jamais la valeur fautive (C8, C12) |

## Contrats

<!-- Entrées, sorties, codes de retour et formats échangés (API, CLI, fichiers). « Sans objet » si rien n’est exposé. -->

**Entrée** : un chemin de fichier CSV.

- Séparateur virgule, encodage UTF-8.
- Ligne d’en-tête facultative.
- Trois colonnes, dans l’ordre : horodatage ISO 8601, latitude (degrés décimaux, [-90, 90]), longitude (degrés décimaux, [-180, 180]).

**Sortie en succès** :

- distance totale en km, arrondie à 0,01 ;
- nombre de points lus ;
- nombre de points écartés et numéro de ligne de chacun ;
- aucune coordonnée.

**Sortie en erreur** : un message qui indique le numéro de la ligne fautive, sans son contenu ; code de sortie non nul ; aucune distance.

Non fixés par l’intent, reportés dans « Questions ouvertes » : nom de la commande, mise en forme exacte de la sortie (texte, séparateur décimal), code de sortie en succès, convention de numérotation des lignes.

## Critères d’acceptation

<!-- Une ligne = un scénario, lu par la recette. Chaque critère de succès de l’intent a au moins une ligne. Type : Automatisé | Manuel | Humain. -->

| # | Critère | Étant donné | Quand | Alors | Type |
|---|---|---|---|---|---|
| A1 | Distance de référence Paris → Lyon | Un CSV de deux points : Paris (48.8566, 2.3522) puis Lyon (45.7640, 4.8357) | On lance l’outil sur ce fichier | La distance affichée est comprise entre 391,00 et 392,00 km (391,50 ± 0,5), 2 points lus, 0 écarté | Automatisé |
| A2 | Saut GPS écarté et signalé | Un CSV où un point est à plus de 2 km du précédent et du suivant, ces deux-là étant à moins de 200 m l’un de l’autre | On lance l’outil sur ce fichier | Le point est compté comme écarté, son numéro de ligne est affiché, et la distance est celle du trajet sans ce point | Automatisé |
| A3 | Latitude hors bornes refusée | Un CSV dont une ligne a une latitude hors de [-90, 90] | On lance l’outil sur ce fichier | Le message d’erreur indique le numéro de cette ligne, le code de sortie est non nul, aucune distance n’est affichée | Automatisé |
| A4 | Longitude hors bornes refusée | Un CSV dont une ligne a une longitude hors de [-180, 180] | On lance l’outil sur ce fichier | Le message d’erreur indique le numéro de cette ligne, le code de sortie est non nul, aucune distance n’est affichée | Automatisé |
| A5 | Fichier vide | Un CSV vide | On lance l’outil sur ce fichier | La distance affichée est 0,00 km, sans erreur | Automatisé |
| A6 | Fichier d’un seul point | Un CSV d’un seul point valide | On lance l’outil sur ce fichier | La distance affichée est 0,00 km, sans erreur | Automatisé |
| A7 | Performance | Un CSV valide de 100 000 points | On lance l’outil sur ce fichier, sur un poste développeur | Le traitement se termine en moins d’une seconde | Automatisé |
| A8 | Aucune coordonnée en sortie | Un CSV valide contenant un saut GPS | On lance l’outil sur ce fichier | Aucune latitude ni longitude du fichier n’apparaît dans la sortie standard ni dans la sortie d’erreur | Automatisé |
| A9 | Aucune coordonnée dans les erreurs | Un CSV avec une coordonnée hors bornes | On lance l’outil sur ce fichier | Ni la valeur fautive ni aucune autre coordonnée du fichier n’apparaît dans la sortie standard ni dans la sortie d’erreur | Automatisé |

## Points d’attention

<!-- Contradictions, risques et arbitrages à trancher avant le build, chacun avec le décideur attendu. « Aucun » s’il n’y en a pas. -->

- **Product owner non désigné.** L’intent fusionné garde `Product-Owner: <Prénom Nom> <email>` et une priorité « à définir ». La PR spec doit être relue et fusionnée par un product owner. Décideur : l’équipe qui porte le besoin.
- **Aucun skill de standards dans `.claude/skills/`.** Rien ne couvre la sécurité, les données personnelles (RGPD) ni les conventions de code, alors que la spec touche des positions horodatées de salariés (C12, C13). Décideur : tech lead.
- **Règle du saut GPS incomplète.** C6 ne couvre ni le premier ou dernier point (L8), ni deux sauts consécutifs (L9) : un tel saut gonflerait la distance, ce que l’intent veut justement éviter. Décideur : product owner.
- **Précision du calcul.** L’intent fixe la distance « à vol d’oiseau » et la référence Paris → Lyon à ± 0,5 km, sans formule ni rayon terrestre. Le choix doit tenir A1. Décideur : tech lead, au plan.
- **A7 dépend du poste.** « Poste développeur » n’est pas défini : un test de performance peut être instable en CI. Décideur : tech lead.

## Hors périmètre

<!-- Ce que la spec ne couvre volontairement pas. -->

- Lecture directe des positions depuis la plateforme (API, base) : seul le CSV exporté est lu.
- Calage sur le réseau routier (map matching).
- Interface graphique, carte, export PDF.
- Agrégation sur plusieurs trajets ou plusieurs véhicules.
- Choix du langage et des dépendances : ils relèvent du plan.

## Questions ouvertes

<!-- Questions de l’intent non tranchées, et informations manquantes. Peut rester vide. -->

Reprises de l’intent :

- Qui est le product owner de ce besoin de démonstration ?
- Priorité (niveau, justification, échéance) : à fixer par le PO.
- Quel langage pour l’outil (Python standard, Bash + awk, Java comme le reste de la plateforme) ?
- Les seuils du saut GPS (2 km / 200 m) sont-ils les bons, ou doivent-ils être paramétrables ?
- Les points dont l’horodatage n’est pas croissant sont-ils triés, écartés ou refusés ? (L10)

Informations manquantes :

- Premier ou dernier point éloigné de son seul voisin : saut GPS ou non ? (L8)
- Deux sauts GPS consécutifs : comment les détecter ? (L9)
- Comment reconnaître la ligne d’en-tête (première ligne non numérique, noms de colonnes attendus) ?
- Numérotation des lignes signalées : ligne physique du fichier (en-tête compris, à partir de 1) ou rang du point ?
- Nom de la commande, format exact de la sortie (texte libre, clé: valeur, JSON) et séparateur décimal (391,50 ou 391.50) ?
- Code de sortie en succès, et codes distincts selon le type d’erreur ou non ?
- Formule de distance et rayon terrestre retenus pour tenir A1.
