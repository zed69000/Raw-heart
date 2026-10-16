# Raw Heart

Prototype jouable (Déni et Tristesse), à ouvrir dans un navigateur. Site statique : un seul `index.html`, sans étape de build.

- Ordinateur : clavier et souris, casque recommandé.
- Téléphone : à l'horizontale ; le bouton Plein écran du titre masque les barres du navigateur. « Ajouter à l'écran d'accueil » l'ouvre en plein écran et en paysage.

## Mise en ligne sur Cloudflare Pages

1. Cloudflare → Workers & Pages → Create → Pages → Connect to Git, puis choisir ce dépôt.
2. Framework preset : None. Build command : vide. Build output directory : `/`.
3. Save and Deploy. Chaque push sur `main` redéploie le site.

Le fichier `_headers` règle le cache (la page est toujours revérifiée, donc une mise à jour arrive tout de suite) et le type du manifeste.
