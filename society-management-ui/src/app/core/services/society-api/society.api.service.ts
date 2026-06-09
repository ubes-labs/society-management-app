import { inject, Injectable } from '@angular/core';
import { AuthService } from '../auth/auth.service';

@Injectable({ providedIn: 'root' })
export class SocietyApiService {
  private readonly _authService = inject(AuthService);

  private readonly _createInitialSocietyFn = 'f_create_initial_society';
  private readonly _getSocietySocietyLocationView = 'v_get_society_society_locations';

  async createSociety(args: Record<string, unknown>) {
    return this._authService._supabase.rpc(this._createInitialSocietyFn, args);
  }

  async getSociety() {
    return this._authService._supabase.from(this._getSocietySocietyLocationView).select('*');
  }
}
