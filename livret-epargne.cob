       IDENTIFICATION DIVISION.
       PROGRAM-ID. LIVRET-EPARGNE.
       AUTHOR. STUDENT.
       DATE-WRITTEN. 2024-09-24.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT F-LIVRET ASSIGN TO "LIVRET"
              ORGANIZATION IS LINE SEQUENTIAL
              FILE STATUS IS WS-FILE-STATUS.
       
       DATA DIVISION.
       FILE SECTION.
       FD F-LIVRET.
       01 FS-TRANSACTION-RECORD.
           05 TRANS-TYPE           PIC X(1).
           05 TRANS-AMOUNT         PIC 9(6)V99.
       
       WORKING-STORAGE SECTION.
       01 WS-FILE-STATUS           PIC X(02).
       01 WS-EOF                   PIC X(01) VALUE "N".
       
      * Variables pour les calculs
       01 WS-SOLDE-INITIAL         PIC 9(8)V99 VALUE ZERO.
       01 WS-SOLDE-FINAL           PIC 9(8)V99 VALUE ZERO.
       01 WS-TOTAL-DEPOTS          PIC 9(8)V99 VALUE ZERO.
       01 WS-TOTAL-RETRAITS        PIC 9(8)V99 VALUE ZERO.
       01 WS-MONTANT-INTERETS      PIC 9(8)V99 VALUE ZERO.
       01 WS-SOLDE-AVEC-INTERETS   PIC 9(8)V99 VALUE ZERO.
       01 WS-TAUX-INTERET          PIC 9V999 VALUE 0.030.
       01 WS-COMPTEUR-TRANS        PIC 9(4) VALUE ZERO.
       
      * Variables pour l'affichage formaté
       01 WS-DISPLAY-SOLDE-INITIAL     PIC Z(8).99.
       01 WS-DISPLAY-SOLDE-FINAL       PIC Z(8).99.
       01 WS-DISPLAY-TOTAL-DEPOTS      PIC Z(8).99.
       01 WS-DISPLAY-TOTAL-RETRAITS    PIC Z(8).99.
       01 WS-DISPLAY-INTERETS          PIC Z(8).99.
       01 WS-DISPLAY-SOLDE-AVEC-INT    PIC Z(8).99.
       01 WS-DISPLAY-TRANSACTION       PIC Z(6).99.
       
       PROCEDURE DIVISION.
       MAIN-PROCESS.
           DISPLAY "===============================================".
           DISPLAY "    GESTION DU LIVRET D'EPARGNE - 2024".
           DISPLAY "===============================================".
           DISPLAY " ".
           
           PERFORM INIT-PROGRAMME
           PERFORM TRAITER-FICHIER
           PERFORM CALCULER-INTERETS
           PERFORM AFFICHER-RESUME
           PERFORM FIN-PROGRAMME
           
           STOP RUN.
       
       INIT-PROGRAMME.
      *    Initialisation du solde initial (optionnel)
           MOVE ZERO TO WS-SOLDE-INITIAL
           MOVE WS-SOLDE-INITIAL TO WS-SOLDE-FINAL
           
           DISPLAY "Ouverture du fichier LIVRET...".
           OPEN INPUT F-LIVRET
           
           IF WS-FILE-STATUS NOT = "00"
              DISPLAY "ERREUR: Impossible d'ouvrir le fichier LIVRET"
              DISPLAY "Status: " WS-FILE-STATUS
              STOP RUN
           END-IF
           
           DISPLAY "Fichier ouvert avec succès."
           DISPLAY " ".
           DISPLAY "Début du traitement des transactions...".
           DISPLAY " ".
       
       TRAITER-FICHIER.
           MOVE "N" TO WS-EOF
           
           PERFORM UNTIL WS-EOF = "Y"
              READ F-LIVRET
                 AT END
                    MOVE "Y" TO WS-EOF
                 NOT AT END
                    PERFORM TRAITER-TRANSACTION
              END-READ
           END-PERFORM.
       
       TRAITER-TRANSACTION.
           ADD 1 TO WS-COMPTEUR-TRANS
           
           EVALUATE TRANS-TYPE
              WHEN "D"
                 PERFORM TRAITER-DEPOT
              WHEN "R"
                 PERFORM TRAITER-RETRAIT
              WHEN OTHER
                 MOVE TRANS-AMOUNT TO WS-DISPLAY-TRANSACTION
                 DISPLAY "ATTENTION: Transaction invalide ignorée - "
                         "Type: " TRANS-TYPE 
                         " Montant: " WS-DISPLAY-TRANSACTION " €"
           END-EVALUATE.
       
       TRAITER-DEPOT.
           ADD TRANS-AMOUNT TO WS-SOLDE-FINAL
           ADD TRANS-AMOUNT TO WS-TOTAL-DEPOTS
           
           MOVE TRANS-AMOUNT TO WS-DISPLAY-TRANSACTION
           DISPLAY "DEPOT   : " WS-DISPLAY-TRANSACTION " € - "
                   "Nouveau solde: " WS-SOLDE-FINAL " €".
       
       TRAITER-RETRAIT.
      *    Vérifier si le solde est suffisant
           IF WS-SOLDE-FINAL >= TRANS-AMOUNT
              SUBTRACT TRANS-AMOUNT FROM WS-SOLDE-FINAL
              ADD TRANS-AMOUNT TO WS-TOTAL-RETRAITS
              
              MOVE TRANS-AMOUNT TO WS-DISPLAY-TRANSACTION
              DISPLAY "RETRAIT : " WS-DISPLAY-TRANSACTION " € - "
                      "Nouveau solde: " WS-SOLDE-FINAL " €"
           ELSE
              MOVE TRANS-AMOUNT TO WS-DISPLAY-TRANSACTION
              DISPLAY "RETRAIT REFUSE: " WS-DISPLAY-TRANSACTION 
              " € - Solde insuffisant (" WS-SOLDE-FINAL " €)"
           END-IF.
       
       CALCULER-INTERETS.
           DISPLAY " ".
           DISPLAY "Calcul des intérêts annuels (3%)...".
           
      *    Calcul: Solde × Taux d'intérêt
           COMPUTE WS-MONTANT-INTERETS = 
                   WS-SOLDE-FINAL * WS-TAUX-INTERET
           
      *    Solde final avec intérêts
           ADD WS-MONTANT-INTERETS TO WS-SOLDE-FINAL 
                                   GIVING WS-SOLDE-AVEC-INTERETS.
       
       AFFICHER-RESUME.
           DISPLAY " ".
           DISPLAY "===============================================".
           DISPLAY "           RESUME ANNUEL DU LIVRET".
           DISPLAY "===============================================".
           
      *    Formatage pour l'affichage
           MOVE WS-SOLDE-INITIAL TO WS-DISPLAY-SOLDE-INITIAL
           MOVE WS-SOLDE-FINAL TO WS-DISPLAY-SOLDE-FINAL
           MOVE WS-TOTAL-DEPOTS TO WS-DISPLAY-TOTAL-DEPOTS
           MOVE WS-TOTAL-RETRAITS TO WS-DISPLAY-TOTAL-RETRAITS
           MOVE WS-MONTANT-INTERETS TO WS-DISPLAY-INTERETS
           MOVE WS-SOLDE-AVEC-INTERETS TO WS-DISPLAY-SOLDE-AVEC-INT
           
           DISPLAY "Solde initial           : " 
                   WS-DISPLAY-SOLDE-INITIAL " €"
           DISPLAY "Nombre de transactions  : " WS-COMPTEUR-TRANS
           DISPLAY " "
           DISPLAY "Total des dépôts        : " 
                   WS-DISPLAY-TOTAL-DEPOTS " €"
           DISPLAY "Total des retraits      : " 
                   WS-DISPLAY-TOTAL-RETRAITS " €"
           DISPLAY " "
           DISPLAY "Solde avant intérêts    : " 
                   WS-DISPLAY-SOLDE-FINAL " €"
           DISPLAY "Intérêts gagnés (3%)    : " 
                   WS-DISPLAY-INTERETS " €"
           DISPLAY "Solde après intérêts    : " 
                   WS-DISPLAY-SOLDE-AVEC-INT " €"
           DISPLAY " "
           DISPLAY "===============================================".
       
       FIN-PROGRAMME.
           CLOSE F-LIVRET
           
           IF WS-FILE-STATUS NOT = "00"
              DISPLAY "ATTENTION: Problème lors de la fermeture"
              DISPLAY "Status: " WS-FILE-STATUS
           ELSE
              DISPLAY "Fichier fermé correctement."
           END-IF
           
           DISPLAY "Fin du programme de gestion du livret.".
           STOP RUN.
           