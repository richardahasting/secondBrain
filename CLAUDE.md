# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository implements "2ndBrain" - a conversational AI assistant with exceptional memory capabilities. Created by Richard Hasting and Hal Fulton, the core concept is an AI that "remembers every single thing" from conversations, storing all data locally in an unstructured format.

## MVP Definition

The minimum viable product is a purely conversational chat agent that:
- Remembers every single interaction and piece of information
- Stores all data locally (privacy-focused)
- Uses totally unstructured data storage
- Provides natural conversational interface

## Core Use Cases

The 2ndBrain assistant should handle these primary functions:

### Information Storage & Retrieval
- **Locations**: "Where did I put my passport/hard drive/keys?"
- **Numbers**: Bank accounts, serial numbers, VINs
- **Secrets**: Passwords, PINs, secure information
- **History**: "When was my last haircut?", "When did I last see Bob?", "How long since that trip?"
- **Inventory**: Track quantities of items, consumption rates, and shopping needs
- **Forget Function**: Selective memory management with "forget" keyword

### Time & Task Management
- **Alarms/Timers**: Set alarms, timers, track durations
- **Calendar**: Track appointments, birthdays, events
- **Log**: Work hours, expenses, maintenance (e.g., "Rotated tires")
- **Journal**: Daily entries and personal notes

### Creative & Productivity
- **Brainstorming**: Store and develop ideas, retrieve previous thoughts
- **Chatting**: Contextual conversations that reference previous discussions
- **Data Monitoring**: Track stocks, crypto, prices
- **Reader**: Find articles, summarize PDFs
- **Stream Buddy**: Media playback management
- **Stenographer**: Transcribe and save conversations
- **Secretary**: Dictate emails, texts, voice messages

### Special Inventory Mode
- **Activation**: "Enter inventory mode" to start location-based tracking
- **Barcode Scanning**: UPC scanning for quick item entry (mobile/Pi)
- **Location Queries**: "What's in the pantry/fridge/freezer?"
- **Expiration Tracking**: Monitor freshness and expiration dates
- **Smart Shopping**: Generate lists based on consumption patterns
- **Multi-location**: Track items across pantry, fridge, freezer, garage, etc.

### AI-Powered Intelligence
- **Pattern Recognition**: "What patterns do you see in my spending/mood/habits?"
- **Predictive Insights**: "When will I run out of coffee?", "What should I prepare for?"
- **Complex Analysis**: "How have my skills progressed?", "Optimize my routines"
- **Smart Summaries**: "What happened last month?", "Key insights from my journal"
- **Relationship Tracking**: "How often do I contact mom?", "Who haven't I seen lately?"
- **Health Insights**: "Correlate my energy levels with sleep/diet/exercise"

## Development Setup

The project targets multiple platforms:

### Mobile App (Flutter)
```bash
# Create Flutter project structure
flutter create . --project-name second_brain

# Get dependencies
flutter pub get

# Run the application
flutter run

# Run tests
flutter test

# Build for production
flutter build apk  # Android
flutter build ios  # iOS
```

### Desktop App (Electron/Tauri)
```bash
# For Electron approach
npm init
npm install electron

# For Tauri approach (recommended for performance)
cargo install tauri-cli
npm install @tauri-apps/cli
npm run tauri init
```

### Raspberry Pi (Web Interface + Services)
```bash
# Python backend with web interface
pip install flask sqlite3 
python app.py

# Or Node.js approach
npm install express sqlite3
node server.js
```

### Inventory Mode Commands
```bash
# Example inventory queries
"Enter inventory mode"
"What's in the pantry?"
"Scan" (activates barcode scanner)
"Add 3 cans of tomato soup to pantry"
"What's expiring soon?"
"Show shopping list"
"What can I make with what I have?"
```

## Architecture Considerations

### Multi-Platform Core
- Shared memory engine (consider Rust for performance and cross-platform)
- Platform-specific UIs (Flutter mobile, Electron/Tauri desktop, Web for Pi)
- Unified data format for cross-device compatibility
- Sync protocol for multi-device usage

### Data Storage
- Use local-only storage (SQLite, Hive, or similar)
- Implement full-text search across all stored conversations
- Design flexible schema to handle unstructured data
- Ensure data encryption for sensitive information
- Platform-aware storage strategies (mobile constraints vs desktop freedom)

### Memory System
- Store complete conversation history
- Implement intelligent retrieval based on context
- Design efficient indexing for quick searches
- Handle data categorization automatically
- Cross-device memory continuity
- Track quantities and consumption patterns
- Support "forget" keyword for selective memory management
- Intelligent suggestions based on usage patterns (e.g., shopping lists)
- AI-powered pattern recognition and insights
- Local LLM integration for privacy-preserving intelligence
- RAG (Retrieval Augmented Generation) for contextual AI responses

### Privacy & Security
- All data stored locally on device
- Implement encryption for sensitive data
- No cloud sync by default
- Export/backup functionality with encryption
- Device-specific security (biometrics on mobile, keychain on desktop)

## Platform-Specific Features

### Mobile (Phone/Tablet)
- Always-with-you memory capture
- Voice input and location awareness
- Biometric security
- Background sync to other devices

### Desktop (Computer)
- Power user interface
- Bulk import/export
- Advanced search and analysis
- File and browser integration

### Raspberry Pi (Home Hub)
- Always-on availability
- Voice-first interface
- Family shared memories
- Home automation integration

## Future Enhancements (Post-MVP)

- Phone sensor integration (GPS, accelerometer, time)
- Plugin system for external services (Amazon, eBay, Wikipedia)
- Smart home device integration via Pi
- Advanced voice interface on all platforms
- Seamless multi-device sync with privacy controls
- Local LLM deployment on Pi/Desktop for offline AI