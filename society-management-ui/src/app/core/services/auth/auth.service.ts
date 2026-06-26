import { Injectable, signal } from '@angular/core';
import { createClient, SupabaseClient, User } from '@supabase/supabase-js';
import { environment } from '../../../../environments/environment';

@Injectable({ providedIn: 'root' })
export class AuthService {
  readonly _supabase: SupabaseClient<any, 'public', 'public', any, any>;
  readonly user = signal<User | null>(null);

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

  loginWithEmailPassword = async (email: string, password: string) =>
    this._supabase.auth.signInWithPassword({
      email: email,
      password: password,
    });

  signupWithEmailPassword = async (email: string, password: string, fullName: string) =>
    this._supabase.auth.signUp({
      email: email,
      password: password,
      options: {
        data: {
          full_name: fullName,
        },
      },
    });

  private _initializeSupabaseClient = () =>
    createClient(environment.supabaseUrl, environment.supabaseAnonKey, {
      auth: {
        flowType: 'pkce',
      },
    });

  private _setUserOnAuth = () =>
    this._supabase.auth.onAuthStateChange((_, session) => this.user.set(session?.user ?? null));
}
