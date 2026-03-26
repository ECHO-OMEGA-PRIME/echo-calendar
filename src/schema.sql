-- Echo Calendar — AI-Powered Calendar & Scheduling Platform
-- D1 Schema

CREATE TABLE IF NOT EXISTS calendars (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tenant_id TEXT NOT NULL DEFAULT 'default',
  owner_id TEXT NOT NULL,
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  description TEXT,
  color TEXT DEFAULT '#0d7377',
  timezone TEXT DEFAULT 'America/Chicago',
  default_duration INTEGER DEFAULT 30,
  min_notice_hours INTEGER DEFAULT 1,
  max_advance_days INTEGER DEFAULT 60,
  buffer_before INTEGER DEFAULT 0,
  buffer_after INTEGER DEFAULT 5,
  availability JSON DEFAULT '{}',
  settings JSON DEFAULT '{}',
  is_public INTEGER DEFAULT 0,
  total_events INTEGER DEFAULT 0,
  total_bookings INTEGER DEFAULT 0,
  status TEXT DEFAULT 'active',
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  calendar_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  location TEXT,
  meeting_url TEXT,
  start_time TEXT NOT NULL,
  end_time TEXT NOT NULL,
  all_day INTEGER DEFAULT 0,
  timezone TEXT DEFAULT 'America/Chicago',
  recurrence_rule TEXT,
  recurrence_end TEXT,
  parent_event_id INTEGER,
  color TEXT,
  attendees JSON DEFAULT '[]',
  reminders JSON DEFAULT '[{"minutes":15,"type":"email"}]',
  metadata JSON DEFAULT '{}',
  status TEXT DEFAULT 'confirmed',
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_events_calendar ON events(calendar_id, status);
CREATE INDEX IF NOT EXISTS idx_events_time ON events(start_time, end_time);

CREATE TABLE IF NOT EXISTS booking_types (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  calendar_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  slug TEXT NOT NULL,
  description TEXT,
  duration INTEGER DEFAULT 30,
  color TEXT DEFAULT '#0d7377',
  price REAL DEFAULT 0,
  currency TEXT DEFAULT 'USD',
  location_type TEXT DEFAULT 'video',
  location_value TEXT,
  questions JSON DEFAULT '[]',
  availability_override JSON,
  max_per_day INTEGER DEFAULT 10,
  requires_approval INTEGER DEFAULT 0,
  confirmation_message TEXT,
  total_bookings INTEGER DEFAULT 0,
  status TEXT DEFAULT 'active',
  created_at TEXT DEFAULT (datetime('now')),
  UNIQUE(calendar_id, slug)
);

CREATE TABLE IF NOT EXISTS bookings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  booking_type_id INTEGER NOT NULL,
  calendar_id INTEGER NOT NULL,
  event_id INTEGER,
  guest_name TEXT NOT NULL,
  guest_email TEXT NOT NULL,
  guest_phone TEXT,
  guest_timezone TEXT,
  start_time TEXT NOT NULL,
  end_time TEXT NOT NULL,
  answers JSON DEFAULT '{}',
  notes TEXT,
  meeting_url TEXT,
  cancel_token TEXT,
  reschedule_token TEXT,
  status TEXT DEFAULT 'confirmed',
  cancelled_reason TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_bookings_calendar ON bookings(calendar_id, status);
CREATE INDEX IF NOT EXISTS idx_bookings_time ON bookings(start_time);
CREATE INDEX IF NOT EXISTS idx_bookings_email ON bookings(guest_email);

CREATE TABLE IF NOT EXISTS availability_rules (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  calendar_id INTEGER NOT NULL,
  day_of_week INTEGER,
  start_time TEXT NOT NULL,
  end_time TEXT NOT NULL,
  is_override INTEGER DEFAULT 0,
  override_date TEXT,
  status TEXT DEFAULT 'active',
  created_at TEXT DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_avail_calendar ON availability_rules(calendar_id);

CREATE TABLE IF NOT EXISTS team_members (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  calendar_id INTEGER NOT NULL,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  role TEXT DEFAULT 'member',
  can_edit INTEGER DEFAULT 0,
  status TEXT DEFAULT 'active',
  created_at TEXT DEFAULT (datetime('now')),
  UNIQUE(calendar_id, user_id)
);

CREATE TABLE IF NOT EXISTS reminders_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  event_id INTEGER NOT NULL,
  booking_id INTEGER,
  send_at TEXT NOT NULL,
  type TEXT DEFAULT 'email',
  recipient TEXT NOT NULL,
  subject TEXT,
  body TEXT,
  status TEXT DEFAULT 'pending',
  sent_at TEXT,
  created_at TEXT DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_reminders_send ON reminders_queue(send_at, status);

CREATE TABLE IF NOT EXISTS analytics_daily (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  calendar_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  events_created INTEGER DEFAULT 0,
  bookings_made INTEGER DEFAULT 0,
  bookings_cancelled INTEGER DEFAULT 0,
  page_views INTEGER DEFAULT 0,
  top_booking_type TEXT,
  UNIQUE(calendar_id, date)
);

CREATE TABLE IF NOT EXISTS activity_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  calendar_id INTEGER,
  actor TEXT,
  action TEXT NOT NULL,
  target TEXT,
  details TEXT,
  created_at TEXT DEFAULT (datetime('now'))
);
