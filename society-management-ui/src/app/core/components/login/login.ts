import { Component, inject } from '@angular/core';
import { AuthService } from '../../services/auth/auth.service';
import { MatButtonModule } from '@angular/material/button';
import { UserResponse } from '@supabase/auth-js';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-login',
  imports: [MatButtonModule, CommonModule],
  templateUrl: './login.html',
  styleUrl: './login.scss',
  standalone: true,
})
export class Login {
  readonly auth = inject(AuthService);

  user: UserResponse | null = null;

  async login() {
    await this.auth.loginWithGoogle();
  }

  async logout() {
    await this.auth.logout();
  }
}
