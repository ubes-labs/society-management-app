import { Component, inject } from '@angular/core';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { LoadingService } from '../..';

@Component({
  selector: 'app-loading-spinner',
  imports: [MatProgressSpinnerModule],
  template: `
    @if (loadingService.isLoading()) {
      <div class="fixed inset-0 flex items-center justify-center loading-overlay">
        <mat-spinner diameter="70"></mat-spinner>
      </div>
    }
  `,
  styles: [
    `
      .loading-overlay {
        z-index: 10000;
        background: rgba(0, 0, 0, 0.4);
        backdrop-filter: blur(4px);
        pointer-events: all;
      }
    `,
  ],
})
export class LoadingSpinner {
  readonly loadingService = inject(LoadingService);
}
