import { Component, inject, OnInit } from '@angular/core';
import { AuthService } from '../../core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-logout',
  imports: [],
  template: ``,
  styles: ``,
})
export class Logout implements OnInit {
  async ngOnInit() {
    await this.auth.logout();
    return this.router.navigate(['']);
  }
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);
}
