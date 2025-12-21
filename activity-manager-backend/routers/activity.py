from fastapi import APIRouter, UploadFile, File, Form, HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import List, Optional
from utils.database import execute_query
from utils.auth_utils import verify_token
import os
import shutil
from datetime import datetime

router = APIRouter(prefix="/api/activities", tags=["Activities"])
security = HTTPBearer()

# ==================== Auth Dependency ====================
def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    payload = verify_token(token)
    if not payload:
        raise HTTPException(status_code=401, detail="Invalid token")
    return payload

# ==================== Get All Sections ====================
@router.get("/sections/{department_id}")
async def get_activity_sections(department_id: int):
    """Get all 5 activity sections for a department"""
    
    query = """
        SELECT 
            s.Section_ID,
            s.Activity_Section,
            COUNT(f.File_ID) as files_count,
            MAX(f.Upload_Date) as latest_upload
        FROM ACTIVITY_SECTION s
        LEFT JOIN ACTIVITY_FILE f ON s.Section_ID = f.Section_ID
        WHERE s.Department_ID = %s
        GROUP BY s.Section_ID, s.Activity_Section
        ORDER BY FIELD(s.Activity_Section, 
            'Departmental Activities',
            'Training and Placement',
            'Student Activities',
            'Student Achievements',
            'Other Activities')
    """
    
    sections = execute_query(query, (department_id,))
    
    if not sections:
        # Create default sections if they don't exist
        default_sections = [
            'Departmental Activities',
            'Training and Placement',
            'Student Activities',
            'Student Achievements',
            'Other Activities'
        ]
        
        for section_name in default_sections:
            execute_query(
                """
                INSERT INTO ACTIVITY_SECTION 
                (Department_ID, Activity_Section, Status) 
                VALUES (%s, %s, 'Active')
                """,
                (department_id, section_name)
            )
        
        sections = execute_query(query, (department_id,))
    
    return {"sections": sections or []}

# ==================== Upload File to Section ====================
@router.post("/sections/{section_id}/upload")
async def upload_file_to_section(
    section_id: int,
    file: UploadFile = File(...),
    description: str = Form(None),
    academic_year: str = Form(None),
    current_user: dict = Depends(get_current_user)
):
    """Upload file to an activity section"""
    
    # Get section info
    section_query = "SELECT * FROM ACTIVITY_SECTION WHERE Section_ID = %s"
    section = execute_query(section_query, (section_id,))
    
    if not section:
        raise HTTPException(status_code=404, detail="Section not found")
    
    section = section[0]
    department_id = section['Department_ID']
    
    # Create upload directory
    upload_dir = f"uploads/documents/section_{section_id}"
    os.makedirs(upload_dir, exist_ok=True)
    
    # Generate unique filename
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    new_filename = f"{timestamp}_{file.filename}"
    file_path = f"{upload_dir}/{new_filename}"
    
    # Save file
    try:
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"File upload failed: {str(e)}")
    
    # Save file info to database
    insert_query = """
        INSERT INTO ACTIVITY_FILE 
        (Section_ID, Department_ID, File_Name, File_Path, File_Type, 
         File_Size, Upload_Date, Uploaded_By, Description, Academic_Year)
        VALUES (%s, %s, %s, %s, %s, %s, NOW(), %s, %s, %s)
    """
    
    file_id = execute_query(insert_query, (
        section_id,
        department_id,
        new_filename,
        file_path,
        file.content_type,
        file.size,
        current_user['user_id'],
        description,
        academic_year
    ))
    
    return {
        "message": "File uploaded successfully",
        "file_id": file_id,
        "file_path": file_path,
        "upload_date": datetime.now().isoformat()
    }

# ==================== Get Section Files ====================
@router.get("/sections/{section_id}/files")
async def get_section_files(section_id: int):
    """Get all files for a section"""
    
    section_query = "SELECT * FROM ACTIVITY_SECTION WHERE Section_ID = %s"
    section = execute_query(section_query, (section_id,))
    
    if not section:
        raise HTTPException(status_code=404, detail="Section not found")
    
    files_query = """
        SELECT * FROM ACTIVITY_FILE 
        WHERE Section_ID = %s 
        ORDER BY Upload_Date DESC
    """
    files = execute_query(files_query, (section_id,))
    
    return {
        "section": section[0],
        "files": files or []
    }

# ==================== Delete File ====================
@router.delete("/sections/files/{file_id}")
async def delete_file(file_id: int, current_user: dict = Depends(get_current_user)):
    """Delete a file from a section"""
    
    file_query = "SELECT * FROM ACTIVITY_FILE WHERE File_ID = %s"
    file = execute_query(file_query, (file_id,))
    
    if not file:
        raise HTTPException(status_code=404, detail="File not found")
    
    file = file[0]
    file_path = file['File_Path']
    
    # Delete physical file
    try:
        if os.path.exists(file_path):
            os.remove(file_path)
    except Exception as e:
        print(f"Error deleting file: {e}")
    
    # Delete from database
    execute_query("DELETE FROM ACTIVITY_FILE WHERE File_ID = %s", (file_id,))
    
    return {"message": "File deleted successfully"}

# ==================== Get Department Summary ====================
@router.get("/department/{department_id}/summary")
async def get_department_activity_summary(department_id: int):
    """Get all activities for all sections in a department"""
    
    dept_query = "SELECT Department_Name FROM DEPARTMENT WHERE Department_ID = %s"
    dept = execute_query(dept_query, (department_id,))
    
    if not dept:
        raise HTTPException(status_code=404, detail="Department not found")
    
    sections_query = """
        SELECT Section_ID, Activity_Section 
        FROM ACTIVITY_SECTION 
        WHERE Department_ID = %s
        ORDER BY FIELD(Activity_Section,
            'Departmental Activities',
            'Training and Placement',
            'Student Activities',
            'Student Achievements',
            'Other Activities')
    """
    
    sections = execute_query(sections_query, (department_id,))
    
    result_sections = []
    
    for section in sections:
        files_query = """
            SELECT * FROM ACTIVITY_FILE 
            WHERE Section_ID = %s
            ORDER BY Upload_Date DESC
        """
        files = execute_query(files_query, (section['Section_ID'],))
        
        result_sections.append({
            "activity_section": section['Activity_Section'],
            "section_id": section['Section_ID'],
            "files_count": len(files) if files else 0,
            "files": files or []
        })
    
    return {
        "department_name": dept[0]['Department_Name'],
        "department_id": department_id,
        "sections": result_sections
    }