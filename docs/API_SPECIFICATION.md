# Shrine Tours API — endpoints & rough expected responses (v1)

Base: `https://api.shrinetours.com/v1` · paths in `lib/core/api/api_constants.dart`

Below is **not a strict contract** — field names/types can align with your stack; it’s the **shape** the app is aiming for.

---

### `POST /auth/login` · `POST /auth/register` · `POST /auth/google`

Rough response:

```json
{
  "access_token": "...",
  "refresh_token": "...",
  "expires_in": 3600,
  "user": { "id": "...", "name": "...", "email": "..." }
}
```

---

### `POST /auth/refresh`

```json
{
  "access_token": "...",
  "refresh_token": "...",
  "expires_in": 3600
}
```

---

### `POST /auth/logout`

Empty body or `{ "ok": true }` is fine.

---

### `GET /trips`

Array of trip summaries (home / “my trips” style cards):

```json
[
  {
    "id": "...",
    "city": "Bhopal",
    "image_url": "https://...",
    "date_range_label": "23 Oct 25 - 26 Oct 25",
    "places_count": 5,
    "days": 3,
    "adults": 2,
    "kids": 1
  }
]
```

*(Alternatively `start_date` / `end_date` instead of a preformatted label — app can format.)*

---

### `GET /trips/{id}`

One object like a trip in the list, optionally with nested `places` or links to an itinerary.

---

### `POST /trips/generate`

Rough idea: enough to open the trip/itinerary in the app, e.g.:

```json
{
  "trip_id": "...",
  "itinerary_id": "...",
  "city": "...",
  "days": 3
}
```

---

### `GET /itineraries`

List similar to trips if that’s how you model it, or lightweight refs: `{ "id", "trip_id", "city", "title" }[]`.

---

### `GET /itineraries/{id}`

Day-by-day schedule:

```json
{
  "id": "...",
  "trip_id": "...",
  "city": "Bhopal",
  "days": [
    {
      "day_number": 1,
      "activities": [
        {
          "id": "...",
          "time": "10:00",
          "title": "Start from Hotel",
          "duration": "30 min",
          "cost": 2500,
          "icon": "car"
        }
      ]
    }
  ]
}
```

---

### `GET /itineraries/activities` (and `/itineraries/activities/{id}` if used)

Either the `activities` array for one day, or same activity objects as above (with `day_number` if flat list).

---

### `GET /places` · `GET /places/search` · `GET /places/suggested`

Same rough shape for all three (search/suggested = filtered lists):

```json
[
  {
    "id": "...",
    "name": "Van Vihar",
    "category": "Nature",
    "image_url": "https://...",
    "typical_duration": "Typically requires 3h",
    "rating": 4.8,
    "reviews_count": 47,
    "verified": true
  }
]
```

---

### `GET /packing` *(e.g. `?trip_id=...`)*

```json
{
  "trip_id": "...",
  "selected_transports": ["airplane", "bus"],
  "categories": [
    {
      "name": "Essentials",
      "icon": "luggage",
      "items": [
        { "id": "e1", "name": "Passport", "is_checked": true, "quantity": 1 }
      ]
    }
  ]
}
```

---

### `GET /packing/categories`

Template list: same `categories[]` idea without a specific `trip_id`, or a minimal `{ "name", "icon", "default_items": [...] }[]`.

---

### `GET /profile`

```json
{
  "name": "...",
  "email": "...",
  "phone": "...",
  "dob": "1990-01-01",
  "level": "Explorer",
  "level_progress": 0.75,
  "trips_completed": 5,
  "is_premium": true
}
```

---

### `PUT /profile/update`

Return the updated profile in the same shape as `GET /profile`.

---

### `GET /profile/payments`

```json
[
  {
    "id": "...",
    "type": "VISA",
    "last_four": "4532",
    "holder_name": "JOHN DOE",
    "expiry": "12/25",
    "is_primary": true
  }
]
```

---

### `GET /profile/subscription`

Rough idea:

```json
{
  "plan": "premium",
  "status": "active",
  "renews_at": "2025-12-01",
  "features": ["unlimited_trips", "..."]
}
```

---

### `GET /weather?city=&date=`

```json
{
  "city": "Bhopal",
  "date": "2025-10-23",
  "condition": "clear",
  "temp_min_c": 22,
  "temp_max_c": 31,
  "description": "Mostly sunny"
}
```
