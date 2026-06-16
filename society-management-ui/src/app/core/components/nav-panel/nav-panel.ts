import { Component, effect, EventEmitter, inject, Output } from '@angular/core';
import { MatListModule } from '@angular/material/list';
import { MatButtonModule } from '@angular/material/button';
import { Router, RouterModule } from '@angular/router';
import { MatIconModule } from '@angular/material/icon';
import { MatMenuModule } from '@angular/material/menu';
import { MatDividerModule } from '@angular/material/divider';
import { AuthService, langConst, navMenuItems, ThemeService } from '../..';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';

@Component({
  selector: 'app-nav-panel',
  imports: [
    MatListModule,
    MatButtonModule,
    RouterModule,
    MatIconModule,
    MatMenuModule,
    MatDividerModule,
    MatSlideToggleModule,
  ],
  templateUrl: './nav-panel.html',
  styleUrl: './nav-panel.scss',
})
export class NavPanel {
  @Output() menuItemsClicked = new EventEmitter<void>();

  readonly navMenuItems = navMenuItems;
  readonly languages =
    Object.values(langConst)?.map((val) => ({ key: val.value, label: val.label })) ?? [];
  private readonly _windowLocation = location;

  readonly auth = inject(AuthService);
  private readonly _router = inject(Router);
  private readonly _themeService = inject(ThemeService);

  constructor() {
    effect(() => {
      const theme = this._themeService.theme();
      document.body.classList.remove('light', 'dark');
      document.body.classList.add(theme);
    });
  }

  async logOut() {
    await this.auth.logout();
    await this._router.navigate([navMenuItems.login.route]);
    this.menuItemsClicked.emit();
  }

  switchLanguage(lang: string) {
    if (this._windowLocation.hostname !== 'localhost' && lang) {
      const paths = this._windowLocation.pathname?.split('/') ?? [];
      if (paths?.length === 4) {
        paths[2] = lang;
        const finalPath = paths.join('/');
        location.replace(`${finalPath}${this._windowLocation.hash}`);
      }
    }
  }

  switchTheme = (theme: 'light' | 'dark') => this._themeService.setTheme(theme);
}
