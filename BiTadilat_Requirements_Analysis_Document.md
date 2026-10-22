# FEYZİYE SCHOOLS FOUNDATION IŞIK UNIVERSITY
## FACULTY OF ENGINEERING AND NATURAL SCIENCES
### DEPARTMENT OF SOFTWARE ENGINEERING
### COMP/SOFT4902/4912 Graduation Design Project (Fall 2026)

---

# REQUIREMENTS ANALYSIS DOCUMENT (RAD)

**Project Title:**  
**BiTadilat: A Location-Based Mobile Platform for Home Repair and Renovation Service Matching and Management**

**Project Team Members:**
* **Alaa Eddin Almallah** (Student ID: 21soft1058) – Technical Product Management Lead (WP1, WP5, WP6)
* **Ata Herdem Atay** (Student ID: 22soft1004) – Frontend & Mobile Interfaces Lead (WP4)
* **Hakan Kuvan** (Student ID: 21soft1018) – Backend & Database Architecture Lead (WP2, WP3)

**Academic Supervisor:** Department of Software Engineering Faculty  
**Date:** Fall Semester, 2026  
**Document Version:** 1.1 (Final Revised Draft)

---

## Table of Contents
1. [1. Introduction](#1-introduction)
   - [1.1 Purpose of the System](#11-purpose-of-the-system)
   - [1.2 Scope of the System](#12-scope-of-the-system)
   - [1.3 Objectives and Success Criteria of the Project](#13-objectives-and-success-criteria-of-the-project)
   - [1.4 Definitions, Acronyms, and Abbreviations](#14-definitions-acronyms-and-abbreviations)
   - [1.5 Document Overview](#15-document-overview)
2. [2. Current System](#2-current-system)
3. [3. Proposed System](#3-proposed-system)
   - [3.1 Overview](#31-overview)
   - [3.2 Functional Requirements](#32-functional-requirements)
     - [3.2.1 Use Cases](#321-use-cases)
     - [3.2.2 Scenarios](#322-scenarios)
   - [3.3 Nonfunctional Requirements](#33-nonfunctional-requirements)
     - [3.3.1 Usability](#331-usability)
     - [3.3.2 Reliability](#332-reliability)
     - [3.3.3 Performance](#333-performance)
     - [3.3.4 Supportability & Implementation](#334-supportability--implementation)
     - [3.3.5 External Interfaces & Packaging](#335-external-interfaces--packaging)
     - [3.3.6 Legal and Privacy Constraints](#336-legal-and-privacy-constraints)
     - [3.3.7 Sustainable Development Goals (SDG) Alignment](#337-sustainable-development-goals-sdg-alignment)
   - [3.4 System Models](#34-system-models)
     - [3.4.1 Use Case Model](#341-use-case-model)
     - [3.4.2 Object Model (Analysis Class Model)](#342-object-model-analysis-class-model)
     - [3.4.3 Dynamic Models](#343-dynamic-models)
     - [3.4.4 User Interface: Navigational Paths, Clickable PDF (D1.3), and Screen Mock-ups](#344-user-interface-navigational-paths-clickable-pdf-d13-and-screen-mock-ups)
4. [4. Other Analysis Elements](#4-other-analysis-elements)
   - [4.1 Risks and Alternative Solutions](#41-risks-and-alternative-solutions)
   - [4.2 Project Plan and Work Packages](#42-project-plan-and-work-packages)
5. [5. Glossary](#5-glossary)
6. [6. References](#6-references)

---

# 1. Introduction

BiTadilat represents a platform concept for home repairs and renovations in Istanbul. The idea takes into account the challenges that users face when searching for appropriate specialists, comparing their offers, and scheduling appointments. The system also aims to help professionals organize service requests, offers, and appointments. Considering the project concept which has been accepted, the platform will include a mobile application, promotional website, and administrative panel accessible via the web browser. This chapter explains the purpose and scope of the system, the objectives and success criteria of the project, and the glossary and document overview.

### 1.1 Purpose of the System
The goal of BiTadilat is to assist customers in Istanbul to identify a fitting contractor for their home repair and renovation requirements using a mobile application. The goal is to facilitate the entire process by providing customers with the opportunity to specify their requirements, compare structured offers, get in touch with a chosen professional, and monitor their job.

Furthermore, it will enable professionals to identify fitting service requests, offers, and appointments. The promotional website will introduce BiTadilat, while the administrator panel will facilitate the process of platform management. BiTadilat aims to support United Nations Sustainable Development Goal 8, Decent Work and Economic Growth, by helping local professionals reach potential customers and organize their work.

### 1.2 Scope of the System
BiTadilat will be created as a mobile application prototype for providing home repair and renovation services in Istanbul. The mobile application will provide separate interfaces for customers and service professionals. In addition, there will be an administrating system accessible from a web platform and a promotional website for introducing the application to customers.

Customers will be capable of registering an account, sending service requests with description and photo upload by choosing the service category and location of the work, classifying them as urgent or planned, and managing their status within the application. Moreover, they will be able to see and compare offers from multiple professionals, select a candidate, communicate in the application, schedule appointments, and manage the course of the job.

Professionals will be able to manage their profiles, service categories, service areas, and stated availability. They will view relevant service requests and submit structured offers. The matching system will provide a list of professionals who match the request based on predefined criteria, displaying matching factors and trust indicators.

**Explicit Scope Exclusions (Out of Scope):**
1. Online payment transactions or escrow holding.
2. Real-time live GPS tracking of professionals on a map.
3. Machine learning / AI-driven automatic problem diagnosis or predictive matching.
4. Services outside the province of Istanbul.
5. Automated translation of user messages.
6. Guarantees regarding professional availability or the quality of work performed.

### 1.3 Objectives and Success Criteria of the Project
1. **Allow customers to create service requests:** Customers choose categories, describe required work, attach photos, designate Istanbul district, and select urgent or planned.  
   *Success criterion:* Test users can create both urgent and planned requests properly. Incomplete submissions are prevented by validation.
2. **Generate relevant and intelligible professional matching:** The system identifies matching professionals using predefined criteria and displays explicit matching reasons.  
   *Success criterion:* System filters out non-relevant professionals and displays matching factors clearly.
3. **Facilitate submission and acceptance of an offer:** Professionals submit itemized offers; customers compare and accept one offer.  
   *Success criterion:* Offers show required fields; atomic concurrency control prevents two offers from being accepted simultaneously.
4. **Support the complete workflow of service provision:** Covers communication, appointment scheduling, progress tracking, completion confirmation, and post-job review.  
   *Success criterion:* Full workflow executes without error; invalid status transitions and premature ratings are blocked.
5. **Secure private information of users:** Precise address, private chat, and uploaded photos are restricted based on user role and job participation.  
   *Success criterion:* Unauthorized access attempts to protected data are rejected.
6. **Ensure interface usability:** Users execute core tasks without guidance.  
   *Success criterion:* At least 80% of core tasks are completed without assistance in formal usability tests with at least five participants.
7. **Supporting website and administrator panel:** Informational web pages and administrative management of accounts, profiles, and complaints.  
   *Success criterion:* Responsive promotional site and operational admin dashboard for test records.

### 1.4 Definitions, Acronyms, and Abbreviations
* **BiTadilat:** Mobile and web platform concept for home repair service matching in Istanbul.
* **RAD:** Requirements Analysis Document.
* **Customer:** User who requests repair or renovation services and evaluates offers.
* **Service Professional:** Skilled repair specialist registered to view requests and submit offers.
* **Administrator:** Authorized platform manager who reviews artisan profiles and handles complaints.
* **Service Request:** Customer description of required repair work.
* **Urgent Request:** High-priority service request flagged for urgent repair needs, without dispatch time guarantees.
* **Planned Request:** Request scheduled for a future appointment.
* **Structured Offer:** Itemized quote specifying labor, estimated materials, arrival time, and notes.
* **Job:** The agreed repair engagement instantiated after an offer is accepted.
* **Trust Indicators:** Credibility indicators such as reviewed profile badge, star rating, and completed jobs count.
* **RBAC:** Role-Based Access Control.

### 1.5 Document Overview
Section 2 covers the Current System status; Section 3 details the Proposed System (use cases, scenarios, non-functional requirements, SDG alignment, UML models, and UI mock-ups); Section 4 discusses Project Risks and Work Packages; Section 5 compiles the Glossary; and Section 6 contains References.

---

# 2. Current System

---

# 3. Proposed System

### 3.1 Overview
BiTadilat implements the service process for home repair and renovation through three major actors – customer, service professional, and administrator. Customers and professionals use dedicated interfaces in the mobile application, while administrators access a web-based panel.

Eligible professionals are identified based on trade categories, declared operational districts in Istanbul, and calendar availability. The matching factors and trust indicators are presented to the customer to support their decision when comparing structured offers. Once an offer is accepted, the platform facilitates direct messaging, appointment coordination, status tracking, and confirmed completion followed by customer reviews.

---

### 3.2 Functional Requirements

#### 3.2.1 Use Cases

| UC ID | Use Case Name | Primary Actor | Priority |
| :--- | :--- | :--- | :--- |
| **UC01** | User Registration & Login | Customer, Pro, Admin | High |
| **UC02** | Create Service Request | Customer | High |
| **UC03** | Rule-Based Matching | System | High |
| **UC04** | Submit Structured Offer | Service Professional | High |
| **UC05** | Compare & Accept Single Offer | Customer | High |
| **UC06** | Schedule Appointment | Customer & Pro | Medium |
| **UC07** | In-App Direct Messaging | Customer & Pro | Medium |
| **UC08** | Update Job Progress | Service Professional | High |
| **UC09** | Confirm Completion | Customer & Pro | High |
| **UC10** | Submit Review & Rating | Customer | Medium |
| **UC11** | Cancel Service Request / Job | Customer & Pro | Medium |
| **UC12** | Verify Professional Profile | Administrator | High |
| **UC13** | Arbitrate Customer Complaints | Administrator | Medium |
| **UC14** | Browse Promotional Showcase | Public Visitor | Low |

---

#### 3.2.2 Scenarios

##### Scenario 1: Emergency Plumbing Repair (Urgent Workflow)
Ahmet discovers a leaking pipe beneath his bathroom sink on Tuesday evening in Moda, Kadıköy. He opens BiTadilat, selects 'Plumbing', flags the urgency as 'Urgent', specifies 'Kadıköy / Moda', adds 2 photos, and submits. The rule-based engine identifies local plumbers with declared availability. Mehmet Usta inspects the request and submits a structured offer (₺850 labor, ₺400 parts, 22:00 arrival). Ahmet compares the offers, inspects Mehmet's profile and rating, and accepts. The request locks atomically. Mehmet receives the exact address, sends an in-app message, arrives at 22:00, fixes the leak, and marks completion. A confirmation dialog appears for Ahmet, who confirms completion and submits a 5-star review.

##### Scenario 2: Planned Apartment Painting (Planned Workflow)
Ayşe plans to repaint her apartment in Beşiktaş next month. She posts a 'Planned Request' with wall dimensions and preferred dates. Registered painters submit quotes with labor and materials breakdowns. She reviews the comparison screen, accepts one valid offer to initiate the job, and then communicates with the chosen painter via in-app messaging to coordinate access and confirm an appointment date.

---

### 3.3 Nonfunctional Requirements

#### 3.3.1 Usability
* **Unassisted Task Completion:** At least 80% of core tasks must be completed without assistance in formal usability testing with at least five participants.
* **Learnability:** First-time customers can submit a request in under 3 minutes; professionals can prepare and send a structured offer in under 90 seconds (measured under agreed usability test scenarios).
* **Dynamic Localization:** Full interface support for Turkish (TR) and English (EN), switchable on-the-fly.
* **Error Prevention & Confirmation Dialogs:** A confirmation dialog is required before accepting an offer, cancelling a job, or confirming completion, ensuring users do not trigger irreversible state changes accidentally.
* **Touch Ergonomics:** Mobile interactive touch targets must meet a minimum interactive area of 48 × 48 dp; text contrast must satisfy WCAG 2.1 AA standards (≥ 4.5:1).

#### 3.3.2 Reliability
* **Platform Availability:** Target API availability of ≥ 99.5% uptime during operational testing hours.
* **Transaction Atomicity:** Database transactions enforce that accepting one offer locks the request and transitions competing offers to rejected status.

#### 3.3.3 Performance
* **API Latency:** Target read requests return within < 500 ms on 4G mobile networks.
* **Image Payload:** Client-side compression limits photo attachments to ≤ 1.5 MB before upload.

#### 3.3.4 Supportability & Implementation
* **Decoupled Architecture:** Client-server architecture separating mobile apps from backend REST APIs.
* **Technology Stack:** Cross-platform mobile framework (Flutter / React Native) and relational database (PostgreSQL).

#### 3.3.5 External Interfaces & Packaging
* **Device Hardware:** Camera and storage access permissions.
* **Notifications:** Push notification services (FCM / APNs) for offer and message alerts.
* **Packaging:** Packaged mobile builds (Android APK, iOS) and containerized backend (Docker).

#### 3.3.6 Legal and Privacy Constraints
* **KVKK Compliance:** Adheres to Turkish Law No. 6698 on Protection of Personal Data.
* **Address Privacy:** Exact street address and apartment numbers remain confidential until an offer is accepted.

#### 3.3.7 Sustainable Development Goals (SDG) Alignment
* **SDG 8 – Decent Work and Economic Growth (Target 8.3 & Target 8.5):** BiTadilat aims to support SDG 8 by helping local repair and renovation professionals in Istanbul reach potential customers and organize their work. By offering structured proposal forms, customer review histories, and a centralized workspace to manage appointments and active jobs, the platform may assist independent tradespeople and small repair services in building their local customer base and coordinating daily service engagements effectively.

---

### 3.4 System Models

#### 3.4.1 Use Case Model
The Use Case Diagram portrays system boundaries and actors (Customer, Service Professional, Administrator) with straight, non-crossing lines according to Visual Paradigm architecture.

#### 3.4.2 Object Model (Analysis Class Model)
The Analysis Class Diagram defines core concepts: `User`, `Customer`, `ServiceProfessional`, `ServiceRequest`, `Photo`, `StructuredOffer`, `Job`, `Appointment`, `Review`, and `Complaint`.

#### 3.4.3 Dynamic Models
* **Sequence Diagram:** Detailed lifecycle interaction from request submission and matching to atomic offer acceptance.
* **State Machine Diagram:** Request and Job state milestones (`OPEN` $\rightarrow$ `OFFER_ACCEPTED` $\rightarrow$ `APPOINTMENT_SCHEDULED` $\rightarrow$ `IN_PROGRESS` $\rightarrow$ `WORK_FINISHED` $\rightarrow$ `COMPLETED` $\rightarrow$ `REVIEWED`).

#### 3.4.4 User Interface: Navigational Paths, Clickable PDF (D1.3), and Screen Mock-ups

> **Deliverable D1.3 (Interactive Navigable PDF):**  
> All user journeys and mock-up screens detailed below have been compiled into an interactive prototype PDF: [`BiTadilat_Navigable_Mockups.pdf`](file:///Users/ata/Documents/antigravity/BiTadilat/BiTadilat_Navigable_Mockups.pdf). Stakeholders can click directly through screens, switch between customer/pro/admin flows, and test prototype navigation.

---

##### Complete Suite of Screen Mock-ups & Wireframes

```
SCR-01: Authentication & Role Selection (Mobile Common)
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
+-------------------------------------------------------------+
```

```
SCR-02: Customer Request Creation Screen (C-02)
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
+-------------------------------------------------------------+
```

```
SCR-03: Rule-Based Matching Results Screen (C-03)
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
+-------------------------------------------------------------+
```

```
SCR-04: Structured Offer Comparison Screen (C-04)
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
+-------------------------------------------------------------+
```

```
SCR-05: Professional Profile View Screen (P-01)
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
+-------------------------------------------------------------+
```

```
SCR-06: Appointment Scheduling Screen (CP-01)
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
+-------------------------------------------------------------+
```

```
SCR-07: In-App Chat & Active Job Workspace (CP-02)
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
+-------------------------------------------------------------+
```

```
SCR-08: Customer Job Tracking & Progress Screen (C-05)
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
+-------------------------------------------------------------+
```

```
SCR-09: Cancellation Confirmation Dialog Screen (Common-01)
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
+-------------------------------------------------------------+
```

```
SCR-10: Completion Confirmation Dialog Screen (C-06)
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
+-------------------------------------------------------------+
```

```
SCR-11: Review & Rating Submission Screen (C-07)
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
+-------------------------------------------------------------+
```

```
SCR-12: Customer Dispute & Complaint Filing Screen (C-08)
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
+-------------------------------------------------------------+
```

```
SCR-13: Customer Complaint Status & Confirmation Screen (C-09)
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
+-------------------------------------------------------------+
```

```
SCR-14: Professional Matched Requests Feed (P-01)
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
+-------------------------------------------------------------+
```

```
SCR-15: Professional Structured Offer Builder (P-02)
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
+-------------------------------------------------------------+
```

```
SCR-16: Professional Offer Submission Status Screen (P-03)
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
+-------------------------------------------------------------+
```

```
SCR-17: Professional Profile & Availability Management (P-04)
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
+-------------------------------------------------------------+
```

```
SCR-18: Professional Job Execution & Milestones (P-05)
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
+-------------------------------------------------------------+
```

```
SCR-19: Admin Profile Review Screen (A-01)
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
+------------------------------------------------------------------------------------------------+
```

```
SCR-20: Admin Dispute & Complaint Center (A-02)
+------------------------------------------------------------------------------------------------+
|  ACTIVE DISPUTE CASES (ALTERNATIVE SCENARIO)                                                   |
|  Case #CMP-104 | Job #504 | Complainant: Zeynep K. vs Professional: Ali Kaya                  |
|  Issue: Customer reports technician did not arrive at scheduled appointment.                  |
|  Audit Trail: Scheduled for 14:00. Last message timestamp recorded.                           |
|  [  CANCEL DISPUTED JOB  ]          [  ISSUE WARNING  ]          [  DISMISS DISPUTE  ]         |
+------------------------------------------------------------------------------------------------+
```

```
SCR-21: Admin User & Professional Account Management (A-03)
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
+------------------------------------------------------------------------------------------------+
```

```
SCR-22: Promotional Showcase Website (W-01)
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
+------------------------------------------------------------------------------------------------+
```

---

# 4. Other Analysis Elements

### 4.1 Risks and Alternatives

| Risk | Likelihood | Effect on the project | B Plan Summary |
| :--- | :---: | :--- | :--- |
| Limited access to professionals and customers across Istanbul for evaluation | Medium | Testing may not represent the variety of service areas and customer needs across the city. | Keep user evaluation focused on a reasonable sample and use simulated personas and scenarios for various Istanbul districts. |
| Language differences among potential users | Medium | Users who cannot speak the interface language will find it difficult to explain requests or compare offers. | Offer Turkish and English interface versions. Employ clear icons and standardized input fields. Test with users fluent in respective languages. |
| Difficulties integrating mobile application and backend | Medium | Incompatible API responses or data formats can cause workflow delays and reduce testing time. | Define data formats first; incorporate a minimum request-to-completion workflow before adding secondary features. Use mock API stubs. |
| Insufficient professional availability in some service areas or categories | Medium | Requests may receive few or no offers, particularly for urgent services, limiting matching usefulness. | Ensure only qualified professionals are matched. Inform customers when no pros qualify and offer options to leave request open or adjust appointment time. |

---

### 4.2 Project Plan and Work Packages

#### Key Project Deadlines
* **16 October 2026:** Requirements Analysis Document (RAD) Submission.
* **30 October 2026:** System Design Document (SDD) Submission.
* **04 December 2026:** Core Implementation Complete.
* **25 December 2026:** Integration, Usability, and Security Testing Complete.
* **02 January 2027:** Final Thesis and Source Code Submission.
* **08 January 2027:** Poster and presentation-file submission (jury presentation dates remain unconfirmed).

---

# 5. Glossary

* **Administrator:** An authorized user responsible for reviewing service professional profile submissions, user accounts, and customer complaints via the web panel.
* **Appointment:** A mutually scheduled date and time agreed upon between customer and professional for site inspection or repair work.
* **BiTadilat:** The mobile and web software platform concept for matching customers with local home repair and renovation specialists in Istanbul.
* **Completion Confirmation:** The mutual status update in the application by customer and professional acknowledging that physical repair work has concluded.
* **Customer:** A registered user seeking home repair or renovation services who creates requests, evaluates offers, and reviews completed work.
* **Eligible Professional:** A registered professional whose declared category, operational district, and schedule availability match an open request.
* **Job:** The service engagement initiated within the application after a customer accepts one professional's offer.
* **Job Status:** The current execution state of a job: `AGREED`, `SCHEDULED`, `IN_PROGRESS`, `WORK_FINISHED`, `COMPLETED` or `CANCELLED`. Request assignment and complaint status are tracked separately.
* **Navigational Path:** The sequence of screens and transitions traversed by a user to achieve a goal within the application.
* **Non-Functional Requirement (NFR):** A requirement describing system quality or constraint, such as usability, reliability, or privacy.
* **Planned Request:** A service request created for repair or renovation work scheduled for a future appointment date.
* **Promotional Website:** An informational website providing an overview of BiTadilat features and application download links.
* **Review & Rating:** Feedback consisting of a star rating (1 to 5) and written comments submitted by a customer after job completion.
* **Role-Based Access Control (RBAC):** Restrictions governing available information and actions based on user role (Customer, Professional, Administrator) and job participation.
* **Rule-Based Matching:** A deterministic approach selecting eligible professionals using predefined criteria (category, district, availability) without machine learning.
* **Screen Mock-up:** A visual layout illustrating user interface components, information placement, and actionable controls.
* **Service Area:** Municipal districts in Istanbul where a professional declares availability to accept and perform services.
* **Service Category:** Trade classification associated with a request or professional profile (e.g., Plumbing, Electrical, Painting).
* **Service Professional:** A skilled repair or renovation specialist registered on BiTadilat to view relevant requests and submit offers.
* **Service Request:** A customer description of required repair work, tracked in `OPEN`, `ASSIGNED`, or `CANCELLED` state.
* **Structured Offer:** A standardized bid submitted by a professional itemizing labor cost, estimated materials cost, arrival time, and notes.
* **Sustainable Development Goals (SDGs):** The 17 global goals established by the United Nations in 2015 for sustainable development.
* **Trust Indicators:** Information shown to customers to assist in evaluating professionals, including profile review status, ratings, and count of completed jobs.
* **Urgent Request:** A service request flagged by the customer as requiring urgent attention, without guaranteeing immediate response times or rapid dispatch.

---

# 6. References

1. Bruegge, B., & Dutoit, A. H. (2010). *Object-Oriented Software Engineering Using UML, Patterns, and Java* (3rd ed.). Prentice Hall. ISBN: 978-0136061250.
2. International Organization for Standardization. (2018). *Ergonomics of human-system interaction — Part 11: Usability: Definitions and concepts* (ISO Standard No. 9241-11:2018). https://www.iso.org/standard/63500.html
3. Nielsen, J. (1994). *Usability Engineering*. Morgan Kaufmann Publishers Inc. ISBN: 978-0125184069.
4. World Wide Web Consortium (W3C). (2018). *Web Content Accessibility Guidelines (WCAG) 2.1*. W3C Recommendation. https://www.w3.org/TR/WCAG21/
5. Google LLC. (2023). *Material Design 3: Guidelines for Responsive Layouts and Mobile Ergonomics*. Material.io. https://m3.material.io/
6. Apple Inc. (2024). *Human Interface Guidelines: Designing for iOS and iPadOS*. Apple Developer Documentation. https://developer.apple.com/design/human-interface-guidelines/
7. United Nations, Department of Economic and Social Affairs. (2015). *Transforming our world: The 2030 Agenda for Sustainable Development (A/RES/70/1)*. United Nations. https://sdgs.un.org/goals
8. United Nations, Division for Sustainable Development Goals. (2023). *SDG 8: Promote sustained, inclusive and sustainable economic growth, full and productive employment and decent work for all*. UN DESA. https://sdgs.un.org/goals/goal8
9. Sommerville, I. (2015). *Software Engineering* (10th ed.). Pearson. ISBN: 978-0133943030.
10. Pressman, R. S., & Maxima, B. R. (2020). *Software Engineering: A Practitioner's Approach* (9th ed.). McGraw-Hill Education. ISBN: 978-1259872976.
11. Official Gazette of the Republic of Turkey. (2016). *Law on the Protection of Personal Data (KVKK No. 6698)*. https://www.kvkk.gov.tr/
