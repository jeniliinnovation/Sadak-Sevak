# 🔒 Super Admin Setup Guide - City Government Executive Portal

## 📋 Overview
The City Government Executive Portal now has a **Super Admin** account with **FULL ACCESS** to all features and permissions.

---

## 🚀 Quick Start

### Super Admin Credentials:
```
Email:    superadmin@citygovernment.gov
Password: superadmin@123
```

### To Create Super Admin in Database:
```bash
cd d:\Sadak-Sevak\backend
node seed_super_admin.js
```

This will:
- ✅ Create the super admin user in the database
- ✅ Display all credentials and permissions
- ✅ Set `isVerified = true` for immediate access

---

## 👑 Super Admin Permissions (ALL ACCESS)

The Super Admin has complete access to:

### 📊 Dashboard & Monitoring
- ✅ Executive Dashboard Overview
- ✅ Real-time KPI monitoring
- ✅ City metrics and analytics

### 📝 Complaint Management
- ✅ View all public complaints
- ✅ Complaint Resolution tracking
- ✅ Update complaint status
- ✅ Manage complaint escalations

### 🗺️ City Operations
- ✅ Live City Tracking (Real-time monitoring)
- ✅ Public Alerts management
- ✅ Area-wise tracking

### 👥 Staff & Organization
- ✅ Staff Directory (View/Edit/Delete)
- ✅ Department Management
- ✅ Role & Permission Management
- ✅ User account creation/modification

### 🏗️ Infrastructure
- ✅ Infrastructure Projects management
- ✅ Contractor Management
- ✅ Work Orders creation and tracking
- ✅ Project assignment

### 📈 Analytics & Reporting
- ✅ Performance Analytics
- ✅ AI Insights (SARA) access
- ✅ Complaint trends analysis
- ✅ Service coverage metrics
- ✅ Department performance reports

### 🛡️ System Administration
- ✅ System Audit Logs (Full access)
- ✅ User activity monitoring
- ✅ System Settings configuration
- ✅ Security settings management

### 👤 Personal
- ✅ Profile Management
- ✅ Password change
- ✅ Account settings

---

## 🔑 Role Hierarchy

```
👑 SUPER ADMIN (admin role)
├── Full access to ALL features
├── Can manage all users
├── Can configure system settings
└── Can view all audit logs

🏛️ GOVERNMENT (government role)
├── Dashboard, Complaints, Live Tracking
├── Notifications, Analytics, SARA
└── Profile management

👔 DEPARTMENT HEAD (department_head role)
├── Complaints, Dashboard
├── Live Tracking, Users, Analytics
└── Notifications, Profile

🤝 TEAM MEMBER (team_member role)
├── Complaints, Notifications
└── Profile

👨‍💼 CITIZEN (citizen role)
├── Complaints, Profile
└── Limited access
```

---

## 🔐 Authentication Flow

### Login Process:
1. User enters email and password
2. Frontend sends credentials to backend API
3. API validates against database
4. JWT token is generated on success
5. User is logged in with their role and permissions

### Demo Mode (Fallback):
- If backend API is unavailable
- Demo credentials work for testing
- Super Admin demo works automatically

---

## 🛠️ How Permissions Work

### Frontend Permission System:
```javascript
// Check if user has a specific permission
const hasAccess = hasPermission('analytics')

// Check if user is super admin
if (isSuperAdmin()) {
  // Show all features
}
```

### Role-Based Navigation:
- Sidebar automatically filters menu items based on user role
- Only permitted features are shown to users
- Unauthorized pages redirect to dashboard

### Backend Authorization:
```javascript
// API routes protected by role
router.get('/admin/settings', authorize('admin'), settingsController)
```

---

## 🚀 Deployment Steps

### 1. Setup Database
```bash
cd backend
npm install
node seed_super_admin.js
```

### 2. Start Backend
```bash
npm start
```

### 3. Start Frontend
```bash
cd government-executive-portal
npm install
npm run dev
```

### 4. Login with Super Admin
- URL: `http://localhost:5173/login`
- Email: `superadmin@citygovernment.gov`
- Password: `superadmin@123`

---

## 📝 Additional Admin Accounts

You can create more admin users by adding them to `seed_super_admin.js` or using the User Management page.

### Via Frontend:
1. Login as Super Admin
2. Go to **Staff Directory**
3. Click **Add User**
4. Set role to `admin`
5. Save

### Via Database:
Use `seed_gov_user.js` or `seed.js` to add more users.

---

## 🔄 Permission Types

Each role has specific permissions:

| Permission | Super Admin | Government | Dept Head | Team Member | Citizen |
|-----------|------------|-----------|----------|-------------|---------|
| dashboard | ✅ | ✅ | ✅ | ❌ | ❌ |
| complaints | ✅ | ✅ | ✅ | ✅ | ✅ |
| users | ✅ | ❌ | ✅ | ❌ | ❌ |
| analytics | ✅ | ✅ | ✅ | ❌ | ❌ |
| settings | ✅ | ❌ | ❌ | ❌ | ❌ |
| auditLogs | ✅ | ❌ | ❌ | ❌ | ❌ |
| allAccess | ✅ | ✅ | ❌ | ❌ | ❌ |

---

## ⚠️ Security Notes

1. **Change Default Passwords**: Immediately change super admin password in production
2. **Use HTTPS**: Always use HTTPS in production
3. **JWT Secret**: Keep JWT_SECRET secure in environment variables
4. **Limit Admin Accounts**: Only create necessary super admin accounts
5. **Audit Logs**: Monitor super admin activity regularly

---

## 📞 Troubleshooting

### Super Admin Can't Login
- Verify database has the user
- Check password is hashed correctly
- Ensure JWT_SECRET is set

### Permissions Not Working
- Clear browser localStorage
- Check user role in database
- Verify ROLE_PERMISSIONS in AuthContext.jsx

### Features Not Appearing
- Check sidebar permissions filter
- Verify user role has permission
- Check AuthContext hasPermission() function

---

## 📚 Files Modified

- ✅ `backend/seed_super_admin.js` - Create super admin
- ✅ `government-executive-portal/src/context/AuthContext.jsx` - Permissions system
- ✅ `government-executive-portal/src/components/Layout/Sidebar.jsx` - Permission filtering
- ✅ `government-executive-portal/src/components/Layout/Header.jsx` - Super admin indicator
- ✅ `government-executive-portal/src/pages/Login.jsx` - Demo account buttons

---

**Status**: ✅ Super Admin Setup Complete
**Last Updated**: 2026-06-12
