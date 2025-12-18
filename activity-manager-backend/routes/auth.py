# LOGIN/REGISTER ---------------------------------------------------------------------------

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from utils.database import execute_query
from utils.auth_utils import hash_password, verify_password, create_access_token

router = APIRouter(prefix="/api/auth", tags=["Authentication"])

class UserRegister(BaseModel):
    user_name: str
    user_email: str
    user_password: str
    user_role: str
    department_id: int
    phone_number: str = None

class UserLogin(BaseModel):
    user_email: str
    user_password: str

@router.post("/register")
async def register(user: UserRegister):
    """Register new user"""
    
    # Check if user already exists
    check_query = "SELECT * FROM USER WHERE User_Email = %s"
    existing_user = execute_query(check_query, (user.user_email,))
    
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    # Hash password
    hashed_password = hash_password(user.user_password)
    
    # Insert user into database
    insert_query = """
        INSERT INTO USER (User_Name, User_Email, User_Password, User_Role, 
                         Phone_Number, Department_ID, Registration_Date)
        VALUES (%s, %s, %s, %s, %s, %s, NOW())
    """
    
    user_id = execute_query(insert_query, (
        user.user_name,
        user.user_email,
        hashed_password,
        user.user_role,
        user.phone_number,
        user.department_id
    ))
    
    if user_id:
        return {"message": "User registered successfully", "user_id": user_id}
    else:
        raise HTTPException(status_code=500, detail="Registration failed")

@router.post("/login")
async def login(credentials: UserLogin):
    """User login"""
    
    # Get user from database
    query = "SELECT * FROM USER WHERE User_Email = %s"
    result = execute_query(query, (credentials.user_email,))
    if not result:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    user = result[0]  # Get first result
    
    # Verify password
    if not verify_password(credentials.user_password, user['User_Password']):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    # Create access token
    token_data = {
        "user_id": user['User_ID'],
        "email": user['User_Email'],
        "role": user['User_Role']
    }
    access_token = create_access_token(token_data)
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": user['User_ID'],
            "name": user['User_Name'],
            "email": user['User_Email'],
            "role": user['User_Role']
        }
    }