# Upload to GitHub

1. Create a new empty GitHub repository, for example `poincare-lean-blueprint`.
2. Unzip this project.
3. Run:

```bash
git init
git add .
git commit -m "Initial Poincare Lean blueprint skeleton"
git branch -M main
git remote add origin git@github.com:<owner>/poincare-lean-blueprint.git
git push -u origin main
```

4. In GitHub Pages settings, choose **GitHub Actions** as the source if you want the blueprint to be deployed later.
5. Replace `OWNER` placeholders in:

- `.github/CODEOWNERS`
- `blueprint/src/web.tex`
- README badges if you add them.

6. Locally run:

```bash
lake update
lake exe cache get
lake build
python3 scripts/check_pending.py
```

7. Commit `lake-manifest.json` after a successful update.
