import os
import base64
import requests
import json
import time

os.makedirs("figures", exist_ok=True)

diagrams = {
    "fig_use_case_model": """
flowchart LR
    subgraph Actors
        C[Customer]
        P[Service Professional]
        A[Administrator]
    end

    subgraph BiTadilat System Boundaries
        UC01((UC01: Register & Login))
        UC02((UC02: Create Service Request))
        UC03((UC03: Rule-Based Matching))
        UC04((UC04: Submit Structured Offer))
        UC05((UC05: Compare & Accept Offer))
        UC06((UC06: Schedule Appointment))
        UC07((UC07: Direct Messaging))
        UC08((UC08: Update Job Progress))
        UC09((UC09: Confirm Completion))
        UC10((UC10: Submit Review & Rating))
        UC11((UC11: Cancel Request / Job))
        UC12((UC12: Verify Professional Profile))
        UC13((UC13: Arbitrate Complaints))
    end

    C --> UC01
    C --> UC02
    C --> UC05
    C --> UC06
    C --> UC07
    C --> UC09
    C --> UC10
    C --> UC11

    P --> UC01
    P --> UC04
    P --> UC06
    P --> UC07
    P --> UC08
    P --> UC09
    P --> UC11

    A --> UC01
    A --> UC12
    A --> UC13

    UC02 -.->|triggers| UC03
    UC04 -.->|informs| UC05
    UC05 -.->|initiates| UC06
    UC09 -.->|unlocks| UC10
""",

    "fig_class_model": """
classDiagram
    class User {
        +String userId
        +String email
        +String phoneNumber
        +String passwordHash
        +UserRole role
        +DateTime createdAt
        +login()
        +logout()
    }

    class Customer {
        +String firstName
        +String lastName
        +String defaultDistrict
        +createRequest()
        +acceptOffer()
        +submitReview()
    }

    class ServiceProfessional {
        +String businessName
        +List~String~ serviceCategories
        +List~String~ serviceDistricts
        +Boolean isVerified
        +Float aggregateRating
        +Int completedJobsCount
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

    class Appointment {
        +String appointmentId
        +DateTime scheduledDateTime
        +AppointmentStatus status
        +reschedule()
    }

    class Job {
        +String jobId
        +JobStatus currentStatus
        +DateTime startedAt
        +DateTime completedAt
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
        +resolve()
    }

    User <|-- Customer
    User <|-- ServiceProfessional
    Customer "1" --> "0..*" ServiceRequest : creates
    ServiceRequest "1" *-- "0..3" Photo : contains
    ServiceRequest "1" <-- "0..*" StructuredOffer : receives
    ServiceProfessional "1" --> "0..*" StructuredOffer : submits
    ServiceRequest "1" --> "0..1" Job : originates
    StructuredOffer "1" --> "0..1" Job : activates
    Job "1" --> "1" Appointment : coordinates
    Job "1" --> "0..1" Review : receives
    Customer "1" --> "0..*" Complaint : files
    Job "1" --> "0..*" Complaint : targets
""",

    "fig_seq_offer_accept": """
sequenceDiagram
    autonumber
    actor C as Customer
    participant App as Mobile App
    participant Engine as Matching Engine
    actor P as Professional
    participant DB as Backend Database

    C->>App: Fill request form (Urgent, Kadikoy, Photos)
    App->>DB: POST /api/requests (Store request, Status: OPEN)
    DB-->>App: Request Created (#1042)
    App->>Engine: Trigger Rule-Based Matching(#1042)
    Engine->>DB: Query Pros (Category='Plumbing', District='Kadikoy', Available=TRUE)
    DB-->>Engine: Return 3 Eligible Pros
    Engine-->>App: Present Eligible Pros with Trust Badges
    
    P->>App: View Matched Request #1042 Feed
    P->>App: Fill Structured Offer (Labor: 850 TL, Materials: 400 TL)
    App->>DB: POST /api/requests/1042/offers
    DB-->>P: Offer Submitted (#Offer-88)

    C->>App: Open Offer Comparison Screen
    C->>App: Click "Accept Offer" on #Offer-88
    App->>DB: PUT /api/offers/Offer-88/accept (Atomic Transaction)
    Note over DB: Lock Request #1042<br/>Set Offer-88 status = ACCEPTED<br/>Set rival offers = REJECTED<br/>Create Job #Job-501<br/>Unlock exact address to Pro
    DB-->>App: Acceptance Confirmed
    App-->>C: Display Active Job Workspace & Appointment Screen
""",

    "fig_state_lifecycle": """
stateDiagram-v2
    [*] --> DRAFT
    DRAFT --> OPEN : Submit Request
    OPEN --> MATCHED : Eligible Pros Identified
    MATCHED --> OFFER_RECEIVED : Pro Submits Structured Offer
    OFFER_RECEIVED --> OFFER_ACCEPTED : Customer Accepts 1 Offer
    OFFER_RECEIVED --> CANCELLED : Customer Cancels Request
    
    state "Active Job Lifecycle" as JobState {
        OFFER_ACCEPTED --> APPOINTMENT_SCHEDULED : Set Inspection/Work Date
        APPOINTMENT_SCHEDULED --> IN_PROGRESS : Pro Arrives & Starts Work
        IN_PROGRESS --> WORK_FINISHED : Pro Marks Work Done
        WORK_FINISHED --> COMPLETED : Customer Confirms Completion
        
        APPOINTMENT_SCHEDULED --> DISPUTED : Complaint Filed
        IN_PROGRESS --> DISPUTED : Complaint Filed
        DISPUTED --> CANCELLED : Admin Arbitrates Cancellation
        DISPUTED --> COMPLETED : Admin Resolves & Finalizes
    }

    COMPLETED --> REVIEWED : Customer Submits Rating (1-5 Stars)
    REVIEWED --> [*]
    CANCELLED --> [*]
""",

    "fig_flow_customer": """
flowchart TD
    C_Splash([App Launch / Splash]) --> C_Auth{Authenticated?}
    C_Auth -- No --> C_Login[Customer Login / Register]
    C_Auth -- Yes --> C_Home[Customer Dashboard]
    
    C_Login --> C_Home
    
    C_Home --> C_ReqCat[Select Service Category]
    C_ReqCat --> C_ReqForm[New Request: Scope, Photos, District, Urgency]
    C_ReqForm --> C_ReqReview[Review & Submit Request]
    C_ReqReview --> C_MatchList[Rule-Based Matching & Eligible Pros]
    
    C_Home --> C_MyReqs[Active Requests & Jobs]
    C_MyReqs --> C_OfferComp[Compare Structured Offers]
    C_OfferComp -->|Accept Single Offer| C_ApptSelect[Select / Confirm Appointment]
    
    C_ApptSelect --> C_JobProgress[Job Workspace: Status & Details]
    C_JobProgress --> C_Chat[Secure 1-to-1 Messaging]
    C_JobProgress --> C_Cancel[Cancel Request/Job with Rule Check]
    C_JobProgress --> C_Complete[Confirm Completion]
    C_Complete --> C_Review[Submit Rating & Written Review]
    C_Review --> C_Home
""",

    "fig_flow_pro": """
flowchart TD
    P_Splash([App Launch / Splash]) --> P_Auth{Authenticated?}
    P_Auth -- No --> P_Login[Professional Login / Register]
    P_Auth -- Yes --> P_Home[Professional Dashboard]
    
    P_Login --> P_ProfileSetup[Profile & Credentials Verification]
    P_ProfileSetup --> P_Home
    
    P_Home --> P_Config[Configure Service Areas & Categories]
    P_Home --> P_Calendar[Manage Availability Calendar]
    P_Home --> P_ReqFeed[Matched Requests Feed]
    
    P_ReqFeed --> P_ReqDetail[View Request Details & Scope Photos]
    P_ReqDetail --> P_MakeOffer[Create Structured Offer: Labor, Materials, Date]
    P_MakeOffer --> P_OfferSent[Offer Submitted Confirmation]
    
    P_Home --> P_ActiveJobs[Accepted Jobs & Appointments]
    P_ActiveJobs --> P_JobWorkspace[Job Execution Workspace]
    P_JobWorkspace --> P_Chat[Secure 1-to-1 Client Messaging]
    P_JobWorkspace --> P_UpdateStatus[Update Job Status: In-Progress / Finished]
""",

    "fig_flow_admin": """
flowchart TD
    A_Login[Admin Login] --> A_Dash[Admin Overview Dashboard]
    A_Dash --> A_Pros[Professional Verification Queue]
    A_Pros --> A_ProInspect[Inspect Trade Documents & Profile]
    A_ProInspect -->|Approve / Reject| A_Pros
    
    A_Dash --> A_Complaints[Complaint & Dispute Management]
    A_Complaints --> A_CompInspect[Review Disputed Job, Messages, & Evidence]
    A_CompInspect -->|Resolve / Warn / Suspend| A_Complaints
    
    A_Dash --> A_Users[User Account Directory: Customers & Pros]
""",

    "fig_flow_promo": """
flowchart TD
    W_Hero[Landing Page / Hero Banner] --> W_Features[Key Features: Urgent vs Planned, Trust Matching]
    W_Hero --> W_HowItWorks[Step-by-Step Customer & Pro Workflows]
    W_Hero --> W_Download[Download App Store / Google Play Links]
    W_Hero --> W_About[About BiTadilat, SDG 8 Mission & Istanbul Focus]
    W_Hero --> W_Contact[Contact & FAQ Section]
""",

    "fig_gantt": """
gantt
    title BiTadilat Project Schedule (Fall 2026 - Jan 2027)
    dateFormat  YYYY-MM-DD
    section WP1: RAD
    Scope & Objectives            :2026-09-28, 2026-10-12
    Use Cases, Models & Mock-ups  :2026-10-05, 2026-10-14
    RAD Review & Submission       :milestone, 2026-10-16, 2026-10-16
    section WP2: SDD
    Architecture & API Design     :2026-10-17, 2026-10-24
    SDD Review & Submission       :milestone, 2026-10-30, 2026-10-30
    section WP3: Backend
    Auth, Roles & Matching Engine :2026-10-19, 2026-11-09
    Offers, Jobs & Admin APIs     :2026-11-09, 2026-12-04
    section WP4: Frontend & Web
    Customer & Pro Mobile Screens :2026-10-19, 2026-11-20
    Admin Panel & Promo Website   :2026-11-16, 2026-12-04
    section WP5: Testing
    Integration & Security Tests  :2026-11-02, 2026-12-15
    Usability Evaluation Trials   :2026-12-07, 2026-12-25
    section WP6: Submission
    Final Thesis & Code Package   :milestone, 2027-01-02, 2027-01-02
    Poster & Demo Presentation    :milestone, 2027-01-08, 2027-01-08
"""
}

def render_diagram(name, code):
    # Try mermaid.ink
    data = {"code": code.strip(), "mermaid": {"theme": "default"}}
    json_bytes = json.dumps(data).encode("utf-8")
    b64_json = base64.urlsafe_b64encode(json_bytes).decode("utf-8")
    url = f"https://mermaid.ink/img/pako:{b64_json}?bgColor=FFFFFF"

    # Direct base64 fallback
    raw_b64 = base64.urlsafe_b64encode(code.strip().encode("utf-8")).decode("utf-8")
    url_direct = f"https://mermaid.ink/img/{raw_b64}?bgColor=FFFFFF"

    print(f"Rendering {name}...")
    for target_url in [url_direct, url]:
        try:
            r = requests.get(target_url, timeout=20)
            if r.status_code == 200 and len(r.content) > 1000:
                with open(f"figures/{name}.png", "wb") as f:
                    f.write(r.content)
                print(f" -> Successfully saved figures/{name}.png ({len(r.content)} bytes)")
                return True
        except Exception as e:
            print(f"  Attempt failed for {target_url[:40]}...: {e}")
            time.sleep(1)
    
    # Kroki fallback
    kroki_url = f"https://kroki.io/mermaid/png/{raw_b64}"
    try:
        r = requests.get(kroki_url, timeout=20)
        if r.status_code == 200 and len(r.content) > 1000:
            with open(f"figures/{name}.png", "wb") as f:
                f.write(r.content)
            print(f" -> Successfully saved figures/{name}.png via Kroki ({len(r.content)} bytes)")
            return True
    except Exception as e:
        print(f"  Kroki failed: {e}")

    print(f"Failed to render {name}")
    return False

for name, code in diagrams.items():
    render_diagram(name, code)
