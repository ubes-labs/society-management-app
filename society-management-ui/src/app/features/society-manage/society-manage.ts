import { Component, inject, OnInit } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatDividerModule } from '@angular/material/divider';
import { MatIconModule } from '@angular/material/icon';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { provideNativeDateAdapter } from '@angular/material/core';
import { navMenuItems } from '../../core';

@Component({
  selector: 'app-society-manage',
  providers: [provideNativeDateAdapter()],
  imports: [
    MatDividerModule,
    MatButtonModule,
    MatCardModule,
    MatIconModule,
    MatFormFieldModule,
    MatIconModule,
    MatInputModule,
    ReactiveFormsModule,
    MatDatepickerModule,
    RouterModule,
  ],
  templateUrl: './society-manage.html',
  styleUrl: './society-manage.scss',
})
export class SocietyManage implements OnInit {
  private readonly _activatedRoute = inject(ActivatedRoute);
  private readonly _formBuilder = inject(FormBuilder);
  private readonly _router = inject(Router);

  pageMode: 'create' | 'edit' = 'create';
  readonly navMenuItems = navMenuItems;

  pageForm = this._formBuilder.group({
    societyName: ['', Validators.required],
    societyDescription: ['', Validators.required],
    societyContactEmail: ['', Validators.required, Validators.email],
    societyContactPhone: ['', Validators.required],
    societyWebsiteUrl: ['', Validators.required],
    societyCompletionDate: [{ value: '', disabled: true }, Validators.required],
    societyBuilder: ['', Validators.required],
    societyPromoter: ['', Validators.required],
    societyLocationAddress: ['', Validators.required],
    societyLocationCity: ['', Validators.required, Validators.email],
    societyLocationState: ['', Validators.required],
    societyLocationPostalCode: ['', Validators.required],
    societyLocationDistrict: ['', Validators.required],
    societyLocationCountry: ['', Validators.required],
  });

  ngOnInit(): void {
    const id = this._activatedRoute.snapshot.paramMap.get('id') || undefined;
    if (id) {
    } else {
    }
  }

  saveData() {
    if (this.pageForm.valid) {
    }
  }

  async cancelSave() {
    this.pageForm.reset();
  }

  async goBackToSocietyPage() {
    return this._router.navigate([navMenuItems.society.route]);
  }
}
