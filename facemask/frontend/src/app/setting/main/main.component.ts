import { Component, PLATFORM_ID, Inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatToolbarModule } from '@angular/material/toolbar';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { ImageService } from '../../services/image.service';
import { NgFor, NgIf } from '@angular/common';
import { MatDialog, MatDialogConfig } from '@angular/material/dialog';
import { ChangpasswordComponent } from '../../editprofile/changpassword/changpassword.component';
import { ChnameComponent } from '../../editprofile/chname/chname.component';
import { ChAvatarimgComponent } from '../../editprofile/ch-avatarimg/ch-avatarimg.component';
import { AddimagesComponent } from '../addimages/addimages.component';


@Component({
  selector: 'app-main',
  standalone: true,
  imports: [
    MatToolbarModule,
    MatButtonModule,
    MatInputModule,
    MatFormFieldModule,
    RouterLink,
    NgFor,
    NgIf
  ],
  templateUrl: './main.component.html',
  styleUrl: './main.component.scss'
})
export class MainComponent {
  userId: any;
  avatar_img: any;
  name: any;
  email: any;
  images: any[] = [];
  aid: any;
  id: any;

  constructor(
    private authService: AuthService,
    private route: ActivatedRoute,
    private imageService: ImageService,
    private dialog: MatDialog
  ) { }

  ngOnInit(): void {
    if (typeof localStorage !== 'undefined') {
      this.aid = localStorage.getItem('_id');
      this.avatar_img = localStorage.getItem('avatar_img');
      this.name = localStorage.getItem('name');
      this.email = localStorage.getItem('email');

      // this.getUsedetail();
      this.getOnlyone();
    } else {
      console.warn('localStorage is not available. Skipping initialization.');
    }

  }

  getUsedetail() {
    if (!this.aid) {
      console.error("aid is not provided");
      return;
    }
    this.authService.getUsedetail(this.aid)
      .subscribe((response: any) => {
        this.aid = response?.aid || this.aid; // Use existing aid if not provided
        this.avatar_img = response?.avatar_img;
        this.name = response?.name;
        this.email = response?.email;
        console.log(response);
     
      }, (error) => {
        console.error("Error occurred while fetching user details:", error);
      });
  }

  getOnlyone() {
    console.log(this.images);

    this.imageService.getOnly(this.aid).subscribe(
      data => {
        this.images = data;
        this.id = data?.images_id; // Corrected line
        localStorage.setItem('image_id', this.id); // Corrected line
      },
      error => {
        console.error(error);
      }
    );
  }

  changepw() {
    const dialogConfig = new MatDialogConfig();
    dialogConfig.width = "1000px";
    dialogConfig.width = "1000px";
    this.dialog.open(ChangpasswordComponent, dialogConfig);
  }

  changename() {
    const dialogConfig = new MatDialogConfig();
    dialogConfig.width = "1000px";
    dialogConfig.width = "1000px";
    this.dialog.open(ChnameComponent, dialogConfig);
  }

  changeAvatar() {
    const dialogConfig = new MatDialogConfig();
    dialogConfig.width = "1000px";
    dialogConfig.width = "1000px";
    this.dialog.open(ChAvatarimgComponent, dialogConfig);
  }
}
