from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import SessionLocal
from models.activities import StudentActivity

router = APIRouter(prefix="/activities")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/student")
def add_student_activity(activity: StudentActivity, db: Session = Depends(get_db)):
    db.add(activity)
    db.commit()
    return {"message": "Student activity added"}

@router.get("/student")
def list_student_activities(db: Session = Depends(get_db)):
    return db.query(StudentActivity).all()
