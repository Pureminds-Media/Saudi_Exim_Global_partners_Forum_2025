# High Level Design (HLD) - Saudi Exim Mobile Application Backend

---

## 1. Application Overview

### Purpose and Objectives
The Saudi Exim Backend serves as the central API server for the Saudi Exim Mobile Application, designed to support event management and service directory functionalities for Saudi Export-Import Bank events.

### Target Users
- **Event Attendees** - Browse agenda, speakers, sponsors
- **Service Users** - Access service directory by city and category
- **Mobile App Clients** - iOS and Android applications consuming the API

### Supported Platforms
| Platform | Status |
|----------|--------|
| iOS | Supported via REST API |
| Android | Supported via REST API |
| Web | CORS-enabled API access |

---

## 2. System Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        MOBILE CLIENTS                                    │
│                   (iOS / Android / Web)                                  │
└─────────────────────────────┬───────────────────────────────────────────┘
                              │
                              │ HTTPS / REST API
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         API GATEWAY                                      │
│                    (Laravel Application)                                 │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                      MIDDLEWARE LAYER                            │    │
│  │  • CORS Handling                                                 │    │
│  │  • API Key Authentication                                        │    │
│  │  • Error Response Formatting                                     │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                              │                                           │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                     CONTROLLER LAYER                             │    │
│  │  • AgendaConfigController    • InstructorController              │    │
│  │  • LectureController         • SponsorController                 │    │
│  │  • CityController            • ServiceCategoryController         │    │
│  │  • ServiceItemController                                         │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                              │                                           │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                       MODEL LAYER                                │    │
│  │  (Eloquent ORM - Data Access & Business Logic)                   │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────┬───────────────────────────────────────────┘
                              │
              ┌───────────────┼
              ▼               ▼               
┌─────────────────┐  ┌─────────────────┐ 
│    DATABASE     │  │  FILE STORAGE   │  
│   (MySQL/SQL)   │  │  (Public Disk)  │  
│                 │  │                 │ 
│                 │  │ • Photos        │  
│ • Lectures      │  │ • Thumbnails    │ 
│ • Instructors   │  │ • Sponsor Logos │  
│ • Sponsors      │  │ • City Images   │  
│ • Services      │  │                 │  
└─────────────────┘  └─────────────────┘  
```

---

## 3. Major Modules / Components

### 3.1 Event Management Module

| Component | Responsibility |
|-----------|----------------|
| **Agenda Configuration** | Manage event schedule with day-based configuration |
| **Lectures/Sessions** | Handle conference sessions, workshops, keynotes |
| **Instructors/Speakers** | Manage speaker profiles and their sessions |
| **Sponsors** | Display partner organizations by tier |

### 3.2 Service Directory Module

| Component | Responsibility |
|-----------|----------------|
| **Cities** | Location-based service organization |
| **Service Categories** | Categorize services (Hotels, Restaurants, etc.) |
| **Service Items** | Individual service listings with details |

### 3.3 Core Infrastructure

| Component | Responsibility |
|-----------|----------------|
| **Authentication** | API Key validation for protected endpoints |
| **Error Handling** | Standardized JSON error responses |
| **CORS** | Cross-origin resource sharing for web clients |
| **File Management** | Photo/thumbnail storage and URL generation |

---

## 4. User Flow (High Level)

```
┌──────────────┐
│  App Launch  │
└──────┬───────┘
       │
       ▼
┌──────────────────────────┐
│  Load Initial Data       │
│  • GET /services-data/all│
│  • GET /agenda-config    │
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│     Main Dashboard       │
│  • Event Agenda          │
│  • Service Directory     │
│  • Sponsors              │
└──────────┬───────────────┘
           │
     ┌─────┴─────┬─────────────┐
     ▼           ▼             ▼
┌─────────┐ ┌─────────┐ ┌─────────────┐
│ Browse  │ │ Browse  │ │   Browse    │
│ Agenda  │ │ Services│ │  Speakers   │
└────┬────┘ └────┬────┘ └──────┬──────┘
     │           │             │
     ▼           ▼             ▼
┌─────────┐ ┌─────────┐ ┌─────────────┐
│ Session │ │ Service │ │  Instructor │
│ Details │ │ Details │ │   Profile   │
└─────────┘ └─────────┘ └─────────────┘
```

---

## 5. Technology Stack

| Layer | Technology |
|-------|------------|
| **Backend Framework** | Laravel 12 (PHP 8.2+) |
| **API Style** | REST API (JSON) |
| **Database** | MySQL / SQL |
| **ORM** | Eloquent |
| **Authentication** | API Key (hash_equals) |
| **File Storage** | Laravel Filesystem (Public Disk) |
| **Testing** | PHPUnit 11 |


---

## 6. Security & Access Control

### 6.1 API Key Validation

```
Accepted Formats:
├── Query Parameter: ?token=API_KEY
├── Request Body: api_key or API_Key
└── Header: X-API-Key
```

### 6.2 Access Control Matrix

| Endpoint | Access Level |
|----------|--------------|
| `/api/agenda-config/*` | Public |
| `/api/lectures` | Public |
| `/api/instructors` | **Protected (API Key)** |
| `/api/sponsors` | Public |
| `/api/cities` | Public |
| `/api/service-categories` | Public |
| `/api/service-items` | Public |
| `/api/services/*` | Public |

### 6.3 Security Measures

- **Timing-Safe Comparison**: `hash_equals()` for API key validation
- **CORS Middleware**: Controlled cross-origin access
- **Error Sanitization**: Standardized error responses (no stack traces)
- **Input Validation**: Request validation on all endpoints

---

---

## 7. Data Entities Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    EVENT DOMAIN                              │
├─────────────────────────────────────────────────────────────┤
│  AgendaConfig ──── Day-based event schedule (JSON)          │
│  Lecture ───────── Conference sessions/workshops            │
│  Instructor ────── Speakers/presenters                      │
│  Sponsor ───────── Partner organizations (tiered)           │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                   SERVICE DOMAIN                             │
├─────────────────────────────────────────────────────────────┤
│  City ──────────── Locations with services                  │
│  ServiceCategory ─ Service groupings                        │
│  ServiceItem ───── Individual services (many-to-many city)  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                   SYSTEM DOMAIN                              │
├─────────────────────────────────────────────────────────────┤
│  IgnoredLectures ─ Filtering rules for lecture endpoints    │
└─────────────────────────────────────────────────────────────┘
```

---

## 8. API Design Principles

### Response Format
- All responses in **JSON format**
- Bilingual fields: `name_en`, `name_ar`, `des_en`, `des_ar`
- Computed URLs via model accessors: `photo_url`, `thumbnail_url`

### Sorting Strategy
- Cities/Categories: `sort_order` → `name_en`
- Sponsors: Type priority → Name alphabetically
- Lectures: `scheduled_at` timestamp

### Filtering Capabilities
- Service Items: by `city_id`, `service_category_id`
- Lectures: Auto-exclude via ignore tables

### Pagination
- Optional on Service Categories: `?per_page=N`

---

## 9. Deployment Considerations

### Environment Requirements
- PHP 8.2+
- MySQL 8.0+ / MariaDB 10.6+
- Composer 2.x
- Node.js (for asset building)

### Configuration Variables
```env
APP_KEY=           # Application encryption key
API_KEY=           # API authentication key
DB_CONNECTION=     # Database driver
DB_HOST=           # Database host
DB_DATABASE=       # Database name
FILESYSTEM_DISK=   # Storage disk (public)
```

### Health Check
- Endpoint: `/up` (Laravel health check)

---

## 11. Summary

| Aspect | Description |
|--------|-------------|
| **Architecture** | Monolithic REST API (Laravel) |
| **API Endpoints** | 14 endpoints across 7 controllers |
| **Authentication** | API Key for protected routes |
| **Database** | Relational (MySQL) with Eloquent ORM |
| **Bilingual** | Full Arabic/English support |
| **File Handling** | Public disk with auto-cleanup |

---

## One-Sentence Definition

> The Saudi Exim Backend is a Laravel-based REST API that provides event agenda management, speaker profiles, sponsor listings, and a city-based service directory with bilingual support for mobile applications.

---

*Document Version: 1.0*
*Last Updated: December 2025*
