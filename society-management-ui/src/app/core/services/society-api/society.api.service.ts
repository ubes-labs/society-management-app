import { inject, Injectable } from '@angular/core';
import { AuthService } from '../auth/auth.service';

@Injectable({ providedIn: 'root' })
export class SocietyApiService {
  private readonly _authService = inject(AuthService);

  private readonly _createInitialSocietyFn = 'f_create_initial_society';

  async createSociety(args: Record<string, unknown>) {
    return this._authService._supabase.rpc(this._createInitialSocietyFn, args);
  }
}
