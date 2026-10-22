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
        print(f"Successfully generated {output_path} ({len(r.content)} bytes)")
        return True
    else:
        print(f"Failed to generate {output_path}: {r.status_code} - {r.text}")
        return False

# -------------------------------------------------------------------------
# PIC 1: Class Diagram (Analysis Object Model)
# Visual Paradigm Style: Orthogonal lines, clean spacing, pastel headers
# -------------------------------------------------------------------------
class_diagram_puml = """
@startuml
skinparam linetype ortho
skinparam shadowing false
skinparam roundcorner 3
skinparam defaultFontName "Times New Roman"
skinparam defaultFontSize 12

skinparam class {
    BackgroundColor #F4F6FB
    ArrowColor #1B365D
    BorderColor #1B365D
    BorderThickness 1.2
    HeaderBackgroundColor #DCE6F5
    FontColor #0F2A4A
}

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

class Customer {
    +String firstName
    +String lastName
    +String defaultDistrict
    __
    +createRequest()
    +acceptOffer()
    +submitReview()
}

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

class Job {
    +String jobId
    +JobStatus currentStatus
    +DateTime startedAt
    +DateTime completedAt
    __
    +updateStatus()
    +confirmCompletion()
}

class Appointment {
    +String appointmentId
    +DateTime scheduledDateTime
    +AppointmentStatus status
    __
    +reschedule()
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

' Generalization
User <|-- Customer
User <|-- ServiceProfessional

' Customer & Professional associations
Customer "1" -down-> "0..*" ServiceRequest : creates >
ServiceProfessional "1" -down-> "0..*" StructuredOffer : submits >

' ServiceRequest associations
ServiceRequest "1" *-left- "0..3" Photo : contains
ServiceRequest "1" <-- "0..*" StructuredOffer : receives <
ServiceRequest "1" -down-> "0..1" Job : originates >

' Offer to Job
StructuredOffer "1" -down-> "0..1" Job : activates >

' Job associations
Job "1" -left-> "1" Appointment : coordinates >
Job "1" -down-> "0..1" Review : receives >
Customer "1" -down-> "0..*" Review : writes >

' Complaints
Customer "1" -right-> "0..*" Complaint : files >
Job "1" -right-> "0..*" Complaint : targets >

@enduml
"""

# -------------------------------------------------------------------------
# PIC 2: Use Case Diagram
# Visual Paradigm Style: Actors on sides, system rectangle, straight lines
# -------------------------------------------------------------------------
usecase_diagram_puml = """
@startuml
skinparam linetype ortho
skinparam shadowing false
skinparam defaultFontName "Times New Roman"
skinparam defaultFontSize 12

skinparam actor {
    BackgroundColor #F4F6FB
    BorderColor #1B365D
    FontColor #0F2A4A
}

skinparam usecase {
    BackgroundColor #F4F6FB
    BorderColor #1B365D
    BorderThickness 1.2
    FontColor #0F2A4A
    ArrowColor #1B365D
}

skinparam rectangle {
    BackgroundColor #FFFFFF
    BorderColor #708090
    BorderThickness 1.5
    FontColor #0F2A4A
    FontSize 14
    FontStyle bold
}

left to right direction

actor "Customer" as C
actor "Service Professional" as P
actor "Administrator" as A

rectangle "BiTadilat System Boundaries" {
    usecase "UC01: Register & Login" as UC01
    usecase "UC02: Create Service Request" as UC02
    usecase "UC03: Rule-Based Matching" as UC03
    usecase "UC04: Submit Structured Offer" as UC04
    usecase "UC05: Compare & Accept Offer" as UC05
    usecase "UC06: Schedule Appointment" as UC06
    usecase "UC07: Direct Messaging" as UC07
    usecase "UC08: Update Job Progress" as UC08
    usecase "UC09: Confirm Completion" as UC09
    usecase "UC10: Submit Review & Rating" as UC10
    usecase "UC11: Cancel Request / Job" as UC11
    usecase "UC12: Verify Professional Profile" as UC12
    usecase "UC13: Arbitrate Complaints" as UC13

    ' Internal Dependencies
    UC02 ..> UC03 : <<triggers>>
    UC04 ..> UC05 : <<informs>>
    UC05 ..> UC06 : <<initiates>>
    UC09 ..> UC10 : <<unlocks>>
}

' Customer Connections
C --- UC01
C --- UC02
C --- UC05
C --- UC06
C --- UC07
C --- UC09
C --- UC10
C --- UC11

' Professional Connections
P --- UC01
P --- UC04
P --- UC06
P --- UC07
P --- UC08
P --- UC09
P --- UC11

' Administrator Connections
A --- UC01
A --- UC12
A --- UC13

@enduml
"""

render_plantuml(class_diagram_puml, "figures/fig_class_model_clean.png")
render_plantuml(usecase_diagram_puml, "figures/fig_use_case_model_clean.png")
