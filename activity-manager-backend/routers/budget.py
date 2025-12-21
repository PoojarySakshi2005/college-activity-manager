from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import SessionLocal
from models.budget import Budget, BudgetStatus

router = APIRouter(prefix="/budget")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/request")
def request_budget(budget: Budget, db: Session = Depends(get_db)):
    db.add(budget)
    db.commit()
    return {"message": "Budget requested"}

@router.post("/approve/{budget_id}")
def approve_budget(budget_id: int, approver_id: int, db: Session = Depends(get_db)):
    budget = db.query(Budget).get(budget_id)
    budget.status = BudgetStatus.APPROVED
    budget.approved_by = approver_id
    db.commit()
    return {"message": "Budget approved"}
