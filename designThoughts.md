# Design Thoughts for 2ndBrain

## Core Philosophy

The fundamental principle of 2ndBrain is **"remember everything, forget nothing"**. This drives all architectural decisions - we optimize for complete data retention and retrieval over storage efficiency.

### The "Forget" Keyword
While we remember everything, users need control:
- **"Forget"**: Marks information for exclusion from active memory
- **Privacy**: Some things should be truly forgotten
- **Corrections**: Override incorrect information without losing history
- **Selective Amnesia**: Choose what to actively remember vs archive

## Key Design Decisions

### 1. Local-First Architecture
- **Why**: Privacy is paramount. Users will store passwords, personal thoughts, and sensitive information.
- **Implications**: No default cloud sync, all processing on-device, encrypted storage
- **Trade-offs**: Single device limitation (initially), backup complexity

### 2. Unstructured Data Storage
- **Why**: Conversations are naturally unstructured. Forcing structure limits what can be remembered.
- **Approach**: Store raw conversation history with metadata
- **Benefits**: Flexibility, natural conversation flow, no data loss
- **Challenges**: Search complexity, storage growth, retrieval efficiency

### 3. Conversation as Primary Interface
- **Why**: Most natural for users, no learning curve
- **Implementation**: Chat UI with persistent message history
- **Features**: Natural language queries, contextual responses, conversation threading

## Multi-Platform Architecture

### Platform Targets
1. **Mobile (iOS/Android)**: Primary interface for most users
2. **Desktop (Windows/Mac/Linux)**: Power users, extended sessions
3. **Embedded (Raspberry Pi)**: Home hub, always-on assistant

### Shared Core Architecture
```
Platform-Agnostic Core:
├── Memory Engine (Rust/C++)
│   ├── Storage abstraction
│   ├── Search & indexing
│   ├── Encryption layer
│   └── Sync protocol
├── API Layer (REST/gRPC)
└── Platform-Specific UI
    ├── Flutter (Mobile)
    ├── Electron/Tauri (Desktop)
    └── Web Interface (Pi)
```

### Platform-Specific Considerations

#### Mobile (Phone/Tablet)
- **Constraints**: Battery life, storage limits, iOS background restrictions
- **Advantages**: Always with user, sensors, biometrics
- **Features**: Voice input, location awareness, camera for doc scanning
- **Storage**: SQLite with size management

#### Desktop (Computer)
- **Constraints**: Multiple user accounts, file system permissions
- **Advantages**: Unlimited storage, processing power, multi-window
- **Features**: File integration, advanced search UI, bulk import/export
- **Storage**: SQLite or embedded DB with no size limits

#### Embedded (Raspberry Pi)
- **Constraints**: Limited resources, headless operation
- **Advantages**: Always-on, home network integration, low power
- **Features**: Voice-first interface, home automation, family hub
- **Storage**: External SSD support, network backup

## Inventory & Consumption Tracking

### Smart Quantity Management
The system should understand quantity changes and make intelligent suggestions:

#### Example Flow:
1. User: "I placed three cans of pinto beans in the pantry" → System records: +3 pinto beans
2. User: "I used a can of pinto beans" (3 times) → System tracks: -1, -1, -1
3. Current state: 0 pinto beans (but remembers the history)
4. User: "What should I consider putting on my shopping list?"
5. System: "You used three cans of pinto beans in the last 4 weeks. You might want to obtain some more."

#### Implementation Concepts:
```
Inventory Tracking:
{
  item: "pinto beans",
  unit: "cans",
  transactions: [
    {date: "2024-05-01", change: +3, current_total: 3},
    {date: "2024-05-08", change: -1, current_total: 2},
    {date: "2024-05-15", change: -1, current_total: 1},
    {date: "2024-05-22", change: -1, current_total: 0}
  ],
  consumption_rate: 0.75 cans/week,
  last_depleted: "2024-05-22",
  suggested_reorder: true
}
```

### Shopping List Intelligence
- Track consumption patterns
- Predict when items will run out
- Suggest quantities based on usage
- Remember brand preferences
- Track price history if mentioned

### Natural Language Processing
- "Added 3 cans" → +3
- "Used one" → -1
- "Ate the last" → set to 0
- "Bought a dozen" → +12
- "Gave away half" → current / 2

## Special Inventory Mode

### Overview
A dedicated mode for comprehensive inventory management with location-based tracking, expiration dates, and barcode scanning.

### Activation & Usage
```
User: "Enter inventory mode" / "Start inventory" / "Inventory mode"
System: "Inventory mode active. Which location? (pantry, fridge, freezer, garage, etc.)"
User: "Pantry"
System: "Ready to inventory pantry. Say 'scan', 'add', 'remove', 'check', or 'done'."
```

### Input Modes

#### 1. Barcode Scanning (Mobile/Pi with camera)
```
User: "Scan"
System: [Activates camera for barcode scanning]
[Beep on successful scan]
System: "Campbell's Tomato Soup, 10.75 oz. How many?"
User: "3"
System: "Added 3 cans Campbell's Tomato Soup to pantry. Expires: Oct 2025"
```

#### 2. Voice/Text Entry
```
User: "Add 2 boxes of pasta"
System: "What type of pasta?"
User: "Penne"
System: "Added 2 boxes of penne to pantry. Any expiration date?"
User: "March 2025"
System: "Noted. 2 boxes penne expire March 2025"
```

#### 3. Bulk Import (Desktop)
- CSV import for initial inventory
- Receipt scanning and parsing
- Shopping app integration

### Output/Query Modes

#### 1. Location Queries
```
User: "What do I have in the pantry?"
System: "Pantry inventory (15 items):
- 3 cans pinto beans
- 2 boxes penne pasta (expires March 2025)
- 5 cans tomato soup (expires Oct 2025)
- ... [grouped by category]"

User: "What's in the freezer?"
System: "Freezer inventory (8 items):
- 2 lbs ground beef (added 2 weeks ago)
- 1 bag frozen peas
- ..."
```

#### 2. Expiration Tracking
```
User: "What's expiring soon?"
System: "Items expiring within 30 days:
- Milk in fridge (3 days)
- Yogurt in fridge (5 days)
- Bread in pantry (1 week)"
```

#### 3. Location Search
```
User: "Where do I have pasta?"
System: "Pasta found in:
- Pantry: 2 boxes penne, 1 box spaghetti
- Cabinet: 1 box mac and cheese"
```

### Data Structure
```
Inventory Item:
{
  id: unique_id,
  name: "Campbell's Tomato Soup",
  upc: "051000012616",
  locations: [{
    place: "pantry",
    quantity: 3,
    added_date: "2024-05-01",
    expiration: "2025-10-01",
    position: "top shelf, left"
  }],
  category: "canned goods",
  brand: "Campbell's",
  size: "10.75 oz",
  nutrition_info: {...},
  typical_locations: ["pantry"],
  purchase_history: [{store, price, date}]
}
```

### Barcode Integration

#### UPC Lookup Services
- OpenFoodFacts API (free, open-source)
- Barcode Lookup API 
- UPCitemdb API
- Local cache of scanned items

#### Scanning Features
- Continuous scan mode for rapid inventory
- Auto-quantity detection (scan multiple identical items)
- Unknown barcode learning (user provides details once)
- Receipt barcode parsing for bulk add

### Platform-Specific Features

#### Mobile
- Native camera barcode scanning
- Location-based reminders ("You're at grocery store, you need milk")
- Quick inventory widgets
- Share shopping list

#### Desktop  
- Webcam barcode scanning
- Bulk edit capabilities
- Advanced reporting (usage trends, cost analysis)
- Print inventory labels

#### Raspberry Pi
- USB barcode scanner support
- Kitchen display mode
- Voice-driven inventory
- Family member preferences

### Smart Features

#### Auto-categorization
- Learn where users typically store items
- Suggest storage locations based on item type
- Alert if item stored in unusual location

#### Predictive Stocking
- "You usually have 5 cans of soup but only have 2"
- Seasonal predictions
- Event-based stocking (holidays, parties)

#### Freshness Tracking
- FIFO (First In, First Out) recommendations
- Produce freshness estimates
- Leftover tracking

#### Recipe Integration
- "What can I make with what I have?"
- Missing ingredient detection
- Meal planning based on inventory

### Natural Language Examples
```
"Move the peanut butter from pantry to cabinet"
"I just used the last of the milk"
"How many cans of beans do I have total?"
"What proteins do I have?"
"Show me everything expiring this week"
"What did I buy last time I was at Costco?"
"How long has the leftover pizza been in the fridge?"
"Set low stock alert for coffee at 1 pound"
```

## AI-Powered Intelligence Layer

### Overview
Feed all stored memories to an AI model that can answer complex questions, identify patterns, and provide insights beyond simple keyword search.

### Architecture Approaches

#### 1. Local AI (Privacy-First)
```
Local LLM Options:
- Llama 2/3 (7B model fits on modern phones)
- Mistral 7B
- Phi-2 (Microsoft, 2.7B params)
- GGML format for efficient mobile/Pi deployment

Implementation:
- Desktop: Full model with GPU acceleration
- Mobile: Quantized models (4-bit)
- Pi: Lightweight models or API to desktop
```

#### 2. Hybrid Approach (Recommended)
```
Privacy Levels:
1. Sensitive queries → Local model only
2. General queries → Can use cloud API
3. User controls per-query or per-category

Architecture:
- Local embeddings for all data
- Local small model for basic queries
- Optional cloud API for complex analysis
```

### AI Query Examples

#### Pattern Recognition
```
User: "What patterns do you notice in my spending?"
AI: "Based on your logged expenses, you spend 40% more on weekends, 
particularly on dining out. Your grocery shopping peaks on Tuesdays."

User: "How has my mood been this month?"
AI: "Analyzing your journal entries, you've been notably happier on days 
you exercised. Stress mentions correlate with Monday meetings."
```

#### Predictive Insights
```
User: "When will I run out of coffee?"
AI: "Based on your consumption (mentioned 'made coffee' 12 times in 2 weeks), 
and you have 1/2 pound left, you'll need more in about 5 days."

User: "What should I prepare for next week?"
AI: "You have: dentist Tuesday (you mentioned tooth pain last week), 
Bob's birthday Thursday (gift?), and you're low on meal prep ingredients."
```

#### Complex Analysis
```
User: "What have I learned about Python in the last year?"
AI: "You've progressed from basic syntax questions to discussing decorators 
and async programming. Key growth areas: pandas (15 mentions), 
API development (8 projects mentioned), struggling with regex (6 complaints)."

User: "How can I optimize my routines?"
AI: "You're most productive 9-11am (based on completed tasks logged). 
You mention forgetting vitamins 3x/week - consider morning alarm. 
Your 'tired' mentions peak on days with <6 hours sleep logged."
```

### Implementation Strategy

#### 1. Embedding Generation
```python
# Generate embeddings for all memories
for memory in all_memories:
    embedding = model.encode(memory.content)
    store_embedding(memory.id, embedding)
```

#### 2. Context Window Management
```
Challenge: Years of data > model context limit
Solution: 
- RAG (Retrieval Augmented Generation)
- Semantic search for relevant memories
- Time-weighted relevance
- Category-based filtering
```

#### 3. Privacy-Preserving AI
```
Techniques:
- On-device processing
- Differential privacy for analytics
- Encrypted embeddings
- Federated learning (learn from patterns without exposing data)
```

### AI Features by Platform

#### Mobile
- Voice questions with AI responses
- Daily insights notification
- Pattern alerts ("You haven't called mom in 2 weeks")

#### Desktop
- Advanced analytics dashboard
- Custom report generation
- Bulk pattern analysis
- Model fine-tuning on personal data

#### Raspberry Pi
- Family insights ("We're eating out more than usual")
- Household patterns
- Proactive suggestions via speaker

### Natural Language Understanding Enhancements

#### Temporal Reasoning
```
"What did I do last Tuesday?" → AI understands relative dates
"How long since I..." → Calculates durations
"Compare this month to last" → Performs comparisons
```

#### Entity Resolution
```
"Bob" vs "Robert Smith" vs "Bob from work" → Same person
"Home" vs "my house" vs "123 Main St" → Same location
```

#### Implicit Information
```
User: "I put milk in fridge"
AI learns: User drinks milk, has a fridge, shops for groceries

User: "Feeling tired again"
AI tracks: Energy levels, potential patterns
```

### Privacy & Control

#### User Controls
- Per-category AI access (never analyze passwords)
- Confidence indicators on AI insights
- "Explain this insight" - show source memories
- Opt-in for each AI feature

#### Data Minimization
- Process locally when possible
- Aggregate before cloud processing
- Time-limited cloud data retention
- No permanent cloud storage

### Training & Personalization

#### Continuous Learning
- Learn user's terminology
- Adapt to communication style
- Improve accuracy over time
- Personalized insights

#### Feedback Loop
```
AI: "You seem stressed on Mondays"
User: "No, that's just how I talk about work"
AI: [Adjusts interpretation model]
```

## Technical Architecture Thoughts

### Storage Layer
```
Conversation Storage:
- Each message stored with timestamp, context, metadata
- Full-text indexing for search
- Separate encrypted storage for sensitive data
- Periodic compression of old conversations
- Platform-aware storage strategies

Potential Structure:
{
  id: unique_id,
  timestamp: datetime,
  type: "user" | "assistant",
  content: "raw message text",
  metadata: {
    tags: auto-generated tags,
    references: linked messages,
    category: auto-categorized type,
    device_origin: "phone" | "desktop" | "pi",
    sync_status: sync metadata
  },
  encrypted: boolean
}
```

### Memory Retrieval System
1. **Temporal Search**: "What did I say about X last week?"
2. **Contextual Search**: "Where did I put..." triggers location memory
3. **Associative Search**: Links related conversations
4. **Fuzzy Matching**: Handle typos, variations, synonyms
5. **Quantity Tracking**: Maintain running totals of consumables
6. **Depletion Analysis**: Track usage patterns over time

### Categories Auto-Detection
Based on conversation patterns, auto-categorize into:
- Locations (contains "where", "put", "left", etc.)
- Dates/Times (appointments, schedules)
- Personal Info (numbers, passwords)
- Ideas/Brainstorming
- Tasks/Reminders
- Journal Entries
- Inventory/Consumables (track quantities and usage)

## User Experience Considerations

### Privacy Indicators
- Clear visual indication when storing sensitive info
- Easy way to mark conversations as "extra private"
- Biometric lock for app access
- Secure export options

### Memory Aids
- "On this day" reminders
- Pattern detection ("You usually do X on Tuesdays")
- Proactive reminders based on conversation history
- Smart suggestions based on context

### Search UX
- Natural language search
- Filter by time range
- Filter by category
- Voice search option
- Search history

## Implementation Phases

### Phase 1: MVP (Single Platform)
- Basic chat interface (Flutter mobile first)
- Store all conversations locally
- Simple keyword search
- Local SQLite storage
- Basic encryption
- No sync capabilities

### Phase 2: Smart Memory & Multi-Platform
- Full-text search across all data
- Auto-categorization
- Temporal queries
- Context linking
- Export/Import
- Desktop app (Electron/Tauri)
- Basic sync protocol between devices

### Phase 3: Advanced Features & Pi Integration
- Voice interface (critical for Pi)
- Plugin system
- Sensor integration
- Full multi-device sync
- Raspberry Pi hub deployment
- Advanced AI features
- Home automation integration

## Technical Challenges to Solve

1. **Storage Growth**: Conversations accumulate quickly
   - Solution: Compression, archiving, smart pruning options
   - Platform-specific: Mobile pruning, desktop archiving, Pi external storage

2. **Search Performance**: Searching years of conversations
   - Solution: Indexing, caching, background processing
   - Platform-specific: Mobile incremental search, desktop full index, Pi cached results

3. **Context Understanding**: Knowing what "that" or "it" refers to
   - Solution: Conversation threading, reference tracking

4. **Privacy vs Convenience**: Encrypted data can't be searched easily
   - Solution: Secure index generation, on-device decryption

5. **Backup Without Cloud**: How to backup securely?
   - Solution: Encrypted local backups, optional secure cloud
   - Platform-specific: Mobile to desktop, desktop to Pi, Pi as backup hub

6. **Cross-Platform Sync**: Keeping memories consistent
   - Solution: Conflict-free replicated data types (CRDTs)
   - Selective sync (privacy levels)
   - Pi as central hub option

7. **Resource Constraints**: Pi has limited CPU/RAM
   - Solution: Lightweight models, efficient indexing
   - Offload heavy processing to desktop when available
   - Voice-optimized interface

## Data Models to Consider

### Conversation Model
- Messages collection
- Conversation threads
- User preferences
- System metadata

### Memory Index Model
- Searchable terms
- Category mappings
- Temporal indices
- Cross-references

### User Model
- Preferences
- Security settings
- Custom categories
- Recurring patterns

## Security Considerations

1. **Encryption at Rest**: All sensitive data encrypted
2. **Biometric Access**: Face/Touch ID for app
3. **Secure Categories**: Extra protection for passwords/secrets
4. **Export Security**: Encrypted backups only
5. **Memory Wiping**: Secure deletion options

## Performance Goals

- Instant message storage (< 100ms)
- Search results in < 500ms for recent data
- Background indexing for older data
- Smooth scrolling through years of history
- Minimal battery impact

## Future Possibilities

### AI Enhancements
- Predictive responses
- Smart summarization
- Pattern learning
- Proactive suggestions
- Local LLM on Pi/Desktop

### Integration Ideas
- Calendar sync
- Contact integration
- Location services (mobile)
- Photo memories
- Voice notes
- Smart home (Pi as hub)
- Car integration (via mobile)

### Advanced Features
- Multi-language support
- Collaborative memories (family brain on Pi)
- Time-based capsules
- Memory visualization
- Emotional tracking
- Cross-device handoff (start on phone, continue on desktop)

### Platform-Specific Innovations
#### Mobile
- Widget for quick capture
- Share extension for saving from other apps
- Background location memories
- Health data integration

#### Desktop  
- Browser extension for web memory
- File watch for document memories
- Multi-monitor memory workspace
- Advanced data analysis tools

#### Raspberry Pi
- Always-listening mode
- Home presence detection
- Environmental sensors
- Family message board
- Local network services

## Open Questions

1. How to handle conflicts between privacy and functionality?
2. What's the best way to handle data migration as schema evolves?
3. Should we support selective memory deletion or maintain immutability?
4. How to balance AI intelligence with privacy concerns?
5. What's the right level of structure vs flexibility?
6. How to handle sync conflicts between devices?
7. Should Pi act as central server or peer device?
8. How to manage different UI paradigms (touch vs keyboard vs voice)?
9. What's the right sync granularity (full sync vs selective)?
10. How to handle platform-specific features in shared codebase?

## Design Principles to Follow

1. **Privacy First**: Every feature must consider privacy implications
2. **Never Forget**: Default to keeping everything
3. **Fast Retrieval**: Finding memories should be instant
4. **Natural Interaction**: Feel like talking to a friend
5. **Secure by Default**: Encryption and protection built-in
6. **User Control**: Users decide what to remember/forget
7. **Offline First**: Full functionality without internet