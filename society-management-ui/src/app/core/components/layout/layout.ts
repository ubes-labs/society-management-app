import { Component } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatIconModule } from '@angular/material/icon';
import { RouterModule } from '@angular/router';
import { NavPanel } from '../nav-panel/nav-panel';

@Component({
  selector: 'app-layout',
  imports: [
    MatSidenavModule,
    MatButtonModule,
    MatToolbarModule,
    RouterModule,
    MatIconModule,
    NavPanel,
  ],
  templateUrl: './layout.html',
  styleUrl: './layout.scss',
  standalone: true,
})
export class Layout {}
