export const supabaseRedirectToUriResolver = () =>
  window.location.hostname === 'localhost'
    ? 'http://localhost:4200'
    : `${window.location.origin}/society-management-app/`;
