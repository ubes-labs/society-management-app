-- =====================================================
-- Schemas
-- =====================================================

CREATE SCHEMA IF NOT EXISTS appAdmin;
CREATE SCHEMA IF NOT EXISTS appSociety;

-- =====================================================
-- Admin Tables
-- =====================================================

CREATE TABLE IF NOT EXISTS appAdmin.permission (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    permission_code TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS appAdmin.role (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    role_code TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS appAdmin.role_permission (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    role_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,

    CONSTRAINT uq_role_permission
        UNIQUE (role_id, permission_id),

    CONSTRAINT fk_role_permission_role
        FOREIGN KEY (role_id)
        REFERENCES appAdmin.role(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_role_permission_permission
        FOREIGN KEY (permission_id)
        REFERENCES appAdmin.permission(id)
        ON DELETE CASCADE
);

-- =====================================================
-- Society Tables
-- =====================================================

CREATE TABLE IF NOT EXISTS appSociety.society (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,

    name TEXT NOT NULL,
    description TEXT NOT NULL,

    contactEmail TEXT NOT NULL,
    contactPhone TEXT NOT NULL,

    websiteUrl TEXT,

    completionDate TIMESTAMPTZ NOT NULL,

    builder TEXT NOT NULL,
    promoter TEXT,

    enabled BOOLEAN DEFAULT TRUE,
    deleted BOOLEAN DEFAULT FALSE,
    status TEXT NOT NULL,

    createdAt TIMESTAMPTZ NOT NULL,
    createdBy TEXT NOT NULL,

    updatedAt TIMESTAMPTZ DEFAULT NOW(),
    updatedBy TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS appSociety.societyLocation (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,

    address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    postalCode TEXT NOT NULL,
    country TEXT NOT NULL,
    district TEXT,

    societyId BIGINT NOT NULL,

    enabled BOOLEAN DEFAULT TRUE,
    deleted BOOLEAN DEFAULT FALSE,
    status TEXT NOT NULL,

    createdAt TIMESTAMPTZ NOT NULL,
    createdBy TEXT NOT NULL,

    updatedAt TIMESTAMPTZ DEFAULT NOW(),
    updatedBy TEXT NOT NULL,

    CONSTRAINT fk_society_location_society
        FOREIGN KEY (societyId)
        REFERENCES appSociety.society(id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS appSociety.societyLocationUnit (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,

    name TEXT NOT NULL,
    description TEXT NOT NULL,

    societyLocationId BIGINT NOT NULL,

    enabled BOOLEAN DEFAULT TRUE,
    deleted BOOLEAN DEFAULT FALSE,
    status TEXT NOT NULL,

    createdAt TIMESTAMPTZ NOT NULL,
    createdBy TEXT NOT NULL,

    updatedAt TIMESTAMPTZ DEFAULT NOW(),
    updatedBy TEXT NOT NULL,

    CONSTRAINT fk_society_location_unit_location
        FOREIGN KEY (societyLocationId)
        REFERENCES appSociety.societyLocation(id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS appSociety.apartment (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,

    name TEXT NOT NULL,

    floor INTEGER,
    type TEXT,
    size NUMERIC(10,2),
    initialSellPrice NUMERIC(12,2),

    societyLocationUnitId BIGINT NOT NULL,
    societyLocationId BIGINT NOT NULL,

    enabled BOOLEAN DEFAULT TRUE,
    deleted BOOLEAN DEFAULT FALSE,
    status TEXT NOT NULL,

    createdAt TIMESTAMPTZ NOT NULL,
    createdBy TEXT NOT NULL,

    updatedAt TIMESTAMPTZ DEFAULT NOW(),
    updatedBy TEXT NOT NULL,

    CONSTRAINT fk_apartment_location
        FOREIGN KEY (societyLocationId)
        REFERENCES appSociety.societyLocation(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_apartment_location_unit
        FOREIGN KEY (societyLocationUnitId)
        REFERENCES appSociety.societyLocationUnit(id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS appAdmin.societyLocationUserRolePermission (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,

    userId TEXT NOT NULL,
    userSub TEXT NOT NULL,

    roleId BIGINT NOT NULL,
    societyLocationId BIGINT NOT NULL,

    enabled BOOLEAN DEFAULT TRUE,
    deleted BOOLEAN DEFAULT FALSE,
    status TEXT NOT NULL,

    createdAt TIMESTAMPTZ NOT NULL,
    createdBy TEXT NOT NULL,

    updatedAt TIMESTAMPTZ DEFAULT NOW(),
    updatedBy TEXT NOT NULL,

    CONSTRAINT fk_user_role_permission_role
        FOREIGN KEY (roleId)
        REFERENCES appAdmin.role(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_user_role_permission_society_location
        FOREIGN KEY (societyLocationId)
        REFERENCES appSociety.societyLocation(id)
        ON DELETE CASCADE
);