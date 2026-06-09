import { Component, inject, OnInit, signal } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { RouterModule } from '@angular/router';
import { LoadingService, navMenuItems, society, SocietyApiService } from '../../core';
import { convertApiResponseToSociety } from '../../shared';
import { MatDividerModule } from '@angular/material/divider';
import { MatCardModule } from '@angular/material/card';
import { MatSnackBar } from '@angular/material/snack-bar';

@Component({
  selector: 'app-society',
  imports: [MatButtonModule, MatIconModule, RouterModule, MatDividerModule, MatCardModule],
  templateUrl: './society.html',
  styleUrl: './society.scss',
})
export class Society implements OnInit {
  private readonly _societyApiService = inject(SocietyApiService);
  private readonly _loadingService = inject(LoadingService);
  private readonly _snackbarService = inject(MatSnackBar);

  readonly navMenuItems = navMenuItems;
  readonly addButtonLabel = $localize`:@@addNewSocietyLabel:Add new society`;
  societySignal = signal<society[]>([]);

  async ngOnInit() {
    await this._loadData();
  }

  private _loadData = async () =>
    this._loadingService.track(
      this._societyApiService
        .getSociety()
        .then((res) => {
          if (!res.success)
            this._snackbarService.open(res.error?.message ?? '', $localize`:@@closeLabel:Close`, {
              horizontalPosition: 'center',
              verticalPosition: 'top',
              duration: 5000,
            });
          else this.societySignal.set(convertApiResponseToSociety(res.data ?? []));
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
