CREATE TABLE IF NOT EXISTS public.permission (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    permission_code TEXT NOT NULL UNIQUE,
    description TEXT,
    enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL,
    created_by uuid NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    updated_by uuid NOT NULL
);

Insert into public.permission (permission_code, description, created_at, created_by, updated_at, updated_by) values 
('society.view', 'Permission to view society details', NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
('society.manage', 'Permission to manage society details', NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
('society_location.view', 'Permission to view society location details', NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
('society_location.manage', 'Permission to manage society location details', NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
('society_location_unit.view', 'Permission to view society location unit details', NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
('society_location_unit.manage', 'Permission to manage society location unit details', NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
('apartment.view', 'Permission to view apartment details', NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
('apartment.manage', 'Permission to manage apartment details', NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
('all', 'Permission to manage all aspects', NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001');

CREATE TABLE IF NOT EXISTS public.role (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    role_code TEXT NOT NULL UNIQUE,
    description TEXT,
    enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL,
    created_by uuid NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    updated_by uuid NOT NULL
);

Insert into public.role (role_code, description, created_at, created_by, updated_at, updated_by) values 
('admin', 'Administrator role with full permissions', NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
('super', 'Super Admin role with extensive permissions', NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
('viewer', 'Viewer role with read-only permissions', NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001');

CREATE TABLE IF NOT EXISTS public.role_permission (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    role_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL,
    created_by uuid NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    updated_by uuid NOT NULL,

    CONSTRAINT uq_role_permission  UNIQUE (role_id, permission_id),
    CONSTRAINT fk_role_permission_role FOREIGN KEY (role_id) REFERENCES public.role(id),
    CONSTRAINT fk_role_permission_permission FOREIGN KEY (permission_id) REFERENCES public.permission(id)
);

Insert into public.role_permission (role_id, permission_id, created_at, created_by, updated_at, updated_by) values 
((SELECT id FROM public.role WHERE role_code = 'admin'), (SELECT id FROM public.permission WHERE permission_code = 'society.view'), NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
((SELECT id FROM public.role WHERE role_code = 'admin'), (SELECT id FROM public.permission WHERE permission_code = 'society.manage'), NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
((SELECT id FROM public.role WHERE role_code = 'admin'), (SELECT id FROM public.permission WHERE permission_code = 'society_location.view'), NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
((SELECT id FROM public.role WHERE role_code = 'admin'), (SELECT id FROM public.permission WHERE permission_code = 'society_location.manage'), NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
((SELECT id FROM public.role WHERE role_code = 'admin'), (SELECT id FROM public.permission WHERE permission_code = 'society_location_unit.view'), NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
((SELECT id FROM public.role WHERE role_code = 'admin'), (SELECT id FROM public.permission WHERE permission_code = 'society_location_unit.manage'), NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
((SELECT id FROM public.role WHERE role_code = 'admin'), (SELECT id FROM public.permission WHERE permission_code = 'apartment.view'), NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
((SELECT id FROM public.role WHERE role_code = 'admin'), (SELECT id FROM public.permission WHERE permission_code = 'apartment.manage'), NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),

((SELECT id FROM public.role WHERE role_code = 'super'), (SELECT id FROM public.permission WHERE permission_code = 'all'), NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),

((SELECT id FROM public.role WHERE role_code = 'viewer'), (SELECT id FROM public.permission WHERE permission_code = 'society.view'), NOW(), '22222222-2222-2222-2222-222222222222', NOW(), '22222222-2222-2222-2222-222222222222'),
((SELECT id FROM public.role WHERE role_code = 'viewer'), (SELECT id FROM public.permission WHERE permission_code = 'society_location.view'), NOW(), '22222222-2222-2222-2222-222222222222', NOW(), '22222222-2222-2222-2222-222222222222'),
((SELECT id FROM public.role WHERE role_code = 'viewer'), (SELECT id FROM public.permission WHERE permission_code = 'society_location_unit.view'), NOW(), '33333333-3333-3333-3333-333333333333', NOW(), '33333333-3333-3333-3333-333333333333'),
((SELECT id FROM public.role WHERE role_code = 'viewer'), (SELECT id FROM public.permission WHERE permission_code = 'apartment.view'), NOW(), '33333333-3333-3333-3333-333333333333', NOW(), '33333333-3333-3333-3333-333333333333');

CREATE TABLE IF NOT EXISTS public.society (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    contact_email TEXT NOT NULL,
    contact_phone TEXT NOT NULL,
    website_url TEXT,
    completion_date TIMESTAMPTZ NOT NULL,
    builder TEXT NOT NULL,
    promoter TEXT,
    enabled BOOLEAN DEFAULT TRUE,
    deleted BOOLEAN DEFAULT FALSE,
    status TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    created_by uuid NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    updated_by uuid NOT NULL,

    CONSTRAINT fk_society_user_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id),
    CONSTRAINT fk_society_user_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id)
);
alter table public.society enable row level security;

CREATE TABLE IF NOT EXISTS public.society_location (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    postal_code TEXT NOT NULL,
    country TEXT NOT NULL,
    district TEXT,
    society_id BIGINT NOT NULL,
    enabled BOOLEAN DEFAULT TRUE,
    deleted BOOLEAN DEFAULT FALSE,
    status TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    created_by uuid NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    updated_by uuid NOT NULL,

    CONSTRAINT fk_society_location_society FOREIGN KEY (society_id) REFERENCES public.society(id),    
    CONSTRAINT fk_society_location_user_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id),
    CONSTRAINT fk_society_location_user_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id)
);
alter table public.society_location enable row level security;

CREATE TABLE IF NOT EXISTS public.society_location_unit (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    society_location_id BIGINT NOT NULL,
    enabled BOOLEAN DEFAULT TRUE,
    deleted BOOLEAN DEFAULT FALSE,
    status TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    created_by uuid NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    updated_by uuid NOT NULL,

    CONSTRAINT fk_society_location_unit_society_location FOREIGN KEY (society_location_id) REFERENCES public.society_location(id),    
    CONSTRAINT fk_society_location_unit_user_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id),
    CONSTRAINT fk_society_location_unit_user_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id)
);
alter table public.society_location_unit enable row level security;

CREATE TABLE IF NOT EXISTS public.apartment (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name TEXT NOT NULL,
    floor INTEGER,
    type TEXT,
    size NUMERIC(10,2),
    initial_sell_price NUMERIC(12,2),
    society_location_unit_id BIGINT NOT NULL,
    society_location_id BIGINT NOT NULL,
    enabled BOOLEAN DEFAULT TRUE,
    deleted BOOLEAN DEFAULT FALSE,
    status TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    created_by uuid NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    updated_by uuid NOT NULL,

    CONSTRAINT fk_apartment_society_location FOREIGN KEY (society_location_id) REFERENCES public.society_location(id),
    CONSTRAINT fk_apartment_society_location_unit FOREIGN KEY (society_location_unit_id) REFERENCES public.society_location_unit(id),    
    CONSTRAINT fk_apartment_user_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id),
    CONSTRAINT fk_apartment_user_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id)
);
alter table public.apartment enable row level security;

CREATE TABLE IF NOT EXISTS public.society_location_user_role_permission (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id uuid NOT NULL,
    role_permission_id BIGINT NOT NULL,
    society_location_id BIGINT NOT NULL,
    enabled BOOLEAN DEFAULT TRUE,
    deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL,
    created_by uuid NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    updated_by uuid NOT NULL,

    CONSTRAINT fk_society_location_user_role_permission_role_permission_id 
        FOREIGN KEY (role_permission_id) REFERENCES public.role_permission(id),
    CONSTRAINT fk_society_location_user_role_permission_society_location 
        FOREIGN KEY (society_location_id) REFERENCES public.society_location(id),
    CONSTRAINT fk_society_location_user_role_permission_user
        FOREIGN KEY (user_id) REFERENCES auth.users(id),
    CONSTRAINT fk_society_location_user_role_permission_user_created_by 
        FOREIGN KEY (created_by) REFERENCES auth.users(id),
    CONSTRAINT fk_society_location_user_role_permission_user_updated_by
        FOREIGN KEY (updated_by) REFERENCES auth.users(id)
);
alter table public.society_location_user_role_permission enable row level security;