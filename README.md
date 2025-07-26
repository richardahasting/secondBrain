# 2ndBrain 🧠

A conversational AI assistant with perfect memory - your personal digital companion that remembers everything and helps you make sense of your life.

## 🌟 Overview

2ndBrain is a privacy-first, locally-stored AI assistant that acts as your "second brain" - remembering every conversation, tracking your inventory, recognizing patterns in your life, and providing intelligent insights when you need them.

Created by Richard Hasting and Hal Fulton

## 🎯 Core Features

### 💬 Perfect Memory
- Remembers every conversation and detail
- Natural language interface - just talk naturally
- Instant retrieval of any information ever shared
- "Forget" keyword for selective memory management

### 📦 Smart Inventory Mode
- Track items by location (pantry, fridge, freezer, garage)
- Barcode scanning for quick entry
- Expiration date monitoring
- Automatic shopping list generation
- "What's in my pantry?" queries

### 🤖 AI-Powered Intelligence
- Pattern recognition in spending, habits, and mood
- Predictive insights ("When will I run out of coffee?")
- Complex analysis of your personal data
- Daily summaries and proactive suggestions
- Local LLM support for complete privacy

### 🔐 Privacy First
- All data stored locally on your devices
- No cloud storage required (optional sync available)
- Encrypted storage for sensitive information
- You control what the AI can access

## 📱 Platform Support

### Mobile (iOS/Android)
- Primary interface for daily use
- Voice input and location awareness
- Biometric security
- Barcode scanning for inventory

### 💻 Desktop (Windows/Mac/Linux)
- Power user interface
- Advanced search and analytics
- Bulk data import/export
- Full AI model support

### 🥧 Raspberry Pi
- Always-on home hub
- Voice-first interface
- Family shared memories
- USB barcode scanner support

## 🚀 Use Cases

- **Location Memory**: "Where did I put my passport?"
- **Personal Info**: Securely store passwords, account numbers, important dates
- **Life Tracking**: "When was my last haircut?", "How long since I saw Bob?"
- **Task Management**: Set reminders, track work hours, log expenses
- **Journaling**: Daily thoughts and experiences
- **Learning**: "What have I learned about Python this year?"
- **Health**: Track symptoms, medications, exercise patterns
- **Shopping**: Inventory tracking, consumption patterns, smart lists

## 🛠️ Technical Architecture

- **Frontend**: Flutter (mobile), Electron/Tauri (desktop), Web (Pi)
- **Core Engine**: Rust for cross-platform performance
- **Storage**: SQLite with full-text search
- **AI**: Local LLMs (Llama, Mistral) with RAG implementation
- **Sync**: Optional CRDT-based multi-device synchronization

## 📖 Documentation

- [CLAUDE.md](CLAUDE.md) - Development guide for Claude AI instances
- [designThoughts.md](designThoughts.md) - Detailed architectural decisions and design philosophy

## 🔮 Roadmap

### Phase 1: MVP (Current)
- Basic chat interface with memory
- Simple search functionality
- Local storage implementation

### Phase 2: Smart Features
- Inventory mode with barcode scanning
- AI pattern recognition
- Multi-platform support

### Phase 3: Advanced Intelligence
- Local LLM integration
- Predictive insights
- Home automation integration
- Family hub features

## 🤝 Contributing

This project is in early development. Contributions, ideas, and feedback are welcome!

## 📄 License

[License details to be determined]

---

*"Remember everything, forget nothing" - except when you really want to.*
