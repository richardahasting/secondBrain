# 2ndBrain Database Schema

This document describes the SQLite database schema for the 2ndBrain conversational AI assistant with perfect memory.

## Schema Overview

The database is designed around several core principles:
- **Perfect Memory**: Never delete data, only mark as forgotten
- **Multi-Device Sync**: Complete change tracking for synchronization
- **AI Integration**: Support for embeddings and pattern recognition
- **Inventory Tracking**: Location-based item management
- **Privacy First**: Encryption-ready with selective access controls

## Core Tables

### Devices
Tracks all devices that can sync with this brain instance.

| Column | Type | Description |
|--------|------|-------------|
| id | TEXT (PK) | Unique device identifier |
| name | TEXT | Human-readable device name |
| type | TEXT | Device type: 'mobile', 'desktop', 'pi' |
| last_seen | INTEGER | Unix timestamp of last activity |
| created_at | INTEGER | Unix timestamp of device registration |

### Conversations
Groups related messages into conversation threads.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Auto-incrementing conversation ID |
| title | TEXT | Optional conversation title |
| started_at | INTEGER | Unix timestamp of first message |
| last_message_at | INTEGER | Unix timestamp of latest message |
| device_id | TEXT (FK) | Device that started conversation |
| archived | BOOLEAN | Whether conversation is archived |
| forgotten | BOOLEAN | Whether conversation is "forgotten" |

### Messages
Individual messages within conversations - the core of the memory system.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Unique message identifier |
| conversation_id | INTEGER (FK) | Parent conversation |
| content | TEXT | Message text content |
| timestamp | INTEGER | Unix timestamp of message |
| type | TEXT | Message type: 'user', 'assistant', 'system' |
| device_id | TEXT (FK) | Device that created message |
| forgotten | BOOLEAN | Whether message is "forgotten" |
| vector_id | TEXT | Reference to AI embedding |
| metadata | JSON | Flexible additional data |

### Categories
Auto-detected categories for organizing messages.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Category identifier |
| name | TEXT | Category name (unique) |
| description | TEXT | Category description |
| color | TEXT | UI color hint |
| created_at | INTEGER | Creation timestamp |

**Default Categories:**
- Locations, Numbers, Secrets, History, Tasks, Journal, Inventory, Ideas, People, Health

### Keywords
Fast indexing system for quick retrieval of content mentioning specific keywords.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Keyword identifier |
| keyword | TEXT | Original keyword (unique) |
| normalized_keyword | TEXT | Lowercase, stemmed version |
| frequency | INTEGER | Total usage count across system |
| first_used | INTEGER | First appearance timestamp |
| last_used | INTEGER | Most recent usage timestamp |
| created_at | INTEGER | Creation timestamp |

### Message Categories (Junction Table)
Links messages to categories with confidence scores.

| Column | Type | Description |
|--------|------|-------------|
| message_id | INTEGER (FK) | Message reference |
| category_id | INTEGER (FK) | Category reference |
| confidence | REAL | AI confidence (0.0-1.0) |

## Keyword Linking Tables

### Message Keywords (Junction Table)
Links messages to keywords for fast retrieval.

| Column | Type | Description |
|--------|------|-------------|
| message_id | INTEGER (FK) | Message reference |
| keyword_id | INTEGER (FK) | Keyword reference |
| position | INTEGER | Position of keyword in message |
| context | TEXT | Surrounding text context |
| relevance | REAL | Relevance score (0.0-1.0) |

### Item Keywords (Junction Table)
Links inventory items to keywords.

| Column | Type | Description |
|--------|------|-------------|
| item_id | INTEGER (FK) | Item reference |
| keyword_id | INTEGER (FK) | Keyword reference |
| source | TEXT | Source: 'name', 'brand', 'description', 'manual' |

### Entity Keywords (Junction Table)
Links entities to keywords.

| Column | Type | Description |
|--------|------|-------------|
| entity_id | INTEGER (FK) | Entity reference |
| keyword_id | INTEGER (FK) | Keyword reference |
| source | TEXT | Source: 'name', 'alias', 'description', 'manual' |

### Conversation Keywords (Junction Table)
Links conversations to keywords with frequency tracking.

| Column | Type | Description |
|--------|------|-------------|
| conversation_id | INTEGER (FK) | Conversation reference |
| keyword_id | INTEGER (FK) | Keyword reference |
| frequency | INTEGER | Occurrences in this conversation |
| last_mention | INTEGER | Last usage timestamp |

### Insight Keywords (Junction Table)
Links AI insights to keywords.

| Column | Type | Description |
|--------|------|-------------|
| insight_id | INTEGER (FK) | Insight reference |
| keyword_id | INTEGER (FK) | Keyword reference |
| source | TEXT | Source: 'title', 'content', 'category', 'manual' |

## Inventory System

### Locations
Physical storage locations for inventory tracking.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Location identifier |
| name | TEXT | Location name (unique) |
| description | TEXT | Location description |
| parent_id | INTEGER (FK) | Parent location for nesting |
| created_at | INTEGER | Creation timestamp |

**Default Locations:**
- Pantry, Refrigerator, Freezer, Kitchen Cabinet, Bedroom Closet, Garage, Basement, Office, Living Room, Bathroom

### Item Categories
Hierarchical categories for organizing items.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Category identifier |
| name | TEXT | Category name (unique) |
| parent_id | INTEGER (FK) | Parent category for hierarchy |
| created_at | INTEGER | Creation timestamp |

**Default Categories:**
- Food & Beverages, Household Supplies, Personal Care, Electronics, Tools & Hardware, Clothing, Books & Media, Health & Medicine, Office Supplies, Other

### Items
Master catalog of all items that can be tracked.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Item identifier |
| name | TEXT | Item name |
| brand | TEXT | Brand name |
| size | TEXT | Package size |
| unit | TEXT | Unit of measurement |
| barcode | TEXT | UPC/barcode (unique) |
| category_id | INTEGER (FK) | Item category |
| nutrition_data | JSON | Nutritional information |
| typical_locations | JSON | Common storage locations |
| created_at | INTEGER | Creation timestamp |

### Inventory
Current quantity and state of items in locations.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Inventory record ID |
| item_id | INTEGER (FK) | Item reference |
| location_id | INTEGER (FK) | Storage location |
| quantity | REAL | Current quantity |
| expiry_date | INTEGER | Expiration timestamp |
| purchase_date | INTEGER | Purchase timestamp |
| purchase_price | REAL | Purchase price |
| purchase_store | TEXT | Store name |
| notes | TEXT | Additional notes |
| last_updated | INTEGER | Last modification time |
| device_id | TEXT (FK) | Device that updated |

**Unique Constraint:** One record per item per location

### Inventory Transactions
Complete audit log of all inventory changes.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Transaction ID |
| item_id | INTEGER (FK) | Item reference |
| location_id | INTEGER (FK) | Location reference |
| change_amount | REAL | Quantity change (+/-) |
| previous_quantity | REAL | Quantity before change |
| new_quantity | REAL | Quantity after change |
| transaction_type | TEXT | Type: 'add', 'use', 'move', 'expire', 'correct' |
| timestamp | INTEGER | Transaction timestamp |
| device_id | TEXT (FK) | Device that made change |
| notes | TEXT | Transaction notes |
| conversation_message_id | INTEGER (FK) | Message that triggered change |

## AI and Pattern Recognition

### Embeddings
Vector embeddings for semantic search and AI processing.

| Column | Type | Description |
|--------|------|-------------|
| id | TEXT (PK) | UUID identifier |
| content_type | TEXT | Type: 'message', 'summary', 'pattern' |
| content_id | INTEGER | ID of embedded content |
| embedding | BLOB | Serialized vector data |
| model_name | TEXT | Model used for embedding |
| created_at | INTEGER | Creation timestamp |

### Patterns
AI-detected behavioral patterns.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Pattern identifier |
| name | TEXT | Pattern name |
| description | TEXT | Pattern description |
| pattern_type | TEXT | Type: 'temporal', 'consumption', 'mood', 'location', 'spending' |
| confidence | REAL | Detection confidence |
| data | JSON | Pattern-specific data |
| first_detected | INTEGER | First detection timestamp |
| last_updated | INTEGER | Last update timestamp |
| active | BOOLEAN | Whether pattern is active |

### Insights
AI-generated insights and suggestions.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Insight identifier |
| title | TEXT | Insight title |
| content | TEXT | Insight description |
| insight_type | TEXT | Type: 'prediction', 'recommendation', 'alert', 'summary' |
| category | TEXT | Insight category |
| confidence | REAL | AI confidence level |
| supporting_data | JSON | References to source data |
| created_at | INTEGER | Creation timestamp |
| presented_at | INTEGER | When shown to user |
| user_feedback | TEXT | User feedback: 'helpful', 'not_helpful', 'wrong' |
| dismissed | BOOLEAN | Whether user dismissed |

## Entity Recognition

### Entities
People, places, organizations, and things mentioned in conversations.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Entity identifier |
| name | TEXT | Entity name |
| entity_type | TEXT | Type: 'person', 'place', 'organization', 'event', 'thing' |
| canonical_name | TEXT | Normalized name |
| aliases | JSON | Alternative names |
| metadata | JSON | Type-specific data |
| created_at | INTEGER | Creation timestamp |
| last_mentioned | INTEGER | Last mention timestamp |

### Message Entities (Junction Table)
Links entities to messages where they appear.

| Column | Type | Description |
|--------|------|-------------|
| message_id | INTEGER (FK) | Message reference |
| entity_id | INTEGER (FK) | Entity reference |
| confidence | REAL | Recognition confidence |
| context | TEXT | Surrounding text context |

### Entity Relationships
Relationships between entities (social graph).

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Relationship identifier |
| entity1_id | INTEGER (FK) | First entity |
| entity2_id | INTEGER (FK) | Second entity |
| relationship_type | TEXT | Relationship type |
| strength | REAL | Relationship strength |
| first_detected | INTEGER | First detection timestamp |
| last_confirmed | INTEGER | Last confirmation timestamp |

## Sync and Versioning

### Sync Log
Tracks all changes for multi-device synchronization.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER (PK) | Log entry ID |
| table_name | TEXT | Modified table name |
| row_id | INTEGER | Modified row ID |
| operation | TEXT | Operation: 'INSERT', 'UPDATE', 'DELETE' |
| timestamp | INTEGER | Change timestamp |
| device_id | TEXT (FK) | Device that made change |
| synced | BOOLEAN | Whether change has been synced |
| sync_data | JSON | Serialized row data |

### Sync Status
Tracks synchronization state between device pairs.

| Column | Type | Description |
|--------|------|-------------|
| local_device_id | TEXT (FK) | Local device ID |
| remote_device_id | TEXT (FK) | Remote device ID |
| last_sync_timestamp | INTEGER | Last successful sync |
| last_sync_status | TEXT | Status: 'success', 'partial', 'failed' |
| conflicts_count | INTEGER | Number of unresolved conflicts |

## Attachments and Media

### Attachments
References to files stored in the filesystem.

| Column | Type | Description |
|--------|------|-------------|
| id | TEXT (PK) | UUID identifier |
| message_id | INTEGER (FK) | Associated message |
| filename | TEXT | Current filename |
| original_filename | TEXT | Original filename |
| mime_type | TEXT | File MIME type |
| file_size | INTEGER | File size in bytes |
| file_path | TEXT | Relative path from data directory |
| thumbnail_path | TEXT | Thumbnail image path |
| created_at | INTEGER | Creation timestamp |

### File Storage Structure
```
/secondBrain/
├── database/
│   └── main.db
├── attachments/
│   ├── 2024/01/15/
│   │   ├── uuid1.jpg
│   │   └── uuid2.pdf
│   └── thumbnails/
└── embeddings/
    └── vectors.db
```

## Settings and Configuration

### Settings
Application settings and user preferences.

| Column | Type | Description |
|--------|------|-------------|
| key | TEXT (PK) | Setting key |
| value | TEXT | Setting value |
| category | TEXT | Setting category |
| data_type | TEXT | Data type: 'string', 'integer', 'real', 'boolean', 'json' |
| updated_at | INTEGER | Last update timestamp |

**Default Settings:**
```
ai_enabled = true
inventory_mode_enabled = true
forget_keyword_enabled = true
auto_categorization = true
pattern_recognition = true
sync_enabled = false
encryption_enabled = true
default_search_limit = 50
conversation_archive_days = 365
low_inventory_threshold = 2
```

## Full-Text Search

### Messages FTS
Full-text search index for message content.
- **Table:** `messages_fts`
- **Tokenizer:** Porter stemming with Unicode support
- **Auto-populated:** Via triggers on message changes

### Items FTS
Full-text search index for item names and brands.
- **Table:** `items_fts`
- **Tokenizer:** Porter stemming with Unicode support
- **Auto-populated:** Via triggers on item changes

## Database Views

### Inventory Summary
Current inventory with freshness status.
```sql
SELECT location_name, item_name, brand, quantity, 
       expiry_date, freshness_status
FROM inventory_summary
WHERE quantity > 0;
```

### Recent Conversations
Conversations ordered by recent activity with message counts.
```sql
SELECT id, title, started_at, last_message_at, 
       message_count, device_name
FROM recent_conversations
LIMIT 10;
```

### Consumption Rates
Item consumption patterns for predictive insights.
```sql
SELECT item_name, unit, total_consumed, 
       daily_rate, days_tracked
FROM consumption_rates
WHERE daily_rate > 0;
```

### Keyword Search
Comprehensive keyword usage across all system entities.
```sql
SELECT keyword, frequency, message_count, item_count,
       entity_count, conversation_count, insight_count
FROM keyword_search
WHERE keyword LIKE '%beans%'
ORDER BY frequency DESC;
```

## Indexes for Performance

### Core Indexes
- `idx_messages_timestamp` - Message timeline queries
- `idx_messages_conversation` - Conversation retrieval
- `idx_messages_device` - Device-specific queries
- `idx_conversations_last_message` - Recent conversations

### Inventory Indexes
- `idx_inventory_item` - Item lookups
- `idx_inventory_location` - Location queries
- `idx_inventory_expiry` - Expiration tracking
- `idx_transactions_timestamp` - Transaction history

### AI Indexes
- `idx_embeddings_content` - Embedding lookups
- `idx_patterns_type` - Pattern queries
- `idx_insights_created` - Recent insights

### Sync Indexes
- `idx_sync_log_table_timestamp` - Change tracking
- `idx_sync_log_synced` - Unsync'd changes

### Keyword Indexes
- `idx_keywords_normalized` - Fast keyword lookup
- `idx_keywords_frequency` - Most popular keywords
- `idx_message_keywords_keyword` - Messages by keyword
- `idx_item_keywords_keyword` - Items by keyword
- `idx_entity_keywords_keyword` - Entities by keyword
- `idx_conversation_keywords_freq` - Conversation keyword popularity

## Triggers and Automation

### Automatic Updates
- **Conversation Timestamps:** Auto-update `last_message_at`
- **FTS Population:** Auto-populate search indexes
- **Sync Logging:** Track all changes for synchronization

### Data Integrity
- **Foreign Key Constraints:** Enforced referential integrity
- **Check Constraints:** Validate enum values
- **Unique Constraints:** Prevent duplicate data

## Performance Configuration

### SQLite Pragma Settings
```sql
PRAGMA foreign_keys = ON;           -- Enable foreign keys
PRAGMA journal_mode = WAL;          -- Write-Ahead Logging
PRAGMA synchronous = NORMAL;        -- Balanced durability
PRAGMA cache_size = -64000;         -- 64MB cache
PRAGMA temp_store = MEMORY;         -- Memory temp storage
PRAGMA mmap_size = 268435456;       -- 256MB memory mapping
```

### Compression Expectations
- **Text Data:** 80-90% compression ratio
- **JSON Metadata:** 70-80% compression ratio
- **Overall Database:** 75-85% compression with gzip

## Schema Version
Current schema version: **1.0**

The schema version is tracked in the settings table for migration purposes.

---

*This schema supports the complete 2ndBrain vision while maintaining performance, sync capabilities, and data integrity.*