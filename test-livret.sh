#!/bin/bash

# Script de test pour le programme de gestion du livret d'épargne
echo "=========================================="
echo "  TEST DU PROGRAMME LIVRET D'EPARGNE"
echo "=========================================="

# Créer le fichier de transactions d'exemple
echo "Création du fichier LIVRET avec transactions d'exemple..."
cat > LIVRET << 'EOF'
D00050000
D00025000
R00010000
D00075000
D00012500
R00005000
D00030000
R00015000
D00020000
R00008000
EOF

echo "Fichier LIVRET créé avec les transactions suivantes :"
echo "D00050000  -> Dépôt de 500.00 €"
echo "D00025000  -> Dépôt de 250.00 €"
echo "R00010000  -> Retrait de 100.00 €"
echo "D00075000  -> Dépôt de 750.00 €"
echo "D00012500  -> Dépôt de 125.00 €"
echo "R00005000  -> Retrait de 50.00 €"
echo "D00030000  -> Dépôt de 300.00 €"
echo "R00015000  -> Retrait de 150.00 €"
echo "D00020000  -> Dépôt de 200.00 €"
echo "R00008000  -> Retrait de 80.00 €"
echo ""

echo "Calculs attendus :"
echo "Total dépôts  : 500 + 250 + 750 + 125 + 300 + 200 = 2125.00 €"
echo "Total retraits: 100 + 50 + 150 + 80 = 380.00 €"
echo "Solde final   : 2125 - 380 = 1745.00 €"
echo "Intérêts 3%   : 1745 × 0.03 = 52.35 €"
echo "Solde + int.  : 1745 + 52.35 = 1797.35 €"
echo ""

# Compilation
echo "Compilation du programme..."
if cobc -x livret-epargne.cob; then
    echo "✓ Compilation réussie"
    echo ""
    
    # Exécution
    echo "=========================================="
    echo "           EXECUTION DU PROGRAMME"
    echo "=========================================="
    ./livret-epargne
    
    echo ""
    echo "=========================================="
    echo "              VERIFICATION"
    echo "=========================================="
    echo "Vérifiez que les résultats correspondent aux calculs attendus ci-dessus."
    
else
    echo "✗ Erreur de compilation"
    echo "Vérifiez le code source pour les erreurs de syntaxe."
fi

echo ""
echo "Pour nettoyer les fichiers générés :"
echo "rm -f livret-epargne LIVRET"