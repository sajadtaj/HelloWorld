# (Semantic Release) Docker & GitHub Actions

## Set Auto Tag : image tag & git tag

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
├── .gitignore
├── secret.env
├── README
└── CHANGELOG.md
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
* اجرای اسکریپت ساخت داکر که در ادامه در زیر امده است

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
    name: Semantic Release
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          persist-credentials: false
          fetch-depth: 0

      - name: Install dependencies
        run: npm install

      - name: Run semantic-release
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


### ✅ 4. فایل `package.json`

```json
{
  "name": "helloworld",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "devDependencies": {
    "semantic-release": "^22.0.0",
    "@semantic-release/commit-analyzer": "^11.0.0",
    "@semantic-release/release-notes-generator": "^12.0.0",
    "@semantic-release/changelog": "^6.0.0",
    "@semantic-release/git": "^10.0.0",
    "@semantic-release/github": "^9.0.0",
    "@semantic-release/exec": "^6.0.3"
  },
  
  "repository": {
    "type": "git",
    "url": "https://github.com/sajadtaj/HelloWorld.git"
  }
}

```

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

| Secret Name            | مقدار                                 |
| ---------------------- | ------------------------------------------ |
| `GH_TOKEN`           | توکن GitHub ساخته‌شده         |
| `DOCKERHUB_USERNAME` | نام کاربری DockerHub              |
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

| نکته                                                                                | توضیح                                          |
| --------------------------------------------------------------------------------------- | --------------------------------------------------- |
| فقط `feat`, `fix`, `BREAKING CHANGE` باعث ساخت نسخه می‌شوند | commit message باید استاندارد باشد |
| می‌توان نسخه `latest` را هم در کنار `v1.2.3` push کرد       | با تغییر `build_and_push.sh`               |
| برای پروژه‌های مختلف فقط یک GH\_TOKEN نیاز است            | اما باید در هر repo تعریف شود    |

---

#### 📦 نمونه تصویر ساخته‌شده در سیستم اوکال

‍

```bash
docker images  # دیدن ایمیج های موجود
```

output:

    REPOSITORY             TAG       IMAGE ID       CREATED        SIZE
    xirana/helloworld    1.0.0     abc123def456   1 minute ago   150MB

اجرای ایمیج:

```bash
docker run --rm -it xirana/helloworld:1.0.0
```

#### 📦 نمونه تصویر ساخته‌شده گرفتن از داکر هاب

```bash
docker pull xirana/helloworld:v1.0.0
docker run -it xirana/helloworld:v1.0.0
```

## Install act-cli

```bash
# Window
choco install act-cli

# MacOS
brew install act

# Linux
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

```

output :
    nektos/act info checking GitHub for latest tag
    nektos/act info found version: 0.2.80 for v0.2.80/Linux/x86_64
    nektos/act info installed ./bin/act

پیغام زیر به وضوح نشان می‌دهد که ابزار act با موفقیت دانلود شده ولی در مسیر PATH قرار نگرفته است:

    nektos/act info installed ./bin/act

لذا باید فایل باینری انرا به مسیر باینری کاربر ببریم:

```bash
sudo mv ./bin/act /usr/local/bin/act

```

حالا میتوان تست کنیم

```bash
sajad@TAJ:~/All Project/temp/HelloWorld$ act --version
act version 0.2.80
sajad@TAJ:~/All Project/temp/HelloWorld$ which act
/usr/local/bin/act
```

> نکته act: صورت پیش فرض فایلها را از  .env میخوانداگر اطلاعات مانن رمز ها در مسیر دیگری از پروژه مثل secret.env باشد باید در دستور انرا مشخص کنیم.

### *secret.env*

```bash
GH_TOKEN=ghp_xxxx        # GitHub Token معتبر با repo + workflow access
DOCKERHUB_USERNAME=xirana
DOCKERHUB_TOKEN=dckr_xxxxx  

```

```bash
act --secret-file secrets.env
# یا
act # یا بصورت پیش فرض از فایل .envپروژه 

```

output:

    sajad@TAJ:~/All Project/temp/HelloWorld$ act
    INFO[0000] Using docker host 'unix:///var/run/docker.sock', and daemon socket 'unix:///var/run/docker.sock'
    ? Please choose the default image you want to use with act:
      - Large size image: ca. 17GB download + 53.1GB storage, you will need 75GB of free disk space, snapshots of GitHub Hosted Runners without snap and pulled docker images
      - Medium size image: ~500MB, includes only necessary tools to bootstrap actions and aims to be compatible with most actions
      - Micro size image: <200MB, contains only NodeJS required to bootstrap actions, doesn't work with all actions

    Default image and other options can be changed manually in /home/sajad/.config/act/actrc (please refer to https://nektosact.com/usage/index.html?highlight=configur#configuration-file for additional information about file structure)  [Use arrows to move, type to filter, ? for more help]
      Large
    > Medium
      Micro

این پیام مربوط به **انتخاب تصویر پیش‌فرض داکر (Docker Image)** برای اجرای GitHub Actions به‌صورت محلی با `act` است.

---

## ✅ توضیح دقیق سه گزینه:

| گزینه       | حجم تقریبی                                    | شامل ابزارها                                                  | مزایا                                                                         | معایب                                                                       |
| ---------------- | ------------------------------------------------------ | ------------------------------------------------------------------------ | ---------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| **Large**  | 17GB دانلود / 75GB فضای ذخیره‌سازی | کامل‌ترین snapshot محیط GitHub Actions                      | کاملاً مشابه runner رسمی GitHub                                     | بسیار حجیم، کند در دانلود                                   |
| **Medium** | \~500MB                                                | ابزارهای پرکاربرد مثل Node.js، Python، Docker، Git | سریع‌تر، سبک‌تر، برای اکثر پروژه‌ها کافی است | ممکن است برای پروژه‌های خاص ناقص باشد             |
| **Micro**  | <200MB                                                 | فقط Node.js                                                           | بسیار سبک، سریع                                                       | فقط برای پروژه‌های Node.js بسیار ساده مناسب است |

---

## ✅ برای پروژه فعلی تو (`HelloWorld` با `semantic-release` و داکر):

> بهترین انتخاب: **Medium**

چون:

* `semantic-release` فقط به Node.js و Git نیاز دارد.
* برای `docker build/push` از Docker host میزبان استفاده می‌شود (نه داخل ایمیج).
* سریع‌تر اجرا می‌شود و حافظه کمتری مصرف می‌کند.

---

## 🛠 اگر اشتباه انتخاب کردی:

می‌توانی هر زمان فایل کانفیگ را تغییر دهی:

```bash
nano ~/.config/act/actrc
```

و مقدار `--default` را تغییر بدهی:

```ini
--default medium
```

---

## ✅ ادامه کار

اگر Medium را انتخاب کردی، اکنون می‌توانی فقط با دستور زیر اکشن کامل را تست کنی:

```bash
act -j release --secret-file secrets.env
```

---

برای اینکه `act` هنگام اجرای GitHub Actions از **ایمیج دلخواه خودت** (نه `catthehacker/ubuntu:act-latest`) استفاده کند، باید مسیر ایمیج را در فایل کانفیگ `~/.config/act/actrc` مشخص کنی.

---

### ✅ مرحله‌به‌مرحله جایگزینی تصویر Docker پیش‌فرض

#### 1. ساخت مسیر کانفیگ (اگر وجود ندارد)

```bash
mkdir -p ~/.config/act
```

#### 2. ایجاد یا ویرایش فایل کانفیگ `actrc`

```bash
nano ~/.config/act/actrc
```

#### 3. نوشتن مسیر تصویر سفارشی

```ini
-P ubuntu-latest=your_custom/image:tag
```

**مثال واقعی:**

```ini
-P ubuntu-latest=sajadtaj/helloworld:latest
```

> این یعنی act به‌جای ایمیج پیش‌فرض، از `sajadtaj/helloworld:latest` به‌عنوان runner برای jobs استفاده می‌کند.

---

### ✅ اگر در `release.yml` چیز خاصی تعریف شده بود

`act` بر اساس key `runs-on` تصمیم می‌گیرد.

مثال:

```yaml
runs-on: ubuntu-latest
```

پس `ubuntu-latest` باید در `actrc` به تصویر دلخواه نگاشت شود.

---

### 🧪 تست اجرا با `act`

```bash
act -j release --secret-file secrets.env
```

---

### Addreess

__Docker hub__ : https://hub.docker.com/repositories/xirana
__Git hub__   : https://github.com/sajadtaj/HelloWorld
