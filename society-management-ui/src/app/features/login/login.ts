import { Component, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { appConst, AuthService, LoadingService, navMenuItems } from '../../core';
import { MatIconModule } from '@angular/material/icon';
import { MatTabsModule } from '@angular/material/tabs';
import { FormBuilder, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatCardModule } from '@angular/material/card';
import {
  convertToLoginFromForm,
  convertToSignupFromForm,
  initializeLoginForm,
  initializeSignupForm,
} from '../../shared';
import { MatSnackBar } from '@angular/material/snack-bar';
import { Router } from '@angular/router';

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
  private readonly _formBuilder = inject(FormBuilder);
  private readonly _loadingService = inject(LoadingService);
  private readonly _snackbarService = inject(MatSnackBar);
  private readonly _router = inject(Router);

  readonly appConst = appConst;
  readonly loginForm = initializeLoginForm(this._formBuilder);
  readonly signupForm = initializeSignupForm(this._formBuilder);
  private readonly _navMenuItems = navMenuItems;

  async login() {
    await this._auth.loginWithGoogle();
  }

  async loginWithEmailPassword() {
    if (this.loginForm.valid) {
      const formObj = convertToLoginFromForm(this.loginForm);
      await this._loadingService.track(
        this._auth
          .loginWithEmailPassword(formObj.email, formObj.password)
          .then(async (res) => {
            if (res?.error) {
              this._snackbarService.open(res.error.message ?? '', $localize`:@@closeLabel:Close`, {
                horizontalPosition: 'center',
                verticalPosition: 'top',
                duration: 5000,
              });
            } else {
              this.cleanUpForm(this.loginForm);
              await this._router.navigate([navMenuItems.dashboard.route]);
            }
          })
          .catch(() =>
            this._snackbarService.open(
              $localize`:@@someErrorOccuredLabel:Some error occured`,
              $localize`:@@closeLabel:Close`,
              {
                horizontalPosition: 'center',
                verticalPosition: 'top',
                duration: 5000,
              },
            ),
          ),
      );
    }
  }

  async signupWithEmailPassword() {
    if (this.signupForm.valid) {
      const formObj = convertToSignupFromForm(this.signupForm);
      await this._loadingService.track(
        this._auth
          .signupWithEmailPassword(
            formObj.email,
            formObj.password,
            `${formObj.firstname} ${formObj.lastname}`,
          )
          .then((res) => {
            if (res?.error) {
              this._snackbarService.open(res.error.message ?? '', $localize`:@@closeLabel:Close`, {
                horizontalPosition: 'center',
                verticalPosition: 'top',
                duration: 5000,
              });
            } else {
              this._snackbarService.open(
                'You have successfully registered',
                $localize`:@@closeLabel:Close`,
                {
                  horizontalPosition: 'center',
                  verticalPosition: 'top',
                  duration: 5000,
                },
              );
              this.cleanUpForm(this.signupForm);
            }
          })
          .catch(() =>
            this._snackbarService.open(
              $localize`:@@someErrorOccuredLabel:Some error occured`,
              $localize`:@@closeLabel:Close`,
              {
                horizontalPosition: 'center',
                verticalPosition: 'top',
                duration: 5000,
              },
            ),
          ),
      );
    }
  }

  cleanUpForm(form: FormGroup) {
    form.reset();
  }
}
