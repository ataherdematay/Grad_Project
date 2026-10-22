import requests

def render_plantuml(puml_code, output_path):
    r = requests.post(
        "https://kroki.io/plantuml/png",
        data=puml_code.encode("utf-8"),
        headers={"Content-Type": "text/plain; charset=utf-8"},
        timeout=25
    )
    if r.status_code == 200:
        with open(output_path, "wb") as f:
            f.write(r.content)
        print(f"Generated {output_path} ({len(r.content)} bytes)")
        return True
    else:
        print(f"Failed {output_path}: {r.status_code}")
        return False

# -------------------------------------------------------------
# CLASS DIAGRAM: PERFECT 3-COLUMN ORTHOGONAL GRID (NO CROSSINGS)
# -------------------------------------------------------------
class_puml = """
@startuml
skinparam linetype ortho
skinparam shadowing false
skinparam roundcorner 4
skinparam defaultFontName "Times New Roman"
skinparam defaultFontSize 12

skinparam class {
    BackgroundColor #F8FAFD
    ArrowColor #16325C
    BorderColor #16325C
    BorderThickness 1.2
    HeaderBackgroundColor #DCE6F5
    FontColor #0F2A4A
}

' Top Entity
class User {
    +String userId
    +String email
    +String phoneNumber
    +String passwordHash
    +UserRole role
    +DateTime createdAt
    __
    +login()
    +logout()
}

' Second Row: ServiceProfessional (Left), Customer (Right)
package "Actors Layer" <<Rectangle>> #FFFFFF {
    class ServiceProfessional {
        +String businessName
        +List<String> serviceCategories
        +List<String> serviceDistricts
        +Boolean isVerified
        +Float aggregateRating
        +Int completedJobsCount
        __
        +submitOffer()
        +updateAvailability()
    }

    class Customer {
        +String firstName
        +String lastName
        +String defaultDistrict
        __
        +createRequest()
        +acceptOffer()
        +submitReview()
    }
}

' Third Row: StructuredOffer (Left), ServiceRequest & Photo (Center/Right)
package "Service Engagement Layer" <<Rectangle>> #FFFFFF {
    class StructuredOffer {
        +String offerId
        +Decimal laborCost
        +Decimal materialsCost
        +Decimal totalEstimatedPrice
        +DateTime earliestArrival
        +String scopeNotes
        +OfferStatus status
        +DateTime submittedAt
    }

    class ServiceRequest {
        +String requestId
        +String category
        +String description
        +UrgencyLevel urgency
        +String district
        +String neighborhood
        +String exactAddress
        +RequestStatus status
        +DateTime createdAt
        __
        +addPhoto()
        +cancelRequest()
    }

    class Photo {
        +String photoId
        +String fileUrl
        +DateTime uploadedAt
    }
}

' Fourth Row: Execution & Feedback Layer
package "Job & Resolution Layer" <<Rectangle>> #FFFFFF {
    class Appointment {
        +String appointmentId
        +DateTime scheduledDateTime
        +AppointmentStatus status
        __
        +reschedule()
    }

    class Job {
        +String jobId
        +JobStatus currentStatus
        +DateTime startedAt
        +DateTime completedAt
        __
        +updateStatus()
        +confirmCompletion()
    }

    class Review {
        +String reviewId
        +Int starRating
        +String commentText
        +DateTime submittedAt
    }

    class Complaint {
        +String complaintId
        +String reason
        +String details
        +ComplaintStatus status
        __
        +resolve()
    }
}

' Generalization (Clean straight arrows up to User)
User <|-- ServiceProfessional
User <|-- Customer

' Associations without conflict
ServiceProfessional "1" -down-> "0..*" StructuredOffer : submits >
Customer "1" -down-> "0..*" ServiceRequest : creates >

StructuredOffer "0..*" -right-> "1" ServiceRequest : receives >
ServiceRequest "1" *-right- "0..3" Photo : contains

StructuredOffer "1" -down-> "0..1" Job : activates >
ServiceRequest "1" -down-> "0..1" Job : originates >

Appointment "1" <-left- "1" Job : coordinates <
Job "1" -right-> "0..1" Review : receives >
Job "1" -down-> "0..*" Complaint : targets >

Customer "1" ..> "0..*" Review : writes >
Customer "1" ..> "0..*" Complaint : files >

@enduml
"""

render_plantuml(class_puml, "figures/fig_class_model_clean.png")
