# Met Collection

A browsable gallery of the Metropolitan Museum of Art's open collection, built with Ruby on Rails and Stimulus JS. Artworks are searchable and filterable by department, with paginated results loaded over the wire — no full page reloads, no client-side state management, no JS framework overhead. File store caching in development (Redis in production) keeps repeated API calls fast. Lighthouse performance and accessibility scores both above 95.

## Live Demo

_Coming soon_

## Tech Stack

- **Ruby on Rails 7.1** — MVC framework
- **Stimulus JS** — lightweight JavaScript controllers
- **Tailwind CSS 4** — utility-first styling
- **Importmap** — no-build JS module loading
- **PostgreSQL** — database
- **Met Museum Open Access API** — artwork data (no API key required)

## Architecture Decisions

### Stimulus JS over React / Vue

We chose Stimulus over React/Vue because of its simplicity and speed in rendering HTML over the wire. Stimulus combined with the native fetch API allows us to swap HTML directly into the page without having to parse JSON on the client side. This allows our app to have the feel and speed of a single page application without the overhead of a virtual DOM, client-side routing, or state management layer.

### Importmap over Webpack

We chose Importmap over Webpack because this project has no complex dependency tree requiring a bundler. Importmap leverages native ES modules in modern browsers, eliminating the build step entirely. We kept the development environment simple and the production asset delivery fast, with each file cached independently by the browser.

### Service Object Pattern

We used a `MetApiService` to keep controllers thin — their job is to handle requests and delegate logic, not to know how to communicate with an external API. Keeping the API logic in one place means it can be reused across multiple actions, the caching strategy is fully encapsulated rather than scattered across the app, and any API-specific errors are easy to isolate and debug.

### Caching Strategy

We use file store caching locally and Redis in production. File store allows us to test and debug how the app responds with cached results versus without. Redis is required in production to prevent cached results from disappearing if the server restarts.

The caching strategy protects the app from API latency and downtime — once results have been fetched, subsequent requests are served instantly. We use two different expiry times based on how frequently the data changes:

- **Search results** — 24 hours, to pick up any newly added artworks
- **Individual artworks** — 1 month, since an artwork's title, medium, and dimensions rarely change

Cache keys are namespaced with a `met-api/` prefix and structured as `met-api/search/{query}/{department}` and `met-api/objects/{id}`. This makes entries descriptive and debuggable, and allows selective cache clearing without touching unrelated cache entries.

### HTML over the Wire for Pagination

We used HTML over the wire for the load more feature. The `more` action renders a partial collection — not a full page, not JSON — and serves just the card fragments needed, which Stimulus then appends to the results grid. This keeps the server doing the rendering work and the client doing the minimum.

### Plain Ruby Model (PORO)

We used a Plain Old Ruby Object (PORO) for the `Artwork` model rather than an ActiveRecord model backed by a database table. This gives us clean attribute access and encapsulated logic without ActiveRecord's overhead. All artwork data comes from the Met API and is handled through caching — there is no need to persist records locally.

## Local Setup

### Prerequisites

- Ruby 3.3.0
- PostgreSQL
- Bundler

### Installation

```bash
# Clone the repository
git clone git@github.com:DylanWeinberger/Met-Collection.git
cd Met-Collection

# Install dependencies
bundle install

# Set up the database
rails db:create
rails db:migrate
```

> **Note:** This app uses no local database tables — all artwork data comes from the Met Museum Open Access API. The database is required only to satisfy Rails defaults.

### SSL Certificate Issues (macOS)

If you encounter SSL certificate errors when making API requests, you may need to sync your macOS keychain certificates with Ruby's OpenSSL store. See [openssl-osx-ca](https://github.com/raggi/openssl-osx-ca) for the recommended fix.

### Running the App

```bash
bin/dev
```

Visit `http://localhost:3000`

### Enable Caching (Optional but Recommended)

```bash
bin/rails dev:cache
```

Without this, every request hits the Met API directly. With caching enabled, repeated searches are served instantly from the file store.

## Future Improvements

- Switch to Redis caching in production
- Add department filter to the load more flow
- Artwork detail page image zoom
- Skeleton loading states while API results are fetched
- Test coverage for the service layer
