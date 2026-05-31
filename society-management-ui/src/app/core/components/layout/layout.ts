import { Component } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-layout',
  imports: [MatSidenavModule, MatButtonModule, MatToolbarModule, RouterModule],
  templateUrl: './layout.html',
  styleUrl: './layout.scss',
  standalone: true,
})
export class Layout {}
