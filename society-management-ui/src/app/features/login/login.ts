import { Component, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { appConst, AuthService } from '../../core';
import { MatIconModule } from '@angular/material/icon';
import { MatTabsModule } from '@angular/material/tabs';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatCardModule } from '@angular/material/card';

@Component({
  selector: 'app-login',
  imports: [
    MatButtonModule,
    MatIconModule,
    MatTabsModule,
    ReactiveFormsModule,
    MatFormFieldModule,
    MatInputModule,
    MatCardModule,
  ],
  templateUrl: './login.html',
  styleUrl: './login.scss',
  standalone: true,
})
export class Login {
  private readonly _auth = inject(AuthService);
  private readonly _fb = inject(FormBuilder);

  readonly appConst = appConst;
  readonly loginForm = this._fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required]],
  });

  async login() {
    await this._auth.loginWithGoogle();
  }

  async loginWithEmailPassword() {
    if (this.loginForm.valid) {
      console.info(this.loginForm.value);
    }
  }
}
