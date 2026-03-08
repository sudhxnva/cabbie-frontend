# Cabbie Frontend — Implementation Blueprint

This document defines the structure and requirements for the `cabbie-frontend` repository, ensuring 100% compatibility with the `cabbie` backend (Slice 3).

## Recommended File Structure (React + TypeScript)

```text
cabbie-frontend/
├── src/
│   ├── api/
│   │   └── booking.ts          # API client (Axios) for backend communication
│   ├── components/
│   │   ├── booking/
│   │   │   ├── BookingForm.tsx  # Pickup, Dropoff, Priority inputs
│   │   │   ├── LoadingState.tsx # High-quality "Agent Working" animations
│   │   │   └── RideCard.tsx     # Individual Uber/Lyft result card
│   │   └── ui/
│   │       ├── Button.tsx       # Reusable styled buttons
│   │       └── Input.tsx        # Reusable styled inputs
│   ├── hooks/
│   │   └── useBooking.ts       # Custom hook for managing booking state/API calls
│   ├── types/
│   │   └── booking.ts          # TypeScript interfaces (Mirror backend types)
│   ├── App.tsx                 # View Orchestrator (Home -> Loading -> Results)
│   └── App.css                 # Modern, polished Vanilla CSS
├── .env                        # REACT_APP_API_URL=http://localhost:3000
```

## Core Implementation Guide

### 1. Data Contracts (src/types/booking.ts)
Must match `CLAUDE.md` exactly:
- `BookingRequest`: userId, pickup, dropoff, constraints (priority).
- `RankedResult`: appName, name, price, etaMinutes, category.

### 2. API Integration (src/api/booking.ts)
- Use **Axios** with a `timeout: 200000` (200 seconds).
- `POST /booking/request` -> Returns `RankedResult[]`.

### 3. The "Agentic" Loading Experience
Since the backend takes ~3 minutes (Claude agents at work), show progress:
- **Phase 1**: "Connecting to Android Emulators..."
- **Phase 2**: "Uber Agent is checking prices..."
- **Phase 3**: "Lyft Agent is calculating ETA..."
- **Phase 4**: "Ranking the best rides for you..."

## Required Packages
Run this in your frontend repo:
```bash
npm install axios lucide-react framer-motion
```
