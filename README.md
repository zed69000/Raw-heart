# Raw Heart

Prototype jouable (Déni et Tristesse), à ouvrir dans un navigateur. Site statique : un seul `index.html`, sans étape de build.

- Ordinateur : clavier et souris, casque recommandé.
- Téléphone : à l'horizontale ; le bouton Plein écran du titre masque les barres du navigateur. « Ajouter à l'écran d'accueil » l'ouvre en plein écran et en paysage.

## Mise en ligne sur Cloudflare

Le jeu est servi comme un Worker de fichiers statiques : `wrangler.jsonc` publie le dossier `public/`.

1. Cloudflare → Workers & Pages → Create → Import a repository, puis choisir ce dépôt.
2. Build command : vide. Deploy command : `npx wrangler deploy`.
3. Deploy. Chaque push sur `main` redéploie le jeu.

Le fichier `public/_headers` règle le cache (la page est toujours revérifiée, donc une mise à jour arrive tout de suite) et le type du manifeste.

## Application Android (Codemagic)

`codemagic.yaml` construit un APK à chaque push sur `main` : le dossier `android-app/` enveloppe `public/` avec Capacitor, l'application s'ouvre en plein écran et à l'horizontale.

1. Dans Codemagic, ouvrir l'application Raw-heart puis cliquer sur « Check for configuration file ».
2. Lancer le workflow « Raw Heart Android (APK) ».
3. Télécharger le fichier `.apk` dans les artefacts du build et l'installer sur le téléphone (autoriser l'installation d'applications inconnues).

L'APK est une version de débogage, non signée pour le Play Store. Three.js est chargé depuis un CDN : le jeu a besoin d’une connexion internet pour démarrer.
