from sqlalchemy import Column, Integer, String, Date, ForeignKey
from database import Base

class StudentActivity(Base):
    __tablename__ = "student_activities"

    activity_id = Column(Integer, primary_key=True)
    student_names = Column(String(255))
    class_name = Column(String(50))
    activity_name = Column(String(150))
    organizing_body = Column(String(150))
    venue = Column(String(150))
    start_date = Column(Date)
    end_date = Column(Date)
    entered_by = Column(Integer, ForeignKey("users.user_id"))
