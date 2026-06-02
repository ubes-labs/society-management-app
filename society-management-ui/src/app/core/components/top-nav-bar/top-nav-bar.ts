import { Component, EventEmitter, Output, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatToolbarModule } from '@angular/material/toolbar';
import { BreakpointObserver } from '../../services/breakpoint-observer/breakpoint-observer';

@Component({
  selector: 'app-top-nav-bar',
  imports: [MatToolbarModule, MatIconModule, MatButtonModule],
  templateUrl: './top-nav-bar.html',
  styleUrl: './top-nav-bar.scss',
})
export class TopNavBar {
  @Output() toggleSidenav = new EventEmitter<void>();

  private readonly breakPointObserver = inject(BreakpointObserver);

  readonly appTitle = 'Society Management System';
  readonly isHandset = this.breakPointObserver.isHandset;
}
