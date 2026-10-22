import requests

def render_graphviz(dot_code, output_path):
    r = requests.post(
        "https://kroki.io/graphviz/png",
        data=dot_code.encode("utf-8"),
        headers={"Content-Type": "text/plain; charset=utf-8"},
        timeout=30
    )
    if r.status_code == 200:
        with open(output_path, "wb") as f:
            f.write(r.content)
        print(f"Generated {output_path} ({len(r.content)} bytes)")
        return True
    else:
        print(f"Failed {output_path}: {r.status_code} - {r.text}")
        return False

# =========================================================================
# 1. CLASS DIAGRAM (Analysis Object Model)
# Visual Paradigm Style: HTML tables, Orthogonal Straight Lines, No Crossing
# =========================================================================
class_dot = """
digraph ClassDiagram {
    graph [rankdir=TB, splines=ortho, bgcolor=white, nodesep=0.7, ranksep=0.9, pad="0.4"];
    node [shape=none, fontname="Times New Roman", fontsize=11];
    edge [color="#1B365D", fontname="Times New Roman", fontsize=10, fontcolor="#0F2A4A"];

    // User Class
    User [label=<
        <TABLE BORDER="1" CELLBORDER="0" CELLSPACING="0" COLOR="#1B365D" BGCOLOR="#F8FAFD">
            <TR><TD BGCOLOR="#DCE6F5" BORDER="1" SIDES="B" ALIGN="CENTER"><B>User</B></TD></TR>
            <TR><TD ALIGN="LEFT" BORDER="1" SIDES="B">
                + userId : String<BR ALIGN="LEFT"/>
                + email : String<BR ALIGN="LEFT"/>
                + phoneNumber : String<BR ALIGN="LEFT"/>
                + passwordHash : String<BR ALIGN="LEFT"/>
                + role : UserRole<BR ALIGN="LEFT"/>
                + createdAt : DateTime
            </TD></TR>
            <TR><TD ALIGN="LEFT">
                + login()<BR ALIGN="LEFT"/>
                + logout()
            </TD></TR>
        </TABLE>
    >];

    // Actors Subgraph
    { rank=same; ServiceProfessional; Customer; }

    ServiceProfessional [label=<
        <TABLE BORDER="1" CELLBORDER="0" CELLSPACING="0" COLOR="#1B365D" BGCOLOR="#F8FAFD">
            <TR><TD BGCOLOR="#DCE6F5" BORDER="1" SIDES="B" ALIGN="CENTER"><B>ServiceProfessional</B></TD></TR>
            <TR><TD ALIGN="LEFT" BORDER="1" SIDES="B">
                + businessName : String<BR ALIGN="LEFT"/>
                + serviceCategories : List&lt;String&gt;<BR ALIGN="LEFT"/>
                + serviceDistricts : List&lt;String&gt;<BR ALIGN="LEFT"/>
                + isVerified : Boolean<BR ALIGN="LEFT"/>
                + aggregateRating : Float<BR ALIGN="LEFT"/>
                + completedJobsCount : Int
            </TD></TR>
            <TR><TD ALIGN="LEFT">
                + submitOffer()<BR ALIGN="LEFT"/>
                + updateAvailability()
            </TD></TR>
        </TABLE>
    >];

    Customer [label=<
        <TABLE BORDER="1" CELLBORDER="0" CELLSPACING="0" COLOR="#1B365D" BGCOLOR="#F8FAFD">
            <TR><TD BGCOLOR="#DCE6F5" BORDER="1" SIDES="B" ALIGN="CENTER"><B>Customer</B></TD></TR>
            <TR><TD ALIGN="LEFT" BORDER="1" SIDES="B">
                + firstName : String<BR ALIGN="LEFT"/>
                + lastName : String<BR ALIGN="LEFT"/>
                + defaultDistrict : String
            </TD></TR>
            <TR><TD ALIGN="LEFT">
                + createRequest()<BR ALIGN="LEFT"/>
                + acceptOffer()<BR ALIGN="LEFT"/>
                + submitReview()
            </TD></TR>
        </TABLE>
    >];

    // Request & Offer Subgraph
    { rank=same; StructuredOffer; ServiceRequest; Photo; }

    StructuredOffer [label=<
        <TABLE BORDER="1" CELLBORDER="0" CELLSPACING="0" COLOR="#1B365D" BGCOLOR="#F8FAFD">
            <TR><TD BGCOLOR="#DCE6F5" BORDER="1" SIDES="B" ALIGN="CENTER"><B>StructuredOffer</B></TD></TR>
            <TR><TD ALIGN="LEFT">
                + offerId : String<BR ALIGN="LEFT"/>
                + laborCost : Decimal<BR ALIGN="LEFT"/>
                + materialsCost : Decimal<BR ALIGN="LEFT"/>
                + totalEstimatedPrice : Decimal<BR ALIGN="LEFT"/>
                + earliestArrival : DateTime<BR ALIGN="LEFT"/>
                + scopeNotes : String<BR ALIGN="LEFT"/>
                + status : OfferStatus<BR ALIGN="LEFT"/>
                + submittedAt : DateTime
            </TD></TR>
        </TABLE>
    >];

    ServiceRequest [label=<
        <TABLE BORDER="1" CELLBORDER="0" CELLSPACING="0" COLOR="#1B365D" BGCOLOR="#F8FAFD">
            <TR><TD BGCOLOR="#DCE6F5" BORDER="1" SIDES="B" ALIGN="CENTER"><B>ServiceRequest</B></TD></TR>
            <TR><TD ALIGN="LEFT" BORDER="1" SIDES="B">
                + requestId : String<BR ALIGN="LEFT"/>
                + category : String<BR ALIGN="LEFT"/>
                + description : String<BR ALIGN="LEFT"/>
                + urgency : UrgencyLevel<BR ALIGN="LEFT"/>
                + district : String<BR ALIGN="LEFT"/>
                + neighborhood : String<BR ALIGN="LEFT"/>
                + exactAddress : String<BR ALIGN="LEFT"/>
                + status : RequestStatus<BR ALIGN="LEFT"/>
                + createdAt : DateTime
            </TD></TR>
            <TR><TD ALIGN="LEFT">
                + addPhoto()<BR ALIGN="LEFT"/>
                + cancelRequest()
            </TD></TR>
        </TABLE>
    >];

    Photo [label=<
        <TABLE BORDER="1" CELLBORDER="0" CELLSPACING="0" COLOR="#1B365D" BGCOLOR="#F8FAFD">
            <TR><TD BGCOLOR="#DCE6F5" BORDER="1" SIDES="B" ALIGN="CENTER"><B>Photo</B></TD></TR>
            <TR><TD ALIGN="LEFT">
                + photoId : String<BR ALIGN="LEFT"/>
                + fileUrl : String<BR ALIGN="LEFT"/>
                + uploadedAt : DateTime
            </TD></TR>
        </TABLE>
    >];

    // Job Layer
    Job [label=<
        <TABLE BORDER="1" CELLBORDER="0" CELLSPACING="0" COLOR="#1B365D" BGCOLOR="#F8FAFD">
            <TR><TD BGCOLOR="#DCE6F5" BORDER="1" SIDES="B" ALIGN="CENTER"><B>Job</B></TD></TR>
            <TR><TD ALIGN="LEFT" BORDER="1" SIDES="B">
                + jobId : String<BR ALIGN="LEFT"/>
                + currentStatus : JobStatus<BR ALIGN="LEFT"/>
                + startedAt : DateTime<BR ALIGN="LEFT"/>
                + completedAt : DateTime
            </TD></TR>
            <TR><TD ALIGN="LEFT">
                + updateStatus()<BR ALIGN="LEFT"/>
                + confirmCompletion()
            </TD></TR>
        </TABLE>
    >];

    // Bottom Layer: Appointment, Review, Complaint
    { rank=same; Appointment; Review; Complaint; }

    Appointment [label=<
        <TABLE BORDER="1" CELLBORDER="0" CELLSPACING="0" COLOR="#1B365D" BGCOLOR="#F8FAFD">
            <TR><TD BGCOLOR="#DCE6F5" BORDER="1" SIDES="B" ALIGN="CENTER"><B>Appointment</B></TD></TR>
            <TR><TD ALIGN="LEFT" BORDER="1" SIDES="B">
                + appointmentId : String<BR ALIGN="LEFT"/>
                + scheduledDateTime : DateTime<BR ALIGN="LEFT"/>
                + status : AppointmentStatus
            </TD></TR>
            <TR><TD ALIGN="LEFT">
                + reschedule()
            </TD></TR>
        </TABLE>
    >];

    Review [label=<
        <TABLE BORDER="1" CELLBORDER="0" CELLSPACING="0" COLOR="#1B365D" BGCOLOR="#F8FAFD">
            <TR><TD BGCOLOR="#DCE6F5" BORDER="1" SIDES="B" ALIGN="CENTER"><B>Review</B></TD></TR>
            <TR><TD ALIGN="LEFT">
                + reviewId : String<BR ALIGN="LEFT"/>
                + starRating : Int<BR ALIGN="LEFT"/>
                + commentText : String<BR ALIGN="LEFT"/>
                + submittedAt : DateTime
            </TD></TR>
        </TABLE>
    >];

    Complaint [label=<
        <TABLE BORDER="1" CELLBORDER="0" CELLSPACING="0" COLOR="#1B365D" BGCOLOR="#F8FAFD">
            <TR><TD BGCOLOR="#DCE6F5" BORDER="1" SIDES="B" ALIGN="CENTER"><B>Complaint</B></TD></TR>
            <TR><TD ALIGN="LEFT" BORDER="1" SIDES="B">
                + complaintId : String<BR ALIGN="LEFT"/>
                + reason : String<BR ALIGN="LEFT"/>
                + details : String<BR ALIGN="LEFT"/>
                + status : ComplaintStatus
            </TD></TR>
            <TR><TD ALIGN="LEFT">
                + resolve()
            </TD></TR>
        </TABLE>
    >];

    // Generalizations (Inheritance)
    ServiceProfessional -> User [arrowhead=onormal, dir=forward, label=""];
    Customer -> User [arrowhead=onormal, dir=forward, label=""];

    // Vertical Associations
    ServiceProfessional -> StructuredOffer [arrowhead=open, headlabel="0..*", taillabel="1", label="  submits"];
    Customer -> ServiceRequest [arrowhead=open, headlabel="0..*", taillabel="1", label="  creates"];

    // Horizontal in Request Layer
    StructuredOffer -> ServiceRequest [arrowhead=open, taillabel="0..*", headlabel="1", label="receives  "];
    ServiceRequest -> Photo [arrowhead=diamond, dir=back, headlabel="0..3", taillabel="1", label="contains  "];

    // Feed into Job
    StructuredOffer -> Job [arrowhead=open, taillabel="1", headlabel="0..1", label="activates  "];
    ServiceRequest -> Job [arrowhead=open, taillabel="1", headlabel="0..1", label="  originates"];

    // Feed into Bottom Entities
    Job -> Appointment [arrowhead=open, taillabel="1", headlabel="1", label="coordinates  "];
    Job -> Review [arrowhead=open, taillabel="1", headlabel="0..1", label="  receives"];
    Job -> Complaint [arrowhead=open, taillabel="1", headlabel="0..*", label="  targets"];
}
"""

# =========================================================================
# 2. USE CASE DIAGRAM
# Visual Paradigm Style: Direct Clean Straight Lines, Left-Center-Right Layout
# =========================================================================
usecase_dot = """
digraph UseCaseDiagram {
    graph [rankdir=LR, splines=line, bgcolor=white, nodesep=0.4, ranksep=1.1, pad="0.3"];
    node [fontname="Times New Roman"];
    edge [color="#1B365D", fontname="Times New Roman", fontsize=10, fontcolor="#0F2A4A"];

    // Actors (Left & Right)
    subgraph cluster_left_actors {
        graph [style=invis];
        Customer [shape=box, style="filled,rounded", fillcolor="#EAEFFE", color="#1B365D", penwidth=1.5, fontsize=13, fontcolor="#0F2A4A", label="«actor»\\nCustomer"];
        ServiceProfessional [shape=box, style="filled,rounded", fillcolor="#EAEFFE", color="#1B365D", penwidth=1.5, fontsize=13, fontcolor="#0F2A4A", label="«actor»\\nService Professional"];
    }

    Administrator [shape=box, style="filled,rounded", fillcolor="#EAEFFE", color="#1B365D", penwidth=1.5, fontsize=13, fontcolor="#0F2A4A", label="«actor»\\nAdministrator"];

    // System Boundary
    subgraph cluster_boundary {
        graph [label="BiTadilat System Boundaries", fontname="Times New Roman", fontsize=15, fontcolor="#0F2A4A", color="#1B365D", penwidth=1.8, style=solid, bgcolor="#FAFBFD"];
        node [shape=ellipse, style="filled,solid", fillcolor="#FFFFFF", color="#1B365D", penwidth=1.2, fontsize=11, fontcolor="#0F2A4A", width=2.4, height=0.6];

        // Column 1 (Left Column Inside Boundary)
        UC01 [label="UC01: Register & Login"];
        UC02 [label="UC02: Create Service Request"];
        UC03 [label="UC03: Rule-Based Matching"];
        UC04 [label="UC04: Submit Structured Offer"];
        UC05 [label="UC05: Compare & Accept Offer"];
        UC11 [label="UC11: Cancel Request / Job"];

        // Column 2 (Right Column Inside Boundary)
        UC06 [label="UC06: Schedule Appointment"];
        UC07 [label="UC07: Direct Messaging"];
        UC08 [label="UC08: Update Job Progress"];
        UC09 [label="UC09: Confirm Completion"];
        UC10 [label="UC10: Submit Review & Rating"];
        UC12 [label="UC12: Verify Professional Profile"];
        UC13 [label="UC13: Arbitrate Complaints"];

        // Column placement alignment
        { rank=same; UC01; UC06; }
        { rank=same; UC02; UC07; }
        { rank=same; UC03; UC08; }
        { rank=same; UC04; UC09; }
        { rank=same; UC05; UC10; }
        { rank=same; UC11; UC12; }
    }

    // Dependencies between use cases (dashed)
    UC02 -> UC03 [style=dashed, arrowhead=vee, label="«triggers»"];
    UC04 -> UC05 [style=dashed, arrowhead=vee, label="«informs»"];
    UC05 -> UC06 [style=dashed, arrowhead=vee, label="«initiates»"];
    UC09 -> UC10 [style=dashed, arrowhead=vee, label="«unlocks»"];

    // Customer Straight Association Lines
    Customer -> UC01 [arrowhead=none, penwidth=1.1];
    Customer -> UC02 [arrowhead=none, penwidth=1.1];
    Customer -> UC05 [arrowhead=none, penwidth=1.1];
    Customer -> UC06 [arrowhead=none, penwidth=1.1];
    Customer -> UC07 [arrowhead=none, penwidth=1.1];
    Customer -> UC09 [arrowhead=none, penwidth=1.1];
    Customer -> UC10 [arrowhead=none, penwidth=1.1];
    Customer -> UC11 [arrowhead=none, penwidth=1.1];

    // Service Professional Straight Association Lines
    ServiceProfessional -> UC01 [arrowhead=none, penwidth=1.1];
    ServiceProfessional -> UC04 [arrowhead=none, penwidth=1.1];
    ServiceProfessional -> UC06 [arrowhead=none, penwidth=1.1];
    ServiceProfessional -> UC07 [arrowhead=none, penwidth=1.1];
    ServiceProfessional -> UC08 [arrowhead=none, penwidth=1.1];
    ServiceProfessional -> UC09 [arrowhead=none, penwidth=1.1];
    ServiceProfessional -> UC11 [arrowhead=none, penwidth=1.1];

    // Administrator Straight Association Lines
    Administrator -> UC01 [arrowhead=none, penwidth=1.1];
    Administrator -> UC12 [arrowhead=none, penwidth=1.1];
    Administrator -> UC13 [arrowhead=none, penwidth=1.1];
}
"""

render_graphviz(class_dot, "figures/fig_class_model_clean.png")
render_graphviz(usecase_dot, "figures/fig_use_case_model_clean.png")
