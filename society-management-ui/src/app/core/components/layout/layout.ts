import { Component, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatIconModule } from '@angular/material/icon';
import { RouterModule } from '@angular/router';
import { NavPanel } from '../nav-panel/nav-panel';
import { TopNavBar } from '../top-nav-bar/top-nav-bar';
import { BreakpointObserver } from '../../services/breakpoint-observer/breakpoint-observer';
import { Footer } from '../footer/footer';
import { MatDividerModule } from '@angular/material/divider';

@Component({
  selector: 'app-layout',
  imports: [
    MatSidenavModule,
    MatButtonModule,
    MatToolbarModule,
    RouterModule,
    MatIconModule,
    MatDividerModule,
    TopNavBar,
    NavPanel,
    Footer,
  ],
  templateUrl: './layout.html',
  styleUrl: './layout.scss',
  standalone: true,
})
export class Layout {
  private readonly _breakpointObserver = inject(BreakpointObserver);

  readonly isHandset = this._breakpointObserver.isHandset;
}
