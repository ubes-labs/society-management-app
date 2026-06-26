import { FormBuilder, Validators, FormGroup } from '@angular/forms';

export const initializeLoginForm = (formBuilder: FormBuilder) =>
  formBuilder.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required]],
  });

export const initializeSignupForm = (formBuilder: FormBuilder) =>
  formBuilder.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required]],
    firstname: ['', [Validators.required]],
    lastname: ['', [Validators.required]],
  });

export const convertToLoginFromForm = (formGroup: FormGroup) => ({
  email: formGroup.get('email')?.value,
  password: formGroup.get('password')?.value,
});

export const convertToSignupFromForm = (formGroup: FormGroup) => ({
  email: formGroup.get('email')?.value,
  password: formGroup.get('password')?.value,
  firstname: formGroup.get('firstname')?.value,
  lastname: formGroup.get('lastname')?.value,
});
