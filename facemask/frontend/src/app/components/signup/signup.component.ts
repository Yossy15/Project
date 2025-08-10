import { Component, OnInit } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';

import { ReactiveFormsModule, FormsModule } from '@angular/forms';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatButtonModule } from '@angular/material/button';
import { MatInputModule } from '@angular/material/input';
import { AuthService } from '../../services/auth.service';
import { HttpClientModule } from '@angular/common/http';
import { RouterLink, Router } from '@angular/router';
import { MatToolbarModule } from '@angular/material/toolbar';
import { SnackbarService } from '../../services/snackbar.service';
import { GlobalConstants } from '../../global/global-constants';
import { NavigationComponent } from '../navigation/navigation.component';
import { CommonModule } from '@angular/common';
import { ImageUploadService } from '../../services/upload-service.service';


@Component({
  selector: 'app-signup',

  standalone: true,
  imports: [
    FormsModule,
    ReactiveFormsModule,
    MatFormFieldModule,
    MatButtonModule,
    MatInputModule,
    HttpClientModule,
    RouterLink,
    MatToolbarModule,
    NavigationComponent,
    CommonModule
  ],
  templateUrl: './signup.component.html',
  styleUrl: './signup.component.scss'
})
export class SignupComponent implements OnInit {
  signupForm: FormGroup;
  responseMessage: any;
  avatar_img: string | null = null;
  selectedImage: string | ArrayBuffer | null = null;

  constructor(
    private authService: AuthService,
    private router: Router,
    private snackbarService: SnackbarService,
    private uploadService: ImageUploadService
  ) {
    this.signupForm = this.createFormGroup();
  }

  ngOnInit(): void {
    this.signupForm = this.createFormGroup();
  }

  createFormGroup(): FormGroup {
    return new FormGroup({
      avatar_img: new FormControl("", [Validators.required]),
      name: new FormControl("", [
        Validators.required,
        Validators.pattern(GlobalConstants.nameRegex),
      ]),
      email: new FormControl("", [
        Validators.required,
        Validators.pattern(GlobalConstants.emailRegex),
      ]),
      password: new FormControl("", [
        Validators.required,
        Validators.minLength(7),
      ]),
    });
  }

  signup(): void {
    // ตรวจสอบว่ามีการอัปโหลดรูปแล้วหรือยัง
    if (!this.avatar_img) {
      this.snackbarService.openSnackBar("Please upload an avatar image", GlobalConstants.error);
      return;
    }

    this.authService.signup(this.signupForm.value).subscribe(
      (response: any) => {
        this.responseMessage = response?.message;
        this.snackbarService.openSnackBar(this.responseMessage, "");
        this.router.navigate(['/login']);
      },
      (error) => {
        this.responseMessage = error.error?.message || GlobalConstants.genericError;
        this.snackbarService.openSnackBar(this.responseMessage, GlobalConstants.error);
      }
    );
  }

  onFileSelected(event: any): void {
    const file: File = event.target.files[0];
    if (file) {
      this.uploadFile(file);
    }
  }

  uploadFile(file: File): void {
    this.uploadService.uploadFile(file)
      .then((downloadURL: string) => {
        console.log('File uploaded successfully. Download URL:', downloadURL);
        this.avatar_img = downloadURL;
        this.signupForm.get('avatar_img')?.setValue(downloadURL);
      })
      .catch((error) => {
        console.error('Error uploading file:', error);
      });

    // แสดง preview
    const reader = new FileReader();
    reader.onload = (e) => {
      if (e.target?.result) {
        this.selectedImage = e.target.result;
      }
    };
    reader.readAsDataURL(file);
  }
}
