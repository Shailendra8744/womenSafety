# Women Security — Online Complaint and SOS Alert System

Mobile app (Flutter), PHP REST API (Apache/XAMPP), MySQL, and web panels for **admin** and **police** (HTML, Bootstrap, AngularJS).

## Prerequisites

- XAMPP (or similar): Apache + PHP 8+ + MySQL
- MySQL client or phpMyAdmin
- Flutter SDK (for the mobile app)
- Optional: [Composer](https://getcomposer.org/) if you want PHPMailer for SMTP (otherwise PHP `mail()` is attempted when SMTP is not configured)

## 1. Database

1. Start MySQL in XAMPP.
2. Import, in order:
   - `database/schema.sql` — creates database `women_security` and tables
   - `database/seed.sql` — demo data

**Seed demo passwords (all accounts):** `Password123!`

- Admin: username `admin`
- Police officers: `officer1@police.local`, `officer2@police.local`
- Demo app user: `user@demo.local`

## 2. PHP configuration

1. Copy the API folder so Apache can serve it, for example:
   - Copy the project (or symlink) to `C:\xampp\htdocs\saftey\` so that the API is at:
   - `http://localhost/saftey/backend/api/`

2. Database credentials: edit [`backend/config/database.php`](backend/config/database.php) or create **`backend/config/database.local.php`** that returns only overrides, for example:

   ```php
   <?php
   return ['pass' => 'your_mysql_password'];
   ```

3. Secrets and email (recommended): copy [`backend/config/config.example.php`](backend/config/config.example.php) to **`backend/config/config.local.php`** and set:
   - `jwt_secret` — long random string
   - `control_room_email` — address that receives SOS copy
   - `smtp` — host, port, username, password, `from_email` (required for reliable delivery; otherwise the API falls back to PHP `mail()` when possible)

4. **mod_rewrite**: Ensure `AllowOverride All` is enabled for the API directory so [`backend/api/.htaccess`](backend/api/.htaccess) works. Example request:  
   `GET http://localhost/saftey/backend/api/police-stations/nearby?lat=28.61&lng=77.20`

5. Optional Composer (PHPMailer only):

   ```bash
   cd backend
   composer install
   ```

## 3. Flutter app

Project: [`mobile/`](mobile/)

Default API URL is set in [`mobile/lib/app_config.dart`](mobile/lib/app_config.dart) as:

`http://10.0.2.2/saftey/backend/api`

- **Android emulator** (`10.0.2.2` = host machine’s localhost): path must match where you deployed the API under `htdocs` (here `saftey/backend/api`).
- **Physical device**: use your PC’s LAN IP, e.g. `http://192.168.1.10/saftey/backend/api`, and build with:

  ```bash
  flutter run --dart-define=API_BASE=http://192.168.1.10/saftey/backend/api
  ```

Android cleartext HTTP is enabled for development in [`mobile/android/app/src/main/AndroidManifest.xml`](mobile/android/app/src/main/AndroidManifest.xml). Use HTTPS in production.

```bash
cd mobile
flutter pub get
flutter run
```

## 4. Admin and police web panels

- **Admin:** open [`admin/index.html`](admin/index.html) via HTTP, e.g.  
  `http://localhost/saftey/admin/`  
  Set **API base URL** on the login page if it differs from the default.

- **Police:**  
  `http://localhost/saftey/police/`

Do not open these as `file://` URLs; CORS and Angular `$http` expect the same origin or allowed origins.

## 5. Manual test checklist

- [ ] Register a new user in the app; login; edit profile.
- [ ] Add a guardian (valid email); trigger SOS with location allowed; check `sos_alerts` in DB and optional emails.
- [ ] List nearby stations; submit a complaint; open complaint detail and see status.
- [ ] Admin: login; create/edit station and officer; view complaints and SOS.
- [ ] Police: login as officer for that station; view complaint; update status and notes; view SOS list.

## API overview (JSON)

| Area | Example |
|------|---------|
| User | `POST /auth/register`, `POST /auth/login` |
| Profile / guardians | `GET/PUT /user/profile`, `GET/POST/PUT/DELETE /user/guardians` |
| SOS | `POST /sos` (Bearer user token) |
| Stations | `GET /police-stations/nearby?lat=&lng=` |
| Complaints | `POST /complaints`, `GET /complaints/my`, `GET /complaints/{id}` |
| Admin | `GET /admin/dashboard`, CRUD `/admin/police-stations`, `/admin/officers`, lists |
| Police | `GET /police/complaints`, `GET/PATCH /police/complaints/{id}`, `GET /police/sos-alerts` |

Successful responses use `{ "success": true, "data": ... }`.

---

For production, use HTTPS, strong `jwt_secret`, restricted CORS in [`backend/config/config.php`](backend/config/config.php), and consider rate limits on `POST /sos`.
