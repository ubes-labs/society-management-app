import { Injectable, signal } from '@angular/core';
import { createClient, SupabaseClient, User } from '@supabase/supabase-js';
import { environment } from '../../../../environments/environment';

@Injectable({ providedIn: 'root' })
export class AuthService {
  readonly _supabase: SupabaseClient<any, 'public', 'public', any, any>;
  readonly user = signal<User | null>(null);
  readonly userPermissions = signal<any[] | null>([]);

  constructor() {
    this._supabase = this._initializeSupabaseClient();
    this._setUserOnAuth();
  }

  // LOGIN WITH GOOGLE
  loginWithGoogle = async () =>
    this._supabase.auth
      .signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: `${location.origin}${location.pathname}`,
        },
      })
      .catch((err) => console.error(err));

  // LOGOUT
  logout = async () => this._supabase.auth.signOut();

  isSessionInitialized = async () => {
    const sessionResponse = await this._supabase.auth.getSession();
    return !!sessionResponse?.data?.session;
  };

  private _initializeSupabaseClient = () =>
    createClient(environment.supabaseUrl, environment.supabaseAnonKey, {
      auth: {
        flowType: 'pkce',
      },
    });

  private _setUserOnAuth = () =>
    this._supabase.auth.onAuthStateChange((_, session) => this.user.set(session?.user ?? null));

  setUserPermissions = async () => {
    if (!!this.userPermissions()?.length) return;
    const res = await this._supabase.from('v_get_user_society_permissions').select('*');
    if (res?.status === 200) this.userPermissions.set(res.data ?? []);
    else {
      console.error('Error fetching user permissions:', res?.error);
      this.userPermissions.set([]);
    }
  };
}
