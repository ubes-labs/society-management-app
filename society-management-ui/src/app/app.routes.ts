import { Routes } from '@angular/router';
import { appConst, authGuard, navMenuItems } from './core';

export const routes: Routes = [
  {
    path: navMenuItems.login.route,
    title: `${navMenuItems.login.label} | ${appConst.appTitle}`,
    loadComponent: () => import('./features/login/login').then((c) => c.Login),
  },
  {
    path: navMenuItems.dashboard.route,
    canActivate: [authGuard],
    title: `${navMenuItems.dashboard.label} | ${appConst.appTitle}`,
    loadComponent: () => import('./features/dashboard/dashboard').then((c) => c.Dashboard),
  },
  {
    path: '**',
    redirectTo: navMenuItems.dashboard.route,
  },
];
