
### 📦 اجرای Workflowها

| دستور               | توضیح                                              |
| ------------------- | -------------------------------------------------- |
| `act`               | اجرای پیش‌فرض workflow (`.github/workflows/*.yml`) |
| `act -j <job_name>` | اجرای فقط یک job خاص از workflow                   |
| `act -e event.json` | اجرای workflow با event شبیه‌سازی‌شده از فایل      |
| `act pull_request`  | اجرای workflow برای رویداد `pull_request`          |
| `act push`          | اجرای workflow برای رویداد `push`                  |

---

### 🔐 مدیریت Secrets و متغیرها

| دستور                           | توضیح                                    |
| ------------------------------- | ---------------------------------------- |
| `act --secret-file secrets.env` | بارگذاری متغیرهای secret از فایل         |
| `act -s GH_TOKEN=<token>`       | تعریف secret مستقیم در CLI               |
| `act --env-file .env`           | بارگذاری فایل `.env` برای متغیرهای محیطی |

---

### 🐳 مدیریت Image و Platform

| دستور                                      | توضیح                                                  |
| ------------------------------------------ | ------------------------------------------------------ |
| `act -P ubuntu-latest=node:16`             | تعریف image دلخواه برای platform                       |
| `act --container-architecture linux/amd64` | تنظیم معماری container                                 |
| `act --reuse`                              | استفاده مجدد از containerها بین اجراها برای سرعت بیشتر |

---

### ⚙️ تنظیمات و دیباگ

| دستور                   | توضیح                                        |
| ----------------------- | -------------------------------------------- |
| `act -v` یا `--verbose` | فعال‌سازی خروجی verbose برای debug           |
| `act --dryrun`          | فقط نمایش مراحل بدون اجرای واقعی             |
| `act --list`            | نمایش لیست jobها در workflow                 |
| `act --rm`              | حذف container بعد از اجرا (پیش‌فرض روشن است) |
| `act --no-rebuild`      | استفاده از image کش‌شده بدون build مجدد      |

---

### ⚠️ رفع مشکلات رایج

| دستور                                 | توضیح                                       |
| ------------------------------------- | ------------------------------------------- |
| `act --pull=false`                    | جلوگیری از pull کردن imageها (حل مشکل auth) |
| `act -W .github/workflows/myfile.yml` | اجرای فایل workflow خاص                     |

---