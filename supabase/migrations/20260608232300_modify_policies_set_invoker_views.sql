CREATE OR REPLACE VIEW public.v_get_user_society_permissions
WITH (security_invoker = true)
AS
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

GRANT SELECT ON public.v_get_user_society_permissions
TO authenticated;

Drop policy if exists society_location_user_role_permission_select on public.society_location_user_role_permission;

CREATE POLICY society_location_user_role_permission_select
ON public.society_location_user_role_permission
FOR SELECT
TO authenticated
USING (
    user_id = auth.uid()
);