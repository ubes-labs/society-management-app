import { Component, inject } from '@angular/core';
import { MatListModule } from '@angular/material/list';
import { topNavRoutes } from '../../const/nav-const/nav.const';
import { MatButtonModule } from '@angular/material/button';
import { RouterLink } from '@angular/router';
import { AuthService } from '../../services/auth/auth.service';

@Component({
  selector: 'app-nav-panel',
  imports: [MatListModule, MatButtonModule, RouterLink],
  templateUrl: './nav-panel.html',
  styleUrl: './nav-panel.scss',
})
export class NavPanel {
  topNavRoutes = topNavRoutes;

  readonly auth = inject(AuthService);

  logOut = async () => this.auth.logout();
}
