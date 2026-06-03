import { Component, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { appConst, AuthService } from '../../core';
import { MatIconModule } from '@angular/material/icon';

@Component({
  selector: 'app-login',
  imports: [MatButtonModule, MatIconModule],
  templateUrl: './login.html',
  styleUrl: './login.scss',
  standalone: true,
})
export class Login {
  private readonly _auth = inject(AuthService);
  readonly appConst = appConst;

  async login() {
    await this._auth.loginWithGoogle();
  }
}
