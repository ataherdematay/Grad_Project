import os
import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

def set_cell_background(cell, fill_hex):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>')
    tcPr.append(shd)

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = parse_xml(f'<w:tcMar {nsdecls("w")}><w:top w:w="{top}" w:type="dxa"/><w:bottom w:w="{bottom}" w:type="dxa"/><w:left w:w="{left}" w:type="dxa"/><w:right w:w="{right}" w:type="dxa"/></w:tcMar>')
    tcPr.append(tcMar)

def create_document():
    doc = Document()
    
    # Page setup - 1 inch margins
    for section in doc.sections:
        section.top_margin = Inches(1.0)
        section.bottom_margin = Inches(1.0)
        section.left_margin = Inches(1.0)
        section.right_margin = Inches(1.0)
        
    # Styles setup
    style_normal = doc.styles['Normal']
    font = style_normal.font
    font.name = 'Times New Roman'
    font.size = Pt(12)
    font.color.rgb = RGBColor(0x22, 0x22, 0x22)
    style_normal.paragraph_format.line_spacing = 1.15
    style_normal.paragraph_format.space_after = Pt(6)
    
    def add_p(text, bold=False, italic=False, size=12, align=WD_ALIGN_PARAGRAPH.LEFT, space_before=0, space_after=6):
        p = doc.add_paragraph()
        p.alignment = align
        p.paragraph_format.space_before = Pt(space_before)
        p.paragraph_format.space_after = Pt(space_after)
        p.paragraph_format.line_spacing = 1.15
        run = p.add_run(text)
        run.bold = bold
        run.italic = italic
        run.font.name = 'Times New Roman'
        run.font.size = Pt(size)
        return p

    def add_h1(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(18)
        p.paragraph_format.space_after = Pt(8)
        p.paragraph_format.keep_with_next = True
        run = p.add_run(text)
        run.bold = True
        run.font.name = 'Times New Roman'
        run.font.size = Pt(16)
        run.font.color.rgb = RGBColor(0x0F, 0x2A, 0x4A)
        return p

    def add_h2(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(14)
        p.paragraph_format.space_after = Pt(6)
        p.paragraph_format.keep_with_next = True
        run = p.add_run(text)
        run.bold = True
        run.font.name = 'Times New Roman'
        run.font.size = Pt(14)
        run.font.color.rgb = RGBColor(0x1B, 0x44, 0x75)
        return p

    def add_h3(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(10)
        p.paragraph_format.space_after = Pt(4)
        p.paragraph_format.keep_with_next = True
        run = p.add_run(text)
        run.bold = True
        run.font.name = 'Times New Roman'
        run.font.size = Pt(12)
        run.font.color.rgb = RGBColor(0x22, 0x22, 0x22)
        return p

    def add_fig(image_path, caption_text, width=Inches(5.2)):
        if os.path.exists(image_path):
            p_img = doc.add_paragraph()
            p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p_img.paragraph_format.space_before = Pt(8)
            p_img.paragraph_format.space_after = Pt(4)
            p_img.paragraph_format.keep_with_next = True
            run = p_img.add_run()
            run.add_picture(image_path, width=width)
            
            p_cap = doc.add_paragraph()
            p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p_cap.paragraph_format.space_before = Pt(2)
            p_cap.paragraph_format.space_after = Pt(12)
            run_cap = p_cap.add_run(caption_text)
            run_cap.font.name = 'Times New Roman'
            run_cap.font.size = Pt(10)
            run_cap.italic = True
            run_cap.font.color.rgb = RGBColor(0x44, 0x44, 0x44)

    def add_code_box(text):
        table = doc.add_table(rows=1, cols=1)
        table.alignment = WD_TABLE_ALIGNMENT.CENTER
        cell = table.cell(0, 0)
        set_cell_background(cell, "F4F6F9")
        set_cell_margins(cell, top=100, bottom=100, left=150, right=150)
        p = cell.paragraphs[0]
        p.paragraph_format.space_before = Pt(2)
        p.paragraph_format.space_after = Pt(2)
        p.paragraph_format.line_spacing = 1.05
        run = p.add_run(text.strip())
        run.font.name = 'Courier New'
        run.font.size = Pt(8.5)
        doc.add_paragraph().paragraph_format.space_after = Pt(4)

    # -------------------------------------------------------------
    # COVER / HEADER
    # -------------------------------------------------------------
    header_table = doc.add_table(rows=4, cols=2)
    header_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    
    cell_c0 = header_table.cell(0, 0)
    p = cell_c0.paragraphs[0]
    p.paragraph_format.space_after = Pt(2)
    r = p.add_run("COMP/SOFT4902/4912   Graduation Design Project")
    r.bold = True
    r.font.size = Pt(11)
    
    cell_c1 = header_table.cell(0, 1)
    p = cell_c1.paragraphs[0]
    p.paragraph_format.space_after = Pt(2)
    p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    r = p.add_run("FEYZİYE SCHOOLS FOUNDATION\nIŞIK UNIVERSITY")
    r.bold = True
    r.font.size = Pt(11)
    r.font.color.rgb = RGBColor(0x0F, 0x2A, 0x4A)

    cell_t = header_table.cell(1, 0)
    cell_t.merge(header_table.cell(1, 1))
    p = cell_t.paragraphs[0]
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(4)
    r1 = p.add_run("Project Title: ")
    r1.bold = True
    r2 = p.add_run("BiTadilat – A Location-Based Mobile Platform for Home Repair and Renovation Service Matching and Management")
    r2.bold = True
    r2.font.color.rgb = RGBColor(0x0F, 0x2A, 0x4A)

    cell_m = header_table.cell(2, 0)
    cell_m.merge(header_table.cell(2, 1))
    p = cell_m.paragraphs[0]
    p.paragraph_format.space_before = Pt(4)
    p.paragraph_format.space_after = Pt(4)
    r = p.add_run("Project Team:\n• Alaa Eddin Almallah (21soft1058) – Technical Product Management Lead\n• Ata Herdem Atay (22soft1004) – Frontend & Mobile Interfaces Lead\n• Hakan Kuvan (21soft1018) – Backend & Database Architecture Lead")
    r.font.size = Pt(10.5)

    cell_doc = header_table.cell(3, 0)
    cell_doc.merge(header_table.cell(3, 1))
    set_cell_background(cell_doc, "0F2A4A")
    p = cell_doc.paragraphs[0]
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(6)
    r = p.add_run("REQUIREMENTS ANALYSIS DOCUMENT (RAD)")
    r.bold = True
    r.font.size = Pt(14)
    r.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

    doc.add_paragraph().paragraph_format.space_after = Pt(12)

    # -------------------------------------------------------------
    # 1. INTRODUCTION
    # -------------------------------------------------------------
    add_h1("1. Introduction")
    add_p("BiTadilat represents a platform concept for home repairs and renovations in Istanbul. The idea takes into account the challenges that users face when searching for appropriate specialists, comparing their offers, and scheduling appointments. The system also aims to help professionals organize service requests, offers, and appointments. Considering the project concept which has been accepted, the platform will include a mobile application, promotional website, and administrative panel accessible via the web browser. This chapter explains the purpose and scope of the system, the objectives and success criteria of the project, and the glossary and document overview.")

    add_h2("1.1. Purpose of the System")
    add_p("The goal of BiTadilat is to assist customers in Istanbul to identify a fitting contractor for their home repair and renovation requirements using a mobile application. The goal is to facilitate the entire process by providing customers with the opportunity to specify their requirements, compare structured offers, get in touch with a chosen professional, and monitor their job.")
    add_p("Furthermore, it will enable professionals to identify fitting service requests, offers, and appointments. The promotional website will introduce BiTadilat, while the administrator panel will facilitate the process of platform management. BiTadilat aims to support United Nations Sustainable Development Goal 8, Decent Work and Economic Growth, by helping local professionals reach potential customers and organize their work.")

    add_h2("1.2. Scope of the System")
    add_p("BiTadilat will be created as a mobile application prototype for providing home repair and renovation services in Istanbul. The mobile application will provide separate interfaces for customers and service professionals. In addition, there will be an administrating system accessible from a web platform and a promotional website for introducing the application to customers.")
    add_p("Customers will be capable of registering an account, sending service requests with description and photo upload by choosing the service category and location of the work, classifying them as urgent or planned, and managing their status within the application. Moreover, they will be able to see and compare offers from multiple professionals, select a candidate, communicate in the application, schedule appointments, and manage the course of the job.")
    add_p("Professionals will be able to manage their profiles, service categories, service areas, and stated availability. They will view relevant service requests and submit structured offers. The matching system will provide a list of professionals who match the request based on predefined criteria, displaying matching factors and trust indicators.")
    add_p("Explicit Out-of-Scope Items: Online payments, live professional GPS tracking, AI-based problem diagnosis, and machine learning for matching purposes are out of scope. The prototype will not support service locations outside Istanbul. The platform will not guarantee professional availability or the quality of work performed.")

    add_h2("1.3. Objectives and Success Criteria of the Project")
    crit_list = [
        ("1. Allow customers to create service requests: ", "Customers choose categories, describe required work, attach photos, designate Istanbul district, and select urgent or planned.\nSuccess criterion: Test users can create both urgent and planned requests properly. Incomplete submissions are prevented by validation."),
        ("2. Generate relevant and intelligible professional matching: ", "The system identifies matching professionals using predefined criteria and displays explicit matching reasons.\nSuccess criterion: System filters out non-relevant professionals and displays matching factors clearly."),
        ("3. Facilitate submission and acceptance of an offer: ", "Professionals submit itemized offers; customers compare and accept one offer.\nSuccess criterion: Offers show required fields; atomic concurrency control prevents two offers from being accepted simultaneously."),
        ("4. Support the complete workflow of service provision: ", "Covers communication, appointment scheduling, progress tracking, completion confirmation, and post-job review.\nSuccess criterion: Full workflow executes without error; invalid status transitions and premature ratings are blocked."),
        ("5. Secure private information of users: ", "Precise address, private chat, and uploaded photos are restricted based on user role and job participation.\nSuccess criterion: Unauthorized access attempts to protected data are rejected."),
        ("6. Ensure interface usability: ", "Users execute core tasks without guidance.\nSuccess criterion: At least 80% of core tasks are completed without assistance in formal usability tests with at least five participants."),
        ("7. Supporting website and administrator panel: ", "Informational web pages and administrative management of accounts, profiles, and complaints.\nSuccess criterion: Responsive promotional site and operational admin dashboard for test records.")
    ]
    for title, desc in crit_list:
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(4)
        p.paragraph_format.space_after = Pt(4)
        p.paragraph_format.left_indent = Inches(0.25)
        r1 = p.add_run(title)
        r1.bold = True
        r2 = p.add_run(desc)

    add_h2("1.4. Definitions, Acronyms, and Abbreviations")
    add_p("• BiTadilat: Mobile and web platform concept for home repair service matching in Istanbul.\n• RAD: Requirements Analysis Document.\n• Customer: User who requests repair or renovation services and evaluates offers.\n• Service Professional: Skilled repair specialist registered to view requests and submit offers.\n• Administrator: Authorized platform manager who reviews artisan profiles and handles complaints.\n• Service Request: Customer description of required repair work.\n• Urgent Request: High-priority service request flagged for urgent repair needs, without dispatch time guarantees.\n• Planned Request: Request scheduled for a future appointment.\n• Structured Offer: Itemized quote specifying labor, estimated materials, arrival time, and notes.\n• Job: The agreed repair engagement instantiated after an offer is accepted.\n• Trust Indicators: Credibility indicators such as reviewed profile badge, star rating, and completed jobs count.\n• RBAC: Role-Based Access Control.")

    add_h2("1.5. Document Overview")
    add_p("Section 2 covers the Current System status; Section 3 details the Proposed System (use cases, scenarios, non-functional requirements, SDG alignment, UML models, and UI mock-ups); Section 4 discusses Project Risks and Work Packages; Section 5 compiles the Glossary; and Section 6 contains References.")

    # -------------------------------------------------------------
    # 2. CURRENT SYSTEM
    # -------------------------------------------------------------
    add_h1("2. Current System")

    # -------------------------------------------------------------
    # 3. PROPOSED SYSTEM
    # -------------------------------------------------------------
    add_h1("3. Proposed System")
    
    add_h2("3.1. Overview")
    add_p("BiTadilat implements the service process for home repair and renovation through three major actors – customer, service professional, and administrator. Customers and professionals use dedicated interfaces in the mobile application, while administrators access a web-based panel.")

    add_h2("3.2. Requirements")

    add_h3("3.2.1. Use Cases")
    uc_table = doc.add_table(rows=15, cols=4)
    uc_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    headers = ["UC ID", "Use Case Name", "Primary Actor", "Priority"]
    for i, h in enumerate(headers):
        cell = uc_table.cell(0, i)
        set_cell_background(cell, "0F2A4A")
        set_cell_margins(cell, 80, 80, 100, 100)
        p = cell.paragraphs[0]
        r = p.add_run(h)
        r.bold = True
        r.font.size = Pt(10)
        r.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

    uc_data = [
        ("UC01", "User Registration & Login", "Customer, Pro, Admin", "High"),
        ("UC02", "Create Service Request", "Customer", "High"),
        ("UC03", "Rule-Based Matching", "System", "High"),
        ("UC04", "Submit Structured Offer", "Service Professional", "High"),
        ("UC05", "Compare & Accept Single Offer", "Customer", "High"),
        ("UC06", "Schedule Appointment", "Customer & Pro", "Medium"),
        ("UC07", "In-App Direct Messaging", "Customer & Pro", "Medium"),
        ("UC08", "Update Job Progress", "Service Professional", "High"),
        ("UC09", "Confirm Completion", "Customer & Pro", "High"),
        ("UC10", "Submit Review & Rating", "Customer", "Medium"),
        ("UC11", "Cancel Service Request / Job", "Customer & Pro", "Medium"),
        ("UC12", "Verify Professional Profile", "Administrator", "High"),
        ("UC13", "Arbitrate Customer Complaints", "Administrator", "Medium"),
        ("UC14", "Browse Promotional Showcase", "Public Visitor", "Low")
    ]
    for row_idx, row in enumerate(uc_data, start=1):
        for col_idx, text in enumerate(row):
            cell = uc_table.cell(row_idx, col_idx)
            set_cell_margins(cell, 60, 60, 80, 80)
            if row_idx % 2 == 1:
                set_cell_background(cell, "F7F9FB")
            p = cell.paragraphs[0]
            r = p.add_run(text)
            r.font.size = Pt(9.5)
            if col_idx == 0 or col_idx == 3:
                r.bold = True

    add_p("", space_after=6)

    add_h3("3.2.2. Scenarios")
    add_p("Scenario 1: Emergency Plumbing Repair (Urgent Workflow)\nAhmet discovers a leaking pipe beneath his bathroom sink on Tuesday evening in Moda, Kadıköy. He opens BiTadilat, selects 'Plumbing', flags the urgency as 'Urgent', specifies 'Kadıköy / Moda', adds 2 photos, and submits. The rule-based engine identifies local plumbers with declared availability. Mehmet Usta inspects the request and submits a structured offer (₺850 labor, ₺400 parts, 22:00 arrival). Ahmet compares the offers, inspects Mehmet's profile and rating, and accepts. The request locks atomically. Mehmet receives the exact address, sends an in-app message, arrives at 22:00, fixes the leak, and marks completion. A confirmation dialog appears for Ahmet, who confirms completion and submits a 5-star review.")

    add_p("Scenario 2: Planned Apartment Painting (Planned Workflow)\nAyşe plans to repaint her apartment in Beşiktaş next month. She posts a 'Planned Request' with wall dimensions and preferred dates. Registered painters submit quotes with labor and materials breakdowns. She reviews the comparison screen, accepts one valid offer to initiate the job, and then communicates with the chosen painter via in-app messaging to coordinate access and confirm an appointment date.")

    # -------------------------------------------------------------
    # 3.3. NONFUNCTIONAL REQUIREMENTS
    # -------------------------------------------------------------
    add_h2("3.3. Nonfunctional Requirements")

    add_h3("3.3.1. Usability")
    add_p("• Unassisted Task Completion: At least 80% of core tasks must be completed without assistance in formal usability testing with at least five participants.")
    add_p("• Learnability: First-time customers can submit a request in under 3 minutes; professionals can prepare and send a structured offer in under 90 seconds (measured under agreed usability test scenarios).")
    add_p("• Dynamic Localization: Full interface support for Turkish (TR) and English (EN), switchable on-the-fly.")
    add_p("• Error Prevention & Confirmation Dialogs: A confirmation dialog is required before accepting an offer, cancelling a job, or confirming completion, ensuring users do not trigger irreversible state changes accidentally.")
    add_p("• Touch Ergonomics: Mobile interactive touch targets must meet a minimum interactive area of 48 × 48 dp; text contrast must satisfy WCAG 2.1 AA standards (≥ 4.5:1).")

    add_h3("3.3.2. Reliability")
    add_p("• Platform Availability: API services shall target ≥ 99.5% uptime during operational testing hours (07:00–23:00 Istanbul time).\n• Atomic Acceptance: Database transactions enforce that accepting one offer locks the request and transitions competing offers to rejected status.")

    add_h3("3.3.3. Performance")
    add_p("• API Latency: Target read requests return within < 500 ms on 4G mobile networks.\n• Image Payload: Client-side compression limits photo attachments to ≤ 1.5 MB before upload.")

    add_h3("3.3.4. Supportability & Implementation")
    add_p("• Decoupled Architecture: Client-server architecture separating mobile apps from backend REST APIs.\n• Technology Stack: Cross-platform mobile framework (Flutter / React Native) and relational database (PostgreSQL).")

    add_h3("3.3.5. External Interfaces & Packaging")
    add_p("• Device Hardware: Camera and storage access permissions.\n• Notifications: Push notification services (FCM / APNs) for offer and message alerts.\n• Packaging: Packaged mobile builds (Android APK, iOS) and containerized backend (Docker).")

    add_h3("3.3.6. Legal & Privacy Constraints")
    add_p("• KVKK Compliance: Adheres to Turkish Law No. 6698 on Protection of Personal Data.\n• Address Privacy: Exact street address and apartment numbers remain confidential until an offer is accepted.")

    add_h3("3.3.7. Sustainable Development Goals (SDG) Alignment")
    add_p("• SDG 8 – Decent Work and Economic Growth (Target 8.3 & Target 8.5): BiTadilat aims to support SDG 8 by helping local repair and renovation professionals in Istanbul reach potential customers and organize their work. By offering structured proposal forms, customer review histories, and a centralized workspace to manage appointments and active jobs, the platform may assist independent tradespeople and small repair services in building their local customer base and coordinating daily service engagements effectively.")

    # -------------------------------------------------------------
    # 3.4. SYSTEM MODELS
    # -------------------------------------------------------------
    add_h2("3.4. System Models")

    add_h3("3.4.1. Use Case Model")
    add_p("Figure 1 illustrates the Use Case model showing actors (Customer and Service Professional on the left, Administrator on the right) interacting with system boundary use cases with clean, straight association lines.")
    add_fig("figures/fig_use_case_model.png", "Figure 1. BiTadilat Use Case Diagram (Visual Paradigm Architecture)", width=Inches(5.5))

    add_h3("3.4.2. Object Model (Analysis Class Model)")
    add_p("Figure 2 illustrates the Analysis Object Model. It defines the core domain entities, their attributes, operations, and clean orthogonal associations without conflicting lines.")
    add_fig("figures/fig_class_model.png", "Figure 2. Analysis Object Model (Class Diagram)", width=Inches(5.5))

    add_h3("3.4.3. Dynamic Models")
    add_p("Figure 3 depicts the sequence of interactions between the Customer, Mobile App, Matching Engine, Service Professional, and Backend Database during request creation, matching, structured offer submission, and atomic offer acceptance.")
    add_fig("figures/fig_seq_offer_accept.png", "Figure 3. Sequence Diagram for Request Matching and Offer Acceptance", width=Inches(5.2))

    add_p("Figure 4 displays the State Machine model governing the lifecycle of a Service Request and its corresponding Job entity.")
    add_fig("figures/fig_state_lifecycle.png", "Figure 4. State Machine Diagram for Service Request and Job Lifecycle", width=Inches(4.8))

    add_h3("3.4.4. User Interface: Navigational Paths and Screen Mock-ups")
    add_p("The BiTadilat platform interface is structured across four primary touchpoints: Customer Mobile App, Service Professional Mobile App, Administrator Web Panel, and Promotional Website.")
    add_p("Deliverable D1.3 (BiTadilat_Navigable_Mockups.pdf) contains the full-fidelity clickable interactive screen mock-ups for all 22 system screens. To directly correlate the external screen prototype with this report, every screen mock-up in D1.3 corresponds directly to the text wireframe specifications and navigational path diagrams presented below.")

    add_p("Navigational Path Diagrams (Screens modeled as discrete interface states linked by user-triggered navigation actions; decision-diamond activity logic has been eliminated in favor of clean state-to-state screen transitions):", bold=True)
    add_fig("figures/fig_flow_customer.png", "Figure 5. Customer Mobile App — Navigational Path Diagram", width=Inches(5.5))
    add_fig("figures/fig_flow_pro.png", "Figure 6. Professional Mobile App — Navigational Path Diagram", width=Inches(4.8))
    add_fig("figures/fig_flow_admin.png", "Figure 7. Administrator Web Panel — Navigational Path Diagram", width=Inches(5.0))
    add_fig("figures/fig_flow_promo.png", "Figure 8. Promotional Website — Navigational Path Diagram", width=Inches(4.5))

    add_p("Traceability Matrix: Text Wireframes vs. Deliverable D1.3 Navigable PDF Mock-ups:", bold=True)
    xref_table = doc.add_table(rows=1, cols=4)
    xref_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    xref_hdr = ["Screen ID", "Wireframe Component", "Target User Role", "Deliverable D1.3 PDF Screen / Page"]
    for i, h in enumerate(xref_hdr):
        cell = xref_table.rows[0].cells[i]
        set_cell_background(cell, "1A365D")
        cell.paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER
        r = cell.paragraphs[0].add_run(h)
        r.bold = True
        r.font.name = 'Times New Roman'
        r.font.size = Pt(9)
        r.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

    xref_data = [
        ("SCR-01", "Authentication & Role Selection", "Customer / Pro / Admin", "Page 1 (Common Gateway)"),
        ("SCR-02", "Customer Request Creation Form", "Customer", "Page 2 (Request Entry)"),
        ("SCR-03", "Rule-Based Matching Results", "Customer", "Page 3 (Specialist Matches)"),
        ("SCR-04", "Structured Offer Comparison", "Customer", "Page 4 (Proposal Review)"),
        ("SCR-05", "Professional Profile View", "Customer / Pro", "Page 5 (Public Profile)"),
        ("SCR-06", "Appointment Scheduling", "Customer / Pro", "Page 6 (Visit Coordination)"),
        ("SCR-07", "In-App Chat & Active Job Workspace", "Customer / Pro", "Page 7 (Active Messaging)"),
        ("SCR-08", "Customer Job Tracking & Progress", "Customer", "Page 8 (Milestones 1-5)"),
        ("SCR-09", "Cancellation Confirmation Dialog", "Customer / Pro", "Page 9 (Pre-Work Dialog)"),
        ("SCR-10", "Completion Confirmation Dialog", "Customer", "Page 10 (Sign-Off Dialog)"),
        ("SCR-11", "Review & Rating Submission", "Customer", "Page 11 (Verified Feedback)"),
        ("SCR-12", "Customer Complaint Filing", "Customer", "Page 12 (Dispute Escalation)"),
        ("SCR-13", "Complaint Submitted Status", "Customer", "Page 13 (Case CMP-104)"),
        ("SCR-14", "Professional Matched Requests Feed", "Professional", "Page 14 (Lead Discovery)"),
        ("SCR-15", "Professional Structured Offer Builder", "Professional", "Page 15 (Proposal Form)"),
        ("SCR-16", "Professional Offer Submission Status", "Professional", "Page 16 (Sent Confirmation)"),
        ("SCR-17", "Professional Profile & Availability Edit", "Professional", "Page 17 (Account Settings)"),
        ("SCR-18", "Professional Job Execution & Milestones", "Professional", "Page 18 (Pro Milestones)"),
        ("SCR-19", "Admin Profile Review & Verification", "Administrator", "Page 19 (Credential Audit)"),
        ("SCR-20", "Admin Dispute & Complaint Center", "Administrator", "Page 20 (Dispute Mediation)"),
        ("SCR-21", "Admin User & Pro Account Directory", "Administrator", "Page 21 (Directory & Ban)"),
        ("SCR-22", "Promotional Showcase Website", "Public Visitors", "Page 22 (Public Web Portal)")
    ]

    for scr_id, w_comp, role_u, pdf_loc in xref_data:
        row = xref_table.add_row()
        vals = [scr_id, w_comp, role_u, pdf_loc]
        for j, v in enumerate(vals):
            cell = row.cells[j]
            set_cell_background(cell, "EBF8FF" if j % 2 == 0 else "FFFFFF")
            set_cell_margins(cell, top=80, bottom=80, left=100, right=100)
            cell.paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.LEFT
            r = cell.paragraphs[0].add_run(v)
            r.font.name = 'Times New Roman'
            r.font.size = Pt(8.5)
            if j == 0:
                r.bold = True
    add_p("", space_after=6)

    add_p("Screen Mock-ups & Text Wireframe Specifications (Directly Corresponding to Deliverable D1.3):", bold=True)

    # 1. Login
    scr_01 = """SCR-01: Authentication & Role Selection (Mobile Common)
+-------------------------------------------------------------+
|  BiTadilat                    Home Repair & Renovation      |
+-------------------------------------------------------------+
|  Welcome Back                                               |
|  Select Account Type:                                       |
|  [ (•) Customer Account ]     [ ( ) Professional Account ]  |
|                                                             |
|  Email or Phone Number:                                     |
|  [ ata@example.com                                        ] |
|  Password:                                                  |
|  [ ••••••••••••                                           ] |
|                                                             |
|  [                 LOG IN AS CUSTOMER                     ] |
|  [         Switch to Service Professional Mode            ] |
|  [          Access Administrator Web Portal               ] |
+-------------------------------------------------------------+"""
    add_code_box(scr_01)

    # 2. Request Form
    scr_02 = """SCR-02: Customer Request Creation Screen (C-02)
+-------------------------------------------------------------+
|  <- Back              New Service Request          [TR / EN] |
+-------------------------------------------------------------+
|  1. Category: [ Plumbing                                v ] |
|  2. Urgency:  (o) Urgent Fix         ( ) Planned Renovation |
|  3. District: [ Kadıköy - Moda                            v ] |
|  4. Scope:                                                  |
|  +-------------------------------------------------------+  |
|  | Pipe burst under bathroom sink. Water leaking rapidly.|  |
|  +-------------------------------------------------------+  |
|  5. Visual Photos: [Photo 1] [Photo 2] [Photo 3] [Photo 4] [Photo 5]      |
|                                                             |
|  [           FIND MATCHING SPECIALISTS (SUBMIT)           ] |
+-------------------------------------------------------------+"""
    add_code_box(scr_02)

    # 3. Matching
    scr_03 = """SCR-03: Rule-Based Matching Results Screen (C-03)
+-------------------------------------------------------------+
|  <- Back              Matching Specialists       [Kadıköy]  |
+-------------------------------------------------------------+
|  2 Eligible Specialists Found in Your Area                  |
|                                                             |
|  +-------------------------------------------------------+  |
|  | Mehmet Usta – Kadıköy Tesisat            [VERIFIED ✓] |  |
|  | ★ 4.9 (42 completed jobs)                                |  |
|  | Matching factors: Covers Kadıköy & Declared Available   |  |
|  | [ View Public Profile ]        [ Request Direct Quote ]  |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  +-------------------------------------------------------+  |
|  | Ahmet Usta – UstaSu Tesisat              [VERIFIED ✓] |  |
|  | ★ 4.7 (19 completed jobs)                                |  |
|  | Matching factors: Covers Kadıköy & Nearby                |  |
|  | [ View Public Profile ]        [ Request Direct Quote ]  |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+"""
    add_code_box(scr_03)

    # 4. Offers
    scr_04 = """SCR-04: Structured Offer Comparison Screen (C-04)
+-------------------------------------------------------------+
|  <- Back             Offers for Request #1042      [TR / EN] |
+-------------------------------------------------------------+
|  Plumbing Repair - Burst Sink Pipe (Kadıköy)                |
|                                                             |
|  +-------------------------------------------------------+  |
|  | OFFER A: Mehmet Usta                   ★ 4.9 (42 jobs)|  |
|  | Proposed Total Price:  ₺1,250                        |  |
|  |   • Labor Fee:         ₺850                           |  |
|  |   • Estimated Parts:   ₺400 (valve replacement)       |  |
|  | Earliest Arrival:      Today at 22:00                 |  |
|  | Scope Notes: Valve replacement and pressure test         |  |
|  | [  ACCEPT THIS OFFER  ]          [ Decline ]          |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  +-------------------------------------------------------+  |
|  | OFFER B: Ahmet Usta                    ★ 4.7 (19 jobs)|  |
|  | Proposed Total Price:  ₺1,100                        |  |
|  |   • Labor Fee:         ₺750  |  Parts: ₺350           |  |
|  | Earliest Arrival:      Tomorrow at 09:30              |  |
|  | [  ACCEPT THIS OFFER  ]          [ Decline ]          |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+"""
    add_code_box(scr_04)

    # 5. Pro Profile
    scr_05 = """SCR-05: Professional Profile View Screen (P-01)
+-------------------------------------------------------------+
|  <- Back                Artisan Profile            [TR / EN] |
+-------------------------------------------------------------+
|  Mehmet Demir (Mehmet Usta)                                 |
|  Plumbing & Gas Maintenance  •  ★ 4.9 Rating (42 jobs)       |
|                                                             |
|  Verified Profile Status:                                   |
|  [✓] Profile information reviewed by BiTadilat admin         |
|                                                             |
|  Service Coverage Areas:                                    |
|  • Istanbul: Kadıköy, Üsküdar, Ataşehir                     |
|                                                             |
|  Recent Customer Reviews:                                   |
|  • Ata H. (5.0 ★): "Fast arrival, replaced valve cleanly."  |
|  • Zeynep K. (5.0 ★): "Polite technician, good repair."     |
+-------------------------------------------------------------+"""
    add_code_box(scr_05)

    # 6. Appointment
    scr_06 = """SCR-06: Appointment Scheduling Screen (CP-01)
+-------------------------------------------------------------+
|  <- Back              Schedule Appointment         [TR / EN] |
+-------------------------------------------------------------+
|  Job #501: Plumbing Repair with Mehmet Usta                 |
|                                                             |
|  Agreed Visit Time:                                         |
|  [ Today, 14 October 2026 – 22:00                         v ]|
|                                                             |
|  Service Location:                                          |
|  Moda Cad. No: 14 D: 5, Caferağa, Kadıköy                   |
|                                                             |
|  [             CONFIRM APPOINTMENT SCHEDULE               ] |
|  (A confirmation dialog is shown before cancelling a job)   |
+-------------------------------------------------------------+"""
    add_code_box(scr_06)

    # 7. In-App Chat
    scr_07 = """SCR-07: In-App Chat & Active Job Workspace (CP-02)
+-------------------------------------------------------------+
|  <- Back          Job #501: Active Service         [Call SOS]|
+-------------------------------------------------------------+
|  Customer: Ata H.              Professional: Mehmet Usta    |
|  Status: IN PROGRESS - ARRIVAL SCHEDULED TODAY 22:00        |
|                                                             |
|  +-- Secure Messaging ------------------------------------+  |
|  | [21:42] Mehmet: On my way, arrived at Kadıköy square.  |  |
|  | [21:44] Ata: Noted, 3rd floor, ring bell marked 'Atay'.|  |
|  | [22:01] Mehmet: Arrived at the building entrance.       |  |
|  +--------------------------------------------------------+  |
|  [ Type a secure message...                     ] [ Send ]  |
|                                                             |
|  [ Track Job Progress ]             [ Report Issue/Cancel ] |
+-------------------------------------------------------------+"""
    add_code_box(scr_07)

    # 8. Customer Job Progress
    scr_08 = """SCR-08: Customer Job Tracking & Progress Screen (C-05)
+-------------------------------------------------------------+
|  <- Back               Job Progress #501           [TR / EN] |
+-------------------------------------------------------------+
|  Status: Professional Reported Work Finished                 |
|                                                             |
|  Milestone Tracking:                                        |
|  (✓) 1. Offer Accepted (14 Oct 21:30 - Agreed: 1.250 TL)     |
|  (✓) 2. Arrival Checked-In (14 Oct 22:05 - Moda, Kadıköy)    |
|  (✓) 3. Work In-Progress (Replacement brass valve fitted)   |
|  (✓) 4. Work Finished by Technician (Sign-off requested)    |
|  ( ) 5. Completed (Awaiting customer confirmation)          |
|                                                             |
|  Customer Permitted Actions:                                |
|  [         CONFIRM JOB COMPLETION & PROCEED TO RATING       ] |
|  [              OPEN CHAT WITH MEHMET USTA                  ] |
|  [             REPORT ISSUE / FILE COMPLAINT                ] |
|  (Direct cancellation allowed only before work starts)      |
+-------------------------------------------------------------+"""
    add_code_box(scr_08)

    # 9. Cancellation Confirmation
    scr_09 = """SCR-09: Cancellation Confirmation Dialog Screen (Common-01)
+-------------------------------------------------------------+
|  <- Back              Cancel Job Confirmation      [TR / EN] |
+-------------------------------------------------------------+
|  Are you sure you want to cancel Job #501?                  |
|  Per usability safeguards, jobs require explicit confirmation|
|  The other assigned party will be notified immediately.      |
|                                                             |
|  Reason for Cancellation:                                   |
|  (•) Scheduling conflict / Changed plans                     |
|  ( ) Problem resolved independently                         |
|  ( ) Specialist failed to show up / Unresponsive             |
|  ( ) Emergency / Unforeseen circumstances                    |
|                                                             |
|  Additional Notes: [ Optional context for records...       ] |
|                                                             |
|  [               CONFIRM JOB CANCELLATION                   ] |
|  [                 <- No, Keep Job Active                   ] |
+-------------------------------------------------------------+"""
    add_code_box(scr_09)

    # 10. Completion Confirmation
    scr_10 = """SCR-10: Completion Confirmation Dialog Screen (C-06)
+-------------------------------------------------------------+
|  <- Back              Confirm Job Completion       [TR / EN] |
+-------------------------------------------------------------+
|  Has the work been completed?                               |
|  Please inspect the repaired sink and leak before signing off|
|                                                             |
|  Job #501 Summary:                                          |
|  • Proposed Total Price: 1.250 TL (Labor: 850 TL + Materials: 400 TL) |
|  • Technician: Mehmet Usta (Kadıköy Tesisat)                 |
|  • Status: Work Finished by Technician at 22:40             |
|                                                             |
|  [      YES, CONFIRM COMPLETION & PROCEED TO RATING       ] |
|  [             REPORT PROBLEM / FILE COMPLAINT              ] |
+-------------------------------------------------------------+"""
    add_code_box(scr_10)

    # 11. Review & Rating
    scr_11 = """SCR-11: Review & Rating Submission Screen (C-07)
+-------------------------------------------------------------+
|  <- Back              Rate & Review Service        [TR / EN] |
+-------------------------------------------------------------+
|  Rate Mehmet Usta:                                          |
|  [ ★ ★ ★ ★ ★ ]  (5.0 / 5.0)                                 |
|                                                             |
|  Feedback Comments:                                         |
|  +-------------------------------------------------------+  |
|  | Arrived right on time for emergency pipe fix. Replaced|  |
|  | valve cleanly and tested pressure. Very satisfied!    |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  [                 SUBMIT VERIFIED REVIEW                 ] |
+-------------------------------------------------------------+"""
    add_code_box(scr_11)

    # 12. Customer Complaints
    scr_12 = """SCR-12: Customer Dispute & Complaint Filing Screen (C-08)
+-------------------------------------------------------------+
|  <- Back              File Customer Complaint      [TR / EN] |
+-------------------------------------------------------------+
|  Alternative Scenario: Reporting Issue with Job #504:        |
|  Reason: [ Technician failed to arrive at appointment   v ] |
|                                                             |
|  Detailed Explanation:                                      |
|  +-------------------------------------------------------+  |
|  | Scheduled arrival was 14:00. Technician has not       |  |
|  | responded to messages for 2 hours.                    |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  [              SUBMIT TO SUPPORT TEAM                    ] |
+-------------------------------------------------------------+"""
    add_code_box(scr_12)

    # 13. Customer Complaint Confirmation
    scr_13 = """SCR-13: Customer Complaint Status & Confirmation Screen (C-09)
+-------------------------------------------------------------+
|  <- Back              Dispute Filed Successfully   [TR / EN] |
+-------------------------------------------------------------+
|  Case #CMP-104 Created (Job #504 Alternative Scenario)      |
|  Your dispute report regarding Job #504 has been logged.     |
|  Our administrator moderation team will review case records. |
|                                                             |
|  Next Steps:                                                |
|  1. Administrator inspects arrival time and chat trail.     |
|  2. Professional is prompted to provide status explanation. |
|  3. You will receive an in-app resolution update.           |
|                                                             |
|  [               <- BACK TO JOB TRACKING                    ] |
|  [                RETURN TO MAIN MENU                       ] |
+-------------------------------------------------------------+"""
    add_code_box(scr_13)

    # 14. Pro Feed
    scr_14 = """SCR-14: Professional Matched Requests Feed (P-01)
+-------------------------------------------------------------+
|  BiTadilat Pro         Matched Requests Feed        [Online] |
+-------------------------------------------------------------+
|  Active Filters: [Plumbing] [Kadıköy, Üsküdar]             |
|                                                             |
|  +-------------------------------------------------------+  |
|  | [URGENT] Pipe burst under bathroom sink                  |  |
|  | Location: Kadıköy, Moda (~1.2 km away)                   |  |
|  | Photos: 2 Attached [Thumb 1] [Thumb 2]                 |  |
|  | [            PREPARE STRUCTURED OFFER                 ] |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  [            MANAGE PROFILE & AVAILABILITY               ] |
|  [            VIEW ACTIVE JOB EXECUTION (#501)            ] |
+-------------------------------------------------------------+"""
    add_code_box(scr_14)

    # 15. Pro Offer Builder
    scr_15 = """SCR-15: Professional Structured Offer Builder (P-02)
+-------------------------------------------------------------+
|  <- Back              Build Structured Offer       [TR / EN] |
+-------------------------------------------------------------+
|  Target Request: #501 (Kadıköy Plumbing Repair)              |
|                                                             |
|  1. Labor Fee (TL):        [ 850 TL                       ] |
|  2. Materials Fee (TL):    [ 400 TL (Brass replacement)   ] |
|  3. Committed Arrival:     [ Today, 14 October at 22:00   ] |
|  4. Scope Clarifications:  [ Replaces valve and runs test ] |
|                                                             |
|  [        SEND STRUCTURED OFFER (PROPOSED TOTAL: 1.250 TL)         ] |
+-------------------------------------------------------------+"""
    add_code_box(scr_15)

    # 16. Pro Offer Success
    scr_16 = """SCR-16: Professional Offer Submission Status Screen (P-03)
+-------------------------------------------------------------+
|  BiTadilat Pro         Offer Sent Successfully     [Online] |
+-------------------------------------------------------------+
|  Offer #OFF-882 Delivered to Customer                       |
|  Your 1.250 TL proposal has been sent to Ata H. (Kadıköy).  |
|  Offer valid until proposed arrival window. Rechecked on acceptance.                 |
|                                                             |
|  Offer Breakdown:                                           |
|  • Labor: 850 TL  |  Materials: 400 TL                      |
|  • Status: Awaiting Customer Acceptance                     |
|                                                             |
|  [         RETURN TO MATCHED REQUESTS FEED                ] |
|  [           MANAGE PROFILE & AVAILABILITY                 ] |
+-------------------------------------------------------------+"""
    add_code_box(scr_16)

    # 17. Pro Profile & Availability Management
    scr_17 = """SCR-17: Professional Profile & Availability Management (P-04)
+-------------------------------------------------------------+
|  <- Back              Profile & Availability       [TR / EN] |
+-------------------------------------------------------------+
|  Working Status:       [ (•) Active / Ready ]  [ ( ) Break ]|
|  1. Trade Skills:      [x] Plumbing  [x] Drains  [ ] Elect. |
|  2. Service Districts: [ Kadıköy, Üsküdar, Ataşehir       ] |
|  3. Working Hours:     [ Mon-Sat 08:30 - 23:00 (Emergency) ]|
|  4. Experience / Bio:  [ 12 years residential plumbing... ] |
|                                                             |
|  [        SAVE PROFILE & UPDATE AVAILABILITY              ] |
+-------------------------------------------------------------+"""
    add_code_box(scr_17)

    # 18. Pro Job Execution
    scr_18 = """SCR-18: Professional Job Execution & Milestones (P-05)
+-------------------------------------------------------------+
|  <- Back               Job Execution #501          [TR / EN] |
+-------------------------------------------------------------+
|  Current Status: Work In-Progress on site                    |
|                                                             |
|  Milestone Progress:                                        |
|  (✓) 1. Offer Accepted (Customer accepted proposed total)    |
|  (✓) 2. Arrival Checked-In (22:05 at Moda location)        |
|  (✓) 3. Repair in Progress (Brass valve replaced)          |
|  ( ) 4. Mark Work Finished (Submit sign-off request)        |
|  ( ) 5. Completed (Awaiting customer sign-off)              |
|                                                             |
|  Professional Permitted Actions:                            |
|  [        MARK WORK FINISHED (NOTIFY CUSTOMER)            ] |
|  [            CHAT WITH CUSTOMER (ATA H.)                 ] |
|  [             REPORT ISSUE / DISPUTE WORK                ] |
+-------------------------------------------------------------+"""
    add_code_box(scr_18)

    # 19. Admin Profile Review (No MERNIS, Sample info, Approve/Reject)
    scr_19 = """SCR-19: Admin Profile Review Screen (A-01)
+------------------------------------------------------------------------------------------------+
|  BiTadilat Admin Panel  |  Dashboard  |  Profile Review Queue (3)  |  Disputes (1)  |  [Logout]|
+------------------------------------------------------------------------------------------------+
|  PROFESSIONAL PROFILE REVIEW                                                                   |
|  Applicant Name:             Mehmet Demir                                                      |
|  Trade Category:             Plumbing & Heating Maintenance                                    |
|  Declared Service Areas:     Istanbul (Kadıköy, Üsküdar, Ataşehir)                             |
|  Experience Summary:         12 years residential plumbing experience                          |
|  Uploaded Document Sample:   plumbing_trade_certificate_sample.jpg                             |
|                                                                                                |
|  [ Sample Document Preview: Administrator visually inspects submitted qualification sample ]    |
|                                                                                                |
|  [        APPROVE PROFILE        ]             [        REJECT APPLICATION        ]            |
+------------------------------------------------------------------------------------------------+"""
    add_code_box(scr_19)

    # 20. Admin Disputes
    scr_20 = """SCR-20: Admin Dispute & Complaint Center (A-02)
+------------------------------------------------------------------------------------------------+
|  ACTIVE DISPUTE CASES (ALTERNATIVE SCENARIO)                                                   |
|  Case #CMP-104 | Job #504 | Complainant: Zeynep K. vs Professional: Ali Kaya                  |
|  Issue: Customer reports technician did not arrive at scheduled appointment.                  |
|  Audit Trail: Scheduled for 14:00. Last message timestamp recorded.                           |
|  [  CANCEL DISPUTED JOB  ]          [  ISSUE WARNING  ]          [  DISMISS DISPUTE  ]         |
+------------------------------------------------------------------------------------------------+"""
    add_code_box(scr_20)

    # 21. Admin Account Management
    scr_21 = """SCR-21: Admin User & Professional Account Management (A-03)
+------------------------------------------------------------------------------------------------+
|  BiTadilat Admin Panel  |  Users (1,420)  |  Active Pros (310)  |  Suspended (7)   |  [Logout]|
+------------------------------------------------------------------------------------------------+
|  USER & PROFESSIONAL ACCOUNT DIRECTORY                                                         |
|  Search Users: [ Mehmet Demir                     ]   Filter: [All Roles v]   [Status v]       |
|                                                                                                |
|  User ID | Name & Contact             | Role         | District | Status    | Action           |
|  USR-101 | Mehmet Demir (+90 532 ***) | Professional | Kadıköy  | Active    | [View] [Suspend] |
|  USR-102 | Ata Herdem (+90 555 ***)   | Customer     | Kadıköy  | Active    | [View] [Suspend] |
|  USR-103 | Ali Kaya (+90 544 ***)     | Professional | Üsküdar  | Suspended | [Reactivate]     |
|                                                                                                |
|  [           REFRESH DIRECTORY             ]           [         VIEW ACCOUNT DETAILS         ]|
+------------------------------------------------------------------------------------------------+"""
    add_code_box(scr_21)

    # 22. Promotional Website
    scr_22 = """SCR-22: Promotional Showcase Website (W-01)
+------------------------------------------------------------------------------------------------+
|  BiTadilat LOGO          Features    How It Works    For Technicians    FAQ        [TR | EN]   |
+------------------------------------------------------------------------------------------------+
|  RELIABLE HOME REPAIRS ACROSS ISTANBUL.                                                        |
|  Match with local repair specialists. Structured offers, transparent trust.                    |
|  [ Download on App Store (iOS) ]          [ Get it on Google Play (Android) ]                  |
|                                                                                                |
|  CORE PILLARS (WRAP-ALIGNED):                                                                  |
|  [ Urgent or Planned Requests ]    [ Structured Quotes ]    [ Empowering Local Trades (SDG 8) ]|
|                                                                                                |
|  HOW IT WORKS:                                                                                 |
|  1. Create Request               2. Compare Quotes          3. Confirm & Review                |
|                                                                                                |
|  (C) 2026 BiTadilat Team • Işık University Software Engineering                                |
+------------------------------------------------------------------------------------------------+"""
    add_code_box(scr_22)

    # -------------------------------------------------------------
    # 4. OTHER ANALYSIS ELEMENTS
    # -------------------------------------------------------------
    add_h1("4. Other Analysis Elements")

    add_h2("4.1. Risks and Alternatives")
    risk_table = doc.add_table(rows=5, cols=4)
    risk_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    risk_headers = ["Risk", "Likelihood", "Effect on the Project", "B Plan Summary"]
    for i, h in enumerate(risk_headers):
        cell = risk_table.cell(0, i)
        set_cell_background(cell, "0F2A4A")
        set_cell_margins(cell, 80, 80, 100, 100)
        p = cell.paragraphs[0]
        r = p.add_run(h)
        r.bold = True
        r.font.size = Pt(10)
        r.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

    risk_data = [
        ("Limited access to professionals and customers across Istanbul for evaluation", "Medium", "Testing may not represent the variety of service areas and customer needs across the city.", "Keep user evaluation focused on a reasonable sample and use simulated personas and scenarios for various Istanbul districts."),
        ("Language differences among potential users", "Medium", "Users who cannot speak the interface language will find it difficult to explain requests or compare offers.", "Offer Turkish and English interface versions. Employ clear icons and standardized input fields. Test with users fluent in respective languages."),
        ("Difficulties integrating mobile application and backend", "Medium", "Incompatible API responses or data formats can cause workflow delays and reduce testing time.", "Define data formats first; incorporate a minimum request-to-completion workflow before adding secondary features. Use mock API stubs."),
        ("Insufficient professional availability in some service areas or categories", "Medium", "Requests may receive few or no offers, particularly for urgent services, limiting matching usefulness.", "Ensure only qualified professionals are matched. Inform customers when no pros qualify and offer options to leave request open or adjust appointment time.")
    ]
    for row_idx, row in enumerate(risk_data, start=1):
        for col_idx, text in enumerate(row):
            cell = risk_table.cell(row_idx, col_idx)
            set_cell_margins(cell, 60, 60, 80, 80)
            if row_idx % 2 == 1:
                set_cell_background(cell, "F7F9FB")
            p = cell.paragraphs[0]
            r = p.add_run(text)
            r.font.size = Pt(9.5)
            if col_idx == 0:
                r.bold = True

    add_p("", space_after=6)

    add_h2("4.2. Project Plan and Work Packages")
    add_p("Figure 9 illustrates the Gantt chart for the BiTadilat project spanning the Fall 2026 semester through final thesis submission in January 2027.")
    add_fig("figures/fig_gantt.png", "Figure 9. BiTadilat Project Gantt Chart", width=Inches(5.5))

    add_p("Table 3 lists the six primary work packages and team allocations.")
    wp_table = doc.add_table(rows=7, cols=3)
    wp_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    wp_headers = ["WP #", "Work Package Title", "Members Involved"]
    for i, h in enumerate(wp_headers):
        cell = wp_table.cell(0, i)
        set_cell_background(cell, "0F2A4A")
        set_cell_margins(cell, 80, 80, 100, 100)
        p = cell.paragraphs[0]
        r = p.add_run(h)
        r.bold = True
        r.font.size = Pt(10)
        r.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

    wp_list = [
        ("WP1", "Requirements Analysis and RAD Preparation", "All three members; led by Technical Product Management member (Alaa Eddin)"),
        ("WP2", "System Design and SDD Preparation", "All three members; led by Backend member (Hakan)"),
        ("WP3", "Backend and Database Development", "Backend member (Hakan), with support from other members"),
        ("WP4", "Mobile and Supporting Web Interfaces", "Frontend/mobile member (Ata), with backend support (Hakan)"),
        ("WP5", "Integration, Testing, and Evaluation", "All three members; led by Technical Product Management member (Alaa Eddin)"),
        ("WP6", "Final Documentation and Presentation", "All three members; led by Technical Product Management member (Alaa Eddin)")
    ]
    for row_idx, row in enumerate(wp_list, start=1):
        for col_idx, text in enumerate(row):
            cell = wp_table.cell(row_idx, col_idx)
            set_cell_margins(cell, 60, 60, 80, 80)
            if row_idx % 2 == 1:
                set_cell_background(cell, "F7F9FB")
            p = cell.paragraphs[0]
            r = p.add_run(text)
            r.font.size = Pt(9.5)
            if col_idx == 0:
                r.bold = True

    add_p("", space_after=6)

    # Detailed WP Tables (Tables 4 - 9)
    wps_detailed = [
        ("Table 4. Work Package 1", "WP 1: Requirements Analysis and RAD Preparation", "28 September 2026", "16 October 2026", "Alaa Eddin Almallah", "Ata Herdem Atay, Hakan Kuvan",
         "Describe BiTadilat scope, stakeholders, goals, and criteria for success. Describe functional and non-functional requirements including security/privacy, reliability, and usability. Develop initial models and screen layouts. Conduct consistent RAD analysis and revise based on supervisor's comments.",
         "Task 1.1 Scope, Objectives, and Requirements: Identify included/excluded features, user types, and success parameters. Establish requirements and describe SDG contribution.\nTask 1.2 Use Cases, Rules, Initial Models, and Mock-ups: Identify key scenarios (match, acceptance, cancellation, completion, review). Create UML interaction diagrams and screen mockups.\nTask 1.3 RAD Review and Final Corrections: Merge parts, ensure consistency, integrate supervisor feedback, and submit files.",
         "D1.1: Completed RAD in PDF format.\nD1.2: Visual Paradigm project file containing system models.\nD1.3: Navigable PDF of screen mock-ups and navigational paths (BiTadilat_Navigable_Mockups.pdf)."),

        ("Table 5. Work Package 2", "WP 2: System Design and SDD Preparation", "17 October 2026", "30 October 2026", "Hakan Kuvan", "Alaa Eddin Almallah, Ata Herdem Atay",
         "Convert requirements to an implementable system design. Determine architecture, data structures, and interactions between mobile app and backend. Outline matching rules, service lifecycle, and interface interactions.",
         "Task 2.1 Architecture, Database, and API Design: Identify system elements, database relations, and API inputs/outputs. Identify security constraints for confidential information.\nTask 2.2 Matching, Lifecycle, Interface Design, and SDD Preparation: Document eligibility and ranking criteria, status changes permitted on jobs, and interface designs. Complete SDD document.",
         "D2.1: Completed SDD document prepared for submission.\nD2.2: Architecture and database design diagrams.\nD2.3: API specifications, matching rules, and updated interface designs."),

        ("Table 6. Work Package 3", "WP 3: Backend and Database Development", "19 October 2026", "04 December 2026", "Hakan Kuvan", "Alaa Eddin Almallah, Ata Herdem Atay",
         "Build backend services and database for selected features. Create matching and rules related to requests, offers, appointments, and jobs. Restrict information access based on role and service participation. Provide APIs for mobile app and admin panel.",
         "Task 3.1 Accounts, Permissions, and Professional Profiles: Incorporate registration, login, authorization, and profile management. Store service types, regions, and availability.\nTask 3.2 Requests, Matching, and Structured Offers: Process requests, photos, eligibility, and ranking rules. Support structured offers with single-acceptance enforcement.\nTask 3.3 Appointments, Cancellations, Messaging, and Reviews: Put in place appointment scheduling, status transitions, cancellation, completion, in-app messaging, and post-job reviews.\nTask 3.4 Administrator Functions: Develop systems for managing accounts, evaluating pro profiles, and resolving complaints.",
         "D3.1: Working backend APIs and relational database.\nD3.2: Implemented matching, access-control, and lifecycle rules.\nD3.3: Database setup instructions and synthetic test data."),

        ("Table 7. Work Package 4", "WP 4: Mobile and Supporting Web Interfaces", "19 October 2026", "04 December 2026", "Ata Herdem Atay", "Hakan Kuvan",
         "Design customer and professional mobile interfaces following agreed mock-ups. Connect them with backend to facilitate service flows. Offer bilingual options (Turkish/English). Design promotional site and administrator panel.",
         "Task 4.1 Customer and Professional Mobile Screens: Create screens for accounts, profiles, requests, matching, offers, appointments, messages, job status, and reviews.\nTask 4.2 Turkish/English Interfaces and API Connections: Provide localized texts according to language choice. Link screens to APIs, managing loading and error states.\nTask 4.3 Promotional Website and Administrator Panel: Create responsive promotional website with app download links. Build admin dashboard screens for accounts, verification, and complaints.",
         "D4.1: Customer and professional mobile interfaces connected to backend.\nD4.2: Turkish and English interface texts and language toggle.\nD4.3: Promotional website and administrator panel web applications."),

        ("Table 8. Work Package 5", "WP 5: Integration, Testing, and Evaluation", "02 November 2026", "25 December 2026", "Alaa Eddin Almallah", "Ata Herdem Atay, Hakan Kuvan",
         "Combine elements and confirm identified requirements. Test workflow, matching criteria, and access control. Conduct usability testing with representative tasks and participant feedback. Fix defects and document outcomes.",
         "Task 5.1 Basic Request Integration: Connect request form with backend. Validate request creation, storage, and retrieval.\nTask 5.2 Full Service Workflow Integration: Implement matching, offers, scheduling, messaging, completion, and review functionalities across interfaces.\nTask 5.3 Functional, Access-Control, and Matching Tests: Perform acceptance and integration tests including unauthorized access, concurrent offer acceptance, and no-match scenarios.\nTask 5.4 Usability Evaluation and Improvements: Conduct usability testing on test participants. Document findings, fix defects, and re-test.",
         "D5.1: Integrated prototype demonstrating main service workflows.\nD5.2: Test cases, execution results, and defect logs.\nD5.3: Usability evaluation findings and documented improvements."),

        ("Table 9. Work Package 6", "WP 6: Final Documentation and Presentation", "19 October 2026", "08 January 2027", "Alaa Eddin Almallah", "Ata Herdem Atay, Hakan Kuvan",
         "Maintain ongoing documentation. Complete final thesis with requirements, design, implementation, and evaluation sections. Package source code and installation steps. Prepare poster, demonstration, and presentation slides.",
         "Task 6.1 Ongoing Documentation and Test Records: Revise descriptions, diagrams, and implementation records. Collate test results.\nTask 6.2 Final Thesis and Source-Code Submission: Organize thesis findings. Finalize code package for submission on 02 January 2027.\nTask 6.3 Poster and Presentation Preparation: Prepare poster and presentation-file submission on 8 January 2027. Jury presentation dates remain unconfirmed.",
         "D6.1: Final thesis with evaluation results.\nD6.2: Source-code package with setup instructions.\nD6.3: Poster, presentation slides, and demonstration materials.")
    ]

    for tbl_title, wp_title, sdate, edate, lead, mems, obj, tasks, delivs in wps_detailed:
        add_p(tbl_title, bold=True, space_before=6, space_after=2)
        t = doc.add_table(rows=6, cols=2)
        t.alignment = WD_TABLE_ALIGNMENT.CENTER
        
        c0 = t.cell(0, 0)
        c0.merge(t.cell(0, 1))
        set_cell_background(c0, "1A365D")
        p = c0.paragraphs[0]
        p.paragraph_format.space_after = Pt(2)
        r = p.add_run(f"{wp_title}\nStart: {sdate}  |  End: {edate}")
        r.bold = True
        r.font.size = Pt(10)
        r.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

        c10 = t.cell(1, 0)
        c11 = t.cell(1, 1)
        set_cell_background(c10, "F0F4F8")
        set_cell_background(c11, "F0F4F8")
        p0 = c10.paragraphs[0]
        p0.paragraph_format.space_after = Pt(2)
        r0 = p0.add_run(f"Leader: {lead}")
        r0.bold = True
        r0.font.size = Pt(9.5)
        p1 = c11.paragraphs[0]
        p1.paragraph_format.space_after = Pt(2)
        r1 = p1.add_run(f"Members: {mems}")
        r1.font.size = Pt(9.5)

        c2 = t.cell(2, 0)
        c2.merge(t.cell(2, 1))
        p = c2.paragraphs[0]
        p.paragraph_format.space_after = Pt(2)
        r = p.add_run(f"Objectives: {obj}")
        r.font.size = Pt(9.5)

        c3 = t.cell(3, 0)
        c3.merge(t.cell(3, 1))
        p = c3.paragraphs[0]
        p.paragraph_format.space_after = Pt(2)
        r = p.add_run(f"Tasks:\n{tasks}")
        r.font.size = Pt(9.5)

        c4 = t.cell(4, 0)
        c4.merge(t.cell(4, 1))
        set_cell_background(c4, "F7F9FB")
        p = c4.paragraphs[0]
        p.paragraph_format.space_after = Pt(2)
        r = p.add_run(f"Deliverables:\n{delivs}")
        r.bold = True
        r.font.size = Pt(9.5)

        for row in t.rows:
            for cell in row.cells:
                set_cell_margins(cell, top=60, bottom=60, left=80, right=80)

        add_p("", space_after=6)

    # -------------------------------------------------------------
    # 5. GLOSSARY (Realistic, no over-promises)
    # -------------------------------------------------------------
    add_h1("5. Glossary")
    add_p("This section collates and defines domain-specific terminology, operational concepts, and technical acronyms used throughout the Requirements Analysis Document in alphabetical order, reflecting agreed prototype capabilities.")

    glossary_items = [
        ("Administrator", "An authorized user responsible for reviewing service professional profile submissions, user accounts, and customer complaints via the web panel."),
        ("Appointment", "A mutually scheduled date and time agreed upon between customer and professional for site inspection or repair work."),
        ("BiTadilat", "The mobile and web software platform concept for matching customers with local home repair and renovation specialists in Istanbul."),
        ("Completion Confirmation", "The mutual status update in the application by customer and professional acknowledging that physical repair work has concluded."),
        ("Customer", "A registered user seeking home repair or renovation services who creates requests, evaluates offers, and reviews completed work."),
        ("Eligible Professional", "A registered professional whose declared category, operational district, and schedule availability match an open request."),
        ("Job", "The service engagement initiated within the application after a customer accepts one professional's offer."),
        ("Job Status", "The current execution state of a job: AGREED, SCHEDULED, IN_PROGRESS, WORK_FINISHED, COMPLETED or CANCELLED. Request assignment and complaint status are tracked separately."),
        ("Navigational Path", "The sequence of screens and transitions traversed by a user to achieve a goal within the application."),
        ("Non-Functional Requirement (NFR)", "A requirement describing system quality or constraint, such as usability, reliability, or privacy."),
        ("Planned Request", "A service request created for repair or renovation work scheduled for a future appointment date."),
        ("Promotional Website", "An informational website providing an overview of BiTadilat features and application download links."),
        ("Review & Rating", "Feedback consisting of a star rating (1 to 5) and written comments submitted by a customer after job completion."),
        ("Role-Based Access Control (RBAC)", "Restrictions governing available information and actions based on user role (Customer, Professional, Administrator) and job participation."),
        ("Rule-Based Matching", "A deterministic approach selecting eligible professionals using predefined criteria (category, district, availability) without machine learning."),
        ("Screen Mock-up", "A visual layout illustrating user interface components, information placement, and actionable controls."),
        ("Service Area", "Municipal districts in Istanbul where a professional declares availability to accept and perform services."),
        ("Service Category", "Trade classification associated with a request or professional profile (e.g., Plumbing, Electrical, Painting)."),
        ("Service Professional", "A skilled repair or renovation specialist registered on BiTadilat to view relevant requests and submit offers."),
        ("Service Request", "A customer description of required repair work, tracked in OPEN, ASSIGNED, or CANCELLED state."),
        ("Structured Offer", "A standardized bid submitted by a professional itemizing labor cost, estimated materials cost, arrival time, and notes."),
        ("Sustainable Development Goals (SDGs)", "The 17 global goals established by the United Nations in 2015 for sustainable development."),
        ("Trust Indicators", "Information shown to customers to assist in evaluating professionals, including profile review status, ratings, and count of completed jobs."),
        ("Urgent Request", "A service request flagged by the customer as requiring urgent attention, without guaranteeing immediate response times or rapid dispatch.")
    ]

    for term, definition in glossary_items:
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(3)
        p.paragraph_format.space_after = Pt(3)
        p.paragraph_format.left_indent = Inches(0.2)
        r_term = p.add_run(f"• {term}: ")
        r_term.bold = True
        r_def = p.add_run(definition)

    # -------------------------------------------------------------
    # 6. REFERENCES
    # -------------------------------------------------------------
    add_h1("6. References")
    add_p("The following list of academic literature, technical standards, and institutional frameworks was utilized during the requirements analysis and modeling of the BiTadilat platform:")

    refs = [
        "1. Bruegge, B., & Dutoit, A. H. (2010). Object-Oriented Software Engineering Using UML, Patterns, and Java (3rd ed.). Prentice Hall. ISBN: 978-0136061250.",
        "2. International Organization for Standardization. (2018). Ergonomics of human-system interaction — Part 11: Usability: Definitions and concepts (ISO Standard No. 9241-11:2018). https://www.iso.org/standard/63500.html",
        "3. Nielsen, J. (1994). Usability Engineering. Morgan Kaufmann Publishers Inc. ISBN: 978-0125184069.",
        "4. World Wide Web Consortium (W3C). (2018). Web Content Accessibility Guidelines (WCAG) 2.1. W3C Recommendation. https://www.w3.org/TR/WCAG21/",
        "5. Google LLC. (2023). Material Design 3: Guidelines for Responsive Layouts and Mobile Ergonomics. Material.io. https://m3.material.io/",
        "6. Apple Inc. (2024). Human Interface Guidelines: Designing for iOS and iPadOS. Apple Developer Documentation. https://developer.apple.com/design/human-interface-guidelines/",
        "7. United Nations, Department of Economic and Social Affairs. (2015). Transforming our world: The 2030 Agenda for Sustainable Development (A/RES/70/1). United Nations. https://sdgs.un.org/goals",
        "8. United Nations, Division for Sustainable Development Goals. (2023). SDG 8: Promote sustained, inclusive and sustainable economic growth, full and productive employment and decent work for all. UN DESA. https://sdgs.un.org/goals/goal8",
        "9. Sommerville, I. (2015). Software Engineering (10th ed.). Pearson. ISBN: 978-0133943030.",
        "10. Pressman, R. S., & Maxim, B. R. (2020). Software Engineering: A Practitioner's Approach (9th ed.). McGraw-Hill Education. ISBN: 978-1259872976.",
        "11. Official Gazette of the Republic of Turkey. (2016). Law on the Protection of Personal Data (KVKK No. 6698). https://www.kvkk.gov.tr/"
    ]

    for ref in refs:
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(3)
        p.paragraph_format.space_after = Pt(3)
        p.paragraph_format.left_indent = Inches(0.25)
        p.add_run(ref)

    output_filename = "BiTadilat_Requirements_Analysis_Document.docx"
    doc.save(output_filename)
    print(f"Successfully generated updated {output_filename} ({os.path.getsize(output_filename)} bytes)")

if __name__ == "__main__":
    create_document()
