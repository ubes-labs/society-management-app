import { appRoutes } from '../route-const/route.const';

export const navRoutes = {
  dashboard: {
    label: 'Dashboard',
    route: appRoutes.DASHBOARD,
    icon: 'home',
  },
  logout: {
    label: 'Logout',
    route: appRoutes.LOGOUT,
    icon: 'account_circle',
  },
};
