
# 📱 SalePro – Sales & Distribution Management System

<p align="center">
  <h1 align="center">SalePro</h1>
  <p align="center">
    A Mobile-Based Sales & Distribution Management System
  </p>
  <p align="center">
    Developed for Freelan Enterprises
  </p>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter"/>
  <img src="https://img.shields.io/badge/Dart-Language-blue?logo=dart"/>
  <img src="https://img.shields.io/badge/Firebase-Backend-orange?logo=firebase"/>
  <img src="https://img.shields.io/badge/Platform-Android-green?logo=android"/>
</p>

---

## 📌 Overview

SalePro is a mobile-based Sales and Distribution Management System developed for Freelan Enterprises, a spice distribution company.

The application is designed to help sales representatives manage shop visits, customer orders, payment collections, and daily sales activities through a centralized digital platform.

SalePro provides separate functionalities for Administrators, Sales Representatives, and Customers, supporting efficient sales operations and improved data management.

---

## 🎯 Objectives

- Improve sales and distribution management.
- Manage shops and assigned routes.
- Simplify customer order placement.
- Track payment collections and outstanding dues.
- Support sales performance monitoring.
- Provide centralized cloud-based data management.
- Enable sales representative location visibility.

---

## ✨ Key Features

### 👨‍💼 Sales Representative Module

- Email-based role routing and authentication.
- Sales representative dashboard.
- Assigned route and shop management.
- Customer shop visits.
- Order placement.
- Previous order management.
- Payment collection.
- Daily sales monitoring.
- Sales representative location visibility.

### 🛒 Customer Module

- Customer registration and login.
- Customer dashboard.
- Order placement.
- Previous order history.
- Payment and outstanding dues information.

### 🛠️ Admin Module

- Admin dashboard.
- Sales representative management.
- Customer and shop management.
- Route assignment.
- Area-based shop visibility.
- Order and payment monitoring.
- Sales analytics.
- Firebase-based data management.

---

## 🔐 Authentication & Role-Based Routing

SalePro uses an email-based role routing approach to direct users to the relevant application module.

### Login Flow

```text
User Opens Application
          │
          ▼
     Login Screen
          │
          ▼
  Enter Email & Password
          │
          ▼
  Firebase Authentication
          │
          ▼
  Identify User Role
          │
     ┌────┼─────────────┐
     │    │             │
     ▼    ▼             ▼
   Admin  Sales Rep   Customer
     │    │             │
     ▼    ▼             ▼
   Admin  Rep         Customer
 Dashboard Dashboard   Dashboard
```

### Supported Roles

| Role | Access |
|---|---|
| Admin | Admin Dashboard & Management |
| Sales Representative | Routes, Shops, Orders & Payments |
| Customer | Orders, Dues & Payment Information |

> **Security:** User access should be enforced using Firebase Authentication and Firestore security rules. Email-based routing alone should not be relied upon for authorization.

---

## 🗺️ Sales Representative Location

The application includes functionality for viewing sales representative locations.

The location feature is intended to support visibility of sales representatives during field sales activities.

> Location tracking and permissions must be configured according to the implemented functionality and user privacy requirements.

---

## 📊 Sales Analytics

The Admin module includes sales analytics functionality to support monitoring and understanding of sales-related information.

Potential analytics include:

- Daily sales totals.
- Order information.
- Payment collection information.
- Sales performance data.

> Update the analytics list according to the charts and reports currently implemented in the application.

---

## 🏗️ Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Mobile Application Development |
| Dart | Programming Language |
| Firebase Authentication | User Authentication |
| Cloud Firestore | Database Management |
| Material 3 | UI Design |
| Provider / Riverpod | State Management |
| Git | Version Control |
| GitHub | Source Code Management |

---

## 📂 Project Structure

```text
salepro/
│
├── android/
├── ios/
├── lib/
│   ├── main.dart
│   ├── models/
│   ├── screens/
│   ├── widgets/
│   ├── services/
│   ├── providers/
│   └── utils/
│
├── assets/
├── test/
├── pubspec.yaml
├── firebase_options.dart
├── .gitignore
└── README.md
```

> Adjust this structure to match the actual project.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio
- Firebase Project
- Git

### 1. Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/salepro.git
```

### 2. Navigate to Project

```bash
cd salepro
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Configure Firebase

Connect the project to your Firebase project.

Configure:

- Firebase Authentication.
- Cloud Firestore.
- Android Firebase configuration.
- Firestore security rules.

### 5. Run Application

```bash
flutter run
```

### 6. Build Release APK

```bash
flutter build apk --release
```

---

## 🖼️ Screenshots

Add screenshots of the implemented application screens.

Recommended screenshots:

- Login Screen
- Admin Dashboard
- Sales Representative Dashboard
- Shop Management
- Route Assignment
- Order Placement
- Payment Collection
- Sales Analytics
- Customer Dashboard
- Rep Location


---

## 🔒 Security & Privacy

- Firebase Authentication for user login.
- Firestore security rules for data protection.
- Role-based access control.
- Secure management of application configuration.
- Protection of user credentials.
- Appropriate handling of location permissions.

**Important:** Never upload real passwords, private keys, or sensitive credentials to GitHub.

---

## 🔮 Future Improvements

- Advanced sales reporting.
- Enhanced sales analytics.
- Automated notifications.
- Improved delivery tracking.
- Additional inventory management features.

---

## 🎓 Project Purpose

SalePro was developed as a practical software development project to demonstrate skills in:

- Mobile Application Development.
- Flutter & Dart Programming.
- Firebase Integration.
- Database Management.
- User Interface Design.
- Role-Based Access Control.
- Software Development & Problem Solving.

---

## 👨‍💻 Developer

**AMC Sandaruwan**

Information Technology Undergraduate

Sri Lanka Institute of Advanced Technological Education (SLIATE)

### Connect With Me

- GitHub: [Your GitHub Profile](https://github.com/AMCNW2002/)
- LinkedIn: [Your LinkedIn Profile](https://www.linkedin.com/)

---

## 📄 License

This project is developed for educational and portfolio purposes.

Add an appropriate open-source license if you intend to distribute the source code.
