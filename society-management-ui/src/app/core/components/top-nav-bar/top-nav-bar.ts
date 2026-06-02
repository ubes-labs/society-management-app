import { Component, EventEmitter, Output, Signal, signal } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatToolbarModule } from '@angular/material/toolbar';
import { BreakpointObserver, Breakpoints } from '@angular/cdk/layout';
import { map } from 'rxjs/internal/operators/map';
import { toSignal } from '@angular/core/rxjs-interop';

@Component({
  selector: 'app-top-nav-bar',
  imports: [MatToolbarModule, MatIconModule, MatButtonModule],
  templateUrl: './top-nav-bar.html',
  styleUrl: './top-nav-bar.scss',
})
export class TopNavBar {
  @Output() toggleSidenav = new EventEmitter<void>();
  readonly appTitle = 'Society Management System';
  readonly isHandset: Signal<boolean>;

  constructor(private readonly breakPointObserver: BreakpointObserver) {
    this.isHandset = toSignal(
      this.breakPointObserver.observe([Breakpoints.Handset]).pipe(map((result) => result.matches)),
      { initialValue: false },
    );
  }
}
