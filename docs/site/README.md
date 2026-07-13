# Site estático — GitHub Pages

Páginas públicas para a **Play Store** e **App Store** (política de privacidade).

| Ficheiro | URL após publicar |
|----------|-------------------|
| `privacy.html` | `https://pakopt.github.io/PhoenixManager/privacy.html` |
| `index.html` | Redirecciona para `privacy.html` |

## Publicar no GitHub Pages

### 0 — Inicializar git (se ainda não tiveres)

```bash
chmod +x scripts/setup_github_pages.sh
./scripts/setup_github_pages.sh
# Seguir instruções: commit, remote, push
```

### Opção A — GitHub Actions (recomendado)

1. Push do repo para GitHub  
2. **Settings → Pages → Build and deployment**  
   - Source: **GitHub Actions**  
3. O workflow `.github/workflows/pages.yml` publica `docs/site/` em cada push para `main`  
4. Aguarda 1–2 min; a URL aparece em **Settings → Pages**

### Opção B — Branch /docs manual

1. **Settings → Pages**  
2. Source: **Deploy from a branch**  
3. Branch: `main`, folder: `/docs/site` (se a UI permitir subpasta)  
   - Nota: GitHub Pages clássico usa `/docs` na raiz do repo; se não houver subpasta, move os HTML para `docs/` ou usa Opção A.

### Opção C — Outro host

Copia `privacy.html` para qualquer hosting estático (Netlify, Cloudflare Pages, etc.).

## Actualizar conteúdo

1. Editar [`docs/PRIVACY.md`](../PRIVACY.md) (fonte)  
2. Reflectir alterações em `privacy.html`  
3. Push → Pages actualiza automaticamente (Opção A)

## Verificar localmente

```bash
cd docs/site
python3 -m http.server 8080
# Abrir http://localhost:8080/privacy.html
```

## Play Console

Colar a URL https em **Política → Política de privacidade**. Testar em janela anónima antes de submeter.
