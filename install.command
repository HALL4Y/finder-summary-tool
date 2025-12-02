#!/bin/bash
cd "$(dirname "$0")"

# --- CONFIGURATION ---
SOURCE_NAME="FinderSummary.workflow"
TARGET_NAME="Créer un résumé de ma sélection.workflow"
DEST_DIR="$HOME/Library/Services"
TARGET_PATH="$DEST_DIR/$TARGET_NAME"

echo "================================================="
echo "📂 FINDER SUMMARY TOOL - INSTALLATION"
echo "================================================="

# 1. Vérifier si le dossier Services existe
if [ ! -d "$DEST_DIR" ]; then
    echo "⚠️  Création du dossier Services..."
    mkdir -p "$DEST_DIR"
fi

# 2. Vérifier si l'ancien existe déjà
if [ -d "$TARGET_PATH" ]; then
    echo "🔄 Une version existe déjà."
    read -p "Voulez-vous la remplacer ? (o/n) " choice
    if [[ "$choice" != "o" ]]; then
        echo "Annulation."
        exit 0
    fi
    rm -rf "$TARGET_PATH"
fi

# 3. Installation
echo "🚀 Installation de l'Action Rapide..."
cp -r "$SOURCE_NAME" "$TARGET_PATH"

# 4. Confirmation
if [ -d "$TARGET_PATH" ]; then
    echo ""
    echo "✅ SUCCÈS !"
    echo "L'action est installée."
    echo ""
    echo "👉 COMMENT L'UTILISER :"
    echo "1. Sélectionnez des fichiers dans le Finder."
    echo "2. Clic-droit > Actions rapides > Créer un résumé de ma sélection"
else
    echo "❌ Erreur lors de la copie."
    exit 1
fi

echo ""
echo "================================================="
read -p "Appuyez sur Entrée pour quitter..."
