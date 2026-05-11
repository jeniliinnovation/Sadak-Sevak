# 🛡️ Sadak-Sevak Master API & RBAC Reference

This document contains the complete list of 60+ endpoints categorized into 10 functional modules, including the Role-Based Access Control (RBAC) matrix.

## 🏛️ Roles Legend
| Code | Role | Description |
| :--- | :--- | :--- |
| **P** | Public | No authentication required |
| **C** | Citizen | Logged-in citizen/user |
| **R** | Repair Team | Field worker / Contractor |
| **G** | Gov Officer | Departmental head / Government official |
| **A** | Admin | Super Administrator |

---

## 🔐 1. Auth Module (8 Endpoints)
| # | Method | Endpoint | P | C | R | G | A |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | POST | `/register` | ✅ | | | | |
| 2 | POST | `/login` | ✅ | | | | |
| 3 | POST | `/logout` | | ✅ | ✅ | ✅ | ✅ |
| 4 | GET | `/me` | | ✅ | ✅ | ✅ | ✅ |
| 5 | PUT | `/me` | | ✅ | ✅ | ✅ | ✅ |
| 6 | POST | `/refresh` | ✅ | ✅ | ✅ | ✅ | ✅ |
| 7 | POST | `/forgot-password` | ✅ | ✅ | ✅ | ✅ | ✅ |
| 8 | POST | `/reset-password` | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## 📋 2. Complaints Module (9 Endpoints)
| # | Method | Endpoint | P | C | R | G | A |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 9 | POST | `/complaints` | | ✅ | | | ✅ |
| 10| GET | `/complaints` | ✅ | ✅ | ✅ | ✅ | ✅ |
| 11| GET | `/complaints/:id` | ✅ | ✅ | ✅ | ✅ | ✅ |
| 14| PUT | `/complaints/:id/status` | | | ✅ | ✅ | ✅ |
| 15| POST | `/complaints/:id/verify` | | ✅ | | | ✅ |
| 16| POST | `/complaints/:id/reopen` | | ✅ | | ✅ | ✅ |

---

## 👥 3. Community Interactions (7 Endpoints)
| # | Method | Endpoint | P | C | R | G | A |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 18| POST | `/:id/like` | | ✅ | ✅ | ✅ | ✅ |
| 20| POST | `/:id/confirm` | | ✅ | ✅ | ✅ | ✅ |
| 21| GET | `/:id/comments` | ✅ | ✅ | ✅ | ✅ | ✅ |
| 22| POST | `/:id/comments` | | ✅ | ✅ | ✅ | ✅ |

---

## 🤖 4. AI Analysis (6 Endpoints)
| # | Method | Endpoint | P | C | R | G | A |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 28| POST | `/analyze` | | | | ✅ | ✅ |
| 29| GET | `/score/:id` | ✅ | ✅ | ✅ | ✅ | ✅ |
| 30| GET | `/risk/:id` | | ✅ | ✅ | ✅ | ✅ |

---

## 🗺️ 5. Live Map (5 Endpoints)
| # | Method | Endpoint | P | C | R | G | A |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 34| GET | `/map/complaints` | ✅ | ✅ | ✅ | ✅ | ✅ |
| 35| GET | `/map/heatmap` | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## 📊 6. Analytics & Admin (14 Endpoints)
| # | Method | Endpoint | P | C | R | G | A |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 45| GET | `/admin/analytics` | | | | ✅ | ✅ |
| 46| GET | `/admin/inactive` | | | | | ✅ |
| 57| GET | `/analytics/complaints` | | | ✅ | ✅ | ✅ |
| 58| GET | `/analytics/zones` | ✅ | ✅ | ✅ | ✅ | ✅ |

---
*For full Swagger documentation, visit http://localhost:5000/api-docs*
