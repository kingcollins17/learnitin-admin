# 🌬️ jaspr_tailwind v0.3.6

> Tailwind integration for [Jaspr](https://pub.dev/packages/jaspr) — a popular CSS framework to quickly compose beautiful websites without needing to write a lot of CSS.
>
> **Publisher:** [brainiacs.in](https://brainiacs.in) · **License:** MIT

---

## Prerequisites

This package expects Tailwind to be installed via the `tailwindcss` CLI. The recommended approach is to use the **standalone Tailwind CLI**.

### Install the Standalone CLI

1. Download the executable for your platform from the [latest GitHub release](https://github.com/tailwindlabs/tailwindcss/releases/latest):

   ```bash
   curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-<your-platform>
   chmod +x tailwindcss-<your-platform>
   ```

2. Move it to a common executable location (or add its directory to your `PATH`):

   ```bash
   # e.g. /usr/local/bin on Unix-based systems (Linux, macOS)
   mv tailwindcss-<your-platform> /usr/local/bin/tailwindcss
   ```

3. Verify the installation:

   ```bash
   tailwindcss -h
   ```

---

## Setup

### 1. Add the Dependency

```bash
dart pub add jaspr_tailwind --dev
```

### 2. Create the Input CSS File

Add a `styles.tw.css` file inside the `web/` directory.

**Tailwind CSS v4:**

```css
@import "tailwindcss";
```

**Tailwind CSS v3:**

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

### 3. Link the Generated Stylesheet

The integration compiles `styles.tw.css` → `styles.css`. Link the output in your document.

**Static / Server mode** (`lib/main.dart`):

```dart
import 'package:jaspr/server.dart';
import './app.dart';

void main() {
  runApp(Document(
    title: 'My Tailwind Site',
    head: [
      // Link the generated styles.css
      link(href: 'styles.css', rel: 'stylesheet'),
    ],
    body: App(),
  ));
}
```

**Client mode** (`web/index.html`):

```html
<html>
  <head>
    <!-- Link the generated styles.css -->
    <link href="styles.css" rel="stylesheet" />
  </head>
</html>
```

> **Tip:** You can have more than one input CSS file. Any file inside `web/` ending in `.tw.css` will be compiled to its `.css` counterpart.

---

## Usage

If you are unfamiliar with Tailwind, head over to the [official documentation](https://tailwindcss.com/docs) first (you can skip the installation section).

The `jaspr_tailwind` integration comes **preconfigured**, so you can use any Tailwind classes inside your Jaspr components immediately.

### Example: Card Component

```dart
import 'package:jaspr/jaspr.dart';

class SimpleCard extends StatelessComponent {
  const SimpleCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'p-6 max-w-sm mx-auto bg-white rounded-xl shadow-lg flex items-center space-x-4',
      [
        div(classes: 'shrink-0', [
          img(classes: 'h-12 w-12', src: '/img/logo.svg', alt: '$title Logo'),
        ]),
        div([
          div(classes: 'text-xl font-medium text-black', [.text(title)]),
          p(classes: 'text-slate-500', [.text(message)]),
        ]),
      ],
    );
  }
}
```

---

## Config

By default, **no config file is needed**. The package automatically scans your project's Dart files and builds the CSS.

To customize the theme or colors, add a `tailwind.config.js` to the project root:

```js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./{lib,web}/**/*.dart"],
  theme: {
    extend: {},
  },
  plugins: [],
};
```

> [!NOTE]
> Starting from **v4**, Tailwind uses **CSS-first configuration**. Prefer using that for themes and variables.

> [!WARNING]
> Setting a custom `content` configuration is possible, but the integration **won't recompile** CSS when those files change. Automatic recompiling is only enabled for `.dart` files.

---

## VS Code Setup: Tailwind CSS IntelliSense

To enable Tailwind CSS IntelliSense in VS Code when working with Jaspr/Dart:

1. Install the **[Tailwind CSS IntelliSense](https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss)** extension.

2. Open **Command Palette** → `Preferences: Open User Settings (JSON)` and add:

   ```json
   {
     "tailwindCSS.includeLanguages": {
       "dart": "html"
     },
     "tailwindCSS.classAttributes": [
       "class",
       "className",
       "ngClass",
       "class:list",
       "classes"
     ],
     "tailwindCSS.experimental.classRegex": [
       "\\W\\s*classes:\\s*'(.*)'"
     ]
   }
   ```

3. Optionally, reload the extension.

This enables IntelliSense autocomplete and suggestions for Tailwind CSS classes in your Dart/Jaspr files.

> [!NOTE]
> If you are using **Tailwind CSS v3**, a config file is **required** — otherwise the IntelliSense plugin won't detect which version of Tailwind is being used. Migrating to **v4** is highly recommended.

---

## Package Info

| Metric     | Value |
|------------|-------|
| Likes      | 28    |
| Pub Points | 140   |
| Downloads  | 821   |

**Dependencies:** `build`, `build_modules`, `glob`, `path`

**Topics:** `#jaspr` `#web` `#html` `#css` `#tailwind`

- [Documentation](https://pub.dev/packages/jaspr_tailwind)
- [API Reference](https://pub.dev/documentation/jaspr_tailwind/latest/)
- [Repository (GitHub)](https://github.com/schultek/jaspr)
- [View / Report Issues](https://github.com/schultek/jaspr/issues)
