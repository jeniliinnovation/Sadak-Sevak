# 🗄️ Sadak-Sevak Database Schema Blueprint

This document describes the MySQL table structure for the Sadak-Sevak platform.

---

## 1. Users Table
Stores information for Citizens, Admins, and Department Teams.
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | UUID (PK) | Unique User Identifier |
| `name` | VARCHAR(255) | Full name |
| `email` | VARCHAR(255) | Unique Email (Indexed) |
| `password` | VARCHAR(255) | Hashed password |
| `role` | ENUM | citizen, admin, department_head, team_member |
| `googleId` | VARCHAR(255) | Google OAuth ID (Optional) |
| `appleId` | VARCHAR(255) | Apple OAuth ID (Optional) |
| `avatar` | VARCHAR(255) | URL to profile image |

---

## 2. Complaints Table
The heart of the application. Tracks road issues.
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | UUID (PK) | Complaint Identifier |
| `title` | VARCHAR(255) | Short summary |
| `description`| TEXT | Full details |
| `media` | JSON | Holds `{url, public_id, type}` |
| `location` | JSON | Holds `{coordinates, address, area, zone}`|
| `citizenId` | UUID (FK) | Reference to `Users.id` |
| `status` | ENUM | submitted, under_review, repair_started, etc. |
| `aiResults` | JSON | AI scores and detections |
| `likesCount` | INT | Number of likes |
| `escalationLevel`| INT | Defaults to 1, increases if overdue |

---

## 3. Comments Table
Allows users to discuss specific complaints.
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | UUID (PK) | Comment Identifier |
| `content` | TEXT | Message body |
| `userId` | UUID (FK) | Reference to `Users.id` |
| `complaintId`| UUID (FK) | Reference to `Complaints.id` |

---

## 4. Notifications Table
System-to-user alerts.
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | UUID (PK) | Notification Identifier |
| `title` | VARCHAR(255) | Alert header |
| `message` | TEXT | Alert body |
| `isRead` | BOOLEAN | Read status |
| `userId` | UUID (FK) | Target user |

---

## 🔗 Relationships
- **Users (1) → (N) Complaints**: One citizen can report multiple issues.
- **Complaints (1) → (N) Comments**: One report can have many discussion points.
- **Users (1) → (N) Notifications**: One user can receive many alerts.
- **Users (1) → (N) Complaints (As Team)**: One team can be assigned many reports.

---
*Schema generated via Sequelize & MySQL 8.0*
