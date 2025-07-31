# 📘 مستند جامع تنظیم نسخه‌دهی خودکار (Semantic Release) برای پروژه‌های Docker با GitHub Actions

---

## 🎯 هدف پروژه

این سیستم برای پروژه‌هایی طراحی شده که:

* با هر **تغییر در کد**، به‌صورت **اتوماتیک نسخه‌دهی (semantic versioning)** انجام شود.
* به‌طور خودکار **Git Tag** ایجاد شود.
* یک **Docker Image** از پروژه ساخته و با همان نسخه به **DockerHub** ارسال شود.
* تمام فرآیند در **GitHub Actions (CI/CD)** انجام گیرد بدون دخالت دستی.

---

## 🧱 ساختار فایل‌ها

```
📦 پروژه
├── Dockerfile
├── hello.py
├── .releaserc
├── package.json
├── .github/
│   ├── workflows/
│   │   └── release.yml
│   └── scripts/
│       └── build_and_push.sh
```

---

## ⚙️ بخش ۱: پیکربندی فایل‌های پروژه

---

### ✅ 1. فایل `.releaserc`

📄 مسیر: `./.releaserc`

```json
{
  "branches": ["master"],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    "@semantic-release/git",
    "@semantic-release/github",
    [
      "@semantic-release/exec",
      {
        "publishCmd": "bash .github/scripts/build_and_push.sh ${nextRelease.version}"
      }
    ]
  ]
}
```

📌 **هدف:**

* تعیین شاخه انتشار
* تعریف نسخه‌دهی مبتنی بر commit
* اجرای اسکریپت ساخت داکر

---

### ✅ 2. اسکریپت `build_and_push.sh`

📄 مسیر: `.github/scripts/build_and_push.sh`

```bash
#!/bin/bash

set -e

VERSION=$1
IMAGE_NAME=sajadtaj/helloworld  # ← آدرس DockerHub شما

echo "🛠 Building Docker image with tag: $VERSION"

docker build -t $IMAGE_NAME:$VERSION .

echo "🚀 Pushing Docker image to DockerHub..."
docker login -u "${DOCKERHUB_USERNAME}" -p "${DOCKERHUB_TOKEN}"
docker push $IMAGE_NAME:$VERSION
```

📌 **هدف:**

* ساخت image با نسخه داده‌شده
* push آن به DockerHub
* اجرای خودکار در مرحله publish

> ✳️ فراموش نکن:

```bash
chmod +x .github/scripts/build_and_push.sh
```

---

### ✅ 3. فایل GitHub Action: `release.yml`

📄 مسیر: `.github/workflows/release.yml`

```yaml
name: Release

on:
  push:
    branches:
      - master

jobs:
  release:
    name: Semantic Release & Docker Build
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install Dependencies
        run: npm install

      - name: Run Semantic Release
        env:
          GH_TOKEN: ${{ secrets.GH_TOKEN }}
          DOCKERHUB_USERNAME: ${{ secrets.DOCKERHUB_USERNAME }}
          DOCKERHUB_TOKEN: ${{ secrets.DOCKERHUB_TOKEN }}
        run: npx semantic-release
```

📌 **هدف:**

* اجرای CI بر اساس push روی `master`
* نصب semantic-release
* انجام فرآیند نسخه‌دهی و انتشار تصویر داکر

---

## 🔐 بخش ۲: تنظیم Tokenها و Secrets در GitHub

---

### ✅ 1. دریافت `GH_TOKEN` برای انتشار تگ

#### مراحل:

1. ورود به: [https://github.com/settings/tokens](https://github.com/settings/tokens)

2. انتخاب: `Generate new token (classic)`

3. مقداردهی:

   * **Note:** `semantic-release for HelloWorld`
   * **Expiration:** `90 days` یا `No expiration`
   * **Scopes:** تیک بزن:

     * ✅ `repo`
     * ✅ `workflow` (اختیاری ولی بهتر)

4. پس از ساخت، توکن را کپی کن. مثال:

   ```
   ghp_12345yourtokenxyz
   ```

---

### ✅ 2. دریافت `DOCKERHUB_USERNAME` و `DOCKERHUB_TOKEN`

#### `DOCKERHUB_USERNAME`:

* همان نام کاربری حساب DockerHub شما است (مثلاً `sajadtaj`)

#### `DOCKERHUB_TOKEN`:

1. ورود به [https://hub.docker.com](https://hub.docker.com)
2. مسیر: `Account Settings → Security → Access Tokens`
3. دکمه: `New Access Token`

   * Description: `semantic-release`
   * Access: `Read/Write`
   * Generate → کپی کن

---

### ✅ 3. اضافه کردن Secrets در GitHub

1. برو به ریپوی `HelloWorld`
2. مسیر: `Settings → Secrets and variables → Actions → New repository secret`
3. سه مورد را اضافه کن:

| Secret Name          | مقدار                       |
| -------------------- | --------------------------- |
| `GH_TOKEN`           | توکن GitHub ساخته‌شده       |
| `DOCKERHUB_USERNAME` | نام کاربری DockerHub        |
| `DOCKERHUB_TOKEN`    | توکن ساخته‌شده در DockerHub |

---

## 🧪 تست نهایی سیستم

1. یک commit خالی با پیام semantic بنویس:

```bash
git commit --allow-empty -m "feat: تست انتشار خودکار"
git push origin master
```

2. برو به تب **Actions** در GitHub
3. بررسی کن:

   * آیا Action اجرا شد؟
   * آیا tag ساخته شد؟ (مثل `v1.0.0`)
   * آیا image در DockerHub push شد؟

---

## 🧠 نکات حرفه‌ای

| نکته                                                        | توضیح                              |
| ----------------------------------------------------------- | ---------------------------------- |
| فقط `feat`, `fix`, `BREAKING CHANGE` باعث ساخت نسخه می‌شوند | commit message باید استاندارد باشد |
| می‌توان نسخه `latest` را هم در کنار `v1.2.3` push کرد       | با تغییر `build_and_push.sh`       |
| برای پروژه‌های مختلف فقط یک GH\_TOKEN نیاز است              | اما باید در هر repo تعریف شود      |

---

## 📦 نمونه تصویر ساخته‌شده

```bash
docker pull sajadtaj/helloworld:v1.0.0
docker run -it sajadtaj/helloworld:v1.0.0
```

