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

usecase_dot = """
digraph UseCaseDiagram {
    graph [rankdir=LR, splines=line, bgcolor=white, nodesep=0.4, ranksep=1.2, pad="0.4"];
    node [fontname="Times New Roman"];
    edge [color="#1B365D", fontname="Times New Roman", fontsize=10, fontcolor="#0F2A4A"];

    // Left Actors
    Customer [shape=box, style="filled,rounded", fillcolor="#EAEFFE", color="#1B365D", penwidth=1.5, fontsize=13, fontcolor="#0F2A4A", label="«actor»\\nCustomer"];
    ServiceProfessional [shape=box, style="filled,rounded", fillcolor="#EAEFFE", color="#1B365D", penwidth=1.5, fontsize=13, fontcolor="#0F2A4A", label="«actor»\\nService Professional"];

    // Right Actor
    Administrator [shape=box, style="filled,rounded", fillcolor="#EAEFFE", color="#1B365D", penwidth=1.5, fontsize=13, fontcolor="#0F2A4A", label="«actor»\\nAdministrator"];

    // System Boundary
    subgraph cluster_system {
        label = "BiTadilat System Boundaries";
        fontname = "Times New Roman";
        fontsize = 15;
        fontcolor = "#0F2A4A";
        color = "#1B365D";
        penwidth = 1.8;
        bgcolor = "#FAFBFD";
        style = solid;

        node [shape=ellipse, style="filled,solid", fillcolor="#FFFFFF", color="#1B365D", penwidth=1.2, fontsize=11, fontcolor="#0F2A4A", width=2.3, height=0.55];

        // Column 1
        UC01 [label="UC01: Register & Login"];
        UC02 [label="UC02: Create Service Request"];
        UC04 [label="UC04: Submit Structured Offer"];
        UC07 [label="UC07: Direct Messaging"];
        UC11 [label="UC11: Cancel Request / Job"];

        // Column 2
        UC03 [label="UC03: Rule-Based Matching"];
        UC05 [label="UC05: Compare & Accept Offer"];
        UC06 [label="UC06: Schedule Appointment"];
        UC08 [label="UC08: Update Job Progress"];
        UC09 [label="UC09: Confirm Completion"];
        UC10 [label="UC10: Submit Review & Rating"];

        // Column 3
        UC12 [label="UC12: Verify Professional Profile"];
        UC13 [label="UC13: Arbitrate Complaints"];
    }

    // Explicit 4-column positioning
    { rank=same; Customer; ServiceProfessional; }
    { rank=same; UC01; UC02; UC04; UC07; UC11; }
    { rank=same; UC03; UC05; UC06; UC08; UC09; UC10; }
    { rank=same; UC12; UC13; Administrator; }

    // Internal Dependencies
    UC02 -> UC03 [style=dashed, arrowhead=vee, label="«triggers»"];
    UC04 -> UC05 [style=dashed, arrowhead=vee, label="«informs»"];
    UC05 -> UC06 [style=dashed, arrowhead=vee, label="«initiates»"];
    UC09 -> UC10 [style=dashed, arrowhead=vee, label="«unlocks»"];

    // Customer Associations
    Customer -> UC01 [arrowhead=none, penwidth=1.1];
    Customer -> UC02 [arrowhead=none, penwidth=1.1];
    Customer -> UC05 [arrowhead=none, penwidth=1.1];
    Customer -> UC06 [arrowhead=none, penwidth=1.1];
    Customer -> UC07 [arrowhead=none, penwidth=1.1];
    Customer -> UC09 [arrowhead=none, penwidth=1.1];
    Customer -> UC10 [arrowhead=none, penwidth=1.1];
    Customer -> UC11 [arrowhead=none, penwidth=1.1];

    // Service Professional Associations
    ServiceProfessional -> UC01 [arrowhead=none, penwidth=1.1];
    ServiceProfessional -> UC04 [arrowhead=none, penwidth=1.1];
    ServiceProfessional -> UC06 [arrowhead=none, penwidth=1.1];
    ServiceProfessional -> UC07 [arrowhead=none, penwidth=1.1];
    ServiceProfessional -> UC08 [arrowhead=none, penwidth=1.1];
    ServiceProfessional -> UC09 [arrowhead=none, penwidth=1.1];
    ServiceProfessional -> UC11 [arrowhead=none, penwidth=1.1];

    // Administrator Associations (Direct on the Right)
    Administrator -> UC01 [arrowhead=none, penwidth=1.1];
    Administrator -> UC12 [arrowhead=none, penwidth=1.1];
    Administrator -> UC13 [arrowhead=none, penwidth=1.1];
}
"""

render_graphviz(usecase_dot, "figures/fig_use_case_model.png")
