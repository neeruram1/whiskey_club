# Collective Spirits of Montclair

A web application for managing a whiskey tasting club. Track bottles, rate whiskeys, discover members with similar taste, and explore club statistics.

## Features

- 🥃 **Bottle Archive** - Browse all whiskeys the club has tasted
- 📅 **Meeting Management** - Schedule regular tastings and flight nights
- ⭐ **Rating System** - Rate bottles with scores, comments, and flavor profiles
- 💛 **Encore Pours** - Save bottles you want to drink again (wishlist)
- 👥 **Member Profiles** - View stats, ratings, and taste compatibility
- 📊 **Club Statistics** - Golden Nose, Tastemaker, and more insights
- ✈️ **Flight Nights** - Support for multi-bottle tasting events
- 🔒 **Bottle Reveals** - Hide bottles until meeting day for surprise tastings

## Key Behaviors

### Automatic Attendance Tracking
When a user rates a bottle from any meeting, they are automatically marked as having attended that meeting. No manual check-in required.

### Backfill Attendance
If you need to mark attendance for existing ratings, run:
```bash
bin/rails attendance:backfill
```

## Documentation

- **[CALCULATIONS.md](CALCULATIONS.md)** - Technical reference for all statistical calculations
- **[DEMO_GUIDE.md](DEMO_GUIDE.md)** - Non-technical walkthrough of features for demos

## Setup

* Ruby version: 3.2+
* Rails version: 7.1.5
* Database: PostgreSQL
* CSS: Tailwind CSS v4

## Development

```bash
# Install dependencies
bundle install

# Setup database
bin/rails db:setup

# Run development server
bin/dev
```

## Deployment

Designed for deployment on platforms like Heroku, Fly.io, or Render with PostgreSQL database support.
