# Sadak-Sevak Backend API 🛣️🛡️

Sadak-Sevak is an advanced road maintenance and complaint management platform designed for citizens and government administrators. It features an intelligent **SARA (Smart Area Road Assessment)** system and a robust **17-table database architecture**.

## 🚀 Recent Updates (May 13, 2026)
- **Comprehensive Testing Suite**: Implemented **43 functional API tests** with 100% pass rate.
- **Each API Module Covered**: Dedicated test files for all 13 route modules including Auth, Complaints, Admin, AI, and Analytics.
- **Infrastructure Fixes**: Resolved critical model association bugs and schema synchronization issues during testing.
- **Mock Media Support**: Integrated mocked file upload testing for media endpoints.
- **CI/CD Ready**: Automated cleanup of test database sessions for reliable local and remote testing.


## 🚀 Key Features

- **SARA Integration**: Automated location enrichment that detects Ward, Zone, and Area from coordinates.
- **AI Analysis**: Simulated road health scoring and damage detection.
- **17-Module API**: Full coverage for Auth, Complaints, Contractors, Analytics, Map, and more.
- **Role-Based Access Control**: Secure endpoints for Citizens (C), Team Members (R), Department Heads (G), and Admins (A).
- **Interactive Documentation**: Fully documented via Swagger/OpenAPI.

## 🛠️ Tech Stack

- **Backend**: Node.js & Express.js
- **Database**: MySQL 8.0 with Sequelize ORM
- **Security**: JWT Authentication & Bcrypt password hashing
- **Documentation**: Swagger UI

## 📋 Database Structure

The API is perfectly aligned with a 17-table normalized structure:
`auth`, `areas`, `complaints`, `comments`, `likes`, `confirmations`, `contractors`, `escalation`, `government_admin`, `live_map`, `media_upload`, `notifications`, `roles_legend`, `summary_table`, `ai_analysis`, `analytics`, `community_interactions`.

## 🚦 Getting Started

### Prerequisites
- Node.js installed
- MySQL Server running

### Installation
1. Clone the repository
2. Navigate to the `backend` directory: `cd backend`
3. Install dependencies: `npm install`
4. Configure your `.env` file:
   ```env
   DB_NAME=sadak_sevak
   DB_USER=root
   DB_PASSWORD=yourpassword
   DB_HOST=127.0.0.1
   JWT_SECRET=your_secret_key
   ```
5. Seed the SARA areas: `node src/utils/seedAreas.js`
6. Start the server: `npm run dev`

## 📖 API Documentation

Once the server is running, you can access the interactive Swagger documentation at:
**`http://localhost:5000/api-docs`**

## 🤝 Roles Legend
- **P**: Public
- **C**: Citizen
- **R**: Registered User / Field Team
- **G**: Government Staff / Dept Head
- **A**: Admin

---
*Built with ❤️ for better roads and safer cities.*
