#!/bin/bash
cd "$(dirname "$0")"

# --- CONFIGURATION DU NOM ---
# 1. Le nom du fichier dans le dossier téléchargé (GitHub)
SOURCE_NAME="FinderSummary.workflow"

# 2. Le nom qui s'affichera dans le menu Clic-Droit du Mac (C'est ici qu'on gère l'UX)
TARGET_NAME="Créer un résumé de ma sélection.workflow"

# 3. Chemin système
DEST_DIR="$HOME/Library/Services"
TARGET_PATH="$DEST_DIR/$TARGET_NAME"

echo "================================================="
echo "📂 FINDER SUMMARY - INSTALLATEUR"
echo "================================================="

# Vérification présence source
if [ ! -d "$SOURCE_NAME" ]; then
    echo "❌ Erreur : Le fichier source '$SOURCE_NAME' est introuvable."
    echo "Assurez-vous d'avoir dézippé tout le dossier."
    exit 1
fi

# Création dossier Services si inexistant
mkdir -p "$DEST_DIR"

# Nettoyage ancienne version
if [ -d "$TARGET_PATH" ]; then
    echo "🔄 Mise à jour de l'action existante..."
    rm -rf "$TARGET_PATH"
fi

# Installation (Copie + Renommage automatique)
echo "🚀 Installation en cours..."
cp -r "$SOURCE_NAME" "$TARGET_PATH"

# Vérification finale
if [ -d "$TARGET_PATH" ]; then
    echo ""
    echo "✅ INSTALLATION RÉUSSIE !"
    echo "L'action s'appelle désormais : '${TARGET_NAME%.*}'"
    echo ""
    echo "👉 TESTEZ MAINTENANT :"
    echo "1. Clic-droit sur un fichier."
    echo "2. Actions rapides > Créer un résumé de ma sélection"
else
    echo "❌ Échec de la copie."
    exit 1
fi

echo ""
echo "================================================="
read -p "Appuyez sur Entrée pour quitter..."
