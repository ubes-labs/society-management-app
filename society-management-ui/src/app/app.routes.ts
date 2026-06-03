import { Routes } from '@angular/router';
import { authGuard, navRoutes } from './core';

const appTitle = 'Society Management System';

export const routes: Routes = [
  {
    path: navRoutes.login.route,
    title: `${navRoutes.login.label} | ${appTitle}`,
    loadComponent: () => import('./features/login/login').then((c) => c.Login),
  },
  {
    path: navRoutes.dashboard.route,
    canActivate: [authGuard],
    title: `${navRoutes.dashboard.label} | ${appTitle}`,
    loadComponent: () => import('./features/dashboard/dashboard').then((c) => c.Dashboard),
  },
  {
    path: '**',
    redirectTo: navRoutes.dashboard.route,
  },
];
