# Cabbie Frontend 🚖

The voice-controlled, agent-powered cab price comparison and booking system. This repository contains the React + TypeScript frontend for the Cabbie project.

## Project Overview

Cabbie uses Claude Agents to navigate real Android apps (Uber, Lyft) to compare prices and book rides. The frontend provides a modern, high-quality interface for users to:
- Input pickup/dropoff locations.
- Set ride constraints (Cheapest, Fastest, Comfort).
- Monitor the real-time "agentic" search process.
- View and book ranked ride options.

## Features

- **Agentic Loading State**: Visualizes the multi-step orchestration process (launching emulators, agent navigation, screen OCR).
- **Dynamic Results**: Displays real-time data from Uber and Lyft side-by-side.
- **Smart Ranking**: Prioritizes rides based on user-defined constraints.
- **Modern UI**: Built with React, TypeScript, and Framer Motion for a polished hackathon aesthetic.

## Tech Stack

- **Framework**: React 18+ (Vite)
- **Language**: TypeScript
- **Styling**: Vanilla CSS (Custom Variables)
- **Icons**: Lucide React
- **Animations**: Framer Motion
- **API Client**: Axios

## Getting Started

### 1. Prerequisites
Ensure you have the [Cabbie Backend](https://github.com/sudhxnva/cabbie) running on `http://localhost:3000`.

### 2. Installation
```bash
npm install
```

### 3. Environment Setup
Create a `.env` file in the root directory:
```text
VITE_API_URL=http://localhost:3000
```

### 4. Run Development Server
```bash
npm run dev
```
Open `http://localhost:5173` in your browser.

## Data Integration

The frontend communicates with the backend via two primary endpoints:
- `POST /booking/request`: Triggers the 180s orchestration flow.
- `POST /booking/confirm`: Confirms the selected ride option.

---
*Built for HackCU by Claude Agents*
