#!/bin/bash

# Script de vérification des credentials Firebase Admin

echo "🔍 Vérification de la configuration Firebase Admin..."
echo ""

# Vérifier si GOOGLE_APPLICATION_CREDENTIALS est défini
if [ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
    echo "❌ GOOGLE_APPLICATION_CREDENTIALS n'est pas défini"
    echo ""
    echo "📋 Pour configurer :"
    echo "   1. Téléchargez le fichier de service account depuis Firebase Console"
    echo "   2. Définissez la variable :"
    echo "      export GOOGLE_APPLICATION_CREDENTIALS=\"/chemin/vers/votre-fichier.json\""
    echo ""
    echo "   Voir SETUP_CREDENTIALS.md pour plus de détails"
    exit 1
fi

echo "✅ Variable GOOGLE_APPLICATION_CREDENTIALS définie"
echo "   Chemin : $GOOGLE_APPLICATION_CREDENTIALS"
echo ""

# Vérifier si le fichier existe
if [ ! -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
    echo "❌ Le fichier n'existe pas : $GOOGLE_APPLICATION_CREDENTIALS"
    echo ""
    echo "📋 Vérifiez que :"
    echo "   - Le chemin est correct"
    echo "   - Le fichier a été téléchargé depuis Firebase Console"
    exit 1
fi

echo "✅ Le fichier existe"
echo ""

# Vérifier que c'est un fichier JSON valide
if ! jq empty "$GOOGLE_APPLICATION_CREDENTIALS" 2>/dev/null; then
    echo "⚠️  Le fichier ne semble pas être un JSON valide"
    echo "   (jq n'est peut-être pas installé, ou le fichier est invalide)"
else
    echo "✅ Le fichier est un JSON valide"
    
    # Extraire le project_id si possible
    PROJECT_ID=$(jq -r '.project_id' "$GOOGLE_APPLICATION_CREDENTIALS" 2>/dev/null)
    if [ "$PROJECT_ID" != "null" ] && [ -n "$PROJECT_ID" ]; then
        echo "   Project ID : $PROJECT_ID"
    fi
fi

echo ""

# Vérifier les permissions
PERMS=$(stat -f "%A" "$GOOGLE_APPLICATION_CREDENTIALS" 2>/dev/null || stat -c "%a" "$GOOGLE_APPLICATION_CREDENTIALS" 2>/dev/null)
if [ "$PERMS" != "600" ] && [ "$PERMS" != "400" ]; then
    echo "⚠️  Les permissions du fichier ne sont pas optimales (actuellement : $PERMS)"
    echo "   Recommandation : chmod 600 \"$GOOGLE_APPLICATION_CREDENTIALS\""
    echo ""
else
    echo "✅ Permissions du fichier correctes ($PERMS)"
    echo ""
fi

# Test rapide avec Node.js
echo "🧪 Test de connexion Firebase Admin..."
cd "$(dirname "$0")"

if command -v node &> /dev/null; then
    node -e "
        const admin = require('firebase-admin');
        try {
            admin.initializeApp({
                credential: admin.credential.applicationDefault(),
            });
            console.log('✅ Firebase Admin initialisé avec succès');
            process.exit(0);
        } catch (error) {
            console.error('❌ Erreur lors de l\'initialisation:', error.message);
            process.exit(1);
        }
    "
else
    echo "⚠️  Node.js n'est pas installé, impossible de tester la connexion"
fi

echo ""
echo "✅ Configuration vérifiée !"
echo ""
echo "📋 Prochaines étapes :"
echo "   npm run sync:users:dev:dry  # Tester en mode DRY-RUN"

