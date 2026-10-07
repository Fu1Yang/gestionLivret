# Bilan annuel d'un livret d'épargne en COBOL

Projet pédagogique de traitement batch sous **GnuCOBOL**. Le programme lit un fichier de transactions, contrôle les dépôts et retraits, calcule des intérêts simples sur le solde final et affiche un rapport de synthèse. Il ne se connecte pas à un mainframe, à DB2 ou à un système bancaire réel.

## Démarrer

Prérequis : GnuCOBOL 3.x (`cobc`) et un terminal Linux, WSL ou équivalent.

```sh
cobc -x -Wall livret-epargne.cob -o livret-epargne
./livret-epargne
```

Le fichier `LIVRET` fourni contient dix transactions d'exemple. Le programme le lit dans le répertoire courant, sans le modifier. Pour appliquer un autre taux annuel, passer un pourcentage de 0 à 100 en argument :

```sh
./livret-epargne 2.5
```

Sans argument, le taux est **3 %**. Les intérêts sont arrondis au centime.

## Format du fichier `LIVRET`

Une transaction par ligne, sans espace :

```text
D001000.00
R000500.00
```

`D` signifie dépôt et `R` retrait. Le montant contient six chiffres pour les euros, un point et deux chiffres pour les centimes. Le format compact historique `D00100000` est aussi accepté ; les huit chiffres représentent alors des centimes. Les montants nuls, les types inconnus, les lignes mal formées et les retraits supérieurs au solde sont rejetés et comptés. Le solde initial est fixé à zéro à chaque exécution.

Le rapport est écrit dans la sortie standard. Le fichier d'entrée n'est jamais modifié et aucun nouveau solde n'est enregistré : chaque exécution recalcule le bilan à partir de `LIVRET`.

## Exemple vérifié

Avec le fichier fourni : 10 opérations acceptées, 2 125,00 EUR de dépôts, 380,00 EUR de retraits, 1 745,00 EUR avant intérêts, 52,35 EUR d'intérêts à 3 %, soit **1 797,35 EUR** après intérêts.

## Vérifier

```sh
./test-livret.sh
```

Le script compile dans un dossier temporaire et vérifie le fichier d'exemple, le format décimal, un taux personnalisé, les transactions rejetées, un fichier vide, un fichier absent et un taux invalide. Il ne modifie pas `LIVRET`.

## Portée

Cette simulation illustre les fichiers séquentiels, les contrôles métier et les calculs décimaux en COBOL. Elle ne gère ni persistance du solde, ni comptes multiples, ni authentification, ni traitement bancaire de production.
