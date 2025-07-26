-- 2ndBrain SQLite Schema
-- A comprehensive database schema for conversational AI with perfect memory
-- Version 1.0

-- Enable foreign key constraints
PRAGMA foreign_keys = ON;

-- Optimize SQLite settings for performance
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA cache_size = -64000;  -- 64MB cache
PRAGMA temp_store = MEMORY;
PRAGMA mmap_size = 268435456;  -- 256MB memory-mapped I/O

-- =====================================
-- CORE CONVERSATION SYSTEM
-- =====================================

-- Devices that can sync with this brain
CREATE TABLE devices (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT CHECK(type IN ('mobile', 'desktop', 'pi')) NOT NULL,
    hostname TEXT,                    -- Machine hostname for network discovery
    ip_address TEXT,                  -- Current IP address (may change)
    port INTEGER DEFAULT 8080,       -- Port for sync service
    public_key TEXT,                  -- Public key for encrypted communication
    sync_endpoint TEXT,               -- Full sync endpoint URL
    discovery_info JSON,              -- Additional discovery metadata (Bonjour, etc.)
    capabilities JSON,                -- What this device can do (features, storage, etc.)
    network_type TEXT CHECK(network_type IN ('local', 'internet', 'both')) DEFAULT 'local',
    last_seen INTEGER NOT NULL,
    last_ip_update INTEGER,           -- When IP was last updated
    is_online BOOLEAN DEFAULT 0,     -- Current online status
    created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

-- Conversation threads
CREATE TABLE conversations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    started_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    last_message_at INTEGER,
    device_id TEXT NOT NULL,
    archived BOOLEAN DEFAULT 0,
    forgotten BOOLEAN DEFAULT 0,
    FOREIGN KEY (device_id) REFERENCES devices(id)
);

-- Individual messages within conversations
CREATE TABLE messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    conversation_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    timestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    type TEXT CHECK(type IN ('user', 'assistant', 'system')) NOT NULL,
    device_id TEXT NOT NULL,
    forgotten BOOLEAN DEFAULT 0,
    vector_id TEXT,  -- Reference to AI embedding
    metadata JSON,   -- Flexible storage for additional data
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (device_id) REFERENCES devices(id)
);

-- Auto-detected categories for messages
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    color TEXT,  -- UI color hint
    created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

-- Keywords for fast indexing and retrieval
CREATE TABLE keywords (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    keyword TEXT UNIQUE NOT NULL,
    normalized_keyword TEXT NOT NULL,  -- Lowercase, stemmed version
    frequency INTEGER DEFAULT 1,       -- How often this keyword appears
    first_used INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    last_used INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

-- Link messages to categories (many-to-many)
CREATE TABLE message_categories (
    message_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    confidence REAL DEFAULT 1.0,  -- AI confidence in categorization
    PRIMARY KEY (message_id, category_id),
    FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

-- Link messages to keywords (many-to-many)
CREATE TABLE message_keywords (
    message_id INTEGER NOT NULL,
    keyword_id INTEGER NOT NULL,
    position INTEGER,              -- Position of keyword in message
    context TEXT,                  -- Surrounding text context
    relevance REAL DEFAULT 1.0,   -- Relevance score for this keyword
    PRIMARY KEY (message_id, keyword_id),
    FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE,
    FOREIGN KEY (keyword_id) REFERENCES keywords(id) ON DELETE CASCADE
);

-- Link items to keywords (many-to-many)
CREATE TABLE item_keywords (
    item_id INTEGER NOT NULL,
    keyword_id INTEGER NOT NULL,
    source TEXT CHECK(source IN ('name', 'brand', 'description', 'manual')) DEFAULT 'name',
    PRIMARY KEY (item_id, keyword_id),
    FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE,
    FOREIGN KEY (keyword_id) REFERENCES keywords(id) ON DELETE CASCADE
);

-- Link entities to keywords (many-to-many)
CREATE TABLE entity_keywords (
    entity_id INTEGER NOT NULL,
    keyword_id INTEGER NOT NULL,
    source TEXT CHECK(source IN ('name', 'alias', 'description', 'manual')) DEFAULT 'name',
    PRIMARY KEY (entity_id, keyword_id),
    FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE,
    FOREIGN KEY (keyword_id) REFERENCES keywords(id) ON DELETE CASCADE
);

-- Link insights to keywords (many-to-many)
CREATE TABLE insight_keywords (
    insight_id INTEGER NOT NULL,
    keyword_id INTEGER NOT NULL,
    source TEXT CHECK(source IN ('title', 'content', 'category', 'manual')) DEFAULT 'content',
    PRIMARY KEY (insight_id, keyword_id),
    FOREIGN KEY (insight_id) REFERENCES insights(id) ON DELETE CASCADE,
    FOREIGN KEY (keyword_id) REFERENCES keywords(id) ON DELETE CASCADE
);

-- Link conversations to keywords (many-to-many)
CREATE TABLE conversation_keywords (
    conversation_id INTEGER NOT NULL,
    keyword_id INTEGER NOT NULL,
    frequency INTEGER DEFAULT 1,   -- How many times keyword appears in conversation
    last_mention INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    PRIMARY KEY (conversation_id, keyword_id),
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (keyword_id) REFERENCES keywords(id) ON DELETE CASCADE
);

-- =====================================
-- INVENTORY MANAGEMENT SYSTEM
-- =====================================

-- Physical locations where items are stored
CREATE TABLE locations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    parent_id INTEGER,  -- For nested locations (pantry -> top shelf)
    created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    FOREIGN KEY (parent_id) REFERENCES locations(id)
);

-- Product categories for organization
CREATE TABLE item_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    parent_id INTEGER,
    created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    FOREIGN KEY (parent_id) REFERENCES item_categories(id)
);

-- Master item catalog
CREATE TABLE items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    brand TEXT,
    size TEXT,
    unit TEXT,  -- cans, boxes, lbs, etc.
    barcode TEXT UNIQUE,
    category_id INTEGER,
    nutrition_data JSON,  -- From barcode lookup
    typical_locations JSON,  -- Array of commonly stored locations
    created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    FOREIGN KEY (category_id) REFERENCES item_categories(id)
);

-- Current inventory state
CREATE TABLE inventory (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    item_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    quantity REAL NOT NULL DEFAULT 0,
    expiry_date INTEGER,
    purchase_date INTEGER,
    purchase_price REAL,
    purchase_store TEXT,
    notes TEXT,
    last_updated INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    device_id TEXT NOT NULL,
    FOREIGN KEY (item_id) REFERENCES items(id),
    FOREIGN KEY (location_id) REFERENCES locations(id),
    FOREIGN KEY (device_id) REFERENCES devices(id),
    UNIQUE(item_id, location_id)  -- One entry per item per location
);

-- Transaction log for inventory changes
CREATE TABLE inventory_transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    item_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    change_amount REAL NOT NULL,  -- Positive for add, negative for use
    previous_quantity REAL NOT NULL,
    new_quantity REAL NOT NULL,
    transaction_type TEXT CHECK(transaction_type IN ('add', 'use', 'move', 'expire', 'correct')) NOT NULL,
    timestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    device_id TEXT NOT NULL,
    notes TEXT,
    conversation_message_id INTEGER,  -- Link to the message that triggered this
    FOREIGN KEY (item_id) REFERENCES items(id),
    FOREIGN KEY (location_id) REFERENCES locations(id),
    FOREIGN KEY (device_id) REFERENCES devices(id),
    FOREIGN KEY (conversation_message_id) REFERENCES messages(id)
);

-- =====================================
-- AI AND PATTERN RECOGNITION
-- =====================================

-- Embeddings for semantic search
CREATE TABLE embeddings (
    id TEXT PRIMARY KEY,  -- UUID
    content_type TEXT CHECK(content_type IN ('message', 'summary', 'pattern')) NOT NULL,
    content_id INTEGER NOT NULL,  -- ID of the content being embedded
    embedding BLOB NOT NULL,  -- Serialized vector
    model_name TEXT NOT NULL,
    created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

-- Detected patterns in user behavior
CREATE TABLE patterns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    pattern_type TEXT CHECK(pattern_type IN ('temporal', 'consumption', 'mood', 'location', 'spending')) NOT NULL,
    confidence REAL NOT NULL,
    data JSON NOT NULL,  -- Pattern-specific data
    first_detected INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    last_updated INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    active BOOLEAN DEFAULT 1
);

-- AI-generated insights and suggestions
CREATE TABLE insights (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    insight_type TEXT CHECK(insight_type IN ('prediction', 'recommendation', 'alert', 'summary')) NOT NULL,
    category TEXT,
    confidence REAL NOT NULL,
    supporting_data JSON,  -- References to messages, patterns, etc.
    created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    presented_at INTEGER,  -- When shown to user
    user_feedback TEXT CHECK(user_feedback IN ('helpful', 'not_helpful', 'wrong')),
    dismissed BOOLEAN DEFAULT 0
);

-- =====================================
-- ENTITY RECOGNITION AND RELATIONSHIPS
-- =====================================

-- Entities mentioned in conversations (people, places, things)
CREATE TABLE entities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    entity_type TEXT CHECK(entity_type IN ('person', 'place', 'organization', 'event', 'thing')) NOT NULL,
    canonical_name TEXT,  -- Normalized name
    aliases JSON,  -- Array of alternative names
    metadata JSON,  -- Type-specific data
    created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    last_mentioned INTEGER
);

-- Link entities to messages where they appear
CREATE TABLE message_entities (
    message_id INTEGER NOT NULL,
    entity_id INTEGER NOT NULL,
    confidence REAL DEFAULT 1.0,
    context TEXT,  -- Surrounding text context
    PRIMARY KEY (message_id, entity_id),
    FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE,
    FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE
);

-- Relationships between entities
CREATE TABLE entity_relationships (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    entity1_id INTEGER NOT NULL,
    entity2_id INTEGER NOT NULL,
    relationship_type TEXT NOT NULL,  -- friend, spouse, works_at, lives_in, etc.
    strength REAL DEFAULT 1.0,  -- How strong is this relationship
    first_detected INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    last_confirmed INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    FOREIGN KEY (entity1_id) REFERENCES entities(id),
    FOREIGN KEY (entity2_id) REFERENCES entities(id),
    UNIQUE(entity1_id, entity2_id, relationship_type)
);

-- =====================================
-- SYNC AND VERSIONING
-- =====================================

-- Track all changes for sync between devices
CREATE TABLE sync_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    table_name TEXT NOT NULL,
    row_id INTEGER NOT NULL,
    operation TEXT CHECK(operation IN ('INSERT', 'UPDATE', 'DELETE')) NOT NULL,
    timestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    device_id TEXT NOT NULL,
    synced BOOLEAN DEFAULT 0,
    sync_data JSON,  -- Serialized row data for sync
    FOREIGN KEY (device_id) REFERENCES devices(id)
);

-- Track last sync timestamps between devices
CREATE TABLE sync_status (
    local_device_id TEXT NOT NULL,
    remote_device_id TEXT NOT NULL,
    last_sync_timestamp INTEGER NOT NULL DEFAULT 0,
    last_sync_status TEXT CHECK(last_sync_status IN ('success', 'partial', 'failed')) DEFAULT 'success',
    conflicts_count INTEGER DEFAULT 0,
    PRIMARY KEY (local_device_id, remote_device_id),
    FOREIGN KEY (local_device_id) REFERENCES devices(id),
    FOREIGN KEY (remote_device_id) REFERENCES devices(id)
);

-- =====================================
-- ATTACHMENTS AND MEDIA
-- =====================================

-- File attachments referenced in conversations
CREATE TABLE attachments (
    id TEXT PRIMARY KEY,  -- UUID
    message_id INTEGER,
    filename TEXT NOT NULL,
    original_filename TEXT,
    mime_type TEXT,
    file_size INTEGER,
    file_path TEXT NOT NULL,  -- Relative path from data directory
    thumbnail_path TEXT,
    created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE SET NULL
);

-- =====================================
-- USER PREFERENCES AND SETTINGS
-- =====================================

-- User preferences and application settings
CREATE TABLE settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    category TEXT,
    data_type TEXT CHECK(data_type IN ('string', 'integer', 'real', 'boolean', 'json')) DEFAULT 'string',
    updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

-- =====================================
-- INDEXES FOR PERFORMANCE
-- =====================================

-- Core conversation indexes
CREATE INDEX idx_messages_timestamp ON messages(timestamp);
CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_device ON messages(device_id);
CREATE INDEX idx_messages_type ON messages(type);
CREATE INDEX idx_conversations_device ON conversations(device_id);
CREATE INDEX idx_conversations_last_message ON conversations(last_message_at);

-- Inventory indexes
CREATE INDEX idx_inventory_item ON inventory(item_id);
CREATE INDEX idx_inventory_location ON inventory(location_id);
CREATE INDEX idx_inventory_expiry ON inventory(expiry_date);
CREATE INDEX idx_inventory_updated ON inventory(last_updated);
CREATE INDEX idx_transactions_item_timestamp ON inventory_transactions(item_id, timestamp);
CREATE INDEX idx_transactions_timestamp ON inventory_transactions(timestamp);

-- AI and search indexes
CREATE INDEX idx_embeddings_content ON embeddings(content_type, content_id);
CREATE INDEX idx_patterns_type ON patterns(pattern_type);
CREATE INDEX idx_patterns_updated ON patterns(last_updated);
CREATE INDEX idx_insights_type ON insights(insight_type);
CREATE INDEX idx_insights_created ON insights(created_at);

-- Entity indexes
CREATE INDEX idx_entities_type ON entities(entity_type);
CREATE INDEX idx_entities_last_mentioned ON entities(last_mentioned);
CREATE INDEX idx_entity_relationships_entity1 ON entity_relationships(entity1_id);
CREATE INDEX idx_entity_relationships_entity2 ON entity_relationships(entity2_id);

-- Keyword indexes
CREATE INDEX idx_keywords_normalized ON keywords(normalized_keyword);
CREATE INDEX idx_keywords_frequency ON keywords(frequency DESC);
CREATE INDEX idx_keywords_last_used ON keywords(last_used);
CREATE INDEX idx_message_keywords_keyword ON message_keywords(keyword_id);
CREATE INDEX idx_message_keywords_message ON message_keywords(message_id);
CREATE INDEX idx_item_keywords_keyword ON item_keywords(keyword_id);
CREATE INDEX idx_item_keywords_item ON item_keywords(item_id);
CREATE INDEX idx_entity_keywords_keyword ON entity_keywords(keyword_id);
CREATE INDEX idx_entity_keywords_entity ON entity_keywords(entity_id);
CREATE INDEX idx_conversation_keywords_keyword ON conversation_keywords(keyword_id);
CREATE INDEX idx_conversation_keywords_freq ON conversation_keywords(frequency DESC);

-- Sync indexes
CREATE INDEX idx_sync_log_table_timestamp ON sync_log(table_name, timestamp);
CREATE INDEX idx_sync_log_device ON sync_log(device_id);
CREATE INDEX idx_sync_log_synced ON sync_log(synced);

-- =====================================
-- FULL-TEXT SEARCH
-- =====================================

-- Full-text search for messages
CREATE VIRTUAL TABLE messages_fts USING fts5(
    content,
    tokenize = 'porter unicode61 remove_diacritics 1'
);

-- Full-text search for items
CREATE VIRTUAL TABLE items_fts USING fts5(
    name,
    brand,
    tokenize = 'porter unicode61 remove_diacritics 1'
);

-- =====================================
-- TRIGGERS FOR AUTOMATION
-- =====================================

-- Update conversation last_message_at when new message added
CREATE TRIGGER update_conversation_timestamp
AFTER INSERT ON messages
BEGIN
    UPDATE conversations 
    SET last_message_at = NEW.timestamp 
    WHERE id = NEW.conversation_id;
END;

-- Sync logging triggers for critical tables
CREATE TRIGGER sync_messages_insert
AFTER INSERT ON messages
BEGIN
    INSERT INTO sync_log (table_name, row_id, operation, device_id, sync_data)
    VALUES ('messages', NEW.id, 'INSERT', NEW.device_id, 
            json_object('id', NEW.id, 'conversation_id', NEW.conversation_id, 
                       'content', NEW.content, 'timestamp', NEW.timestamp, 
                       'type', NEW.type, 'forgotten', NEW.forgotten));
END;

CREATE TRIGGER sync_messages_update
AFTER UPDATE ON messages
BEGIN
    INSERT INTO sync_log (table_name, row_id, operation, device_id, sync_data)
    VALUES ('messages', NEW.id, 'UPDATE', NEW.device_id,
            json_object('id', NEW.id, 'conversation_id', NEW.conversation_id, 
                       'content', NEW.content, 'timestamp', NEW.timestamp, 
                       'type', NEW.type, 'forgotten', NEW.forgotten));
END;

CREATE TRIGGER sync_inventory_update
AFTER UPDATE ON inventory
BEGIN
    INSERT INTO sync_log (table_name, row_id, operation, device_id, sync_data)
    VALUES ('inventory', NEW.id, 'UPDATE', NEW.device_id,
            json_object('id', NEW.id, 'item_id', NEW.item_id, 'location_id', NEW.location_id,
                       'quantity', NEW.quantity, 'last_updated', NEW.last_updated));
END;

-- Automatically populate FTS tables
CREATE TRIGGER messages_fts_insert
AFTER INSERT ON messages
BEGIN
    INSERT INTO messages_fts(rowid, content) VALUES (NEW.id, NEW.content);
END;

CREATE TRIGGER messages_fts_update
AFTER UPDATE ON messages
BEGIN
    UPDATE messages_fts SET content = NEW.content WHERE rowid = NEW.id;
END;

CREATE TRIGGER messages_fts_delete
AFTER DELETE ON messages
BEGIN
    DELETE FROM messages_fts WHERE rowid = OLD.id;
END;

CREATE TRIGGER items_fts_insert
AFTER INSERT ON items
BEGIN
    INSERT INTO items_fts(rowid, name, brand) VALUES (NEW.id, NEW.name, COALESCE(NEW.brand, ''));
END;

CREATE TRIGGER items_fts_update
AFTER UPDATE ON items
BEGIN
    UPDATE items_fts SET name = NEW.name, brand = COALESCE(NEW.brand, '') WHERE rowid = NEW.id;
END;

-- Keyword management triggers
CREATE TRIGGER update_keyword_frequency
AFTER INSERT ON message_keywords
BEGIN
    UPDATE keywords 
    SET frequency = frequency + 1, 
        last_used = strftime('%s', 'now')
    WHERE id = NEW.keyword_id;
END;

CREATE TRIGGER update_conversation_keyword_frequency
AFTER INSERT ON message_keywords
BEGIN
    INSERT OR REPLACE INTO conversation_keywords (conversation_id, keyword_id, frequency, last_mention)
    SELECT m.conversation_id, NEW.keyword_id, 
           COALESCE((SELECT frequency FROM conversation_keywords 
                    WHERE conversation_id = m.conversation_id 
                    AND keyword_id = NEW.keyword_id), 0) + 1,
           strftime('%s', 'now')
    FROM messages m 
    WHERE m.id = NEW.message_id;
END;

-- =====================================
-- INITIAL DATA
-- =====================================

-- Insert default categories
INSERT INTO categories (name, description, color) VALUES
('Locations', 'Where things are placed or found', '#FF6B6B'),
('Numbers', 'Account numbers, serial numbers, VINs', '#4ECDC4'),
('Secrets', 'Passwords, PINs, sensitive information', '#45B7D1'),
('History', 'Past events, dates, timeline items', '#96CEB4'),
('Tasks', 'Reminders, todos, work items', '#FFEAA7'),
('Journal', 'Personal thoughts and daily entries', '#DDA0DD'),
('Inventory', 'Items, quantities, consumption tracking', '#98D8C8'),
('Ideas', 'Brainstorming, creative thoughts', '#F7DC6F'),
('People', 'Contacts, relationships, social interactions', '#BB8FCE'),
('Health', 'Medical info, symptoms, appointments', '#85C1E9');

-- Insert default item categories
INSERT INTO item_categories (name) VALUES
('Food & Beverages'),
('Household Supplies'),
('Personal Care'),
('Electronics'),
('Tools & Hardware'),
('Clothing'),
('Books & Media'),
('Health & Medicine'),
('Office Supplies'),
('Other');

-- Insert default locations
INSERT INTO locations (name, description) VALUES
('Pantry', 'Kitchen pantry storage'),
('Refrigerator', 'Main refrigerator'),
('Freezer', 'Freezer compartment'),
('Kitchen Cabinet', 'Kitchen storage cabinets'),
('Bedroom Closet', 'Main bedroom closet'),
('Garage', 'Garage storage area'),
('Basement', 'Basement storage'),
('Office', 'Home office space'),
('Living Room', 'Living room storage'),
('Bathroom', 'Bathroom storage');

-- Insert default settings
INSERT INTO settings (key, value, category, data_type) VALUES
('device_id', '', 'system', 'string'),
('device_name', '', 'system', 'string'),
('ai_enabled', 'true', 'ai', 'boolean'),
('inventory_mode_enabled', 'true', 'features', 'boolean'),
('forget_keyword_enabled', 'true', 'privacy', 'boolean'),
('auto_categorization', 'true', 'ai', 'boolean'),
('pattern_recognition', 'true', 'ai', 'boolean'),
('sync_enabled', 'false', 'sync', 'boolean'),
('sync_port', '8080', 'sync', 'integer'),
('sync_discovery_enabled', 'true', 'sync', 'boolean'),
('encryption_enabled', 'true', 'security', 'boolean'),
('default_search_limit', '50', 'ui', 'integer'),
('conversation_archive_days', '365', 'storage', 'integer'),
('low_inventory_threshold', '2', 'inventory', 'integer');

-- =====================================
-- VIEWS FOR COMMON QUERIES
-- =====================================

-- Current inventory summary by location
CREATE VIEW inventory_summary AS
SELECT 
    l.name as location_name,
    i.name as item_name,
    i.brand,
    inv.quantity,
    inv.expiry_date,
    CASE 
        WHEN inv.expiry_date < strftime('%s', 'now') THEN 'expired'
        WHEN inv.expiry_date < strftime('%s', 'now', '+7 days') THEN 'expiring_soon'
        ELSE 'fresh'
    END as freshness_status
FROM inventory inv
JOIN items i ON inv.item_id = i.id
JOIN locations l ON inv.location_id = l.id
WHERE inv.quantity > 0
ORDER BY l.name, i.name;

-- Recent conversations with message counts
CREATE VIEW recent_conversations AS
SELECT 
    c.id,
    c.title,
    c.started_at,
    c.last_message_at,
    COUNT(m.id) as message_count,
    d.name as device_name
FROM conversations c
JOIN messages m ON c.id = m.conversation_id
JOIN devices d ON c.device_id = d.id
WHERE c.forgotten = 0
GROUP BY c.id
ORDER BY c.last_message_at DESC;

-- Consumption rates for predictive insights
CREATE VIEW consumption_rates AS
SELECT 
    i.name as item_name,
    i.unit,
    COUNT(t.id) as transaction_count,
    SUM(ABS(t.change_amount)) as total_consumed,
    AVG(ABS(t.change_amount)) as avg_per_transaction,
    (julianday('now') - julianday(MIN(t.timestamp), 'unixepoch')) as days_tracked,
    SUM(ABS(t.change_amount)) / NULLIF((julianday('now') - julianday(MIN(t.timestamp), 'unixepoch')), 0) as daily_rate
FROM items i
JOIN inventory_transactions t ON i.id = t.item_id
WHERE t.transaction_type = 'use' AND t.timestamp > strftime('%s', 'now', '-90 days')
GROUP BY i.id
HAVING COUNT(t.id) >= 2;

-- Keyword search summary view
CREATE VIEW keyword_search AS
SELECT 
    k.keyword,
    k.normalized_keyword,
    k.frequency,
    k.last_used,
    COUNT(DISTINCT mk.message_id) as message_count,
    COUNT(DISTINCT ik.item_id) as item_count,
    COUNT(DISTINCT ek.entity_id) as entity_count,
    COUNT(DISTINCT ck.conversation_id) as conversation_count,
    COUNT(DISTINCT ink.insight_id) as insight_count
FROM keywords k
LEFT JOIN message_keywords mk ON k.id = mk.keyword_id
LEFT JOIN item_keywords ik ON k.id = ik.keyword_id
LEFT JOIN entity_keywords ek ON k.id = ek.keyword_id
LEFT JOIN conversation_keywords ck ON k.id = ck.keyword_id
LEFT JOIN insight_keywords ink ON k.id = ink.keyword_id
GROUP BY k.id
ORDER BY k.frequency DESC;

-- Available devices for sync
CREATE VIEW available_devices AS
SELECT 
    id,
    name,
    type,
    hostname,
    ip_address,
    port,
    sync_endpoint,
    network_type,
    is_online,
    last_seen,
    CASE 
        WHEN last_seen > strftime('%s', 'now', '-5 minutes') THEN 'online'
        WHEN last_seen > strftime('%s', 'now', '-1 hour') THEN 'recent'
        WHEN last_seen > strftime('%s', 'now', '-1 day') THEN 'today'
        ELSE 'offline'
    END as connection_status,
    (strftime('%s', 'now') - last_seen) as seconds_since_seen
FROM devices
WHERE id != (SELECT value FROM settings WHERE key = 'device_id')  -- Exclude self
ORDER BY is_online DESC, last_seen DESC;

-- =====================================
-- SCHEMA VERSION
-- =====================================

INSERT INTO settings (key, value, category) VALUES ('schema_version', '1.0', 'system');