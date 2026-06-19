export const stats = {
  totalComplaints: 1824,
  resolved: 1328,
  pending: 321,
  rejected: 175,
  totalUsers: 545,
  avgResolutionTime: '2d 6h',
  resolutionRate: '72%',
};

export const complaintsTrend = {
  labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
  data: [210, 240, 200, 270, 310, 380, 420],
};

export const categoryBreakdown = {
  labels: ['Potholes', 'Water Logging', 'Cracks', 'Street Light', 'Drainage'],
  data: [35, 22, 18, 14, 11],
};

export const saraCoverage = [
  { label: 'Potholes', value: 86 },
  { label: 'Water Logging', value: 72 },
  { label: 'Cracks', value: 65 },
  { label: 'Road Damage', value: 78 },
];

export const recentComplaints = [
  { id: 'CMP-1001', title: 'Deep pothole near civic centre', category: 'Potholes', location: 'Sector 7', priority: 'High', status: 'Pending', date: '2026-06-09' },
  { id: 'CMP-1002', title: 'Street light outage', category: 'Street Light', location: 'MG Road', priority: 'Medium', status: 'Resolved', date: '2026-06-08' },
  { id: 'CMP-1003', title: 'Water logging after rain', category: 'Water Logging', location: 'Ring Road', priority: 'High', status: 'In Progress', date: '2026-06-07' },
  { id: 'CMP-1004', title: 'Cracked footpath', category: 'Cracks', location: 'Shastri Nagar', priority: 'Low', status: 'Rejected', date: '2026-06-05' },
];

export const users = [
  { name: 'Asha Patel', email: 'asha.patel@sadaksevak.org', phone: '+91 98765 43210', role: 'Department Head', department: 'Road Maintenance', joined: '2024-11-12', status: 'Active' },
  { name: 'Rajesh Mehta', email: 'rajesh.mehta@sadaksevak.org', phone: '+91 91234 56789', role: 'Field Team', department: 'Drainage', joined: '2025-02-08', status: 'Active' },
  { name: 'Neha Sharma', email: 'neha.sharma@sadaksevak.org', phone: '+91 90123 45678', role: 'Citizen', department: 'N/A', joined: '2026-01-22', status: 'Inactive' },
  { name: 'Vikram Singh', email: 'vikram.singh@sadaksevak.org', phone: '+91 99876 54321', role: 'Admin', department: 'Operations', joined: '2023-08-19', status: 'Active' },
];

export const notifications = [
  { id: 1, message: 'New complaint submitted for Road Damage in Sector 5', time: '2 mins ago', unread: true },
  { id: 2, message: 'User Asha Patel assigned to a new work order', time: '1 hr ago', unread: false },
  { id: 3, message: 'SARA system updated with latest camera data', time: '3 hrs ago', unread: true },
];

export const auditLogs = [
  { user: 'Vikram Singh', action: 'Updated complaint status', details: 'CMP-1001 moved to In Progress', ip: '103.12.45.89', datetime: '2026-06-09 15:20' },
  { user: 'Asha Patel', action: 'Added new user', details: 'Created Field Team account for Rajesh', ip: '103.12.46.10', datetime: '2026-06-09 14:55' },
  { user: 'System', action: 'SARA health scan completed', details: 'Analyzed 248 new frames', ip: '127.0.0.1', datetime: '2026-06-09 13:05' },
];

export const liveTracking = [
  { id: 'CMP-1001', type: 'Potholes', position: [22.3072, 70.7654], location: 'Sector 7', status: 'Pending' },
  { id: 'CMP-1003', type: 'Water Logging', position: [22.2993, 70.8022], location: 'Ring Road', status: 'In Progress' },
  { id: 'CMP-1005', type: 'Cracks', position: [22.3094, 70.7981], location: 'Shastri Nagar', status: 'Pending' },
];

export const roles = [
  { role: 'Admin', users: 4, status: 'Active' },
  { role: 'Department Head', users: 7, status: 'Active' },
  { role: 'Field Team', users: 18, status: 'Active' },
  { role: 'Citizen', users: 516, status: 'Active' },
];
