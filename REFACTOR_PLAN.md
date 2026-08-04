# Whiskey Club — Refactor Plan (Usability + Code Quality)

*Written from the perspective of a senior Rails dev. The app is healthy and small
(~5k LOC, Rails 7.1, Postgres, Devise, Hotwire, RSpec). This is not a rewrite —
it's a sequence of safe, incremental improvements, each shippable on its own.*

## Assessment

**What's already good**
- Sensible domain (Meetings → Bottles → Ratings, wishlists, attendance).
- Eager-loading is used thoughtfully in most controllers (N+1 already considered).
- RSpec + FactoryBot in place with real model/controller coverage.
- Counter caches and a cached bottle average exist.

**Where it hurts (the refactor targets)**
1. **No safety net / quality tooling.** No RuboCop, Brakeman, SimpleCov, Bullet, or CI.
   Refactoring without these is flying blind.
2. **Fat `User` model.** `user.rb` (155 lines) holds heavy analytics with raw SQL
   (`golden_nose`, `tastemaker`, `favorite_bringer`, `taste_compatibility_with`,
   `find_closest_match`). Business/stats logic mixed with the ORM record.
3. **God action: `PublicController#stats`** — one action builds ~12 ad-hoc aggregate
   queries inline. Hard to read, test, or reuse.
4. **Duplicated logic.** The "bottles brought by a user" query
   (`meetings.bottle_bringer_id = ? OR bottles.user_id = ?`) is copy-pasted in
   `PublicController#index` and `UsersController#show`. Attendance-rate math is
   duplicated too.
5. **Leaky domain assumption.** `Meeting#bottle` = `bottles.first` — a single-bottle
   assumption threaded through views while `is_flight` meetings have many bottles.
6. **No authorization abstraction.** Ownership/role checks are hand-rolled inline
   (`unless current_user.id == @meeting.bottle_bringer_id`, the new `require_admin`,
   rating ownership). Fine at this size, but scattered.
7. **Large, logic-heavy views.** `meetings/index` (349), `bottles/_archive` (332),
   `public/stats` (308). Formatting/branching lives in ERB.
8. **Test gaps.** No system/feature specs (Capybara is installed but unused), so
   Hotwire flows (reveal, rate, attendance) aren't covered end-to-end.

---

## Guiding principles
- **One concern per PR.** Every phase below is independently shippable and revertible.
- **Green before and after.** Never refactor on red; add characterization tests first
  where coverage is thin.
- **Rails-native first.** Prefer scopes, query objects, POROs, and helpers over new
  frameworks. Introduce a gem only when it removes more code than it adds.

---

## Phase 0 — Safety net & guardrails *(do this first)*
Goal: make every later phase provably safe. No behavior change.

- Add **RuboCop** (`rubocop-rails`, `rubocop-rspec`, `rubocop-performance`) with
  `rubocop --auto-gen-config` to snapshot the current state in `.rubocop_todo.yml`;
  fix only trivially-safe offenses now, burn down the todo later.
- Add **Brakeman** (security) and **bundler-audit** — the invite-code / raw-SQL work
  makes this worthwhile.
- Add **SimpleCov** to see real coverage before touching anything.
- Add **Bullet** (dev/test) to surface N+1s objectively instead of guessing.
- Add a minimal **CI workflow** (`.github/workflows/ci.yml`): `rspec`, `rubocop`,
  `brakeman`. This is the biggest single quality win — it makes every future PR safe.
- **Files:** `Gemfile`, `.rubocop.yml`, `.github/workflows/ci.yml`, `spec/rails_helper.rb`.

## Phase 1 — Extract stats into query objects & a stats namespace
Goal: kill the God action and the fat-model SQL. Highest readability payoff.

- Create `app/queries/` (or `app/stats/`) POROs, one per metric or grouped sensibly:
  `Stats::TopBottle`, `Stats::ControversialBottle`, `Stats::RaterExtremes`,
  `Stats::BestMeeting`, `Stats::FavoriteDistillery`, plus move `golden_nose` /
  `tastemaker` off `User` into `Stats::GoldenNose` / `Stats::Tastemaker`.
- `PublicController#stats` becomes a thin assembler (or a single `ClubStats` facade
  object exposing memoized readers) — target ~10 lines.
- Move `favorite_bringer`, `find_closest_match`, `taste_compatibility_with` into a
  `Stats::TasteProfile.new(user)` PORO. `User` keeps only `full_name`,
  `wishlist_includes?`, associations, and `admin?`.
- **Write unit specs for each query object** (they're pure, easy to test) — this also
  backfills the missing stats coverage.
- **Files:** new `app/queries/**`, slim `app/models/user.rb`,
  `app/controllers/public_controller.rb`, `spec/queries/**`.

## Phase 2 — De-duplicate with scopes & consolidate domain logic
Goal: single source of truth for repeated queries and shared math.

- Add scopes to replace copy-paste:
  - `Bottle.brought_by(user)` → the `bottle_bringer_id OR bottles.user_id` query,
    used by `PublicController#index` and `UsersController#show`.
  - `Meeting.past` / reuse existing `past_meetings`; a `User#attendance_rate` (or
    `Attendance.new(user).rate`) for the duplicated percentage math.
- Reconsider **`Meeting#bottle`**: rename to `primary_bottle` and make the
  single-vs-flight distinction explicit, or push presentation of "the bottle(s)" into
  a presenter so views stop assuming one bottle.
- **Files:** `app/models/bottle.rb`, `app/models/meeting.rb`, `app/models/user.rb`,
  the two controllers, matching specs.

## Phase 3 — Authorization consolidation
Goal: one obvious place for "can this user do X".

- Introduce **Pundit** (lightweight, Rails-idiomatic). Start with the cases that
  already exist: `MeetingPolicy` (reveal = spirit guide only), `RatingPolicy`
  (edit own only), `Admin::UsersPolicy` (admin only), replacing the scattered inline
  checks in `bottles_controller#reveal`, `ratings_controller#update`, and
  `admin/users_controller`.
- Keep it minimal — only add policies for actions that already do an inline check.
- **Files:** `Gemfile`, `app/policies/**`, the three controllers, `spec/policies/**`.

## Phase 4 — View layer cleanup
Goal: shrink the big ERB files; move logic out of templates.

- Extract repeated markup into partials/helpers: the rating module, bottle cards,
  the stat tiles on `public/stats`, attendee lists.
- Move display logic (score formatting, "spirit guide" labels, badge classes) into
  **helpers or presenters** (e.g. `BottlePresenter`, `MeetingPresenter`) so ERB is
  markup, not branching. `ApplicationHelper` already has the right pattern
  (`friendly_date`, `form_input_classes`) — extend it.
- Optional: evaluate **ViewComponent** for the genuinely reusable pieces (stat tile,
  bottle card) — only if the partial+helper approach proves insufficient.
- **Files:** `app/views/meetings/index`, `app/views/bottles/_archive`,
  `app/views/public/stats`, new `app/presenters/**` or `app/helpers/**`.

## Phase 5 — Usability improvements
Goal: the "usability" half of the request. Prioritize by user pain.

- **Empty states & guidance:** friendly empty states for no-ratings / no-meetings /
  empty wishlist and stats-with-insufficient-data (many stats need ≥3 ratings and
  silently render nothing).
- **Feedback & affordances:** confirm dialogs consistency, disabled/loading states on
  Turbo actions (rate, reveal, attendance toggle), clearer flash copy.
- **Mobile nav:** the header menu is hand-rolled with inline `onclick`; move to a small
  Stimulus controller for reliability and accessibility (focus trap, `aria-expanded`).
- **Accessibility pass:** labels are frequently `sr-only` with visible text duplicated;
  audit form labels, color contrast on gold/green, and keyboard nav.
- **Stats legibility:** the stats page shows raw metrics; add short explanations
  ("≥3 ratings needed") and tooltips.
- **Files:** view partials, a new `app/javascript/controllers/*` Stimulus controller.

## Phase 6 — Test depth & performance verification
Goal: lock in the refactor and catch regressions.

- Add **system specs** (Capybara + headless Chrome) for the core Hotwire flows:
  schedule meeting → add bottle → reveal → rate → attendance/wishlist toggles.
- Turn on **Bullet in test** to fail on introduced N+1s (Phase 0 wired Bullet in
  but left `Bullet.raise = false`; flip it here once existing findings are triaged).
- Add DB indexes if Bullet/`EXPLAIN` reveal gaps (e.g. `ratings (user_id, bottle_id)`
  is already unique-indexed; verify `bottles.user_id`, `meetings.date`).
- **Files:** `spec/system/**`, `spec/rails_helper.rb`, a migration if indexes are needed.

## Phase 7 — Dependency & framework upgrade *(security debt — schedule deliberately)*
Goal: clear the CVE backlog that `bundle-audit` surfaces. As of Phase 0 the audit
reports **~83 known advisories**, almost all stemming from the EOL runtime/framework.
This is why the CI `bundle-audit` step is currently **report-only** (`continue-on-error`).

- **Ruby 3.2 → 3.3/3.4** (3.2 is past end-of-life). Update `.ruby-version` + Gemfile,
  reinstall, run the suite.
- **Rails 7.1 → 7.2, then 8.0** (7.1.5.1 is EOL). Use `rails app:update` and step the
  minor versions; the pre-existing Action View XSS, Active Storage, and DoS advisories
  require ≥ 7.2 / 8.0.
- **Patch-level gem bumps** for the many transitive CVEs (nokogiri, rack, puma, loofah,
  rexml, devise, net-imap, etc.) — mostly a `bundle update` per gem with the suite green.
- When the audit is clean, **remove `continue-on-error` from the bundle-audit CI step**
  and remove the `CheckEOLRuby` / `CheckEOLRails` skips from `config/brakeman.yml`.
- Do this in small, verifiable steps (one runtime/framework bump per PR), leaning on the
  Phase 0 CI + Phase 6 system specs as the safety net. Highest-risk phase — schedule it
  when there's time to test the app thoroughly, not alongside feature work.
- **Files:** `.ruby-version`, `Gemfile`, `Gemfile.lock`, `config/**` (framework
  defaults), `.github/workflows/ci.yml`, `config/brakeman.yml`.

---

## Suggested sequencing & sizing
| Phase | Theme | Risk | Rough size |
|-------|-------|------|-----------|
| 0 | Tooling / CI | none | S |
| 1 | Query objects, slim User | low | M |
| 2 | Scopes / de-dup | low | S |
| 3 | Pundit authz | low-med | M |
| 4 | View cleanup | low | M |
| 5 | Usability | low | M (iterative) |
| 6 | System specs / perf | low | M |
| 7 | Dependency & framework upgrade | high | L |

**Do Phase 0 first, then 1 and 2 (biggest code-quality wins), then pick between the
authz (3), view (4), and usability (5) tracks based on what you feel most day-to-day.**
Each phase is its own PR with green CI.

## Explicitly out of scope (for now)
- No framework swap (staying on Hotwire/Turbo, not adding React/API layer).
- No database restructuring beyond additive indexes.
- No premature ViewComponent/service-object adoption where a scope or helper suffices.
