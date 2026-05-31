import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: 'first-page',
    loadComponent: () => import('./features/first-page/first-page').then((m) => m.FirstPage),
  },
  {
    path: 'second-page',
    loadComponent: () => import('./features/second-page/second-page').then((m) => m.SecondPage),
  },
];
