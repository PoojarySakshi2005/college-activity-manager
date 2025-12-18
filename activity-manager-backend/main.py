# MAIN FILE ---------------------------------------------------

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.openapi.utils import get_openapi
import os

from routes import auth, activity, budget, events
from utils.database import get_db_connection

app = FastAPI(
    title="Activity Manager & Budget Tracker API",
    version="1.0.0",
    description="Backend API for Activity Manager and Budget Tracker",
)

# -------------------- CORS --------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -------------------- FOLDERS --------------------
os.makedirs("uploads/documents", exist_ok=True)
os.makedirs("uploads/reports", exist_ok=True)

app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# -------------------- ROUTERS --------------------
app.include_router(auth.router)
app.include_router(activity.router)
app.include_router(budget.router)
app.include_router(events.router)

# -------------------- BASIC ROUTES --------------------
@app.get("/")
def root():
    return {
        "message": "Activity Manager & Budget Tracker API",
        "status": "running",
        "docs": "/docs"
    }

@app.get("/health")
def health():
    db = get_db_connection()
    status = "connected" if db else "disconnected"
    if db:
        db.close()
    return {"status": "healthy", "database": status}
