# CabCompare iOS Frontend Plan

Voice-controlled cab comparison and booking interface built with
SwiftUI + ElevenLabs Agents SDK + ElevenLabs Components.

The iOS app acts as a conversational UI that sends user requests to the
agent and displays ride options returned from the backend. The backend
performs emulator orchestration and booking automation.

------------------------------------------------------------------------

# Objectives

The frontend should focus on three responsibilities:

1.  Voice and text conversation with the agent
2.  Display search progress and ride options
3.  Allow users to confirm bookings

Everything else happens in the backend.

------------------------------------------------------------------------

# Technology Stack

UI Framework SwiftUI

Voice Agent ElevenLabs Agents Swift SDK

Voice UI Components ElevenLabs Components Swift Examples: -
OrbVisualizer - Voice interaction components

Networking URLSession

Optional Apple Live Activities for ride status

------------------------------------------------------------------------

# App Architecture

Use a simple MVVM structure.

ios-app/ ├── App/ │ └── CabCompareApp.swift │ ├── Views/ │ ├──
ChatView.swift │ ├── SetupAppsView.swift │ ├── EmulatorStreamView.swift
│ ├── ResultsView.swift │ ├── BookingConfirmationView.swift │ ├──
Components/ │ ├── ChatBubble.swift │ ├── CabOptionCard.swift │ ├──
VoiceOrbView.swift │ ├── ViewModels/ │ ├── ChatViewModel.swift │ ├──
BookingViewModel.swift │ ├── SetupViewModel.swift │ ├── Services/ │ ├──
ElevenLabsService.swift │ ├── BackendAPI.swift │ ├──
LiveActivityService.swift │ └── Models/ ├── BookingRequest.swift ├──
CabOption.swift └── AppConfig.swift

------------------------------------------------------------------------

# Core UI Screens

## Chat Screen

Primary user interface.

The user speaks or types requests such as:

"I need a cab to the airport."

The agent gathers required information and sends the structured request
to the backend.

Layout:

  ------------
  CabCompare
  ------------

Chat bubbles

User "I need a cab to the airport"

Agent "Searching Uber and Lyft"

Ride option cards appear here

  -----------------------
  Text input Mic button
  -----------------------

Components:

ChatView ├── ScrollView │ ├── ChatBubble │ └── CabOptionCard │ ├──
TextInput └── VoiceOrbView

VoiceOrbView uses the ElevenLabs visualizer.

------------------------------------------------------------------------

# Voice Interface

Use ElevenLabs SDK for voice conversations.

The orb visualizer indicates listening and speaking states.

Listening Orb animation active

Agent speaking Orb pulsing

Idle Orb dimmed

------------------------------------------------------------------------

# Voice Service

Create a service wrapper around the ElevenLabs SDK.

ElevenLabsService

Responsibilities

-   Start conversation session
-   Stream microphone audio
-   Receive agent messages
-   Handle tool calls

Example interface

class ElevenLabsService: ObservableObject {

    func startConversation()

    func sendText(_ message: String)

    func stopConversation()

}

The service publishes:

messages conversationState agentEvents

The UI observes these updates.

------------------------------------------------------------------------

# Backend Communication

The agent triggers tools that map to backend endpoints.

Tools:

search_cabs confirm_booking

Backend API endpoints:

POST /booking/request POST /booking/confirm GET /health

------------------------------------------------------------------------

# Results View

After the backend finishes searching cab apps, results appear in the
chat.

Each ride option becomes a card.

Example card

UberX \$14 3 min away

\[ Book Ride \]

SwiftUI component

CabOptionCard

Example structure

struct CabOptionCard: View {

    let option: CabOption

    var body: some View {
        VStack {
            Text(option.name)
            Text(option.price)
            Text("\(option.etaMinutes) min away")

            Button("Book Ride") {
                confirm(option)
            }
        }
    }

}

------------------------------------------------------------------------

# Booking Confirmation

After confirmation, show a final booking state.

Ride Booked

UberX \$14 Driver arriving in 3 minutes

If available:

Driver name Vehicle License plate

------------------------------------------------------------------------

# Setup Flow

First-time users must connect cab apps.

This step lets them log in to their apps using a streamed emulator.

User flow

SetupAppsView ↓ Select Cab App ↓ Backend launches emulator ↓ Emulator
stream displayed ↓ User logs in

------------------------------------------------------------------------

# Emulator Streaming Screen

The emulator stream is displayed inside a web view.

Backend provides a streaming URL.

EmulatorStreamView └── WebView

Layout

  ---------------
  Login to Uber
  ---------------

\[ Live emulator screen \]

------------------------------------------------------------------------

------------------------------------------------------------------------

# Data Models

BookingRequest

struct BookingRequest: Codable {

    let userId: String
    let pickup: String
    let dropoff: String
    let passengers: Int?

}

CabOption

struct CabOption: Codable, Identifiable {

    let id = UUID()
    let name: String
    let price: String
    let etaMinutes: Int
    let appName: String

}

------------------------------------------------------------------------

# Live Activities (Optional)

Shows booking progress outside the app.

States

Searching rides Comparing prices Booking ride Ride confirmed

Dynamic Island example

Searching Uber and Lyft

After booking

UberX booked Driver arriving in 3 min

------------------------------------------------------------------------

# Application Flow

Launch ↓ Check configured apps

If none configured

SetupAppsView

Otherwise

ChatView

Conversation flow

User request ↓ ElevenLabs agent ↓ Backend orchestration ↓ Results
returned ↓ Results displayed ↓ User confirms ↓ Booking confirmed

------------------------------------------------------------------------

# Hackathon MVP

Minimum required screens

1 Chat screen 2 Voice interaction 3 Ride option cards 4 Booking
confirmation

Optional enhancements

-   Setup flow
-   Emulator streaming
-   Live activities
-   Search progress indicators

------------------------------------------------------------------------

# Demo Flow

1 Open the app 2 Tap the voice orb 3 Say: "I need a cab from Pearl
Street to Denver Airport. Cheapest option." 4 Show agents searching
multiple apps 5 Display ride options 6 Tap "Book Ride" 7 Show
confirmation

------------------------------------------------------------------------

# Visual Demo Enhancement

Display emulator thumbnails while searching.

Uber emulator Lyft emulator

This visually proves that multiple agents are running simultaneously.

------------------------------------------------------------------------

# Build Order

Step 1 Chat UI

Step 2 ElevenLabs SDK integration

Step 3 Results cards

Step 4 Backend API integration

Step 5 Booking confirmation

Step 6 Setup flow

Step 7 Live activities
