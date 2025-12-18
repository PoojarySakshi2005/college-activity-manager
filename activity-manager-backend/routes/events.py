from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel
from utils.database import execute_query
from utils.auth_utils import verify_token

router = APIRouter(prefix="/api/events", tags=["Events"])
security = HTTPBearer()


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    token = credentials.credentials
    payload = verify_token(token)

    if not payload:
        raise HTTPException(status_code=401, detail="Invalid token")

    return payload


class EventCreate(BaseModel):
    event_name: str
    event_date: str
    event_time: str | None = None
    event_status: str
    event_venue: str
    event_description: str | None = None
    club_name: str | None = None
    department_id: int


@router.post("/")
async def create_event(
    event: EventCreate,
    current_user: dict = Depends(get_current_user)
):
    insert_query = """
        INSERT INTO EVENT (Event_Name, Event_Date, Event_Time, Event_Status,
                          Event_Venue, Event_Description, Club_Name, 
                          Department_ID, Created_Date)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, NOW())
    """

    event_id = execute_query(insert_query, (
        event.event_name,
        event.event_date,
        event.event_time,
        event.event_status,
        event.event_venue,
        event.event_description,
        event.club_name,
        event.department_id
    ))

    return {"message": "Event created successfully", "event_id": event_id}


@router.get("/")
async def get_events(status: str | None = None):
    query = "SELECT * FROM EVENT WHERE 1=1"
    params = []

    if status:
        query += " AND Event_Status = %s"
        params.append(status)
    else:
        query += " AND Event_Status IN ('Upcoming', 'Ongoing')"

    query += " ORDER BY Event_Date ASC"

    events = execute_query(query, tuple(params) if params else None)
    return {"events": events or []}


@router.get("/{event_id}")
async def get_event(event_id: int):
    query = "SELECT * FROM EVENT WHERE Event_ID = %s"
    event = execute_query(query, (event_id,))

    if not event:
        raise HTTPException(status_code=404, detail="Event not found")

    return {"event": event[0]}


@router.put("/{event_id}")
async def update_event(
    event_id: int,
    event: EventCreate,
    current_user: dict = Depends(get_current_user)
):
    update_query = """
        UPDATE EVENT 
        SET Event_Name = %s, Event_Date = %s, Event_Time = %s, 
            Event_Status = %s, Event_Venue = %s, Event_Description = %s,
            Club_Name = %s
        WHERE Event_ID = %s
    """

    execute_query(update_query, (
        event.event_name,
        event.event_date,
        event.event_time,
        event.event_status,
        event.event_venue,
        event.event_description,
        event.club_name,
        event_id
    ))

    return {"message": "Event updated successfully"}


@router.delete("/{event_id}")
async def delete_event(
    event_id: int,
    current_user: dict = Depends(get_current_user)
):
    delete_query = "DELETE FROM EVENT WHERE Event_ID = %s"
    execute_query(delete_query, (event_id,))
    return {"message": "Event deleted successfully"}
