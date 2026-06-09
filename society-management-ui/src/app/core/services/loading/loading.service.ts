import { Injectable, computed, signal } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class LoadingService {
  private readonly _pendingRequests = signal(0);
  readonly isLoading = computed(() => this._pendingRequests() > 0);

  private _show = () => this._pendingRequests.update((v) => v + 1);

  private _hide = () => this._pendingRequests.update((v) => Math.max(0, v - 1));

  reset = () => this._pendingRequests.set(0);

  async track<T>(operation: Promise<T>): Promise<T> {
    this._show();

    try {
      return await operation;
    } finally {
      this._hide();
    }
  }
}
