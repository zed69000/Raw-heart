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
