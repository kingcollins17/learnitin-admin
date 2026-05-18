# Deploying Learnitin Admin (Jaspr) to Render (Prebuilt Strategy)

## Overview

Your app is a **Jaspr** (Dart web framework) project that compiles to static HTML/CSS/JS. Building Dart apps directly on Render can fail due to environment constraints or memory limits. 

To ensure **100% reliable, ultra-fast deployments**, we use a **Prebuilt Deployment Strategy**:
1. You compile the production bundle locally (`build/jaspr/`).
2. You commit the `build/jaspr/` directory to Git.
3. Render instantly deploys the static files as a **Static Site** in under 10 seconds without running any server-side compilation!

---

## Step 1: Prepare Git (Done)
Ensure `/build/` is **not** ignored in your `.gitignore` so the production assets can be added to git:
```
# In your .gitignore, make sure /build/ is commented out:
# /build/
```

---

## Step 2: Compile the Production Bundle Locally
Run these commands to clean, run code generation, and compile the final static build folder:

```bash
# 1. Clean build caches
make clean

# 2. Re-generate all code generation files (.freezed, .g.dart, .retrofit.dart)
make gen

# 3. Compile the production bundle
jaspr build
```

This compiles your entire app into pure static files inside the `build/jaspr/` folder.

---

## Step 3: Push Prebuilt Files to GitHub
Commit all modified files and the newly generated local build assets, then push to GitHub:

```bash
git add .
git commit -m "deploy: add production build assets for Render"
git push origin main
```

---

## Step 4: Configure the Static Site on Render

1. Go to [render.com](https://render.com) → **Dashboard** → **New** → **Static Site**
2. Connect your GitHub repository: `kingcollins17/learnitin-admin`
3. Configure the following settings:

| Setting | Value |
|---|---|
| **Name** | `learnitin-admin` |
| **Branch** | `main` |
| **Build Command** | *Leave completely blank* (or use `echo "Prebuilt Deployment"`) |
| **Publish Directory** | `build/jaspr` |

> [!TIP]
> Leaving the Build Command blank prevents Render from trying to build the project. It will instantly serve the precompiled files directly from your Git commit.

---

## Step 5: Configure Custom Domain (Optional)

1. Go to your service on Render → **Settings** → **Custom Domains**
2. Add your domain and update your DNS records as instructed.
