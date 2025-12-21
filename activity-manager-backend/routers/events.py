from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import SessionLocal
from models.events import Event

router = APIRouter(prefix="/events")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/")
def create_event(event: Event, db: Session = Depends(get_db)):
    db.add(event)
    db.commit()
    return {"message": "Event created"}

@router.get("/")
def list_events(db: Session = Depends(get_db)):
    return db.query(Event).all()
