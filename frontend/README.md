This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://nextjs.org/docs/app/api-reference/cli/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
```

The development server will start on the port specified in your `.env.local` file (`NEXT_FRONTEND_PORT` variable). If not specified, it defaults to port 3000.

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result (replace 3000 with your configured port if different).

You can start editing the page by modifying `app/page.tsx`. The page auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.

## Project Configuration

This frontend application is configured using environment variables defined in `.env.local`. The application reads the following variables:

- `NEXT_PUBLIC_PROJECT_NAME`: The name of your project (default: "TheSuperProject")
- `NEXT_PUBLIC_API_PREFIX`: The prefix for API routes (default: "/api/v1")
- `NEXT_PUBLIC_API_URL`: The URL of your backend API (default: "http://localhost:2000")
- `NEXT_FRONTEND_PORT`: The port on which the frontend runs (default: "3000")

These variables are accessible through the configuration module at `src/lib/config.ts`.

## Project Structure

- `src/app/page.tsx` - Home page with links to login and dashboard
- `src/app/login/page.tsx` - Login and registration page
- `src/app/dashboard/page.tsx` - Protected dashboard page showing user profile
- `src/app/globals.css` - Global CSS styles with Tailwind configuration
- `src/lib/config.ts` - Configuration module that loads environment variables
- `src/lib/hooks/useConfig.ts` - Custom hook to access configuration in components

## Authentication

This frontend application integrates with a FastAPI backend for user authentication:

1. Users can register with email, password, first name, last name, and optional phone number
2. Users can log in with email and password
3. Authentication tokens are stored in localStorage
4. Protected routes check for valid authentication tokens

## User Profile

The dashboard page displays the user's profile information including:
- First name and last name
- Full name
- Email address
- Phone number (if provided)
- User role (user, mod, admin, superadmin)

Profile data is retrieved from the backend API and displayed in a responsive grid layout.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.