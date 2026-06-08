import { Component, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';

@Component({
  selector: 'app-dialogs',
  imports: [MatButtonModule, MatDialogModule],
  template: `
    <div>
      <div>
        <h2 mat-dialog-title>{{ headerLabel }}</h2>
      </div>
      <div>
        <mat-dialog-content>{{ content }}</mat-dialog-content>
      </div>
      <mat-dialog-actions>
        <button matButton mat-dialog-close="false" i18n="@@noLabel">No</button>
        <button mat-raised-button color="primary" [mat-dialog-close]="true" i18n="@@yesLabel">
          Yes
        </button>
      </mat-dialog-actions>
    </div>
  `,
  styles: ``,
})
export class YesNoDialog {
  readonly data = inject(MAT_DIALOG_DATA);
  readonly headerLabel = this.data['headerLabel'];
  readonly content = this.data['content'];
}
