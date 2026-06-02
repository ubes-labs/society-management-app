import { inject, Injectable } from '@angular/core';
import { BreakpointObserver as cdkBreakpointObserver } from '@angular/cdk/layout';
import { toSignal } from '@angular/core/rxjs-interop';
import { map } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class BreakpointObserver {
  private readonly _breakpointObserverService = inject(cdkBreakpointObserver);

  readonly isHandset = toSignal(
    this._breakpointObserverService
      .observe('(max-width: 600px)')
      .pipe(map((result) => result.matches)),
    { initialValue: false },
  );
}
