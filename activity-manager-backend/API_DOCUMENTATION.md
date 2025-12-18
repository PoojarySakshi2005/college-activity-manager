# Activity Manager & Budget Tracker - API Documentation (Updated)

## 📋 Table of Contents
1. [Base URL](#base-url)
2. [Authentication](#authentication)
3. [Activity Sections Endpoints](#1-activity-sections-endpoints)
4. [Budget Tracker Endpoints](#2-budget-tracker-endpoints)
5. [Events Endpoints](#3-events-endpoints)
6. [Error Responses](#error-responses)
7. [Notes for Frontend Team](#notes-for-frontend-team)

---

## Base URL
```
http://localhost:8000
```

**Interactive Documentation:** http://localhost:8000/docs

---

## Authentication

All protected endpoints require a Bearer token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

**How to get token:**
1. Call `/api/auth/login` (from auth endpoints - see full documentation)
2. Save the `access_token` from response
3. Include it in subsequent requests

---

## 1. ACTIVITY SECTIONS ENDPOINTS

### 1.1 Get All Activity Sections
**Endpoint:** `GET /api/activities/sections/{department_id}`

**Auth Required:** ❌ No

**Description:** Get all 5 activity sections for a department with file count

**Example:** `GET /api/activities/sections/1`

**Success Response (200):**
```json
{
  "sections": [
    {
      "Section_ID": 1,
      "Activity_Section": "Departmental Activities",
      "files_count": 3,
      "latest_upload": "2024-12-15T10:30:00"
    },
    {
      "Section_ID": 2,
      "Activity_Section": "Training and Placement",
      "files_count": 2,
      "latest_upload": "2024-12-14T14:20:00"
    },
    {
      "Section_ID": 3,
      "Activity_Section": "Student Activities",
      "files_count": 1,
      "latest_upload": "2024-12-13T09:15:00"
    },
    {
      "Section_ID": 4,
      "Activity_Section": "Student Achievements",
      "files_count": 4,
      "latest_upload": "2024-12-16T16:45:00"
    },
    {
      "Section_ID": 5,
      "Activity_Section": "Other Activities",
      "files_count": 0,
      "latest_upload": null
    }
  ]
}
```

---

### 1.2 Upload File to Section
**Endpoint:** `POST /api/activities/sections/{section_id}/upload`

**Auth Required:** ✅ Yes

**Content-Type:** `multipart/form-data`

**Example:** `POST /api/activities/sections/1/upload`

**Form Fields:**
- `file` (required): File (PDF, Word, Excel, Image, etc.)
- `description` (optional): String
- `academic_year` (optional): String (e.g., "2024-25")

**Example using JavaScript Fetch:**
```javascript
const formData = new FormData();
formData.append('file', fileObject); // File object from input
formData.append('description', 'Activities from January to June');
formData.append('academic_year', '2024-25');

fetch('http://localhost:8000/api/activities/sections/1/upload', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`
  },
  body: formData
});
```

**Success Response (200):**
```json
{
  "message": "File uploaded successfully",
  "file_id": 1,
  "file_path": "uploads/documents/section_1/20241215_103000_activities.pdf",
  "upload_date": "2024-12-15T10:30:00"
}
```

**Error Response (400):**
```json
{
  "detail": "File upload failed"
}
```

---

### 1.3 Get Section Files
**Endpoint:** `GET /api/activities/sections/{section_id}/files`

**Auth Required:** ❌ No

**Description:** Get all files uploaded in a specific section

**Example:** `GET /api/activities/sections/1/files`

**Success Response (200):**
```json
{
  "section": {
    "Section_ID": 1,
    "Department_ID": 1,
    "Activity_Section": "Departmental Activities",
    "Status": "Active"
  },
  "files": [
    {
      "File_ID": 1,
      "Section_ID": 1,
      "File_Name": "20241215_103000_departmental_activities.pdf",
      "File_Path": "uploads/documents/section_1/20241215_103000_departmental_activities.pdf",
      "File_Type": "application/pdf",
      "File_Size": 2048,
      "Description": "All departmental activities from Jan-June",
      "Academic_Year": "2024-25",
      "Upload_Date": "2024-12-15T10:30:00",
      "Uploaded_By": 1
    },
    {
      "File_ID": 2,
      "Section_ID": 1,
      "File_Name": "20241216_143000_activities_july_dec.xlsx",
      "File_Path": "uploads/documents/section_1/20241216_143000_activities_july_dec.xlsx",
      "File_Type": "application/vnd.ms-excel",
      "File_Size": 5120,
      "Description": "Activities from July-December",
      "Academic_Year": "2024-25",
      "Upload_Date": "2024-12-16T14:30:00",
      "Uploaded_By": 1
    }
  ]
}
```

**To display/download file:**
```
http://localhost:8000/uploads/documents/section_1/20241215_103000_departmental_activities.pdf
```

---

### 1.4 Delete File
**Endpoint:** `DELETE /api/activities/sections/files/{file_id}`

**Auth Required:** ✅ Yes

**Description:** Delete a file from a section

**Example:** `DELETE /api/activities/sections/files/1`

**Success Response (200):**
```json
{
  "message": "File deleted successfully"
}
```

**Error Response (404):**
```json
{
  "detail": "File not found"
}
```

---

### 1.5 Get Department Activity Summary
**Endpoint:** `GET /api/activities/department/{department_id}/summary`

**Auth Required:** ❌ No

**Description:** Get all sections and files for entire department

**Example:** `GET /api/activities/department/1/summary`

**Success Response (200):**
```json
{
  "department_name": "Computer Applications (BCA)",
  "department_id": 1,
  "sections": [
    {
      "activity_section": "Departmental Activities",
      "section_id": 1,
      "files_count": 3,
      "files": [
        {
          "File_ID": 1,
          "File_Name": "20241215_103000_departmental_activities.pdf",
          "File_Path": "uploads/documents/section_1/20241215_103000_departmental_activities.pdf",
          "Upload_Date": "2024-12-15T10:30:00"
        }
      ]
    },
    {
      "activity_section": "Training and Placement",
      "section_id": 2,
      "files_count": 2,
      "files": [...]
    },
    {
      "activity_section": "Student Activities",
      "section_id": 3,
      "files_count": 1,
      "files": [...]
    },
    {
      "activity_section": "Student Achievements",
      "section_id": 4,
      "files_count": 4,
      "files": [...]
    },
    {
      "activity_section": "Other Activities",
      "section_id": 5,
      "files_count": 0,
      "files": []
    }
  ]
}
```

---

## 2. BUDGET TRACKER ENDPOINTS

### 2.1 Create Budget
**Endpoint:** `POST /api/budget`

**Auth Required:** ✅ Yes

**Request Body:**
```json
{
  "event_name": "Annual Day 2024",
  "club_name": "Cultural Club",
  "total_collected_amount": 10000.00,
  "department_id": 1
}
```

**Success Response (200):**
```json
{
  "message": "Budget created successfully",
  "budget_id": 1
}
```

---

### 2.2 Get All Budgets
**Endpoint:** `GET /api/budget`

**Auth Required:** ✅ Yes

**Query Parameters:**
- `department_id` (optional): Number

**Success Response (200):**
```json
{
  "budgets": [
    {
      "Budget_ID": 1,
      "Event_Name": "Annual Day 2024",
      "Club_Name": "Cultural Club",
      "Total_Collected_Amount": 10000.00,
      "Total_Expenses": 3000.00,
      "Balance": 7000.00,
      "Budget_Status": "Active"
    }
  ]
}
```

---

### 2.3 Get Budget Details
**Endpoint:** `GET /api/budget/{budget_id}`

**Auth Required:** ❌ No

**Example:** `GET /api/budget/1`

**Success Response (200):**
```json
{
  "budget": {
    "Budget_ID": 1,
    "Event_Name": "Annual Day 2024",
    "Total_Collected_Amount": 10000.00,
    "Total_Expenses": 3000.00,
    "Balance": 7000.00
  },
  "transactions": [
    {
      "Transaction_ID": 1,
      "Transaction_Type": "Contribution",
      "Amount": 10000.00,
      "Description": "Student collection"
    }
  ]
}
```

---

### 2.4 Add Transaction
**Endpoint:** `POST /api/budget/{budget_id}/transaction`

**Auth Required:** ✅ Yes

**Request Body:**
```json
{
  "transaction_type": "Expense",
  "amount": 2000.00,
  "description": "Stage decorations",
  "payment_method": "Cash"
}
```

**Success Response (200):**
```json
{
  "message": "Transaction added successfully",
  "transaction_id": 2
}
```

---

### 2.5 Get Budget Summary
**Endpoint:** `GET /api/budget/{budget_id}/summary`

**Auth Required:** ❌ No

**Success Response (200):**
```json
{
  "event_name": "Annual Day 2024",
  "club_name": "Cultural Club",
  "total_collected": 10000.00,
  "total_expenses": 3000.00,
  "balance": 7000.00,
  "breakdown": [
    {
      "Transaction_Type": "Contribution",
      "Total": 10000.00
    },
    {
      "Transaction_Type": "Expense",
      "Total": 3000.00
    }
  ],
  "status": "Active"
}
```

---

### 2.6 Update Budget Status
**Endpoint:** `PUT /api/budget/{budget_id}/status`

**Auth Required:** ✅ Yes

**Request Body:**
```json
{
  "status": "Closed"
}
```

**Success Response (200):**
```json
{
  "message": "Budget status updated successfully"
}
```

---

## 3. EVENTS ENDPOINTS

### 3.1 Create Event
**Endpoint:** `POST /api/events`

**Auth Required:** ✅ Yes

**Request Body:**
```json
{
  "event_name": "Tech Fest 2024",
  "event_date": "2024-12-15",
  "event_time": "10:00:00",
  "event_status": "Upcoming",
  "event_venue": "Main Auditorium",
  "event_description": "Annual technical festival",
  "club_name": "Tech Club",
  "department_id": 1
}
```

**Success Response (200):**
```json
{
  "message": "Event created successfully",
  "event_id": 1
}
```

---

### 3.2 Get Events
**Endpoint:** `GET /api/events`

**Auth Required:** ❌ No

**Query Parameters:**
- `status` (optional): Upcoming, Ongoing, Completed

**Default:** Returns Upcoming and Ongoing events if no status provided

**Success Response (200):**
```json
{
  "events": [
    {
      "Event_ID": 1,
      "Event_Name": "Tech Fest 2024",
      "Event_Date": "2024-12-15",
      "Event_Status": "Upcoming",
      "Event_Venue": "Main Auditorium"
    }
  ]
}
```

---

### 3.3 Get Single Event
**Endpoint:** `GET /api/events/{event_id}`

**Auth Required:** ❌ No

**Success Response (200):**
```json
{
  "event": {
    "Event_ID": 1,
    "Event_Name": "Tech Fest 2024",
    ...
  }
}
```

---

### 3.4 Update Event
**Endpoint:** `PUT /api/events/{event_id}`

**Auth Required:** ✅ Yes

**Request Body:** Same as Create Event

**Success Response (200):**
```json
{
  "message": "Event updated successfully"
}
```

---

### 3.5 Delete Event
**Endpoint:** `DELETE /api/events/{event_id}`

**Auth Required:** ✅ Yes

**Success Response (200):**
```json
{
  "message": "Event deleted successfully"
}
```

---

### 3.6 Get Events by Department
**Endpoint:** `GET /api/events/department/{department_id}`

**Auth Required:** ❌ No

**Success Response (200):**
```json
{
  "events": [...]
}
```

---

### 3.7 Get Upcoming Events
**Endpoint:** `GET /api/events/upcoming/list`

**Auth Required:** ❌ No

**Success Response (200):**
```json
{
  "events": [...]
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "detail": "Validation error or bad input"
}
```

### 401 Unauthorized
```json
{
  "detail": "Not authenticated"
}
```

### 404 Not Found
```json
{
  "detail": "Resource not found"
}
```

### 500 Internal Server Error
```json
{
  "detail": "Internal server error"
}
```

---

## Notes for Frontend Team

### 1. File Upload Format
Always use FormData for file uploads:
```javascript
const formData = new FormData();
formData.append('file', fileObject);
formData.append('description', 'Description here');
formData.append('academic_year', '2024-25');

fetch('http://localhost:8000/api/activities/sections/{section_id}/upload', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`
  },
  body: formData
});
```

### 2. Supported File Types
- PDF (.pdf)
- Word (.doc, .docx)
- Excel (.xls, .xlsx)
- Images (.jpg, .png, .gif)
- Text (.txt)
- And all other common formats

### 3. File Access
Downloaded files are available at:
```
http://localhost:8000/{file_path}
```

Example:
```
http://localhost:8000/uploads/documents/section_1/20241215_103000_activities.pdf
```

### 4. Date Format
Always use `YYYY-MM-DD` format:
- ✅ Correct: `2024-12-15`
- ❌ Wrong: `15/12/2024`

### 5. Activity Sections (Fixed)
Always use these exact strings:
- `"Departmental Activities"`
- `"Training and Placement"`
- `"Student Activities"`
- `"Student Achievements"`
- `"Other Activities"`

### 6. Event Status (Exact Strings)
- `"Upcoming"`
- `"Ongoing"`
- `"Completed"`

### 7. Transaction Types
- `"Contribution"` - Money coming in
- `"Expense"` - Money going out

### 8. Token Storage
```javascript
// After login
localStorage.setItem('accessToken', response.access_token);
localStorage.setItem('user', JSON.stringify(response.user));

// Use in requests
const token = localStorage.getItem('accessToken');
```

### 9. API Response Format
All successful responses include appropriate data:
- Create operations return the created resource ID
- Get operations return the requested data
- Update/Delete operations return success message

### 10. Error Handling
Always check response status:
```javascript
if (response.ok) {
  const data = await response.json();
  // Handle success
} else {
  const error = await response.json();
  console.error(error.detail);
  // Handle error
}
```

---

## Endpoint Summary Table

| Method | Endpoint | Auth | Purpose |
|--------|----------|------|---------|
| GET | /api/activities/sections/{dept_id} | ❌ | Get all sections |
| POST | /api/activities/sections/{section_id}/upload | ✅ | Upload file |
| GET | /api/activities/sections/{section_id}/files | ❌ | Get section files |
| DELETE | /api/activities/sections/files/{file_id} | ✅ | Delete file |
| GET | /api/activities/department/{dept_id}/summary | ❌ | Get dept summary |
| GET | /api/budget | ✅ | Get budgets |
| POST | /api/budget | ✅ | Create budget |
| GET | /api/budget/{budget_id} | ❌ | Get budget details |
| POST | /api/budget/{budget_id}/transaction | ✅ | Add transaction |
| GET | /api/budget/{budget_id}/summary | ❌ | Budget summary |
| PUT | /api/budget/{budget_id}/status | ✅ | Update status |
| GET | /api/events | ❌ | Get events |
| POST | /api/events | ✅ | Create event |
| GET | /api/events/{event_id} | ❌ | Get event |
| PUT | /api/events/{event_id} | ✅ | Update event |
| DELETE | /api/events/{event_id} | ✅ | Delete event |
| GET | /api/events/department/{dept_id} | ❌ | Get dept events |
| GET | /api/events/upcoming/list | ❌ | Get upcoming |

---

**Last Updated:** December 2024  
**API Version:** 2.0 (File-based Activity System)
