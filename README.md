Programme Batch — Bilan Annuel de Livret d'Épargne
Projet COBOL de traitement batch simulant le bilan annuel d'un livret d'épargne bancaire.

Description
Programme batch automatique qui lit un fichier de transactions séquentiel, traite les dépôts et retraits, calcule les intérêts annuels et génère un rapport de synthèse. Ce type de traitement est typique des jobs batch nocturnes en environnement bancaire.

Fonctionnalités
Lecture séquentielle d'un fichier de transactions
Traitement des dépôts (type D) et retraits (type R)
Contrôle métier : vérification du solde avant retrait
Calcul automatique des intérêts annuels (taux paramétrable, défaut 3%)
Génération d'un rapport de synthèse complet
Gestion des erreurs (FILE-STATUS, transactions invalides)
Structure du fichier d'entrée
Le fichier LIVRET est un fichier séquentiel (LINE SEQUENTIAL) avec le format suivant :

Type (1 car)  Montant (6 entiers + 2 décimales)
D             001000.00   → Dépôt de 1 000,00 €
R             000500.00   → Retrait de 500,00 €
Exemple de sortie
===============================================
    GESTION DU LIVRET D'EPARGNE - 2024
===============================================

DEPOT   :   1000.00 € - Nouveau solde:   1000.00 €
RETRAIT :    500.00 € - Nouveau solde:    500.00 €

===============================================
           RESUME ANNUEL DU LIVRET
===============================================
Solde initial           :        .00 €
Nombre de transactions  : 2

Total des dépôts        :   1000.00 €
Total des retraits      :    500.00 €

Solde avant intérêts    :    500.00 €
Intérêts gagnés (3%)    :     15.00 €
Solde après intérêts    :    515.00 €
===============================================
Prérequis
GnuCOBOL 3.x
WSL2 Debian ou Linux
Installation
bash
sudo apt update
sudo apt install gnucobol
Compilation et exécution
bash
cobc -x LIVRET-EPARGNE.cbl -o livret
./livret
Environnement de développement
OS : WSL2 Debian
Compilateur : GnuCOBOL 3.x
IDE : Visual Studio Code + COBOL Language Support
Versionning : Git / GitHub
Compétences démontrées
Traitement séquentiel de fichiers COBOL
Gestion de boucles avec PERFORM UNTIL
Logique métier bancaire (validation solde, calcul intérêts)
Formatage de l'affichage avec zones éditées (PIC Z)
Gestion des erreurs FILE-STATUS
Structure modulaire avec paragraphes COBOL
Auteur
Fu Yang — Projet pédagogique d'apprentissage des technologies mainframe COBOL.

