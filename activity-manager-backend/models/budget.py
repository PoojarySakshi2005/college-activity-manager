from sqlalchemy import Column, Integer, String, Enum, DECIMAL, ForeignKey
from database import Base
import enum

class BudgetStatus(enum.Enum):
    PENDING = "PENDING"
    APPROVED = "APPROVED"
    REJECTED = "REJECTED"

class Budget(Base):
    __tablename__ = "budgets"

    budget_id = Column(Integer, primary_key=True)
    title = Column(String(150))
    amount = Column(DECIMAL(10,2))
    status = Column(Enum(BudgetStatus), default=BudgetStatus.PENDING)
    requested_by = Column(Integer, ForeignKey("users.user_id"))
    approved_by = Column(Integer, ForeignKey("users.user_id"), nullable=True)
