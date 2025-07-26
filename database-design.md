# 2ndBrain Database Design (UML Style)

This document provides a visual representation of the 2ndBrain database schema using UML-style notation and entity relationship diagrams.

## Entity Relationship Overview

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              2ndBrain Database Schema                                │
│                                                                                     │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐                │
│  │    DEVICES      │────│  CONVERSATIONS  │────│    MESSAGES     │                │
│  │                 │    │                 │    │                 │                │
│  │ + id (PK)       │    │ + id (PK)       │    │ + id (PK)       │                │
│  │ + name          │    │ + title         │    │ + content       │                │
│  │ + type          │    │ + started_at    │    │ + timestamp     │                │
│  │ + last_seen     │    │ + device_id (FK)│    │ + conv_id (FK)  │                │
│  └─────────────────┘    │ + archived      │    │ + device_id (FK)│                │
│                         │ + forgotten     │    │ + type          │                │
│                         └─────────────────┘    │ + forgotten     │                │
│                                                │ + vector_id     │                │
│                                                └─────────────────┘                │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

## Core Domain Model

### Conversation Management Domain

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           CONVERSATION MANAGEMENT                                   │
└─────────────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────┐
    │    DEVICES      │
    │─────────────────│
    │ + id: TEXT      │◄──┐
    │ + name: TEXT    │   │
    │ + type: ENUM    │   │ 1:N
    │ + last_seen: TS │   │
    │ + created_at: TS│   │
    └─────────────────┘   │
                          │
    ┌─────────────────┐   │
    │ CONVERSATIONS   │───┘
    │─────────────────│
    │ + id: INTEGER   │◄──┐
    │ + title: TEXT   │   │
    │ + started_at: TS│   │ 1:N
    │ + last_msg_at:TS│   │
    │ + device_id: FK │   │
    │ + archived: BOOL│   │
    │ + forgotten:BOOL│   │
    └─────────────────┘   │
                          │
    ┌─────────────────┐   │
    │    MESSAGES     │───┘
    │─────────────────│
    │ + id: INTEGER   │
    │ + conversation_id:FK│
    │ + content: TEXT │
    │ + timestamp: TS │
    │ + type: ENUM    │
    │ + device_id: FK │
    │ + forgotten:BOOL│
    │ + vector_id: REF│
    │ + metadata: JSON│
    └─────────────────┘
            │ M:N
            ▼
    ┌─────────────────┐         ┌─────────────────┐
    │MESSAGE_CATEGORIES│◄────────│   CATEGORIES    │
    │─────────────────│         │─────────────────│
    │ + message_id: FK│         │ + id: INTEGER   │
    │ + category_id:FK│         │ + name: TEXT    │
    │ + confidence:REAL│        │ + description   │
    └─────────────────┘         │ + color: TEXT   │
                                │ + created_at: TS│
                                └─────────────────┘
            │ M:N
            ▼
    ┌─────────────────┐         ┌─────────────────┐
    │MESSAGE_KEYWORDS │◄────────│    KEYWORDS     │
    │─────────────────│         │─────────────────│
    │ + message_id: FK│         │ + id: INTEGER   │
    │ + keyword_id: FK│         │ + keyword: TEXT │
    │ + position: INT │         │ + normalized    │
    │ + context: TEXT │         │ + frequency: INT│
    │ + relevance:REAL│         │ + first_used: TS│
    └─────────────────┘         │ + last_used: TS │
                                └─────────────────┘
```

### Inventory Management Domain

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                            INVENTORY MANAGEMENT                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────┐         ┌─────────────────┐
    │   LOCATIONS     │         │ ITEM_CATEGORIES │
    │─────────────────│         │─────────────────│
    │ + id: INTEGER   │         │ + id: INTEGER   │
    │ + name: TEXT    │         │ + name: TEXT    │
    │ + description   │         │ + parent_id: FK │◄──┐ SELF
    │ + parent_id: FK │◄──┐     │ + created_at: TS│   │ REFERENCING
    │ + created_at: TS│   │     └─────────────────┘   │ (Hierarchy)
    └─────────────────┘   │                           │
            │ 1:N         │                           ▼
            ▼             │
    ┌─────────────────┐   │     ┌─────────────────┐
    │   INVENTORY     │───┘     │     ITEMS       │
    │─────────────────│         │─────────────────│
    │ + id: INTEGER   │◄────────│ + id: INTEGER   │
    │ + item_id: FK   │ 1:N     │ + name: TEXT    │
    │ + location_id:FK│         │ + brand: TEXT   │
    │ + quantity: REAL│         │ + size: TEXT    │
    │ + expiry_date:TS│         │ + unit: TEXT    │
    │ + purchase_date │         │ + barcode: TEXT │
    │ + purchase_price│         │ + category_id:FK│──┐
    │ + purchase_store│         │ + nutrition: JSON│  │
    │ + notes: TEXT   │         │ + typical_locs:JSON│ │
    │ + last_updated  │         │ + created_at: TS│  │
    │ + device_id: FK │         └─────────────────┘  │
    └─────────────────┘                              │
            │ 1:N                                    │
            ▼                                        │
    ┌─────────────────┐                              │
    │INV_TRANSACTIONS │                              │
    │─────────────────│                              │
    │ + id: INTEGER   │                              │
    │ + item_id: FK   │──────────────────────────────┘
    │ + location_id:FK│
    │ + change_amount │
    │ + prev_quantity │
    │ + new_quantity  │
    │ + trans_type:ENUM│
    │ + timestamp: TS │
    │ + device_id: FK │
    │ + notes: TEXT   │
    │ + conv_msg_id:FK│───┐
    └─────────────────┘   │ (Links to conversation
                          │  that triggered change)
                          ▼
                    ┌─────────────────┐
                    │    MESSAGES     │
                    └─────────────────┘
```

### AI and Pattern Recognition Domain

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                          AI & PATTERN RECOGNITION                                   │
└─────────────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────┐
    │   EMBEDDINGS    │
    │─────────────────│
    │ + id: UUID      │
    │ + content_type  │
    │ + content_id: INT│───┐ (References various
    │ + embedding:BLOB│   │  content types)
    │ + model_name    │   │
    │ + created_at: TS│   │
    └─────────────────┘   │
                          │
    ┌─────────────────┐   │
    │    PATTERNS     │   │
    │─────────────────│   │
    │ + id: INTEGER   │   │
    │ + name: TEXT    │   │
    │ + description   │   │
    │ + pattern_type  │   │
    │ + confidence    │   │
    │ + data: JSON    │   │
    │ + first_detected│   │
    │ + last_updated  │   │
    │ + active: BOOL  │   │
    └─────────────────┘   │
                          │
    ┌─────────────────┐   │
    │    INSIGHTS     │   │
    │─────────────────│   │
    │ + id: INTEGER   │   │
    │ + title: TEXT   │   │
    │ + content: TEXT │   │
    │ + insight_type  │   │
    │ + category: TEXT│   │
    │ + confidence    │   │
    │ + support_data  │───┘ (JSON refs to patterns,
    │ + created_at: TS│      messages, etc.)
    │ + presented_at  │
    │ + user_feedback │
    │ + dismissed     │
    └─────────────────┘
```

### Keyword Indexing System

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              KEYWORD INDEXING SYSTEM                                │
└─────────────────────────────────────────────────────────────────────────────────────┘

                        ┌─────────────────┐
                        │    KEYWORDS     │ ◄─── CENTRAL KEYWORD REGISTRY
                        │─────────────────│
                        │ + id: INTEGER   │
                        │ + keyword: TEXT │
                        │ + normalized    │
                        │ + frequency: INT│
                        │ + first_used: TS│
                        │ + last_used: TS │
                        └─────────────────┘
                                │ 1:N to all keyword junction tables
          ┌─────────────────────┼─────────────────────┐
          │                     │                     │
          ▼                     ▼                     ▼
┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐
│MESSAGE_KEYWORDS │   │ ITEM_KEYWORDS   │   │ENTITY_KEYWORDS  │
│─────────────────│   │─────────────────│   │─────────────────│
│ + message_id: FK│   │ + item_id: FK   │   │ + entity_id: FK │
│ + keyword_id: FK│   │ + keyword_id: FK│   │ + keyword_id: FK│
│ + position: INT │   │ + source: ENUM  │   │ + source: ENUM  │
│ + context: TEXT │   └─────────────────┘   └─────────────────┘
│ + relevance:REAL│
└─────────────────┘

┌─────────────────┐   ┌─────────────────┐
│CONVERSATION_KW  │   │ INSIGHT_KW      │
│─────────────────│   │─────────────────│
│ + conv_id: FK   │   │ + insight_id: FK│
│ + keyword_id: FK│   │ + keyword_id: FK│
│ + frequency: INT│   │ + source: ENUM  │
│ + last_mention  │   └─────────────────┘
└─────────────────┘

SEARCH CAPABILITIES:
• Find all messages containing "beans"
• Find all items related to "pantry"
• Find all entities of type "person" with keyword "Bob"
• Cross-reference keywords across all content types
• Track keyword usage frequency and trends
```

### Entity Recognition and Relationships Domain

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        ENTITY RECOGNITION & RELATIONSHIPS                           │
└─────────────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────┐                    ┌─────────────────┐
    │    ENTITIES     │◄──┐                │MESSAGE_ENTITIES │
    │─────────────────│   │ 1:N            │─────────────────│
    │ + id: INTEGER   │   │                │ + message_id: FK│──┐
    │ + name: TEXT    │   │                │ + entity_id: FK │  │
    │ + entity_type   │   │                │ + confidence    │  │
    │ + canonical_name│   │                │ + context: TEXT │  │
    │ + aliases: JSON │   │                └─────────────────┘  │
    │ + metadata: JSON│   │                                     │ M:N
    │ + created_at: TS│   │                                     │
    │ + last_mentioned│   │                ┌─────────────────┐  │
    └─────────────────┘   │                │    MESSAGES     │◄─┘
            │             │                └─────────────────┘
            │ M:N         │
            ▼             │
    ┌─────────────────┐   │
    │ENTITY_RELATIONS │───┘
    │─────────────────│
    │ + id: INTEGER   │
    │ + entity1_id: FK│
    │ + entity2_id: FK│
    │ + relationship  │
    │ + strength: REAL│
    │ + first_detected│
    │ + last_confirmed│
    └─────────────────┘
```

## Synchronization and System Tables

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                          SYNCHRONIZATION & SYSTEM                                  │
└─────────────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────┐         ┌─────────────────┐
    │   SYNC_LOG      │         │  SYNC_STATUS    │
    │─────────────────│         │─────────────────│
    │ + id: INTEGER   │         │ + local_dev: FK │
    │ + table_name    │         │ + remote_dev: FK│
    │ + row_id: INT   │         │ + last_sync: TS │
    │ + operation     │         │ + sync_status   │
    │ + timestamp: TS │         │ + conflicts: INT│
    │ + device_id: FK │         └─────────────────┘
    │ + synced: BOOL  │
    │ + sync_data:JSON│
    └─────────────────┘

    ┌─────────────────┐         ┌─────────────────┐
    │  ATTACHMENTS    │         │    SETTINGS     │
    │─────────────────│         │─────────────────│
    │ + id: UUID      │         │ + key: TEXT (PK)│
    │ + message_id: FK│         │ + value: TEXT   │
    │ + filename: TEXT│         │ + category: TEXT│
    │ + orig_filename │         │ + data_type     │
    │ + mime_type     │         │ + updated_at: TS│
    │ + file_size: INT│         └─────────────────┘
    │ + file_path     │
    │ + thumb_path    │
    │ + created_at: TS│
    └─────────────────┘
```

## Detailed Entity Diagrams

### Core Message Flow

```
     USER INPUT                 SYSTEM PROCESSING              STORAGE & SYNC
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│                 │         │                 │         │                 │
│  "I put 3 cans  │──────►  │  NLP Processing │──────►  │   MESSAGES      │
│  of beans in    │         │                 │         │                 │
│  the pantry"    │         │  • Parse items  │         │  • Store raw    │
│                 │         │  • Extract qty  │         │  • Categorize   │
└─────────────────┘         │  • Detect loc   │         │  • Generate FTS │
                            │  • Create trans │         │  • Log for sync │
                            └─────────────────┘         └─────────────────┘
                                     │                           │
                                     ▼                           ▼
                            ┌─────────────────┐         ┌─────────────────┐
                            │ INVENTORY_TRANS │         │   SYNC_LOG      │
                            │                 │         │                 │
                            │ + item: beans   │         │ • Track change  │
                            │ + location:pantry│        │ • Device ID     │
                            │ + change: +3    │         │ • Sync status   │
                            │ + type: add     │         │ • JSON payload  │
                            └─────────────────┘         └─────────────────┘
```

### Inventory Transaction Flow

```
     INVENTORY STATE CHANGES
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                     │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐                │
│  │     ITEMS       │    │   LOCATIONS     │    │   INVENTORY     │                │
│  │─────────────────│    │─────────────────│    │─────────────────│                │
│  │ id: 1           │    │ id: 1           │    │ item_id: 1      │                │
│  │ name: "Beans"   │    │ name: "Pantry"  │    │ location_id: 1  │                │
│  │ barcode: "123"  │    │ description...  │    │ quantity: 3     │                │
│  └─────────────────┘    └─────────────────┘    │ expiry_date...  │                │
│          │                       │              │ last_updated... │                │
│          │                       │              └─────────────────┘                │
│          │                       │                       │                         │
│          └───────────────────────┼───────────────────────┘                         │
│                                  │                                                 │
│                                  ▼                                                 │
│                      ┌─────────────────┐                                          │
│                      │INV_TRANSACTIONS │                                          │
│                      │─────────────────│                                          │
│                      │ item_id: 1      │                                          │
│                      │ location_id: 1  │                                          │
│                      │ change_amount:+3│                                          │
│                      │ prev_quantity: 0│                                          │
│                      │ new_quantity: 3 │                                          │
│                      │ trans_type: add │                                          │
│                      │ timestamp: now  │                                          │
│                      │ conv_msg_id: 42 │                                          │
│                      └─────────────────┘                                          │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

## Full-Text Search Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              FULL-TEXT SEARCH                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────┐         ┌─────────────────┐
    │    MESSAGES     │         │  MESSAGES_FTS   │
    │─────────────────│  AUTO   │─────────────────│
    │ + id: INTEGER   │ SYNC    │ + rowid ────────│───┐ (Maps to messages.id)
    │ + content: TEXT │ ──────► │ + content (FTS5)│   │
    │ + timestamp...  │ TRIGGER │ + tokenize      │   │ SEARCH QUERIES:
    │ + type...       │         │   porter unicode│   │ • "find beans"
    └─────────────────┘         └─────────────────┘   │ • "pantry items"
                                                      │ • "last week"
    ┌─────────────────┐         ┌─────────────────┐   │
    │     ITEMS       │         │   ITEMS_FTS     │   │
    │─────────────────│  AUTO   │─────────────────│   │
    │ + id: INTEGER   │ SYNC    │ + rowid ────────│───┘
    │ + name: TEXT    │ ──────► │ + name (FTS5)   │
    │ + brand: TEXT   │ TRIGGER │ + brand (FTS5)  │
    └─────────────────┘         └─────────────────┘

                    SEARCH INTERFACE
                ┌─────────────────────────┐
                │  "What beans do I have  │
                │   in the pantry?"       │
                └─────────────────────────┘
                            │
                            ▼
                ┌─────────────────────────┐
                │   COMBINED SEARCH:      │
                │ • FTS5 on "beans"       │
                │ • Location filter       │
                │ • Join inventory        │
                │ • Return with context   │
                └─────────────────────────┘
```

## Database Constraints and Rules

### Primary Keys and Uniqueness
```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                               CONSTRAINTS                                           │
└─────────────────────────────────────────────────────────────────────────────────────┘

PRIMARY KEYS:
• devices.id (TEXT)              - Device UUID
• conversations.id (AUTOINCR)    - Conversation sequence
• messages.id (AUTOINCR)         - Message sequence
• items.id (AUTOINCR)            - Item catalog sequence
• inventory.id (AUTOINCR)        - Inventory record sequence

UNIQUE CONSTRAINTS:
• locations.name                 - No duplicate location names
• items.barcode                  - One barcode per item
• inventory(item_id, location_id) - One record per item/location
• categories.name                - No duplicate category names

FOREIGN KEY RELATIONSHIPS:
• conversations.device_id → devices.id
• messages.conversation_id → conversations.id
• messages.device_id → devices.id
• inventory.item_id → items.id
• inventory.location_id → locations.id
• inventory_transactions.item_id → items.id
• (and many more...)

CHECK CONSTRAINTS:
• devices.type IN ('mobile', 'desktop', 'pi')
• messages.type IN ('user', 'assistant', 'system')
• inventory_transactions.transaction_type IN ('add', 'use', 'move', 'expire', 'correct')
• entities.entity_type IN ('person', 'place', 'organization', 'event', 'thing')
```

## Indexing Strategy

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                  INDEXES                                            │
└─────────────────────────────────────────────────────────────────────────────────────┘

TEMPORAL INDEXES (Most Critical):
• idx_messages_timestamp         - Timeline queries, recent messages
• idx_conversations_last_message - Recent conversations
• idx_inventory_updated          - Recently changed inventory

LOOKUP INDEXES:
• idx_messages_conversation      - Get all messages in conversation
• idx_inventory_item            - Find all locations for item
• idx_inventory_location        - Find all items in location
• idx_entities_type             - Find people, places, etc.

SYNC INDEXES:
• idx_sync_log_table_timestamp  - Changes by table and time
• idx_sync_log_synced          - Unsynced changes
• idx_sync_log_device          - Changes by device

AI INDEXES:
• idx_embeddings_content        - Find embeddings by content
• idx_patterns_type            - Patterns by type
• idx_insights_created         - Recent insights

COMPOSITE INDEXES:
• idx_transactions_item_timestamp - Item transaction history
• idx_message_entities_message   - Entities in messages
```

## Data Flow Patterns

### Message Processing Pipeline
```
USER INPUT → PARSING → STORAGE → INDEXING → SYNC → AI PROCESSING
     │           │         │         │        │         │
     ▼           ▼         ▼         ▼        ▼         ▼
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
│ Raw     │ │ Extract │ │ Insert  │ │ Update  │ │ Log for │ │ Generate│
│ Message │ │ • Items │ │ MESSAGE │ │ FTS     │ │ Sync    │ │ Embed   │
│ Text    │ │ • Qty   │ │ • INV   │ │ Index   │ │ Queue   │ │ • Cat   │
│         │ │ • Loc   │ │ • TRANS │ │         │ │         │ │ • Entity│
└─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘
```

### Inventory State Management
```
CURRENT STATE:           TRANSACTION LOG:         SYNC PREPARATION:
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   INVENTORY     │     │INV_TRANSACTIONS │     │   SYNC_LOG      │
│                 │ ◄── │                 │ ──► │                 │
│ item_id: 1      │     │ change: +3      │     │ table: inventory│
│ location_id: 2  │     │ prev_qty: 0     │     │ operation: UPD  │
│ quantity: 3     │     │ new_qty: 3      │     │ device_id: mob1 │
│ last_updated: T │     │ type: add       │     │ timestamp: T    │
└─────────────────┘     │ timestamp: T    │     │ sync_data: {...}│
                        │ device_id: mob1 │     └─────────────────┘
                        └─────────────────┘
```

This UML-style design document provides a comprehensive visual representation of the 2ndBrain database schema, showing relationships, constraints, data flow, and architectural patterns. Each domain is clearly separated while showing how they interconnect to support the complete 2ndBrain functionality.

<function_calls>
<invoke name="TodoWrite">
<parameter name="todos">[{"id": "1", "content": "Create UML-style database design document", "status": "completed", "priority": "high"}]