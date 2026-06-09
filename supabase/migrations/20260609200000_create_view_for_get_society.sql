Drop policy if exists society_location_user_role_permission_select on public.society_location_user_role_permission;
CREATE POLICY society_location_user_role_permission_select
ON public.society_location_user_role_permission
FOR SELECT
TO authenticated
USING (user_id = (select auth.uid()));

CREATE INDEX IF NOT EXISTS idx_apartment_society_location_id ON public.apartment (society_location_id);
CREATE INDEX IF NOT EXISTS idx_apartment_society_location_unit_id ON public.apartment (society_location_unit_id);
CREATE INDEX IF NOT EXISTS idx_apartment_created_by ON public.apartment (created_by);
CREATE INDEX IF NOT EXISTS idx_apartment_updated_by ON public.apartment (updated_by);

CREATE INDEX IF NOT EXISTS idx_society_location_unit_updated_by 
ON public.society_location_unit (society_location_id);
CREATE INDEX IF NOT EXISTS idx_society_location_unit_created_by ON public.society_location_unit (created_by);
CREATE INDEX IF NOT EXISTS idx_society_location_unit_updated_by ON public.society_location_unit (updated_by);

CREATE INDEX IF NOT EXISTS idx_society_location_society_id ON public.society_location (society_id);
CREATE INDEX IF NOT EXISTS idx_society_location_created_by ON public.society_location (created_by);
CREATE INDEX IF NOT EXISTS idx_society_location_updated_by ON public.society_location (updated_by);

CREATE INDEX IF NOT EXISTS idx_society_created_by ON public.society (created_by);
CREATE INDEX IF NOT EXISTS idx_society_updated_by ON public.society (updated_by);

CREATE INDEX IF NOT EXISTS idx_role_permission_permission_id ON public.role_permission (permission_id);

CREATE INDEX IF NOT EXISTS idx_society_location_user_role_permission_role_id
ON public.society_location_user_role_permission (role_id);
CREATE INDEX IF NOT EXISTS idx_society_location_user_role_permission_society_location_id
ON public.society_location_user_role_permission (society_location_id);
CREATE INDEX IF NOT EXISTS idx_society_location_user_role_permission_user_id
ON public.society_location_user_role_permission (user_id);
CREATE INDEX IF NOT EXISTS idx_society_location_user_role_permission_created_by
ON public.society_location_user_role_permission (created_by);
CREATE INDEX IF NOT EXISTS idx_society_location_user_role_permission_updated_by
ON public.society_location_user_role_permission (updated_by);

-------------------------------------------------------------------------------------------------------------

alter table public.permission enable row level security;
alter table public.role enable row level security;
alter table public.role_permission enable row level security;

---------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE VIEW public.v_get_society_society_locations
WITH (security_invoker = true)
AS
SELECT * FROM public.society s;

GRANT SELECT ON public.v_get_society_society_locations TO authenticated;