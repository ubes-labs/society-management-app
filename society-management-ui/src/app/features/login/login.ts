import { Component, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { AuthService } from '../../core';

@Component({
  selector: 'app-login',
  imports: [MatButtonModule],
  templateUrl: './login.html',
  styleUrl: './login.scss',
  standalone: true,
})
export class Login {
  readonly auth = inject(AuthService);

  async login() {
    await this.auth.loginWithGoogle();
  }
}
