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
# USE CASE DIAGRAM: VISUAL PARADIGM STYLE WITH DIRECT CLEAN LINES
# -------------------------------------------------------------
usecase_puml = """
@startuml
skinparam shadowing false
skinparam defaultFontName "Times New Roman"
skinparam defaultFontSize 12

skinparam actor {
    BackgroundColor #F4F6FB
    BorderColor #1B365D
    BorderThickness 1.2
    FontColor #0F2A4A
    FontSize 13
    FontStyle bold
}

skinparam usecase {
    BackgroundColor #F8FAFD
    BorderColor #1B365D
    BorderThickness 1.2
    FontColor #0F2A4A
    FontSize 11.5
    ArrowColor #1B365D
    ArrowThickness 1.1
}

skinparam rectangle {
    BackgroundColor #FFFFFF
    BorderColor #1B365D
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
    package "Core Management" <<Rectangle>> #FDFDFD {
        usecase "UC01: Register & Login" as UC01
        usecase "UC11: Cancel Request / Job" as UC11
    }

    package "Request & Match Lifecycle" <<Rectangle>> #FDFDFD {
        usecase "UC02: Create Service Request" as UC02
        usecase "UC03: Rule-Based Matching" as UC03
        usecase "UC04: Submit Structured Offer" as UC04
        usecase "UC05: Compare & Accept Offer" as UC05
    }

    package "Job Execution & Review" <<Rectangle>> #FDFDFD {
        usecase "UC06: Schedule Appointment" as UC06
        usecase "UC07: Direct Messaging" as UC07
        usecase "UC08: Update Job Progress" as UC08
        usecase "UC09: Confirm Completion" as UC09
        usecase "UC10: Submit Review & Rating" as UC10
    }

    package "Platform Administration" <<Rectangle>> #FDFDFD {
        usecase "UC12: Verify Professional Profile" as UC12
        usecase "UC13: Arbitrate Complaints" as UC13
    }

    ' Explicit dependencies
    UC02 .> UC03 : <<triggers>>
    UC04 .> UC05 : <<informs>>
    UC05 .> UC06 : <<initiates>>
    UC09 .> UC10 : <<unlocks>>
}

' Customer Connections
C -- UC01
C -- UC02
C -- UC05
C -- UC06
C -- UC07
C -- UC09
C -- UC10
C -- UC11

' Service Professional Connections
P -- UC01
P -- UC04
P -- UC06
P -- UC07
P -- UC08
P -- UC09
P -- UC11

' Administrator Connections (from right)
UC01 -- A
UC12 -- A
UC13 -- A

@enduml
"""

render_plantuml(usecase_puml, "figures/fig_use_case_model_clean.png")
