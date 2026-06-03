import { Component, EventEmitter, inject, Output } from '@angular/core';
import { MatListModule } from '@angular/material/list';
import { MatButtonModule } from '@angular/material/button';
import { Router, RouterModule } from '@angular/router';
import { MatIconModule } from '@angular/material/icon';
import { MatMenuModule } from '@angular/material/menu';
import { MatDividerModule } from '@angular/material/divider';
import { AuthService, langConst, navRoutes } from '../..';

@Component({
  selector: 'app-nav-panel',
  imports: [
    MatListModule,
    MatButtonModule,
    RouterModule,
    MatIconModule,
    MatMenuModule,
    MatDividerModule,
  ],
  templateUrl: './nav-panel.html',
  styleUrl: './nav-panel.scss',
})
export class NavPanel {
  @Output() menuItemsClicked = new EventEmitter<void>();

  navRoutes = navRoutes;
  languages = Object.values(langConst)?.map((val) => ({ key: val.value, label: val.label })) ?? [];
  windowLocation = location;

  readonly auth = inject(AuthService);
  readonly router = inject(Router);

  async logOut() {
    await this.auth.logout();
    await this.router.navigate([navRoutes.login.route]);
    this.menuItemsClicked.emit();
  }

  switchLanguage(lang: string) {
    if (this.windowLocation.hostname !== 'localhost' && lang) {
      const paths = this.windowLocation.pathname?.split('/') ?? [];
      if (paths?.length === 4) {
        paths[2] = lang;
        const finalPath = paths.join('/');
        location.replace(`${finalPath}${this.windowLocation.hash}`);
      }
    }
  }
}
