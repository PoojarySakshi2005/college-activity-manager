from sqlalchemy import Column, Integer, String, Date, Enum, ForeignKey
from database import Base
import enum

class EventStatus(enum.Enum):
    UPCOMING = "UPCOMING"
    ONGOING = "ONGOING"
    COMPLETED = "COMPLETED"

class Event(Base):
    __tablename__ = "events"

    event_id = Column(Integer, primary_key=True)
    title = Column(String(150))
    venue = Column(String(150))
    start_date = Column(Date)
    end_date = Column(Date)
    status = Column(Enum(EventStatus))
    created_by = Column(Integer, ForeignKey("users.user_id"))
