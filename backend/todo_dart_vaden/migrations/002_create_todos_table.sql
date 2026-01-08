-- Migration: Create Todos Table
-- Date: 2026-01-08
-- Description: Creates the todos table with foreign key to users and soft delete support

CREATE TABLE IF NOT EXISTS todos (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL
);

-- Indexes for performance
CREATE INDEX idx_todos_user_id ON todos(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_todos_completed ON todos(completed) WHERE deleted_at IS NULL;
CREATE INDEX idx_todos_created_at ON todos(created_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_todos_deleted_at ON todos(deleted_at);

-- Comment
COMMENT ON TABLE todos IS 'Stores todo/task items for users';
COMMENT ON COLUMN todos.user_id IS 'Foreign key to users table';
COMMENT ON COLUMN todos.completed IS 'Task completion status';
COMMENT ON COLUMN todos.deleted_at IS 'Soft delete timestamp (NULL if active)';
