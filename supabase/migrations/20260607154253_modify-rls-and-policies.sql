Insert into public.role (role_code, description, created_at, created_by, updated_at, updated_by) values 
('regional_admin', 'Regional Admin role with extensive permissions', NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001');

Insert into public.role_permission (role_id, permission_id, created_at, created_by, updated_at, updated_by) values 
((SELECT id FROM public.role WHERE role_code = 'regional_admin'), (SELECT id FROM public.permission WHERE permission_code = 'society_location.view'), NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
((SELECT id FROM public.role WHERE role_code = 'regional_admin'), (SELECT id FROM public.permission WHERE permission_code = 'society_location.manage'), NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
((SELECT id FROM public.role WHERE role_code = 'regional_admin'), (SELECT id FROM public.permission WHERE permission_code = 'society_location_unit.view'), NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
((SELECT id FROM public.role WHERE role_code = 'regional_admin'), (SELECT id FROM public.permission WHERE permission_code = 'society_location_unit.manage'), NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
((SELECT id FROM public.role WHERE role_code = 'regional_admin'), (SELECT id FROM public.permission WHERE permission_code = 'apartment.view'), NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001'),
((SELECT id FROM public.role WHERE role_code = 'regional_admin'), (SELECT id FROM public.permission WHERE permission_code = 'apartment.manage'), NOW(), '00000000-0000-0000-0000-000000000001', NOW(), '00000000-0000-0000-0000-000000000001');

------------------------------------------------------------------------------------------------------------------

ALTER TABLE public.society_location_user_role_permission
    DROP CONSTRAINT IF EXISTS fk_society_location_user_role_permission_role_permission_id,
    DROP COLUMN IF EXISTS role_permission_id,
    ADD COLUMN IF NOT EXISTS role_id BIGINT NOT NULL;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_society_location_user_role_permission_role'
    ) THEN
        ALTER TABLE public.society_location_user_role_permission
        ADD CONSTRAINT fk_society_location_user_role_permission_role FOREIGN KEY (role_id) REFERENCES public.role(id);
    END IF;
END $$;

------------------------------------------------------------------------------------------------------------------

create or replace function public.has_any_permissions(
    p_society_location_id bigint, 
    p_permission_codes text[]
) 
returns boolean 
Language sql 
STABLE
SECURITY DEFINER
SET search_path = public
AS
$$
    select exists (
        select 1
        from public.society_location_user_role_permission s
        join public.role r on s.role_id = r.id and r.enabled = true
        join public.role_permission rp on s.role_id = rp.role_id and rp.enabled = true
        join public.permission p on rp.permission_id = p.id and p.enabled = true        
        where 
            s.user_id = auth.uid() and
            s.society_location_id = p_society_location_id and
            p.permission_code = any(p_permission_codes) and
            s.enabled = true and
            s.deleted = false
    );
$$;

create or replace function public.society_manage_has_any_permissions(
    p_society_id bigint, 
    p_permission_codes text[]
) 
returns boolean 
Language sql 
STABLE
SECURITY DEFINER
SET search_path = public
AS
$$
    select exists (
        select 1
        from public.society sc
        join public.society_location sl on sc.id = sl.society_id and sl.enabled = true and sl.deleted = false
        join public.society_location_user_role_permission s on sl.id = s.society_location_id and s.enabled = true and s.deleted = false
        join public.role r on s.role_id = r.id and r.enabled = true
        join public.role_permission rp on s.role_id = rp.role_id and rp.enabled = true
        join public.permission p on rp.permission_id = p.id and p.enabled = true       
        where 
            s.user_id = auth.uid() and
            sc.id = p_society_id and
            p.permission_code = any(p_permission_codes) and
            sc.enabled = true and
            sc.deleted = false
    );
$$;

-- for public. apartment
Drop policy if exists apartment_select on public.apartment;
Create policy apartment_select on public.apartment  for select to authenticated using (
    public.has_any_permissions(
        society_location_id, 
        ARRAY['apartment.view']
    )
);

Drop policy if exists apartment_update on public.apartment;
Create policy apartment_update on public.apartment  for update to authenticated using (
    public.has_any_permissions(
        society_location_id, 
        ARRAY['apartment.manage']
    )
) WITH CHECK (
    public.has_any_permissions(
        society_location_id,
        ARRAY['apartment.manage']
    )
);

Drop policy if exists apartment_insert on public.apartment;
Create policy apartment_insert on public.apartment  for insert to authenticated WITH CHECK (
    public.has_any_permissions(
        society_location_id,
        ARRAY['apartment.manage']
    )
);

-- for public.society_location_unit
Drop policy if exists society_location_unit_select on public.society_location_unit;
Create policy society_location_unit_select on public.society_location_unit  for select to authenticated using (
    public.has_any_permissions(
        society_location_id, 
        ARRAY['society_location_unit.view']
    )
);

Drop policy if exists society_location_unit_update on public.society_location_unit;
Create policy society_location_unit_update on public.society_location_unit  for update to authenticated using (
    public.has_any_permissions(
        society_location_id, 
        ARRAY['society_location_unit.manage']
    )
) WITH CHECK (
    public.has_any_permissions(
        society_location_id,
        ARRAY['society_location_unit.manage']
    )
);

Drop policy if exists society_location_unit_insert on public.society_location_unit;
Create policy society_location_unit_insert on public.society_location_unit  for insert to authenticated WITH CHECK (
    public.has_any_permissions(
        society_location_id,
        ARRAY['society_location_unit.manage']
    )
);

-- for public.society_location
Drop policy if exists society_location_select on public.society_location;
Create policy society_location_select on public.society_location  for select to authenticated using (true);

Drop policy if exists society_location_update on public.society_location;
Create policy society_location_update on public.society_location  for update to authenticated using (
    public.has_any_permissions(
        id, 
        ARRAY['society_location.manage']
    )
) WITH CHECK (
    public.has_any_permissions(
        id,
        ARRAY['society_location.manage']
    )
);

-- for public.society
Drop policy if exists society_select on public.society;
Create policy society_select on public.society  for select to authenticated using (true);

Drop policy if exists society_update on public.society;
Create policy society_update on public.society  for update to authenticated using (
    public.society_manage_has_any_permissions(
        id, 
        ARRAY['society.manage']
    )
) WITH CHECK (
    public.society_manage_has_any_permissions(
        id,
        ARRAY['society.manage']
    )
);

-- for public.society_location_user_role_permission
Drop policy if exists society_location_user_role_permission_select on public.society_location_user_role_permission;
Create policy society_location_user_role_permission_select on public.society_location_user_role_permission for select to authenticated 
using (true);

Drop policy if exists society_location_user_role_permission_update on public.society_location_user_role_permission;
Create policy society_location_user_role_permission_update on public.society_location_user_role_permission for update to authenticated 
using (
    public.has_any_permissions(
        society_location_id, 
        ARRAY['society_location.manage']
    )
) WITH CHECK (
    public.has_any_permissions(
        society_location_id,
        ARRAY['society_location.manage']
    )
);

-- for public.role_permission
Drop policy if exists role_permission_select on public.role_permission;
Create policy role_permission_select on public.role_permission for select to authenticated using (true);

-- for public.role
Drop policy if exists role_select on public.role;
Create policy role_select on public.role for select to authenticated using (true);

-- for public.permission
Drop policy if exists permission_select on public.permission;
Create policy permission_select on public.permission for select to authenticated using (true);

-----------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.f_create_initial_society(
    p_name TEXT,
    p_description TEXT,
    p_contact_email TEXT,
    p_contact_phone TEXT,
    p_website_url TEXT,
    p_completion_date TIMESTAMPTZ,
    p_builder TEXT,
    p_promoter TEXT,
    p_society_status TEXT,
    p_address TEXT,
    p_city TEXT,
    p_state TEXT,
    p_postal_code TEXT,
    p_country TEXT,
    p_district TEXT,
    p_location_status TEXT
)
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_society_id bigint;
    v_location_id bigint;
    v_admin_role_id bigint;
    v_regional_admin_role_id bigint;
BEGIN

    -- create society

    INSERT INTO public.society
    (
        name,
        description,
        contact_email,
        contact_phone,
        website_url,
        completion_date,
        builder,
        promoter,
        status,
        created_at,
        created_by,
        updated_by
    )
    VALUES
    (
        p_name,
        p_description,
        p_contact_email,
        p_contact_phone,
        p_website_url,
        p_completion_date,
        p_builder,
        p_promoter,
        p_society_status,
        NOW(),
        auth.uid(),
        auth.uid()
    )
    RETURNING id
    INTO v_society_id;

    -- create first location

    INSERT INTO public.society_location
    (
        society_id,
        address,
        city,
        state,
        country,
        postal_code,
        district,
        created_by,
        created_at,
        updated_by,
        status
    )
    VALUES
    (
        v_society_id,
        p_address,
        p_city,
        p_state,
        p_country,
        p_postal_code,
        p_district,
        auth.uid(),
        NOW(),
        auth.uid(),
        p_location_status
    )
    RETURNING id
    INTO v_location_id;

    -- find regional admin role and admin role

    SELECT id INTO v_regional_admin_role_id FROM public.role WHERE role_code = 'regional_admin';
    SELECT id INTO v_admin_role_id FROM public.role WHERE role_code = 'admin';

    -- assign creator as regional admin and admin for the created location

    INSERT INTO public.society_location_user_role_permission
    (
        user_id,
        role_id,
        society_location_id,
        created_at,
        created_by,
        updated_by
    )
    VALUES
    (
        auth.uid(),
        v_admin_role_id,
        v_location_id,
        NOW(),
        auth.uid(),
        auth.uid()
    ),
    (
        auth.uid(),
        v_regional_admin_role_id,
        v_location_id,
        NOW(),
        auth.uid(),
        auth.uid()
    );

    RETURN v_society_id;
END;
$$;

CREATE OR REPLACE VIEW public.v_get_user_society_permissions AS
SELECT
    slurp.society_location_id as society_location_id,
    array_agg(DISTINCT p.permission_code) as permission_codes
FROM public.society_location_user_role_permission slurp
JOIN public.role r  ON slurp.role_id = r.id and r.enabled = true
join public.role_permission rp ON slurp.role_id = rp.role_id and rp.enabled = true
join public.permission p ON rp.permission_id = p.id and p.enabled = true
JOIN public.society_location sl  ON slurp.society_location_id = sl.id and sl.enabled = true and sl.deleted = false
WHERE slurp.user_id = auth.uid() AND slurp.enabled = true AND slurp.deleted = false
GROUP BY slurp.society_location_id;