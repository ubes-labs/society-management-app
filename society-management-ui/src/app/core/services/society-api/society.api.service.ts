import { inject, Injectable } from '@angular/core';
import { AuthService } from '../auth/auth.service';
import { society, societyLocation } from '../../interfaces/societies/societies.entity';

@Injectable({ providedIn: 'root' })
export class SocietyApiService {
  private readonly _authService = inject(AuthService);

  async CreateSociety(society: society, societyLocation: societyLocation) {
    return this._authService._supabase.rpc('f_create_initial_society');
  }
}
