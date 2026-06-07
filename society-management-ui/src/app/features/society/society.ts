import { Component } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { RouterModule } from '@angular/router';
import { navMenuItems } from '../../core';

@Component({
  selector: 'app-society',
  imports: [MatButtonModule, MatIconModule, RouterModule],
  templateUrl: './society.html',
  styleUrl: './society.scss',
})
export class Society {
  navMenuItems = navMenuItems;

  readonly addButtonLabel = $localize`:@@addNewSocietyLabel:Add new society`;
}
