#!/bin/bash

# Script pour configurer la variable d'environnement GOOGLE_APPLICATION_CREDENTIALS

CREDENTIALS_FILE="$HOME/.firebase-credentials/hire-me-28191-firebase-adminsdk-fbsvc-94815a6453.json"

if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "❌ Le fichier de credentials n'existe pas : $CREDENTIALS_FILE"
    echo "📋 Vérifiez que le fichier a été téléchargé depuis Firebase Console"
    exit 1
fi

# Définir la variable pour cette session
export GOOGLE_APPLICATION_CREDENTIALS="$CREDENTIALS_FILE"

echo "✅ Variable GOOGLE_APPLICATION_CREDENTIALS définie :"
echo "   $GOOGLE_APPLICATION_CREDENTIALS"
echo ""
echo "📋 Pour rendre cette configuration permanente, ajoutez cette ligne à votre ~/.zshrc :"
echo "   export GOOGLE_APPLICATION_CREDENTIALS=\"\$HOME/.firebase-credentials/hire-me-28191-firebase-adminsdk-fbsvc-94815a6453.json\""
echo ""
echo "💡 Ou exécutez : source ~/.zshrc"

