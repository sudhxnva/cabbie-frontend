# Cabbie Frontend

> Voice-first cab price comparison and booking interface powered by AI agents.

<div align="center">
  <a href="https://www.youtube.com/watch?v=ibSTQ5sBlCk">
    <img src="https://img.youtube.com/vi/ibSTQ5sBlCk/maxresdefault.jpg" alt="Cabbie Demo" width="720" />
  </a>
</div>

---

Cabbie lets you compare Uber and Lyft prices in real time using nothing but your voice. Speak your pickup and dropoff locations, choose a ride preference, and the AI agent handles the rest — navigating the actual apps on a real Android device to fetch live prices.

---

## Overview

The frontend is a React + TypeScript single-page app with a conversational interface built on ElevenLabs voice agents. It pairs with the Cabbie backend, which orchestrates Claude AI agents running on a connected Android phone to compare rides across Uber and Lyft.

**How it works:**

1. User speaks (or types) their trip — e.g. _"From Union Square to SFO, cheapest"_
2. ElevenLabs voice agent parses the request and calls the backend
3. Backend dispatches Android AI agents to open Uber/Lyft and scrape live prices
4. Frontend polls for results and displays ranked ride options
5. User selects a ride; the agent confirms the booking on-device

---

## Features

- **Voice-first UI** — WebRTC microphone integration via ElevenLabs, with animated waveform and speaking indicators
- **Text fallback** — Type your trip in `from X to Y, priority` format when mic is unavailable
- **Live price polling** — Polls backend every 2.5s until results are ready (up to 200s timeout)
- **Multi-provider comparison** — Ranks Uber and Lyft options side-by-side with price and ETA
- **Booking confirmation** — Displays booking reference, provider, price, and ETA on success
- **Responsive mobile layout** — Optimized for 430px viewport with safe area inset support
- **Dark glassmorphism design** — Purple accent palette, backdrop blur, smooth Framer Motion animations

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | React 19, TypeScript |
| Build Tool | Vite |
| Voice Agent | ElevenLabs (`@elevenlabs/react`) |
| HTTP Client | Axios |
| Animations | Framer Motion |
| Icons | Lucide React |
| Deployment | Nginx on Alpine Linux |

---

## Getting Started

### Prerequisites

- Node.js 18+
- A running instance of the [Cabbie backend](https://github.com/sudhxnva/cabbie)
- An ElevenLabs account with a configured voice agent

### Installation

```bash
git clone https://github.com/sudhxnva/cabbie-frontend
cd cabbie-frontend
npm install
```

### Environment Setup

Create a `.env` file in the project root:

```env
VITE_ELEVENLABS_AGENT_ID=your_elevenlabs_agent_id
VITE_BACKEND_URL=http://localhost:3001
```

| Variable | Description |
|---|---|
| `VITE_ELEVENLABS_AGENT_ID` | ElevenLabs agent ID for voice conversation |
| `VITE_BACKEND_URL` | URL of the Cabbie backend server |

### Development

```bash
npm run dev
```

Opens at `http://localhost:5173`. Requires the backend to be running on `VITE_BACKEND_URL`.

### Production Build

```bash
npm run build      # Compile TypeScript and bundle with Vite
npm run preview    # Preview the production build locally
```

---

## Deployment

The repo includes an Alpine Linux deployment script and Nginx configuration.

```bash
# On your VPS (Alpine Linux)
bash deploy.sh
```

The included `nginx.conf` configures:
- Gzip compression
- Static asset caching (6 months)
- Client-side routing via `try_files $uri /index.html`


---

## Backend API

The frontend communicates with three backend endpoints:

| Endpoint | Method | Description |
|---|---|---|
| `/booking/request` | POST | Submit pickup, dropoff, and priority |
| `/booking/status/:sessionId` | GET | Poll for ride results |
| `/booking/confirm` | POST | Confirm the selected ride option |

### Ride Option Schema

```typescript
interface RideOption {
  optionId: string       // Unique ID for selection
  name: string           // e.g. "UberX", "Lyft Standard"
  appName?: string       // "Uber" or "Lyft"
  price: string          // e.g. "$12.50"
  priceMin?: number      // Lower bound for price ranges
  etaMinutes: number     // Estimated pickup time in minutes
  category: string       // standard | comfort | xl | luxury | eco | free
}
```

---

## ElevenLabs Agent Integration

The voice agent drives the UI via two tool calls:

- **`show_options`** — Populates the ride selection list with results
- **`show_confirmation`** — Triggers the booking confirmed screen

The frontend uses the `useConversation` hook from `@elevenlabs/react` to manage the WebRTC connection lifecycle and handle incoming tool calls.

---

## Scripts

```bash
npm run dev       # Start development server
npm run build     # Production build
npm run preview   # Preview production build
npm run lint      # Run ESLint
```

---

*Built for HackCU*
