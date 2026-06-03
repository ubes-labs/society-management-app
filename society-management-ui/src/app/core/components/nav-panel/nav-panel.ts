import { Component, inject } from '@angular/core';
import { MatListModule } from '@angular/material/list';
import { navRoutes } from '../../const/nav-const/nav.const';
import { MatButtonModule } from '@angular/material/button';
import { Router, RouterModule } from '@angular/router';
import { AuthService } from '../../services/auth/auth.service';
import { MatIconModule } from '@angular/material/icon';

@Component({
  selector: 'app-nav-panel',
  imports: [MatListModule, MatButtonModule, RouterModule, MatIconModule],
  templateUrl: './nav-panel.html',
  styleUrl: './nav-panel.scss',
})
export class NavPanel {
  navRoutes = navRoutes;

  readonly auth = inject(AuthService);
  readonly router = inject(Router);

  async logOut() {
    await this.auth.logout();
    return this.router.navigate([navRoutes.login.route]);
  }
}
