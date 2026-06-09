import { Component, inject, OnInit } from '@angular/core';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatDividerModule } from '@angular/material/divider';
import { MatIconModule } from '@angular/material/icon';
import { ActivatedRoute, RouterModule } from '@angular/router';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { provideNativeDateAdapter } from '@angular/material/core';
import { LoadingService, navMenuItems, SocietyApiService } from '../../core';
import { MatDialog } from '@angular/material/dialog';
import {
  convertToSocietyCreateRpcFromObject,
  convertToSocietyFromForm,
  initializeSocietyForm,
  YesNoDialog,
} from '../../shared';
import { firstValueFrom } from 'rxjs';
import { MatSnackBar } from '@angular/material/snack-bar';

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
  private readonly _matDialog = inject(MatDialog);
  private readonly _societyApiService = inject(SocietyApiService);
  private readonly _loadingService = inject(LoadingService);
  private readonly _snackbarService = inject(MatSnackBar);

  pageMode: 'create' | 'edit' = 'create';
  readonly navMenuItems = navMenuItems;

  pageForm = initializeSocietyForm(this._formBuilder);

  ngOnInit(): void {
    const id = this._activatedRoute.snapshot.paramMap.get('id') || undefined;
    if (id) {
    } else {
    }
  }

  async saveData() {
    if (this.pageForm.valid) {
      const dialogResponse = await firstValueFrom(
        this._matDialog
          .open<
            YesNoDialog,
            {
              headerLabel: string;
              content: string;
            },
            boolean
          >(YesNoDialog, {
            data: {
              headerLabel: 'User Confirmation',
              content: 'Are you sure you want to save the changes?',
            },
          })
          .afterClosed(),
      );
      if (dialogResponse) await this._saveDataEntity();
    }
  }

  cancelSave() {
    this.pageForm.reset();
  }

  private async _saveDataEntity() {
    const convertedData = convertToSocietyFromForm(this.pageForm);
    const rpcRequest = convertToSocietyCreateRpcFromObject(
      convertedData.society,
      convertedData.societyLocation,
    );
    await this._createSociety(rpcRequest);
  }

  private _createSociety = async (rpcRequest: Record<string, any>) =>
    this._loadingService.track(
      this._societyApiService
        .createSociety(rpcRequest)
        .then((res) => {
          if (!res.success)
            this._snackbarService.open(res.error?.message ?? '', $localize`:@@closeLabel:Close`, {
              horizontalPosition: 'center',
              verticalPosition: 'top',
              duration: 5000,
            });
          else {
            this._snackbarService.open(
              $localize`:@@successfullyCreatedLabel:Successfully created`,
              $localize`:@@closeLabel:Close`,
              {
                horizontalPosition: 'center',
                verticalPosition: 'top',
                duration: 5000,
              },
            );
            this.cancelSave();
          }
        })
        .catch(() => {
          this._snackbarService.open(
            $localize`:@@someErrorOccuredLabel:Some error occured`,
            $localize`:@@closeLabel:Close`,
            {
              horizontalPosition: 'center',
              verticalPosition: 'top',
              duration: 5000,
            },
          );
        }),
    );
}
