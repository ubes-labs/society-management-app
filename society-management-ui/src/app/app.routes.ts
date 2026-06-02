import { Routes } from '@angular/router';
import { appRoutes, authGuard } from './core';

export const routes: Routes = [
  {
    path: appRoutes.LOGIN,
    loadComponent: () => import('./features/login/login').then((c) => c.Login),
  },
  {
    path: appRoutes.DASHBOARD,
    canActivate: [authGuard],
    loadComponent: () => import('./features/dashboard/dashboard').then((c) => c.Dashboard),
  },
  {
    path: appRoutes.LOGOUT,
    loadComponent: () => import('./features/logout/logout').then((c) => c.Logout),
  },
  {
    path: '**',
    redirectTo: appRoutes.DASHBOARD,
  },
];
