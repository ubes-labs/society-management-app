import { Injectable, signal } from '@angular/core';
import { createClient, SupabaseClient, User } from '@supabase/supabase-js';
import { environment } from '../../../../environments/environment';
import { supabaseRedirectToUriResolver } from '../../utils';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly supabase: SupabaseClient<any, 'public', 'public', any, any>;
  readonly user = signal<User | null>(null);

  constructor() {
    this.supabase = this._initializeSupabaseClient();
    this._setUserOnAuth();
  }

  // LOGIN WITH GOOGLE
  loginWithGoogle = async () =>
    this.supabase.auth
      .signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: supabaseRedirectToUriResolver(),
        },
      })
      .catch((err) => console.error(err));

  // LOGOUT
  logout = async () => this.supabase.auth.signOut();

  initialize = () => this.supabase.auth.initialize();

  private _initializeSupabaseClient = () =>
    createClient(environment.supabaseUrl, environment.supabaseAnonKey, {
      auth: {
        flowType: 'pkce',
      },
    });

  private _setUserOnAuth = () =>
    this.supabase.auth.onAuthStateChange((_, session) => this.user.set(session?.user ?? null));
}
