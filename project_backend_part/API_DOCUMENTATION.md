# Saudi Exim Backend API Documentation

> **Version:** 1.0
> **Framework:** Laravel 11+
> **Base URL:** `/api`

---

## Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [API Endpoints](#api-endpoints)
   - [Agenda Configuration](#agenda-configuration)
   - [Lectures](#lectures)
   - [Instructors](#instructors)
   - [Sponsors](#sponsors)
   - [Cities](#cities)
   - [Service Categories](#service-categories)
   - [Service Items](#service-items)
   - [Service Catalog](#service-catalog)
4. [Data Models](#data-models)
5. [Error Handling](#error-handling)
6. [Features](#features)

---

## Overview

The Saudi Exim Backend is a REST API designed for the Saudi Exim Mobile Application. It provides data management for:

- **Agenda/Schedule** - Event day configurations
- **Lectures/Sessions** - Conference sessions with instructors
- **Instructors** - Speaker profiles
- **Sponsors** - Partner organizations
- **Service Directory** - Cities, categories, and service items

### Key Features

- Bilingual support (English & Arabic)
- JSON API response format
- File storage with automatic URL generation
- Flexible filtering and sorting

---

## Authentication

### API Key Authentication

Some endpoints require API key authentication.

**Methods to provide API key:**

| Method | Example |
|--------|---------|
| Query Parameter | `?token=YOUR_API_KEY` |
| Request Body | `api_key` or `API_Key` field |
| Header | `X-API-Key: YOUR_API_KEY` |

**Protected Endpoints:**
- `GET /api/instructors`

**Error Response (401):**
```json
{
  "message": "Invalid or missing API key",
  "status": 401
}
```

---

## API Endpoints

### Agenda Configuration

#### Get All Configuration Keys

```
GET /api/agenda-config/{slug}/keys
GET /api/agenda-config/keys
```

Returns flattened key-value pairs for agenda configuration.

**Parameters:**
| Name | Type | Description |
|------|------|-------------|
| `slug` | string | Configuration slug (default: `default`) |

**Response:**
```json
{
  "slug": "default",
  "keys": {
    "days.day.1.title_en": "Day 1",
    "days.day.1.title_ar": "اليوم الأول",
    "days.day.1.fixed.0.start": "09:00",
    "days.day.1.fixed.0.end": "10:00",
    "days.day.1.fixed.0.title_en": "Opening Ceremony"
  }
}
```

#### Get Specific Configuration Key

```
GET /api/agenda-config/{slug}/keys/{key}
```

**Parameters:**
| Name | Type | Description |
|------|------|-------------|
| `slug` | string | Configuration slug |
| `key` | string | Dot-notation key path (e.g., `days.day.1.title_en`) |

**Response:**
```json
{
  "slug": "default",
  "key": "days.day.1.title_en",
  "value": "Day 1"
}
```

---

### Lectures

#### List All Lectures

```
GET /api/lectures
```

Returns all lectures (excluding ignored lectures).

**Response:**
```json
[
  {
    "id": 1,
    "title": "Opening Keynote",
    "title_ar": "الكلمة الافتتاحية",
    "description": "Welcome address...",
    "description_ar": "كلمة الترحيب...",
    "instructor_ids": [1, 2],
    "moderator_id": 3,
    "scheduled_at": "2025-01-15T09:00:00.000000Z",
    "end_time": "2025-01-15T10:00:00.000000Z",
    "location": "Main Hall",
    "type": "notworkshop",
    "instructors": [
      {
        "id": 1,
        "name": "John Doe",
        "name_ar": "جون دو",
        "photo_path": "instructors/photo1.jpg"
      }
    ],
    "moderator": {
      "id": 3,
      "name": "Jane Smith"
    }
  }
]
```

**Notes:**
- Lectures in `lecture_controller_ignored_lectures` table are excluded
- Includes eager-loaded `moderator` relationship
- `instructors` attribute computed from `instructor_ids` JSON array

---

### Instructors

#### List All Instructors

```
GET /api/instructors
```

**Authentication Required**

Returns instructors with their associated lectures.

**Response:**
```json
[
  {
    "id": 1,
    "name": "John Doe",
    "name_ar": "جون دو",
    "email": "john@example.com",
    "bio": "Expert in...",
    "bio_ar": "خبير في...",
    "title_en": "CEO",
    "title_ar": "الرئيس التنفيذي",
    "photo_path": "instructors/photo1.jpg",
    "lectures": [
      {
        "title": "Session Title",
        "title_ar": "عنوان الجلسة",
        "instructor_ids": [1],
        "scheduled_at": "2025-01-15T09:00:00.000000Z",
        "moderator_id": null
      }
    ]
  }
]
```

**Notes:**
- Ordered by `scheduled_at` timestamp
- Lectures in `instructor_controller_ignored_lectures` are excluded
- Limited lecture fields returned

---

### Sponsors

#### List All Sponsors

```
GET /api/sponsors
```

Returns sponsors sorted by type priority and name.

**Sponsor Types (Priority Order):**
1. Strategic partner
2. Gold Partner
3. Diamond Partner

**Response:**
```json
[
  {
    "id": 1,
    "name_en": "Company ABC",
    "name_ar": "شركة أ ب ج",
    "details_en": "Leading company...",
    "details_ar": "شركة رائدة...",
    "type": "Strategic partner",
    "photo_path": "sponsors/logo1.png"
  }
]
```

#### Get Specific Sponsor

```
GET /api/sponsors/{id}
```

**Response:**
```json
{
  "id": 1,
  "name_en": "Company ABC",
  "name_ar": "شركة أ ب ج",
  "details_en": "Leading company...",
  "details_ar": "شركة رائدة...",
  "type": "Strategic partner",
  "photo_path": "sponsors/logo1.png"
}
```

---

### Cities

#### List All Cities

```
GET /api/cities
```

Returns cities ordered by `sort_order` then `name_en`.

**Response:**
```json
[
  {
    "id": 1,
    "name_en": "Riyadh",
    "name_ar": "الرياض",
    "des_en": "Capital city...",
    "des_ar": "العاصمة...",
    "photo_path": "cities/riyadh.jpg",
    "photo_url": "https://example.com/storage/cities/riyadh.jpg",
    "sort_order": 1
  }
]
```

#### Get Specific City

```
GET /api/cities/{id}
```

---

### Service Categories

#### List All Categories

```
GET /api/service-categories
```

**Query Parameters:**
| Name | Type | Description |
|------|------|-------------|
| `per_page` | integer | Items per page (0 = all) |

**Response:**
```json
[
  {
    "id": 1,
    "name_en": "Hotels",
    "name_ar": "الفنادق",
    "des_en": "Accommodation services",
    "des_ar": "خدمات الإقامة",
    "photo_path": "categories/hotels.jpg",
    "photo_url": "https://example.com/storage/categories/hotels.jpg",
    "sort_order": 1
  }
]
```

#### Get Category with Items

```
GET /api/service-categories/{id}
```

**Response:**
```json
{
  "id": 1,
  "name_en": "Hotels",
  "name_ar": "الفنادق",
  "service_items": [
    {
      "id": 1,
      "name_en": "Hotel ABC",
      "name_ar": "فندق أ ب ج"
    }
  ]
}
```

---

### Service Items

#### List All Service Items

```
GET /api/service-items
```

**Query Parameters:**
| Name | Type | Description |
|------|------|-------------|
| `city_id` | integer | Filter by city |
| `service_category_id` | integer | Filter by category |

**Response:**
```json
[
  {
    "id": 1,
    "service_category_id": 1,
    "name_en": "Hotel ABC",
    "name_ar": "فندق أ ب ج",
    "short_des_en": "5-star hotel",
    "short_des_ar": "فندق 5 نجوم",
    "des_en": "Luxury hotel in downtown...",
    "des_ar": "فندق فاخر في وسط المدينة...",
    "thumbnail_path": "items/hotel_thumb.jpg",
    "thumbnail_url": "https://example.com/storage/items/hotel_thumb.jpg",
    "photo_path": "items/hotel.jpg",
    "photo_url": "https://example.com/storage/items/hotel.jpg",
    "website": "https://hotel.com",
    "location_link": "https://maps.google.com/...",
    "sort_order": 1,
    "cities": [...],
    "service_category": {...}
  }
]
```

#### Get Specific Service Item

```
GET /api/service-items/{id}
```

---

### Service Catalog

#### Get Complete Catalog

```
GET /api/services-data/all
```

Returns complete service catalog for mobile app initialization.

**Query Parameters:**
| Name | Type | Description |
|------|------|-------------|
| `city_id` | integer | Filter items by city |

**Response:**
```json
{
  "cities": [...],
  "categories": [...],
  "first_category": {...},
  "first_category_items": [...]
}
```

#### Get Services by Category

```
GET /api/services/{categoryId}
```

**Query Parameters:**
| Name | Type | Description |
|------|------|-------------|
| `city_id` | integer | Filter items by city |

**Response:**
```json
{
  "category": {...},
  "items": [...]
}
```

---

## Data Models

### Instructor

| Field | Type | Description |
|-------|------|-------------|
| `id` | bigint | Primary key |
| `name` | string | Name (English) |
| `name_ar` | string | Name (Arabic) |
| `email` | string | Email (unique) |
| `bio` | text | Biography (English) |
| `bio_ar` | text | Biography (Arabic) |
| `title_en` | string | Job title (English) |
| `title_ar` | string | Job title (Arabic) |
| `photo_path` | string | Photo file path |
| `country_id` | bigint | Country FK |

### Lecture

| Field | Type | Description |
|-------|------|-------------|
| `id` | bigint | Primary key |
| `title` | string | Title (English) |
| `title_ar` | string | Title (Arabic) |
| `description` | text | Description (English) |
| `description_ar` | text | Description (Arabic) |
| `instructor_ids` | json | Array of instructor IDs |
| `moderator_id` | bigint | Moderator instructor FK |
| `scheduled_at` | timestamp | Start time |
| `end_time` | timestamp | End time |
| `location` | string | Venue/room |
| `type` | enum | `workshop` or `notworkshop` |

### Sponsor

| Field | Type | Description |
|-------|------|-------------|
| `id` | bigint | Primary key |
| `name_en` | string | Name (English) |
| `name_ar` | string | Name (Arabic) |
| `details_en` | text | Details (English) |
| `details_ar` | text | Details (Arabic) |
| `type` | string | `Strategic partner`, `Gold Partner`, `Diamond Partner` |
| `photo_path` | string | Logo file path |

### City

| Field | Type | Description |
|-------|------|-------------|
| `id` | bigint | Primary key |
| `name_en` | string | Name (English) |
| `name_ar` | string | Name (Arabic) |
| `des_en` | text | Description (English) |
| `des_ar` | text | Description (Arabic) |
| `photo_path` | string | Photo file path |
| `photo_url` | string | Computed public URL |
| `sort_order` | integer | Display order |

### Service Category

| Field | Type | Description |
|-------|------|-------------|
| `id` | bigint | Primary key |
| `name_en` | string | Name (English) |
| `name_ar` | string | Name (Arabic) |
| `des_en` | text | Description (English) |
| `des_ar` | text | Description (Arabic) |
| `photo_path` | string | Photo file path |
| `photo_url` | string | Computed public URL |
| `sort_order` | integer | Display order |

### Service Item

| Field | Type | Description |
|-------|------|-------------|
| `id` | bigint | Primary key |
| `service_category_id` | bigint | Category FK |
| `name_en` | string | Name (English) |
| `name_ar` | string | Name (Arabic) |
| `short_des_en` | string | Short description (English) |
| `short_des_ar` | string | Short description (Arabic) |
| `des_en` | text | Full description (English) |
| `des_ar` | text | Full description (Arabic) |
| `thumbnail_path` | string | Thumbnail file path |
| `thumbnail_url` | string | Computed thumbnail URL |
| `photo_path` | string | Photo file path |
| `photo_url` | string | Computed photo URL |
| `website` | string | Website URL |
| `location_link` | string | Map/location URL |
| `sort_order` | integer | Display order |

### Agenda Config

| Field | Type | Description |
|-------|------|-------------|
| `id` | bigint | Primary key |
| `slug` | string | Unique identifier |
| `data` | json | Hierarchical agenda data |

---

## Error Handling

### Standard Error Format

```json
{
  "error": ["Error message 1", "Error message 2"]
}
```

### HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 401 | Unauthorized (invalid API key) |
| 404 | Resource not found |
| 422 | Validation error |
| 500 | Server error |

### Validation Error Example

```json
{
  "error": [
    "The city_id must exist in cities table",
    "The service_category_id must exist in service_categories table"
  ]
}
```

---

## Features

### Bilingual Support

All content entities support English and Arabic:
- Fields with `_en` suffix for English
- Fields with `_ar` suffix for Arabic

### File Storage

- Photos stored on `public` disk
- URLs generated via `photo_url` accessors
- Automatic file cleanup on record deletion

### Sorting

- Cities: `sort_order`, then `name_en`
- Categories: `sort_order`, then `name_en`
- Service Items: `sort_order`, then `name_en`
- Sponsors: Type priority, then name alphabetically

### Filtering

- Service Items can be filtered by `city_id` and `service_category_id`
- Lectures automatically exclude ignored entries

### Pagination

Service Categories support pagination:
```
GET /api/service-categories?per_page=15
```

---

## Database Schema

```
┌─────────────────┐       ┌─────────────────┐
│   INSTRUCTORS   │◄──────│    LECTURES     │
├─────────────────┤       ├─────────────────┤
│ id              │       │ id              │
│ name            │       │ title           │
│ name_ar         │       │ title_ar        │
│ email           │       │ instructor_ids[]│
│ bio / bio_ar    │       │ moderator_id FK │
│ title_en/ar     │       │ scheduled_at    │
│ photo_path      │       │ end_time        │
│ country_id      │       │ location        │
└─────────────────┘       │ type            │
                          └─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│    SPONSORS     │       │  AGENDA_CONFIGS │
├─────────────────┤       ├─────────────────┤
│ id              │       │ id              │
│ name_en/ar      │       │ slug (unique)   │
│ details_en/ar   │       │ data (JSON)     │
│ type            │       └─────────────────┘
│ photo_path      │
└─────────────────┘

┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│     CITIES      │◄─────►│CITY_SERVICE_ITEM│◄─────►│  SERVICE_ITEMS  │
├─────────────────┤       ├─────────────────┤       ├─────────────────┤
│ id              │       │ city_id         │       │ id              │
│ name_en/ar      │       │ service_item_id │       │ category_id FK  │
│ des_en/ar       │       └─────────────────┘       │ name_en/ar      │
│ photo_path      │                                 │ des_en/ar       │
│ sort_order      │                                 │ photo_path      │
└─────────────────┘                                 │ website         │
                                                    │ location_link   │
┌─────────────────┐                                 └────────┬────────┘
│SERVICE_CATEGORIES│                                         │
├─────────────────┤                                         │
│ id              │◄────────────────────────────────────────┘
│ name_en/ar      │
│ des_en/ar       │
│ photo_path      │
│ sort_order      │
└─────────────────┘
```

---

## Quick Reference

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/agenda-config/keys` | GET | No | Get agenda config |
| `/api/agenda-config/{slug}/keys` | GET | No | Get agenda by slug |
| `/api/agenda-config/{slug}/keys/{key}` | GET | No | Get specific key |
| `/api/lectures` | GET | No | List lectures |
| `/api/instructors` | GET | **Yes** | List instructors |
| `/api/sponsors` | GET | No | List sponsors |
| `/api/sponsors/{id}` | GET | No | Get sponsor |
| `/api/cities` | GET | No | List cities |
| `/api/cities/{id}` | GET | No | Get city |
| `/api/service-categories` | GET | No | List categories |
| `/api/service-categories/{id}` | GET | No | Get category |
| `/api/service-items` | GET | No | List items |
| `/api/service-items/{id}` | GET | No | Get item |
| `/api/services-data/all` | GET | No | Get full catalog |
| `/api/services/{categoryId}` | GET | No | Get by category |

---

*Generated: December 2025*
