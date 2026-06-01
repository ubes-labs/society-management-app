import { Component, inject } from '@angular/core';
import { MatListModule } from '@angular/material/list';
import { navRoutes } from '../../const/nav-const/nav.const';
import { MatButtonModule } from '@angular/material/button';
import { RouterLink } from '@angular/router';
import { AuthService } from '../../services/auth/auth.service';
import { appRoutes } from '../../const/route-const/route.const';

@Component({
  selector: 'app-nav-panel',
  imports: [MatListModule, MatButtonModule, RouterLink],
  templateUrl: './nav-panel.html',
  styleUrl: './nav-panel.scss',
})
export class NavPanel {
  navRoutes = navRoutes;
  approutes = appRoutes;

  readonly auth = inject(AuthService);

  logOut = async () => this.auth.logout();
}
