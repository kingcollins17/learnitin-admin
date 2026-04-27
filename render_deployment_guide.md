# Deploying learnitin_admin (Jaspr) to Render

## Overview

Your app is a **Jaspr** (Dart web framework) project that compiles to static HTML/CSS/JS. On Render you'll deploy it as a **Static Site**.

---

## Prerequisites

> [!IMPORTANT]
> Before deploying, fix the current build errors. You need to run code generation first:
> ```bash
> make gen    # generates .g.dart files (freezed, json_serializable, retrofit)
> make build  # then build for production
> ```
> The errors you're seeing (`AssetNotFoundException: local_storage_provider.g.dart`, `login_response.g.dart`) mean `build_runner` hasn't been run.

---

## Step 1: Fix & Verify the Build Locally

```bash
# 1. Clean everything
make clean

# 2. Install dependencies
make deps

# 3. Run code generation
make gen

# 4. Build for production
make build
```

The production build output will be in `build/jaspr/` (static files: HTML, JS, CSS).

Verify the output directory:
```bash
ls build/jaspr/
```

---

## Step 2: Push to GitHub

Make sure your repo is pushed to GitHub (you already have a remote set up):

```bash
git add -A
git commit -m "fix: run code generation and prepare for deployment"
git push origin main
```

---

## Step 3: Create a Static Site on Render

1. Go to [render.com](https://render.com) → **Dashboard** → **New** → **Static Site**
2. Connect your GitHub repo: `kingcollins17/learnitin-admin`
3. Configure the following settings:

| Setting | Value |
|---|---|
| **Name** | `learnitin-admin` |
| **Branch** | `main` |
| **Build Command** | `curl -fsSL https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-x64-release.zip -o dart-sdk.zip && unzip -o dart-sdk.zip && export PATH="$PWD/dart-sdk/bin:$HOME/.pub-cache/bin:$PATH" && dart pub get && dart run build_runner build --delete-conflicting-outputs && dart pub global activate jaspr_cli && jaspr build` |
| **Publish Directory** | `build/jaspr` |

> [!NOTE]
> Render doesn't have Dart pre-installed, so the build command downloads the Dart SDK, runs code gen, and then builds. This works but the build will take a few minutes.

---

## Step 4: Environment Variables (if needed)

If your app uses API base URLs or other environment-specific config, add them in:
- Render Dashboard → Your Service → **Environment** → **Environment Variables**

---

## Step 5: Configure Custom Domain (Optional)

1. Go to your service on Render → **Settings** → **Custom Domains**
2. Add your domain and update your DNS records as instructed
