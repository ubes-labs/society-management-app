import { Component, inject } from '@angular/core';
import { AuthService } from '../../core';
import { MatCardModule } from '@angular/material/card';

@Component({
  selector: 'app-dashboard',
  imports: [MatCardModule],
  templateUrl: './dashboard.html',
  styleUrl: './dashboard.scss',
})
export class Dashboard {
  readonly authService = inject(AuthService);
}
