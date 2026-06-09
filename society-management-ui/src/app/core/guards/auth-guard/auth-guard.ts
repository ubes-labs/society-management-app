import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../../services/auth/auth.service';
import { navMenuItems } from '../../const/nav-const/nav.const';

export const authGuard: CanActivateFn = async () => {
  const authService = inject(AuthService);
  const router = inject(Router);

  const isSessionInitialized = await authService.isSessionInitialized();
  return isSessionInitialized ? true : router.navigate([navMenuItems.login.route]);
};
