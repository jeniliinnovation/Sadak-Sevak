# Sadak-Sevak Backend API

Powerful backend infrastructure for the Road Maintenance and Citizen Reporting platform.

## 🚀 Recent Updates (Today)

### 📊 Before vs. After
| Feature | Previous State | Current State (Improved) |
| :--- | :--- | :--- |
| **API Endpoints** | ~15 basic stubs | **62 full features** (Complete Logic) |
| **Documentation** | Minimal Swagger (titles only) | **High-Fidelity Swagger** (Schemas/Examples) |
| **Authentication** | Basic Login/Register | **Full Auth Flow** (Google/Apple/OTP/Reset) |
| **Roles/RBAC** | Hardcoded citizen logic | **Advanced RBAC** (Admin/Team/Citizen/Head) |
| **Database** | Conflicting table names/types | **Clean UUID Schema** (CHAR 36) |
| **Testing** | No automated tests | **Jest/Supertest Suite** Integrated |
| **Media** | No working upload | **Multipart Binary Upload** (S3/Cloudinary ready) |

### 1. API Implementation (62 Endpoints Complete)
- **Authentication**: Fully implemented Register, Login, Logout, Profile (Get/Update), Password Reset, and Token Refresh.
- **Complaints**: Created a robust lifecycle including Submission, Nearby Search, Verification (Citizen-led), Reopening, and Status Tracking.
- **Community Interactions**: RESTful nested endpoints for Likes, Confirmations, and Comments (`/api/complaints/:id/comments`).
- **Admin & Governance**: Advanced User Management, Contractor CRUD, and Departmental monitoring.
- **Analytics & Maps**: Specialized feeds for Geo-pins, Zone Summaries, AI Accuracy metrics, and Repair rates.
- **Escalation**: Automated and manual escalation logic with audit trail support.

### 📜 Enhanced Swagger Documentation
- Accessible at: `http://localhost:5000/api-docs`
- Added **Request Schemas** for all endpoints with field-level examples.
- Added **Response Examples** to guide frontend integration.
- Supported **Multipart/Form-Data** for image uploads (Proof of Repair, Complaint Photos).
- Simplified Authentication testing with integrated **Bearer Token** support.

### 🛡️ Database & Security Infrastructure
- **UUID Standardization**: Migrated all IDs to `CHAR(36)` (UUIDv4) for collision-proof data linking.
- **RBAC Enforced**: Role-Based Access Control protecting all admin and departmental routes.
- **Fixed Schema Incompatibility**: Improved synchronization logic to handle complex foreign key relationships during schema evolution.

### 🧪 Automated Testing (Update)
- **43 Passing Tests**: Achieved 100% pass rate across the entire API suite.
- **Each Module Covered**: Individual functional test files created for all 13 route modules (Auth, Complaints, Admin, AI, Map, Notifications, etc.).
- **Dynamic DB Cleanup**: Implemented automated test database synchronization that handles complex foreign key constraints and orphan tables.
- **Bug Fixes**: Resolved critical `ReferenceError` in Interactions and missing field errors in Complaint creation discovered through testing.
- Run tests via: `npm test`

---

## 🛠️ Getting Started

### Prerequisites
- Node.js (v18+)
- MySQL (v5.7+ or v8.0+)

### Setup
1. Clone the repository
2. Install dependencies:
   ```bash
   npm install --legacy-peer-deps
   ```
3. Configure `.env` (use `.env.example` as a template)
4. Start the development server:
   ```bash
   npm run dev
   ```

## 📂 Project Structure
- `src/models`: Database schemas using Sequelize.
- `src/routes`: API route definitions with Swagger JSDoc.
- `src/middleware`: Auth protection and RBAC logic.
- `src/tests`: Automated test suites.
- `src/config`: Connection and environment settings.
