# Intent : 2026-10-30-demo-factory2

<!--
  Gabarit du SDLC fondé sur l’IA, copié par `git sdlc new <slug>`.
  Rédigez-le avec Claude, dans vos propres mots : ce qui est voulu, pourquoi,
  et sous quelles contraintes. Poussez, puis `git sdlc ready 2026-10-30-demo intent` :
  le product owner relit la PR sur GitHub, demande des corrections ou la fusionne.

  N’ajoutez PAS de champ « Statut » : l’étape se déduit de git
  (`git sdlc status 2026-10-30-demo`) et des PR GitHub, elle ne peut donc pas diverger.
  Product-Owner et Parent sont lus par git-sdlc : gardez « Clé: valeur » en début de ligne.
-->

Author: Mathieu Texier
Product-Owner: Khai
Created: 2026-10-30
Origin: idée
Parent: —
Ticket: —
Risk: standard

<!--
  Origin   idée | ticket | incident | scan-securite
  Parent   id du besoin d’origine quand l’intent naît d’un incident (boucle Maintain)
  Ticket   référence Jira / ServiceNow si un outil existant reste la source de vérité ;
           reportez-y en retour le SHA du commit qui accepte cet intent
  Risk     standard | élevé — « élevé » impose l’avis d’un tech lead avant le build
-->

## Problème

Les responsables de flotte veulent connaître la distance réellement parcourue par un véhicule sur un trajet, à partir des positions GPS remontées par le boîtier. Aujourd’hui, ils exportent les positions en CSV et font le calcul à la main dans un tableur : c’est lent (une dizaine de minutes par trajet), sujet aux erreurs de formule, et les sauts GPS aberrants (position qui « téléporte » le véhicule à plusieurs kilomètres puis revient) gonflent la distance sans que personne ne s’en aperçoive.

Ce besoin sert aussi de démonstration de bout en bout du SDLC (intent → spec → build) : il est volontairement petit, autonome et vérifiable par des tests.

## Pour qui

- Exprime : les responsables de flotte.
- Valide : le product owner, à désigner (voir « Questions ouvertes »).
- Consomme : les responsables de flotte, et le support client qui répond aux contestations de kilométrage.

## Pourquoi

Sans outil, chaque trajet coûte une dizaine de minutes de tableur, et une distance gonflée par un saut GPS passe inaperçue : le kilométrage communiqué au client peut être faux, et la contestation retombe sur le support.

## Priorité

<!-- Décision du product owner, jamais déduite. Niveau : Haute | Moyenne | Basse.
     Justification en une phrase. Échéance seulement si elle est réelle, sinon « aucune ». -->

- Niveau : à définir par le PO
- Justification :
- Échéance : aucune

## Résultat attendu

Le responsable de flotte lance une commande sur le CSV exporté et obtient, en moins d’une seconde :

- la distance totale du trajet, en kilomètres, arrondie à 0,01 km ;
- le nombre de points lus et le nombre de points écartés comme sauts GPS, avec leur numéro de ligne.

Un fichier mal formé produit un message d’erreur qui indique la ligne fautive, sans calculer de distance partielle.

## Utilisateurs et systèmes concernés

- Utilisateurs : responsables de flotte, support client qui répond aux contestations de kilométrage.
- Systèmes, API, dépôts : ce dépôt uniquement (nouvel outil en ligne de commande) ; en entrée, le CSV d’export des positions (colonnes horodatage, latitude, longitude).

## Contraintes

- Données personnelles : des positions horodatées d’un véhicule de service permettent de suivre un salarié (RGPD). L’outil ne journalise ni n’affiche aucune coordonnée, ne garde aucune copie du fichier et ne fait aucun appel réseau.
- Performance : un trajet de 100 000 points est traité en moins d’une seconde sur un poste développeur.
- Compatibilité : CSV séparé par des virgules, UTF-8, avec ou sans ligne d’en-tête, horodatage ISO 8601.
- Aucune dépendance externe ajoutée sans justification dans le plan.

## Hors périmètre

- Lecture directe des positions depuis la plateforme (API, base) : on part uniquement du CSV exporté.
- Calage sur le réseau routier (map matching) : la distance est calculée à vol d’oiseau entre points successifs.
- Interface graphique, carte, export PDF.
- Agrégation sur plusieurs trajets ou plusieurs véhicules.

## Critères de succès

Mesurables, pour que les tests et la revue puissent les vérifier.

- [ ] Sur un trajet de référence Paris (48.8566, 2.3522) → Lyon (45.7640, 4.8357) en deux points, la distance affichée est 391,50 km ± 0,5 km.
- [ ] Un point situé à plus de 2 km du précédent et du suivant, alors que ces deux-là sont à moins de 200 m l’un de l’autre, est écarté et signalé par son numéro de ligne.
- [ ] Un fichier avec une latitude hors de [-90, 90] ou une longitude hors de [-180, 180] est refusé avec le numéro de ligne, code de sortie non nul.
- [ ] Un fichier vide ou d’un seul point donne 0,00 km, sans erreur.
- [ ] 100 000 points traités en moins d’une seconde (test de performance).
- [ ] Aucune coordonnée n’apparaît dans la sortie ni dans les messages d’erreur (test dédié).

## Questions ouvertes

Elles doivent être tranchées ou reportées explicitement dans spec.md.

- Qui est le product owner de ce besoin de démonstration ?
- Priorité (niveau, justification, échéance) : à fixer par le PO.
- Quel langage pour l’outil (Python standard, Bash + awk, Java comme le reste de la plateforme) ?
- Les seuils du saut GPS (2 km / 200 m) sont-ils les bons, ou doivent-ils être paramétrables ?
- Les points dont l’horodatage n’est pas croissant sont-ils triés, écartés ou refusés ?
