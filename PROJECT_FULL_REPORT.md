# Women Security Project Full Report

## 1. Project Overview

**Project name:** Women Security - Online Complaint and SOS Alert System  
**Project type:** Multi-platform safety and emergency response system  
**Main goal:** Help women quickly send SOS alerts, contact guardians, file police complaints, and allow admin and police teams to manage incidents digitally.

This project is built as a complete system with:

- A **Flutter mobile app** for users
- A **PHP REST API backend**
- A **MySQL database**
- An **Admin web dashboard**
- A **Police web dashboard**

The project is mainly designed for local deployment using **XAMPP / Apache / MySQL**, with mobile and web clients connected to the same backend API.

## 2. Main Modules in the Project

### 2.1 Mobile App (`mobile/`)

The mobile application is the main user-facing part of the system. It is built with **Flutter** and supports:

- User registration
- User login
- Persistent login using local token storage
- Profile viewing and editing
- Guardian management
- SOS alert sending with live location
- Viewing nearby police stations
- Filing complaints
- Tracking complaint details and status

### 2.2 Backend API (`backend/`)

The backend is a **vanilla PHP REST API**. It handles:

- Authentication for users, police, and admin
- JWT token generation and verification
- Role-based authorization
- User profile operations
- Guardian CRUD operations
- SOS creation and email notification
- Nearby station lookup
- Complaint creation and retrieval
- Admin dashboard and management APIs
- Police complaint handling APIs

### 2.3 Admin Panel (`admin/`)

The admin dashboard is a browser-based management interface built with:

- HTML
- CSS
- AngularJS
- Bootstrap

Admin capabilities include:

- Login
- Overview/dashboard
- Manage police stations
- Manage police officers
- View user list
- View complaints
- Filter complaints by status
- View SOS alerts
- Soft-delete stations and officers
- View deleted station/officer history

### 2.4 Police Panel (`police/`)

The police dashboard is also web-based and built with:

- HTML
- CSS
- AngularJS
- Bootstrap

Police officer capabilities include:

- Officer login
- View complaints assigned to their station
- Open full complaint details
- Update complaint status
- Add police notes
- View SOS alerts
- Open user location in Google Maps

### 2.5 Database (`database/`)

The project contains SQL scripts for:

- Full schema creation
- Demo seed data

Important tables:

- `admins`
- `users`
- `guardians`
- `police_stations`
- `police_officers`
- `complaints`
- `sos_alerts`

## 3. Features Available in This Project

### 3.1 User Features

- Register a new account
- Login securely
- Stay logged in using stored token
- Edit profile data
- Add, edit, and remove guardians
- Trigger SOS alert with current latitude and longitude
- Automatically generate Google Maps link for SOS
- View nearest police stations based on current location
- Submit a complaint to a selected police station
- View complaint status such as `pending`, `in_progress`, `resolved`, and `closed`
- Open complaint location in maps when available

### 3.2 Emergency / SOS Features

- Capture current GPS coordinates from device
- Save SOS alert in database
- Create direct map URL
- Email guardians about emergency
- Optionally email a control-room address
- Apply SOS throttling so a user cannot spam repeated alerts within 45 seconds

### 3.3 Complaint Management Features

- Users can create complaints
- Complaint includes station, description, and optional location
- Users can view all their submitted complaints
- Users can open one complaint in detail
- Police can update complaint status
- Police can add notes to complaint
- Admin can monitor all complaints system-wide

### 3.4 Station and Officer Management Features

- Admin can create police stations
- Admin can edit station details
- Admin can soft-delete stations
- Admin can create police officers
- Admin can edit officer data
- Admin can soft-delete officers
- Deleting a station also soft-deletes linked officers

### 3.5 Dashboard and Monitoring Features

- Admin dashboard shows key summary counts
- Admin can review users, SOS alerts, complaints, stations, and officers
- Police dashboard focuses on station-level complaints and SOS
- Both web dashboards allow configurable API base URL

## 4. Technology Stack

### 4.1 Frontend

- **Flutter / Dart** for mobile app
- **AngularJS 1.8.3** for admin and police dashboards
- **Bootstrap 5.3.3** for web layout and UI styling
- **Bootstrap Icons** for dashboard icons

### 4.2 Backend

- **PHP 8+**
- **PDO** for database access
- **Custom REST routing** in a single API entry point
- **JWT authentication**
- **PHPMailer** support for SMTP email sending

### 4.3 Database

- **MySQL**
- **InnoDB**
- Foreign keys
- Indexed lookup columns

### 4.4 Flutter Packages Used

- `http`
- `geolocator`
- `shared_preferences`
- `url_launcher`
- `permission_handler`
- `mailer`

## 5. Project Structure

```text
saftey/
|- admin/        -> admin web dashboard
|- backend/      -> PHP API, auth, config, utilities
|- database/     -> schema and seed SQL
|- mobile/       -> Flutter mobile application
|- police/       -> police web dashboard
|- README.md     -> setup and usage guide
```

### Important backend files

- `backend/api/index.php` -> main API router and controller logic
- `backend/bootstrap.php` -> app bootstrap, config loading, CORS, DB init
- `backend/middleware/auth.php` -> bearer token and role checking
- `backend/utils/jwt_helper.php` -> JWT encoding/decoding
- `backend/utils/haversine.php` -> distance calculation
- `backend/utils/mail.php` -> SMTP / mail sending
- `backend/utils/response.php` -> standard JSON responses

### Important mobile files

- `mobile/lib/main.dart` -> app entry point
- `mobile/lib/app_config.dart` -> API base configuration
- `mobile/lib/services/api_client.dart` -> reusable HTTP client
- `mobile/lib/services/session_store.dart` -> local token persistence
- `mobile/lib/screens/` -> user flows and screens

## 6. API Design and Flow

The API follows a **REST-style JSON architecture**. All clients communicate with the backend using HTTP requests and receive JSON responses in this format:

```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

Main API groups:

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/police/login`
- `POST /auth/admin/login`
- `GET/PUT /user/profile`
- `GET/POST/PUT/DELETE /user/guardians`
- `POST /sos`
- `GET /police-stations/nearby`
- `POST /complaints`
- `GET /complaints/my`
- `GET /complaints/{id}`
- `GET /admin/...`
- `GET /police/...`

## 7. Algorithms and Technical Logic Used

### 7.1 Haversine Distance Algorithm

The project uses the **Haversine formula** to calculate the distance between:

- User current location
- Police station latitude and longitude

This is used in the nearby police station feature. After calculating distance for each station, the stations are sorted in ascending order and the nearest stations are returned.

**Purpose:** nearest-station recommendation based on real geographic distance.

### 7.2 Sorting Algorithm for Nearby Stations

After distance is calculated for all stations, the backend uses sorting logic with `usort()` to order results by `distance_km`.

**Purpose:** show closest stations first.

### 7.3 JWT-Based Authentication

The project uses **JSON Web Tokens** with:

- HS256 signing
- issued time (`iat`)
- expiry time (`exp`)
- role payload such as `user`, `admin`, or `police`

This is used for stateless authentication between client and server.

### 7.4 Password Hashing

User, admin, and police passwords are stored using PHP `password_hash()` and verified by `password_verify()`.

**Purpose:** secure credential storage.

### 7.5 Role-Based Access Control

The middleware checks token validity and user role before protected actions are allowed.

Examples:

- User-only routes for profile, guardians, complaints, SOS
- Admin-only routes for management APIs
- Police-only routes for complaint handling APIs

### 7.6 SOS Throttling Logic

Before a new SOS is accepted, the backend checks whether the same user already created an SOS in the last **45 seconds**.

**Purpose:** prevent repeated spam or accidental multiple emergency submissions.

### 7.7 Soft Delete Strategy

Police stations and officers are not fully removed. Instead, these fields are used:

- `is_deleted`
- `deleted_at`
- `deleted_by_admin_id`

**Purpose:** preserve historical records and avoid losing operational data.

### 7.8 CRUD-Based Data Management

Most modules use standard **Create, Read, Update, Delete** structure:

- Guardians
- Stations
- Officers
- Complaints
- Profiles

This makes the system easy to maintain and extend.

## 8. Software Architecture Used

### 8.1 Overall Architecture

The project follows a **3-tier architecture**:

1. **Presentation layer**
   Mobile app, admin dashboard, police dashboard
2. **Application layer**
   PHP API and business logic
3. **Data layer**
   MySQL database

### 8.2 Backend Structure Style

The backend is not a full MVC framework, but it follows a **lightweight modular procedural architecture**:

- One main router file
- Separate utility/helper files
- Middleware for authorization
- Config files for environment and database

This is simple and practical for small to medium academic or prototype systems.

### 8.3 Client-Server Model

The whole system uses a **client-server architecture**:

- Mobile/web clients act as clients
- PHP backend acts as central server
- MySQL stores shared persistent data

### 8.4 Database Structure

The database is **relational** and normalized around key entities:

- users
- guardians
- police stations
- officers
- complaints
- SOS alerts

Relations are maintained using **foreign keys**.

## 9. Technical Assessment

### 9.1 Strengths

- Complete end-to-end system with mobile, backend, database, admin, and police modules
- Real practical use case with safety, emergency, and complaint workflows
- Role-based access separation is clearly implemented
- Password hashing is correctly used
- JWT tokens provide lightweight session management
- Geolocation is integrated into both SOS and station lookup
- Haversine distance logic is appropriate for nearest-station selection
- Soft-delete approach is better than hard delete for administrative data
- Database tables include useful indexes on key lookup columns
- JSON response structure is consistent across API endpoints
- The project is deployable in a local XAMPP environment without heavy infrastructure

### 9.2 Limitations / Gaps

- Backend routing and business logic are concentrated in one large file, which reduces scalability and maintainability
- There is no advanced validation layer or request DTO structure
- No visible automated backend test suite is included
- No rate limiting except SOS throttling
- No password reset, email verification, or account recovery flow
- No audit log for complaint updates or officer actions
- Police SOS view is global, not station-filtered
- Nearby station lookup currently loads all stations first, then calculates distance in PHP, which may become inefficient for very large datasets
- Some dependencies appear underused or redundant
  For example, `firebase/php-jwt` is declared but custom JWT helper code is used directly
- Mobile app uses token persistence but does not appear to store full user session metadata
- Production hardening is still needed for HTTPS-only deployment, stricter CORS, and stronger operational monitoring

### 9.3 Suitability

This project is well suited for:

- Academic final-year project work
- Prototype or demo system
- Small pilot deployment with further hardening

For large real-world deployment, it would need:

- better modular backend structure
- automated testing
- stronger logging and monitoring
- stricter security controls
- scalable geospatial querying

## 10. Database Design Assessment

The database design is generally good for the project scope.

### Positive points

- Proper entity separation
- Foreign key relationships
- Timestamp tracking
- Status-based complaint workflow
- Indexed fields for station coordinates, complaint status, and dates

### Improvement points

- `sos_alerts` could optionally include nearest station or dispatch status
- complaints could include category, evidence attachment, priority, and assignment history
- soft-delete relations could be formalized with dedicated audit tables
- admin and police activity logs could be stored for accountability

## 11. Security Assessment

### Security features already present

- Password hashing
- JWT expiry support
- Role-based route protection
- Basic CORS handling
- Input validation in important routes

### Security improvements recommended

- Enforce HTTPS in production
- Restrict CORS origins tightly
- Add refresh-token or token revocation strategy
- Add login attempt throttling
- Add stronger validation and sanitization rules
- Add centralized audit logging
- Add CSRF strategy if web panels ever move to cookie-based auth

## 12. Conclusion

The Women Security project is a strong full-stack safety application that combines emergency response, police complaint management, guardian notification, and administrative control in one system. It uses practical technologies and includes meaningful real-world logic such as geolocation, nearest-station selection, JWT authentication, soft deletes, and SOS email notification.

From a technical assessment point of view, this is a solid prototype or academic project with a clear structure and useful functionality. Its main next step is improving maintainability, testing, and production-grade security so it can scale beyond a demo or classroom environment.

## 13. Suggested Report Title

You can use this title in your submission:

**Technical Report on Women Security Online Complaint and SOS Alert System**
