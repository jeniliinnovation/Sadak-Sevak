# Data Structure Mapping - Mock Data vs API

This document shows how mockData fields map to API response fields.

---

## 📊 Dashboard Stats

### Before (mockData):
```javascript
const stats = {
  totalComplaints: 1824,
  resolved: 1328,
  pending: 321,
  rejected: 175,
  totalUsers: 545,
  avgResolutionTime: '2d 6h',
  resolutionRate: '72%',
}
```

### After (API Response from `/analytics/stats`):
```javascript
{
  totalComplaints: 1824,
  resolved: 1328,
  pending: 321,
  rejected: 175,
  totalUsers: 545,
  avgResolutionTime: '2d 6h',
  resolutionRate: 72  // May be number instead of string
}
```

---

## 📋 User List

### Before (mockData):
```javascript
const users = [
  { 
    name: 'Asha Patel', 
    email: 'asha.patel@sadaksevak.org', 
    phone: '+91 98765 43210', 
    role: 'Department Head', 
    department: 'Road Maintenance', 
    joined: '2024-11-12', 
    status: 'Active' 
  },
  // ... more
]
```

### After (API Response from `/admin/users`):
```javascript
[
  {
    id: 'uuid-123',
    name: 'Asha Patel',
    email: 'asha.patel@sadaksevak.org',
    phone: '+91 98765 43210',
    role: 'department_head',  // May use different format
    department: 'road_maintenance',
    joinedDate: '2024-11-12T00:00:00Z',  // ISO format
    status: 'active'  // Lowercase
  }
]
```

### Field Mapping:
- `joined` → `joinedDate` (convert to date)
- `role` → `role` (may need case normalization)
- `status` → `status` (normalize case)

---

## 🚩 Complaint List

### Before (mockData):
```javascript
const recentComplaints = [
  {
    id: 'CMP-1001',
    title: 'Deep pothole near civic centre',
    category: 'Potholes',
    location: 'Sector 7',
    priority: 'High',
    status: 'Pending',
    date: '2026-06-09'
  },
  // ... more
]
```

### After (API Response from `/complaints`):
```javascript
[
  {
    id: 'CMP-1001',
    title: 'Deep pothole near civic centre',
    category: 'Potholes',
    location: 'Sector 7',
    priority: 'High',
    status: 'pending',  // Lowercase
    createdAt: '2026-06-09T10:30:00Z',  // ISO timestamp
    // Additional fields
    userId: 'user-uuid',
    photos: ['url1', 'url2'],
    coordinates: { lat: 22.3072, lng: 70.7654 }
  }
]
```

### Field Mapping:
- `date` → `createdAt` (convert to readable date)
- `status` → `status` (normalize case)
- `category` → `category` (should match)

---

## 📝 Audit Logs

### Before (mockData):
```javascript
const auditLogs = [
  {
    user: 'Vikram Singh',
    action: 'Updated complaint status',
    details: 'CMP-1001 moved to In Progress',
    ip: '103.12.45.89',
    datetime: '2026-06-09 15:20'
  },
  // ... more
]
```

### After (API Response from `/admin/audit-logs`):
```javascript
[
  {
    userId: 'user-uuid',
    userName: 'Vikram Singh',
    action: 'updated_complaint_status',  // Snake case
    details: 'CMP-1001 moved to In Progress',
    ipAddress: '103.12.45.89',
    timestamp: '2026-06-09T15:20:00Z',  // ISO format
    resourceType: 'complaint',
    resourceId: 'CMP-1001'
  }
]
```

### Field Mapping:
- `user` → `userName`
- `ip` → `ipAddress`
- `datetime` → `timestamp` (convert to readable format)
- `action` → `action` (may use snake_case)

---

## 🔔 Notifications

### Before (mockData):
```javascript
const notifications = [
  {
    id: 1,
    message: 'New complaint submitted for Road Damage in Sector 5',
    time: '2 mins ago',
    unread: true
  },
  // ... more
]
```

### After (API Response from `/notifications`):
```javascript
[
  {
    id: 'notif-uuid',
    message: 'New complaint submitted for Road Damage in Sector 5',
    timestamp: '2026-06-09T14:58:00Z',  // Convert to "2 mins ago"
    read: false,  // Instead of `unread`
    userId: 'user-uuid',
    type: 'complaint_created',
    actionUrl: '/complaints/CMP-1001'
  }
]
```

### Field Mapping:
- `time` → `timestamp` (calculate relative time)
- `unread` → `read` (invert boolean or use `!read`)

---

## 👷 Contractors

### Before (mockData):
```javascript
const contractors = [
  {
    name: 'Green Roads Pvt Ltd',
    contact: 'Rohit Kumar',
    phone: '+91 98765 12345',
    specialization: 'Potholes',
    status: 'Active'
  }
]
```

### After (API Response from `/admin/contractors`):
```javascript
[
  {
    id: 'contractor-uuid',
    name: 'Green Roads Pvt Ltd',
    companyName: 'Green Roads Pvt Ltd',
    contactPerson: 'Rohit Kumar',
    contact: 'Rohit Kumar',
    phone: '+91 98765 12345',
    email: 'contact@greenroads.com',
    specialization: 'Potholes',
    expertise: ['Potholes', 'Cracks'],
    status: 'active',
    ratingScore: 4.8,
    completedProjects: 45
  }
]
```

### Field Mapping:
- `contact` → `contactPerson`
- `specialization` → `specialization` or `expertise`
- `status` → `status` (normalize case)

---

## 📦 Work Orders

### Before (mockData):
```javascript
const orders = [
  {
    id: 'WO-2651',
    type: 'Pothole Repair',
    location: 'Sector 3',
    assigned: 'Rajesh Mehta',
    progress: 72,
    status: 'In Progress'
  }
]
```

### After (API Response from `/admin/work-orders`):
```javascript
[
  {
    id: 'WO-2651',
    type: 'pothole_repair',  // Snake case
    workType: 'Pothole Repair',
    location: 'Sector 3',
    assigned: 'Rajesh Mehta',
    assignedTo: 'user-uuid',
    progress: 72,
    status: 'in_progress',  // Snake case
    startDate: '2026-06-01',
    estimatedCompletion: '2026-06-15',
    completionDate: null,
    budget: 50000,
    spent: 36000,
    contractor: 'contractor-uuid'
  }
]
```

### Field Mapping:
- `type` → `type` or `workType` (handle both)
- `assigned` → `assignedTo` (may be UUID, display name)
- `status` → `status` (normalize case)

---

## 📊 Categories & Dropdowns

### Before (hardcoded):
```javascript
// In AddComplaint.jsx
<option>Potholes</option>
<option>Water Logging</option>
<option>Cracks</option>
```

### After (API from `/analytics/categories`):
```javascript
[
  { id: 'pothole', name: 'Potholes', icon: '🕳️' },
  { id: 'water_logging', name: 'Water Logging', icon: '💧' },
  { id: 'cracks', name: 'Cracks', icon: '🌐' },
  { id: 'street_light', name: 'Street Light', icon: '💡' },
  { id: 'drainage', name: 'Drainage', icon: '🔧' }
]
```

---

## 🎯 Charts Data

### Before (mockData):
```javascript
const complaintsTrend = {
  labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
  data: [210, 240, 200, 270, 310, 380, 420],
}
```

### After (API from `/analytics`):
```javascript
{
  complaintsTrend: {
    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
    data: [210, 240, 200, 270, 310, 380, 420],
    // Additional info
    period: 'monthly',
    year: 2026
  },
  categoryBreakdown: {
    labels: ['Potholes', 'Water Logging', 'Cracks', 'Street Light', 'Drainage'],
    data: [35, 22, 18, 14, 11],
    total: 100
  }
}
```

---

## ⚠️ Field Name Transformations

Many API fields use `snake_case` while mockData used `camelCase`:

| mockData | API | Notes |
|----------|-----|-------|
| totalComplaints | totalComplaints | Direct match |
| joined | joinedDate | Different naming |
| datetime | timestamp | ISO format |
| date | createdAt | ISO format |
| status | status | Usually lowercase |
| user | userName/userId | May need mapping |
| unread | read | Boolean inverted |
| specialization | expertise | May be array |
| assigned | assignedTo | UUID instead of name |

---

## 🔄 Data Transformation Pattern

When API field doesn't exactly match expected format:

```javascript
// Safe access with fallback
const userName = item.userName || item.user
const joinDate = item.joinedDate ? new Date(item.joinedDate).toLocaleDateString() : item.joined
const isUnread = item.unread || !item.read
const role = (item.role || '').toUpperCase()
```

---

## ✅ Implementation Notes

1. **Always use Optional Chaining** - `data?.field || defaultValue`
2. **Date Formatting** - Convert ISO timestamps to readable format
3. **Case Normalization** - Handle both camelCase and snake_case
4. **Array vs Object** - Some fields might be array instead of string
5. **Fallbacks** - Provide sensible defaults for missing fields
6. **Type Coercion** - Ensure numbers/booleans are correct type
