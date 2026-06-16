import { effect, Injectable, signal } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class ThemeService {
  private readonly _theme = signal<'light' | 'dark'>('light');
  readonly theme = this._theme.asReadonly();

  setTheme = (theme: 'light' | 'dark') => this._theme.set(theme);
}
