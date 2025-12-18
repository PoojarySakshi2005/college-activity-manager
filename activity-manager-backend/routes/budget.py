from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel
from utils.database import execute_query
from utils.auth_utils import verify_token

router = APIRouter(prefix="/api/budget", tags=["Budget Tracker"])
security = HTTPBearer()


def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    payload = verify_token(token)

    if not payload:
        raise HTTPException(status_code=401, detail="Invalid token")

    return payload


class BudgetCreate(BaseModel):
    event_name: str
    club_name: str | None = None
    total_collected_amount: float
    department_id: int


class TransactionCreate(BaseModel):
    transaction_type: str  # "Contribution" or "Expense"
    amount: float
    description: str
    payment_method: str | None = None


@router.post("/")
async def create_budget(
    budget: BudgetCreate,
    current_user: dict = Depends(get_current_user)
):
    insert_query = """
        INSERT INTO BUDGET_TRACKER (Event_Name, Club_Name, Total_Collected_Amount,
                                    Total_Expenses, Balance, Created_By,
                                    Department_ID, Created_Date, Budget_Status)
        VALUES (%s, %s, %s, 0, %s, %s, %s, NOW(), 'Active')
    """

    budget_id = execute_query(insert_query, (
        budget.event_name,
        budget.club_name,
        budget.total_collected_amount,
        budget.total_collected_amount,
        current_user['user_id'],
        budget.department_id
    ))

    return {"message": "Budget created successfully", "budget_id": budget_id}


@router.get("/")
async def get_budgets(
    department_id: int | None = None,
    current_user: dict = Depends(get_current_user)
):
    query = "SELECT * FROM BUDGET_TRACKER WHERE 1=1"
    params = []

    if current_user['role'] in ['Student', 'Club_Head']:
        query += " AND Created_By = %s"
        params.append(current_user['user_id'])

    if department_id:
        query += " AND Department_ID = %s"
        params.append(department_id)

    query += " ORDER BY Created_Date DESC"

    budgets = execute_query(query, tuple(params) if params else None)
    return {"budgets": budgets or []}


@router.get("/{budget_id}")
async def get_budget_details(
    budget_id: int,
    current_user: dict = Depends(get_current_user)
):
    budget_query = "SELECT * FROM BUDGET_TRACKER WHERE Budget_ID = %s"
    budget = execute_query(budget_query, (budget_id,))

    if not budget:
        raise HTTPException(status_code=404, detail="Budget not found")

    trans_query = """
        SELECT * FROM BUDGET_TRANSACTION
        WHERE Budget_ID = %s
        ORDER BY Transaction_Date DESC
    """
    transactions = execute_query(trans_query, (budget_id,))

    return {
        "budget": budget[0],
        "transactions": transactions or []
    }


@router.post("/{budget_id}/transaction")
async def add_transaction(
    budget_id: int,
    transaction: TransactionCreate,
    current_user: dict = Depends(get_current_user)
):
    budget_query = "SELECT * FROM BUDGET_TRACKER WHERE Budget_ID = %s"
    budget = execute_query(budget_query, (budget_id,))

    if not budget:
        raise HTTPException(status_code=404, detail="Budget not found")

    budget = budget[0]

    trans_query = """
        INSERT INTO BUDGET_TRANSACTION (Budget_ID, Transaction_Type, Amount,
                                        Description, Transaction_Date, Added_By,
                                        Payment_Method)
        VALUES (%s, %s, %s, %s, NOW(), %s, %s)
    """

    trans_id = execute_query(trans_query, (
        budget_id,
        transaction.transaction_type,
        transaction.amount,
        transaction.description,
        current_user['user_id'],
        transaction.payment_method
    ))

    if transaction.transaction_type == "Contribution":
        new_collected = float(budget['Total_Collected_Amount']) + transaction.amount
        new_balance = float(budget['Balance']) + transaction.amount

        update_query = """
            UPDATE BUDGET_TRACKER
            SET Total_Collected_Amount = %s, Balance = %s
            WHERE Budget_ID = %s
        """
        execute_query(update_query, (new_collected, new_balance, budget_id))

    elif transaction.transaction_type == "Expense":
        new_expenses = float(budget['Total_Expenses']) + transaction.amount
        new_balance = float(budget['Balance']) - transaction.amount

        if new_balance < 0:
            raise HTTPException(status_code=400, detail="Insufficient balance")

        update_query = """
            UPDATE BUDGET_TRACKER
            SET Total_Expenses = %s, Balance = %s
            WHERE Budget_ID = %s
        """
        execute_query(update_query, (new_expenses, new_balance, budget_id))

    return {"message": "Transaction added successfully", "transaction_id": trans_id}


@router.get("/{budget_id}/summary")
async def get_budget_summary(
    budget_id: int,
    current_user: dict = Depends(get_current_user)
):
    budget_query = "SELECT * FROM BUDGET_TRACKER WHERE Budget_ID = %s"
    budget = execute_query(budget_query, (budget_id,))

    if not budget:
        raise HTTPException(status_code=404, detail="Budget not found")

    budget = budget[0]

    trans_query = """
        SELECT Transaction_Type, SUM(Amount) as Total
        FROM BUDGET_TRANSACTION
        WHERE Budget_ID = %s
        GROUP BY Transaction_Type
    """
    breakdown = execute_query(trans_query, (budget_id,))

    return {
        "event_name": budget['Event_Name'],
        "club_name": budget['Club_Name'],
        "total_collected": float(budget['Total_Collected_Amount']),
        "total_expenses": float(budget['Total_Expenses']),
        "balance": float(budget['Balance']),
        "breakdown": breakdown or [],
        "status": budget['Budget_Status']
    }
