# KAWANG

This repository currently contains the KAWANG admin frontend. It is used to manage products, account pools, gift/CDKEY records, orders, and notices from a single dashboard.

## Repository Layout

- `admin/`: Vue 3 + TypeScript + Vite admin application
- `admin/src/pages/`: page views such as login, products, accounts, gifts, orders, and notices
- `admin/src/api/`: API wrappers for backend requests
- `admin/src/router/`: routes and auth guard

## Tech Stack

- Vue 3
- TypeScript
- Vite
- Element Plus
- Vue Router
- Pinia
- Axios

## Local Development

Requirements:

- Node.js 20+ or 22+
- npm
- a running backend service

Start the admin app:

```bash
cd admin
npm install
npm run dev
```

Default local URL:

```text
http://127.0.0.1:5174
```

## Backend Integration

During development, Vite proxies `/api` requests to:

```text
http://localhost:8080
```

The proxy is configured in `admin/vite.config.ts`.

The frontend API base path is:

```text
/api/admin
```

The current codebase expects backend resources such as:

- `/auth/login`
- `/auth/me`
- `/products`
- `/accounts`
- `/gifts`
- `/orders`
- `/notices`

## Available Scripts

Run these inside `admin/`:

```bash
npm run dev
npm run build
npm run preview
npm run type-check
```

## Auth Notes

- The login token is stored in browser `localStorage`
- Token key: `kawang_admin_token`
- Profile cache key: `kawang_admin_profile`
- When an API call returns `401`, the frontend clears local auth state and redirects to `/login`

## Notes

- This repository currently includes the admin frontend only
- Local secrets, editor folders, dependencies, build outputs, and dev logs are excluded by `.gitignore`
