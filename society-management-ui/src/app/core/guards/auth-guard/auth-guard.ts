import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../../services/auth/auth.service';
import { appRoutes } from '../../const/route-const/route.const';

export const authGuard: CanActivateFn = () => {
  const authService = inject(AuthService);
  const router = inject(Router);

  return !authService.user() ? router.navigate([appRoutes.LOGIN]) : true;
};
