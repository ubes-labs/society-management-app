import { Routes } from '@angular/router';
import { authGuard, navRoutes } from './core';

export const routes: Routes = [
  {
    path: navRoutes.login.route,
    loadComponent: () => import('./features/login/login').then((c) => c.Login),
  },
  {
    path: navRoutes.dashboard.route,
    canActivate: [authGuard],
    loadComponent: () => import('./features/dashboard/dashboard').then((c) => c.Dashboard),
  },
  {
    path: '**',
    redirectTo: navRoutes.dashboard.route,
  },
];
