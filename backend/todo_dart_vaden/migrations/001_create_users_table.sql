-- Migration: Create Users Table
-- Date: 2026-01-08
-- Description: Creates the users table with proper indexes and constraints

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  roles TEXT[] DEFAULT ARRAY['user'],
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL
);

-- Indexes for performance
CREATE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_created_at ON users(created_at DESC);
CREATE INDEX idx_users_deleted_at ON users(deleted_at);

-- Comment
COMMENT ON TABLE users IS 'Stores user account information';
COMMENT ON COLUMN users.roles IS 'Array of user roles: admin, user';
COMMENT ON COLUMN users.deleted_at IS 'Soft delete timestamp (NULL if active)';
