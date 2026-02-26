-- docker/init.sql

-- Habilita função gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Apaga as tabelas se já existirem (para dev/testes)
DROP TABLE IF EXISTS todos;
DROP TABLE IF EXISTS users;

-- Cria tabela de usuários (schema superset para compatibilidade entre Java/Go/Dart)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT,
    first_name TEXT,
    last_name TEXT,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    roles TEXT DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Cria tabela de todos (schema superset para compatibilidade entre Java/Go/Dart)
CREATE TABLE todos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE INDEX idx_todos_user_id ON todos(user_id);
CREATE INDEX idx_todos_deleted_at ON todos(deleted_at);
CREATE INDEX idx_users_deleted_at ON users(deleted_at);
