# Government Executive Portal - Dynamic API Integration

## Summary of Changes

The government-executive-portal has been completely transformed from using **hardcoded mock data** to **dynamic API-driven data**. All pages now fetch real data from the backend API.

---

## 🎯 What Changed

### 1. **Created Custom React Hooks** (`src/hooks/useApi.js`)
   - **`useApi()`** - Generic hook for API calls with loading/error states
   - **Data Hooks:**
     - `useComplaints()` - Fetch all complaints
     - `useUsers()` - Fetch user list
     - `useStats()` - Fetch dashboard statistics
     - `useAnalytics()` - Fetch analytics data
     - `useAuditLogs()` - Fetch audit logs
     - `useNotifications()` - Fetch notifications
     - `useRoles()` - Fetch roles
     - `useLiveTracking()` - Fetch live tracking data
     - `useContractors()` - Fetch contractor list
     - `useWorkOrders()` - Fetch work orders
   - **Form Data Hooks:**
     - `useComplaintCategories()` - Fetch available complaint categories
     - `useDepartments()` - Fetch departments
     - `useAreas()` - Fetch areas

### 2. **Updated All Pages to Use API** (Removed mockData dependency)

#### Data Display Pages:
| Page | Changes |
|------|---------|
| **Dashboard** | Fetches real stats, complaints trends, category breakdown, SARA coverage from `/analytics/*` endpoints |
| **Users** | Dynamic user list from `/admin/users` with search functionality |
| **Complaints** | Real complaints from `/complaints` with pagination |
| **Audit Logs** | Live audit logs from `/admin/audit-logs` |
| **Notifications** | Real notifications from `/notifications` |
| **Roles** | Dynamic role list from `/admin/roles` |
| **Analytics** | Charts populated from `/analytics` endpoints |
| **SARA** | SARA management data from `/analytics` with health scores |
| **Live Tracking** | Real-time GPS coordinates from `/map/live` for map display |
| **Contractors** | Contractor list from `/admin/contractors` |
| **Work Orders** | Work orders from `/admin/work-orders` |

#### Form Pages (Now with Dynamic Options):
| Page | Changes |
|------|---------|
| **Add Complaint** | Categories and departments loaded from API; form submission to `/complaints` |
| **Add User** | Roles and departments loaded dynamically; user creation to `/admin/users` |
| **Profile** | Shows authenticated user's profile from AuthContext; password change functionality |
| **Complaint Details** | Already using API (ComplaintDetails.jsx) |

### 3. **Key Features Implemented**

✅ **Loading States** - Shows "Loading..." while fetching data
✅ **Error Handling** - Displays error messages for failed requests
✅ **Dynamic Dropdowns** - Form selects populate from API
✅ **Form Submissions** - Create/update operations send to backend
✅ **Real-time Data** - All tables reflect actual database data
✅ **Search & Filter** - Works on live API data (Users page)
✅ **Charts & Graphs** - Populate with real analytics data
✅ **Date Formatting** - Converts API timestamps to readable format
✅ **Pagination** - Maintains same UI patterns

### 4. **Removed Dependencies**

❌ **Deleted mockData usage** from all pages
❌ **No more hardcoded arrays** of static data
❌ **No more placeholder data** in tables and charts

---

## 🔌 API Endpoints Used

```
GET  /complaints                      - List all complaints
GET  /admin/users                     - List users
GET  /analytics/stats                 - Dashboard statistics
GET  /analytics                       - Analytics & trends data
GET  /admin/audit-logs                - Audit logs
GET  /notifications                   - User notifications
GET  /admin/roles                     - Available roles
GET  /map/live                        - Live tracking locations
GET  /admin/contractors               - Contractor list
GET  /admin/work-orders               - Work orders
GET  /analytics/categories            - Complaint categories (for forms)
GET  /admin/departments               - Departments (for forms)
GET  /map/areas                       - Areas/zones (for forms)
POST /complaints                      - Create new complaint
POST /admin/users                     - Create/add user
POST /auth/change-password            - Update password
```

---

## 📁 Modified Files

### Hooks Created:
- `src/hooks/useApi.js` ✨ NEW

### Pages Updated:
- `src/pages/Dashboard.jsx`
- `src/pages/Users.jsx`
- `src/pages/Complaints.jsx`
- `src/pages/AuditLogs.jsx`
- `src/pages/Notifications.jsx`
- `src/pages/Roles.jsx`
- `src/pages/Analytics.jsx`
- `src/pages/SARA.jsx`
- `src/pages/LiveTracking.jsx`
- `src/pages/Contractors.jsx`
- `src/pages/WorkOrders.jsx`
- `src/pages/AddComplaint.jsx`
- `src/pages/AddUser.jsx`
- `src/pages/Profile.jsx`

### Files NOT Modified (Already using API):
- `src/pages/ComplaintDetails.jsx` ✅ Already dynamic
- `src/pages/Settings.jsx` ✅ Static UI (content-driven, not data-driven)
- `src/pages/ContractorForm.jsx` - Will work with form data
- `src/pages/Login.jsx` ✅ Already has API integration

---

## 🚀 How It Works

### Example: Dashboard Loading Data

```javascript
// Before (Mock Data):
import { stats, complaintsTrend } from '../data/mockData'
const stats = { totalComplaints: 1824, resolved: 1328, ... }

// After (API):
import { useStats, useAnalytics } from '../hooks/useApi'
const { data: statsData, loading } = useStats()
// statsData now contains live data from backend
```

### Loading State Handling:
```javascript
{loading ? (
  <p>Loading...</p>
) : (
  <table>
    {/* Real data renders here */}
  </table>
)}
```

---

## ⚙️ Configuration

### API Base URL
The API base URL is configured in `src/services/api.js`:
```javascript
export const API_BASE = import.meta.env.VITE_API_BASE || '/api'
```

Set `VITE_API_BASE` in `.env` if backend is on different domain:
```
VITE_API_BASE=http://localhost:5000/api
```

### Authentication
All API requests automatically include:
- Bearer token from localStorage (`admin_user`)
- Content-Type headers
- Error handling and JSON parsing

---

## ✨ Benefits

1. **Real-time Data** - Portal always shows current database state
2. **No Hardcoding** - Dynamic content from backend
3. **Scalable** - Easily add new features tied to API
4. **Error Resilient** - Handles network failures gracefully
5. **User-Friendly** - Loading states keep users informed
6. **Maintainable** - Centralized hook system for API calls
7. **Type-Safe** - API responses validated and handled properly

---

## 🔍 Testing the Changes

1. Start the backend server (Node.js)
2. Start the frontend dev server: `npm run dev`
3. Login with valid credentials
4. Navigate through pages to see live data from backend
5. Check Network tab in DevTools to see API calls
6. Try adding a complaint or user to see form submissions
7. Watch tables update with new entries

---

## 📝 Notes

- All pages maintain the same UI/UX - only data source changed
- Pagination still works with API data
- Search filters now work on live data
- Error messages show API-returned error details
- Date formatting automatically converts timestamps
- Loading states prevent UI flicker

---

**Status:** ✅ All Pages Dynamicized - Ready for Production
