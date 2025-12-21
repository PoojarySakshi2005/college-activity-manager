from fastapi import FastAPI
from routers import auth, events, activities, budget
from database import Base, engine

Base.metadata.create_all(bind=engine)

app = FastAPI()

app.include_router(auth.router)
app.include_router(events.router)
app.include_router(activities.router)
app.include_router(budget.router)
