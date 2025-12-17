# Collective Spirits - Calculations Reference

## Overview
This document explains all the statistical calculations and algorithms used in the Collective Spirits whiskey club app.

---

## User Stats

### Average Rating
**Where:** User profiles, stats page (hardest/easiest rater)

**Formula:**
```
Average Rating = SUM(all user's ratings) / COUNT(ratings)
```

**Example:**
- User rates 5 bottles: [4, 5, 3, 4, 4]
- Average = (4 + 5 + 3 + 4 + 4) / 5 = **4.0**

---

### Attendance Rate
**Where:** User profiles

**Formula:**
```
Attendance Rate = (Meetings Attended / Total Past Meetings) × 100
```

**Notes:**
- Only counts meetings in the past (date < today)
- Rounded to nearest whole number
- **Automatic Tracking:** Users are automatically marked as attending a meeting when they rate any bottle from that meeting

**Example:**
- User attended 8 meetings out of 10 total
- Attendance = (8 / 10) × 100 = **80%**

---

## Bottle Stats

### Bottle Average Rating
**Where:** Bottle show pages, archives, stats page

**Formula:**
```
Bottle Average = SUM(all ratings for bottle) / COUNT(ratings)
```

**Cached:** Yes - stored in `bottles.cached_average_rating` and updated whenever a rating changes

**Example:**
- Bottle has 4 ratings: [5, 4, 4, 3]
- Average = (5 + 4 + 4 + 3) / 4 = **4.0**

---

### Club Average Rating
**Where:** Stats page overview

**Formula:**
```
Club Average = SUM(all ratings) / COUNT(all ratings)
```

**Example:**
- 50 total ratings across all bottles with sum = 195
- Club Average = 195 / 50 = **3.9**

---

## Compatibility & Similarity

### Taste Compatibility
**Where:** User profiles (when viewing someone else), dashboard "Closest Match"

**Algorithm:**
1. Find all bottles both users have rated (shared bottles)
2. For each shared bottle, calculate absolute difference between their ratings
3. Calculate average difference across all shared bottles
4. Convert to percentage score

**Formula:**
```
For each shared bottle:
  difference = |user1_rating - user2_rating|

avg_difference = SUM(differences) / COUNT(shared_bottles)

compatibility = ((5 - avg_difference) / 5) × 100
```

**Example:**
- 3 shared bottles:
  - Bottle A: You = 5, Them = 4, diff = 1
  - Bottle B: You = 3, Them = 3, diff = 0
  - Bottle C: You = 4, Them = 3, diff = 1
- Average difference = (1 + 0 + 1) / 3 = 0.67
- Compatibility = ((5 - 0.67) / 5) × 100 = **86.6% → 87%**

**Interpretation:**
- 100% = Perfect match (identical ratings)
- 80% = Very similar tastes (1 point difference on average)
- 50% = Moderate similarity (2.5 point difference)
- 0% = Complete opposites (5 point difference)

---

## Stats Page Calculations

### Golden Nose (Most Predictive)
**Algorithm:** Finds the user whose ratings best predict the club average

1. For each user, calculate their "accuracy" across all bottles they've rated
2. For each bottle they rated, find the difference between their rating and the bottle's average
3. Calculate average accuracy

**Formula:**
```
For each user:
  For each bottle they rated:
    difference = |user_rating - bottle_average|
  
  accuracy = 5 - (SUM(differences) / COUNT(ratings))
```

**Example:**
- User rated 4 bottles:
  - Bottle A: User = 5, Avg = 4.5, diff = 0.5
  - Bottle B: User = 3, Avg = 3.2, diff = 0.2
  - Bottle C: User = 4, Avg = 4.0, diff = 0
  - Bottle D: User = 5, Avg = 4.8, diff = 0.2
- Average difference = (0.5 + 0.2 + 0 + 0.2) / 4 = 0.225
- Accuracy = 5 - 0.225 = **4.78**

**Winner:** User with highest accuracy score

---

### Tastemaker (Best Curator)
**Algorithm:** Finds the spirit guide whose bottles score highest on average

**Includes:**
- Bottles they brought as spirit guide (bottle_bringer)
- Bottles they contributed to flight nights

**Formula:**
```
For each user who has brought bottles:
  avg_score = AVG(all their bottles' average ratings)
```

**Example:**
- User brought 3 bottles with averages: [4.5, 4.8, 4.2]
- Their avg = (4.5 + 4.8 + 4.2) / 3 = **4.5**

**Winner:** User with highest average

---

### Most Prolific Spirit Guide
**Algorithm:** Simple count of meetings where user was the spirit guide

**Formula:**
```
count = COUNT(meetings where bottle_bringer_id = user.id)
```

**Notes:** 
- Only counts regular tastings (where they were designated spirit guide)
- Does not count flight night bottles

---

### Toughest Critic
**Algorithm:** User with lowest average rating

**Formula:**
```
avg_rating = AVG(all user's ratings)
```

**Winner:** User with lowest average

---

### Most Generous
**Algorithm:** User with highest average rating

**Formula:**
```
avg_rating = AVG(all user's ratings)
```

**Winner:** User with highest average

---

### Most Divisive Bottle
**Algorithm:** Finds bottle with highest variance (widest spread) in ratings

**Formula:**
```
For each bottle:
  mean = AVG(ratings)
  
  variance = SUM((rating - mean)²) / COUNT(ratings)
  
  standard_deviation = √variance
```

**Example:**
- Bottle with ratings [5, 5, 4, 4] has low variance = **0.5**
- Bottle with ratings [5, 3, 5, 1] has high variance = **2.5** ← Most divisive

**Winner:** Bottle with highest standard deviation

**Notes:** 
- High variance means people strongly disagree
- The bottle's average might be moderate, but opinions are polarized

---

### Highest Rated Bottle
**Algorithm:** Simple max of all bottle averages

**Formula:**
```
TOP 1 bottle ORDER BY cached_average_rating DESC
```

---

### Favorite Distillery
**Algorithm:** Distillery that appears most frequently

**Formula:**
```
GROUP BY distillery
ORDER BY COUNT(*) DESC
LIMIT 1
```

---

### Best Meeting
**Algorithm:** Meeting with highest-rated bottle

**Formula:**
```
For single-bottle meetings:
  score = bottle.cached_average_rating

For flight nights:
  score = AVG(all bottles' cached_average_rating)

ORDER BY score DESC
LIMIT 1
```

---

## Dashboard Calculations

### Favorite Curator
**Where:** Dashboard personal stats

**Algorithm:** Among bottles YOU rated, which spirit guide's bottles did you rate highest on average?

**Formula:**
```
For each spirit guide:
  their_bottles = bottles they brought that you rated
  your_avg_for_them = AVG(your ratings for their bottles)

ORDER BY your_avg_for_them DESC
LIMIT 1
```

**Example:**
- Spirit Guide A brought 3 bottles you rated: [5, 4, 5] → avg = 4.67
- Spirit Guide B brought 2 bottles you rated: [3, 4] → avg = 3.5
- Your favorite curator = **Spirit Guide A**

---

### Closest Match
**Where:** Dashboard personal stats

**Algorithm:** Uses the same Taste Compatibility calculation described above, but finds the user with highest compatibility score to you

---

## Flavor Profile Aggregation

### Bottle Flavor Summary
**Where:** Bottle show pages

**Algorithm:** Aggregates flavor tags from all ratings

**Formula:**
```
For each flavor tag across all ratings:
  count = COUNT(times tag appears)

ORDER BY count DESC
```

**Example:**
- 5 ratings with flavors:
  - Rating 1: [Smoky, Peaty, Oaky]
  - Rating 2: [Smoky, Spicy]
  - Rating 3: [Smoky, Peaty]
  - Rating 4: [Fruity]
  - Rating 5: [Smoky, Oaky]

- Aggregated: Smoky (4), Peaty (2), Oaky (2), Spicy (1), Fruity (1)

---

## Notes

### Minimum Data Requirements
- **Taste Compatibility:** Requires at least 1 shared rated bottle
- **Golden Nose:** Requires users to have rated multiple bottles
- **Tastemaker:** Requires spirit guides to have brought multiple bottles
- **Most Divisive:** Requires bottles to have multiple ratings

### Rounding
- Most percentages rounded to nearest whole number
- Ratings displayed to 1 decimal place
- Compatibility scores rounded to whole numbers

### Performance
- Bottle averages are cached in database to avoid recalculation
- Stats page queries are not cached (recalculated on each page load)
- User profile compatibility is calculated on-demand
