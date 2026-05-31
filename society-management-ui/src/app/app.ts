import { Component, signal } from '@angular/core';
import { Layout } from './core/components/layout/layout';

@Component({
  selector: 'app-root',
  imports: [Layout],
  templateUrl: './app.html',
  styleUrl: './app.scss',
})
export class App {}
