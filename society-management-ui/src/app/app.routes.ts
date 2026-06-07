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
    path: navMenuItems.society.route,
    children: [
      {
        path: '',
        canActivate: [authGuard],
        title: `${navMenuItems.society.label} | ${appConst.appTitle}`,
        loadComponent: () => import('./features/society/society').then((c) => c.Society),
      },
      {
        path: navMenuItems.societyManage.route,
        canActivate: [authGuard],
        title: `${navMenuItems.societyManage.label} | ${appConst.appTitle}`,
        loadComponent: () =>
          import('./features/society-manage/society-manage').then((c) => c.SocietyManage),
      },
    ],
  },
  {
    path: '**',
    redirectTo: navMenuItems.dashboard.route,
  },
];
