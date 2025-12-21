from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import SessionLocal
from models.user import User, RoleEnum
from core.security import hash_password, verify_password, create_access_token

router = APIRouter(prefix="/auth")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/register-teacher")
def register_teacher(name: str, email: str, password: str, db: Session = Depends(get_db)):
    user = User(
        full_name=name,
        email=email,
        password_hash=hash_password(password),
        role=RoleEnum.TEACHER
    )
    db.add(user)
    db.commit()
    return {"message": "Teacher registered"}

@router.post("/login")
def login(email: str, password: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == email).first()
    if not user or not verify_password(password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    token = create_access_token({"user_id": user.user_id, "role": user.role.value})
    return {"access_token": token}
