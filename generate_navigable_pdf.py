import os
import math
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from reportlab.lib import colors
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

def setup_fonts():
    """
    Registers a TrueType font supporting full Turkish character sets (ç, ğ, ı, ö, ş, ü, Ç, Ğ, İ, Ö, Ş, Ü)
    and standard symbols without square glyphs.
    """
    candidates = [
        ('/System/Library/Fonts/Supplemental/Arial.ttf',
         '/System/Library/Fonts/Supplemental/Arial Bold.ttf',
         '/System/Library/Fonts/Supplemental/Arial Italic.ttf'),
        ('/Library/Fonts/Arial.ttf',
         '/Library/Fonts/Arial Bold.ttf',
         '/Library/Fonts/Arial Italic.ttf'),
        ('/System/Library/Fonts/Helvetica.ttc',
         '/System/Library/Fonts/Helvetica.ttc',
         '/System/Library/Fonts/Helvetica.ttc')
    ]
    for reg, bld, itl in candidates:
        if os.path.exists(reg) and os.path.exists(bld):
            try:
                pdfmetrics.registerFont(TTFont('AppFont', reg))
                pdfmetrics.registerFont(TTFont('AppFont-Bold', bld))
                if os.path.exists(itl):
                    pdfmetrics.registerFont(TTFont('AppFont-Italic', itl))
                else:
                    pdfmetrics.registerFont(TTFont('AppFont-Italic', reg))
                return 'AppFont', 'AppFont-Bold', 'AppFont-Italic'
            except Exception:
                continue
    return 'Helvetica', 'Helvetica-Bold', 'Helvetica-Oblique'

def create_navigable_mockups_pdf(output_filename="BiTadilat_Navigable_Mockups.pdf"):
    F_REG, F_BOLD, F_ITALIC = setup_fonts()

    PAGE_WIDTH, PAGE_HEIGHT = letter # 612 x 792 pt
    c = canvas.Canvas(output_filename, pagesize=letter)

    # Color Palette
    c_navy = colors.HexColor("#0F2A4A")
    c_blue = colors.HexColor("#1A365D")
    c_accent = colors.HexColor("#2B6CB0")
    c_bg = colors.HexColor("#F7FAFC")
    c_border = colors.HexColor("#CBD5E0")
    c_text_dark = colors.HexColor("#2D3748")
    c_text_muted = colors.HexColor("#718096")
    c_green = colors.HexColor("#2F855A")
    c_amber = colors.HexColor("#C05621")
    c_red = colors.HexColor("#C53030")

    def wrap_text_lines(text, font_name, font_size, max_width):
        words = text.split()
        lines = []
        cur_line = []
        for w in words:
            test_line = " ".join(cur_line + [w])
            if c.stringWidth(test_line, font_name, font_size) <= max_width:
                cur_line.append(w)
            else:
                if cur_line:
                    lines.append(" ".join(cur_line))
                cur_line = [w]
        if cur_line:
            lines.append(" ".join(cur_line))
        return lines

    def draw_top_nav(title, current_journey, prev_target, next_target):
        # Top Header Bar (Height = 60)
        c.setFillColor(c_navy)
        c.rect(0, PAGE_HEIGHT - 60, PAGE_WIDTH, 60, fill=1, stroke=0)
        
        # Brand & Subtitle (Row 1)
        c.setFillColor(colors.HexColor("#CBD5E0"))
        c.setFont(F_REG, 8.5)
        c.drawString(24, PAGE_HEIGHT - 20, "BiTadilat Interactive UI Prototype  |  Deliverable D1.3")

        # Screen Title (Row 2 - ample space, no clipping or overlap with buttons)
        c.setFillColor(colors.white)
        c.setFont(F_BOLD, 11.5)
        c.drawString(24, PAGE_HEIGHT - 42, title)

        # Top Navigation Buttons (Aligned to right edge)
        btn_y = PAGE_HEIGHT - 45
        btn_h = 24
        
        # Hub Button
        c.setFillColor(c_accent)
        c.roundRect(PAGE_WIDTH - 250, btn_y, 70, btn_h, 3, fill=1, stroke=0)
        c.setFillColor(colors.white)
        c.setFont(F_BOLD, 8.5)
        c.drawCentredString(PAGE_WIDTH - 215, btn_y + 7, "Map Hub")
        c.linkRect("hub", "map_hub", Rect=(PAGE_WIDTH - 250, btn_y, PAGE_WIDTH - 180, btn_y + btn_h), Border='[0 0 0]')

        # Prev Button
        if prev_target:
            c.setFillColor(c_accent)
            c.roundRect(PAGE_WIDTH - 170, btn_y, 58, btn_h, 3, fill=1, stroke=0)
            c.setFillColor(colors.white)
            c.setFont(F_BOLD, 8.5)
            c.drawCentredString(PAGE_WIDTH - 141, btn_y + 7, "<- Prev")
            c.linkRect("prev", prev_target, Rect=(PAGE_WIDTH - 170, btn_y, PAGE_WIDTH - 112, btn_y + btn_h), Border='[0 0 0]')

        # Next Button
        if next_target:
            c.setFillColor(c_green)
            c.roundRect(PAGE_WIDTH - 102, btn_y, 58, btn_h, 3, fill=1, stroke=0)
            c.setFillColor(colors.white)
            c.setFont(F_BOLD, 8.5)
            c.drawCentredString(PAGE_WIDTH - 73, btn_y + 7, "Next ->")
            c.linkRect("next", next_target, Rect=(PAGE_WIDTH - 102, btn_y, PAGE_WIDTH - 44, btn_y + btn_h), Border='[0 0 0]')

        # Sub-header bar (Breadcrumb & Journey switcher)
        c.setFillColor(colors.HexColor("#EDF2F7"))
        c.rect(0, PAGE_HEIGHT - 85, PAGE_WIDTH, 25, fill=1, stroke=0)
        c.setFillColor(c_text_dark)
        c.setFont(F_BOLD, 8.5)
        c.drawString(24, PAGE_HEIGHT - 78, f"ACTIVE JOURNEY: {current_journey}")

        # Quick Switcher links
        c.setFont(F_REG, 8.5)
        c.setFillColor(c_accent)
        c.drawString(PAGE_WIDTH - 365, PAGE_HEIGHT - 78, "Switch Journey:")
        
        c.drawString(PAGE_WIDTH - 280, PAGE_HEIGHT - 78, "[Customer]")
        c.linkRect("goto_cust", "scr_login", Rect=(PAGE_WIDTH - 280, PAGE_HEIGHT - 82, PAGE_WIDTH - 225, PAGE_HEIGHT - 70), Border='[0 0 0]')

        c.drawString(PAGE_WIDTH - 215, PAGE_HEIGHT - 78, "[Professional]")
        c.linkRect("goto_pro", "scr_pro_feed", Rect=(PAGE_WIDTH - 215, PAGE_HEIGHT - 82, PAGE_WIDTH - 145, PAGE_HEIGHT - 70), Border='[0 0 0]')

        c.drawString(PAGE_WIDTH - 135, PAGE_HEIGHT - 78, "[Admin]")
        c.linkRect("goto_adm", "scr_admin_verif", Rect=(PAGE_WIDTH - 135, PAGE_HEIGHT - 82, PAGE_WIDTH - 90, PAGE_HEIGHT - 70), Border='[0 0 0]')

        c.drawString(PAGE_WIDTH - 80, PAGE_HEIGHT - 78, "[Web]")
        c.linkRect("goto_web", "scr_promo_web", Rect=(PAGE_WIDTH - 80, PAGE_HEIGHT - 82, PAGE_WIDTH - 40, PAGE_HEIGHT - 70), Border='[0 0 0]')

    def draw_mobile_frame():
        fx, fy, fw, fh = 145, 40, 322, 645
        c.setFillColor(colors.HexColor("#1A202C"))
        c.roundRect(fx - 8, fy - 8, fw + 16, fh + 16, 22, fill=1, stroke=0)
        
        c.setFillColor(colors.white)
        c.roundRect(fx, fy, fw, fh, 16, fill=1, stroke=0)

        # Notch / Camera pill
        c.setFillColor(colors.HexColor("#2D3748"))
        c.roundRect(fx + fw/2 - 45, fy + fh - 18, 90, 14, 7, fill=1, stroke=0)

        # Status Bar info
        c.setFillColor(c_text_muted)
        c.setFont(F_BOLD, 8)
        c.drawString(fx + 16, fy + fh - 14, "09:41")
        c.drawRightString(fx + fw - 16, fy + fh - 14, "4G  100%")

        return fx, fy, fw, fh

    # =========================================================================
    # PAGE 1: MASTER NAVIGATION HUB
    # =========================================================================
    c.bookmarkPage("map_hub")
    
    c.setFillColor(c_navy)
    c.rect(0, PAGE_HEIGHT - 120, PAGE_WIDTH, 120, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 20)
    c.drawString(35, PAGE_HEIGHT - 50, "BiTadilat – Interactive Screen Mock-ups")
    c.setFont(F_REG, 11)
    c.drawString(35, PAGE_HEIGHT - 74, "Deliverable D1.3: Clickable Prototype & Role-Separated User Navigation")
    c.setFont(F_ITALIC, 9.5)
    c.drawString(35, PAGE_HEIGHT - 94, "Lead Contributor: Ata Herdem Atay (22soft1004) - Frontend / Mobile Lead (WP4)")

    c.setFillColor(colors.HexColor("#EBF8FF"))
    c.rect(35, PAGE_HEIGHT - 165, PAGE_WIDTH - 70, 36, fill=1, stroke=0)
    c.setFillColor(colors.HexColor("#2B6CB0"))
    c.setFont(F_BOLD, 9.5)
    c.drawString(48, PAGE_HEIGHT - 145, "HOW TO NAVIGATE:")
    c.setFont(F_REG, 8.5)
    c.setFillColor(c_text_dark)
    c.drawString(48, PAGE_HEIGHT - 158, "Click any screen below to jump directly to it. Every screen includes working role actions, breadcrumbs, and back/next buttons.")

    journeys = [
        ("1. Customer Journey (Mobile)", [
            ("SCR-01: Authentication & Role Selection", "scr_login"),
            ("SCR-02: New Service Request Form", "scr_cust_req"),
            ("SCR-03: Rule-Based Matching Results", "scr_cust_match"),
            ("SCR-04: Structured Offer Comparison", "scr_cust_offers"),
            ("SCR-05: Professional Public Profile", "scr_pro_profile"),
            ("SCR-06: Appointment Scheduling", "scr_appointment"),
            ("SCR-07: In-App Chat & Active Job", "scr_chat_job"),
            ("SCR-08: Customer Job Tracking & Progress", "scr_cust_job_progress"),
            ("SCR-09: Cancellation Confirmation Dialog", "scr_cancel_confirm"),
            ("SCR-10: Job Completion Confirmation Dialog", "scr_complete_confirm"),
            ("SCR-11: Review & Rating Submission", "scr_review_rating"),
            ("SCR-12: Customer Complaint Filing", "scr_cust_complaint"),
            ("SCR-13: Complaint Status & Confirmation", "scr_cust_complaint_success")
        ], 35, PAGE_HEIGHT - 180, 260),

        ("2. Professional Journey (Mobile)", [
            ("SCR-01: Pro Login & Role Select", "scr_login"),
            ("SCR-14: Matched Requests Feed", "scr_pro_feed"),
            ("SCR-15: Structured Offer Builder", "scr_pro_make_offer"),
            ("SCR-16: Pro Offer Submission Confirmation", "scr_pro_offer_success"),
            ("SCR-17: Profile & Availability Management", "scr_pro_profile_edit"),
            ("SCR-06: Scheduled Appointment View", "scr_appointment"),
            ("SCR-07: In-App Client Chat", "scr_chat_job"),
            ("SCR-18: Pro Job Execution & Milestones", "scr_pro_job_progress"),
            ("SCR-09: Pro Cancellation Dialog", "scr_cancel_confirm")
        ], 315, PAGE_HEIGHT - 180, 260),

        ("3. Administrator Web Portal", [
            ("SCR-19: Admin Profile Review (No MERNIS)", "scr_admin_verif"),
            ("SCR-20: Dispute & Complaint Console", "scr_admin_disputes"),
            ("SCR-21: User & Pro Account Management", "scr_admin_accounts")
        ], 315, PAGE_HEIGHT - 455, 260),

        ("4. Public Promotional Showcase Website", [
            ("SCR-22: BiTadilat Showcase Landing Page", "scr_promo_web")
        ], 315, PAGE_HEIGHT - 585, 260)
    ]

    for j_title, items, jx, jy, jw in journeys:
        jh = len(items) * 20 + 32
        c.setFillColor(colors.white)
        c.setStrokeColor(c_border)
        c.roundRect(jx, jy - jh, jw, jh, 6, fill=1, stroke=1)
        
        c.setFillColor(c_navy)
        c.rect(jx, jy - 24, jw, 24, fill=1, stroke=0)
        c.setFillColor(colors.white)
        c.setFont(F_BOLD, 9.5)
        c.drawString(jx + 10, jy - 16, j_title)

        ly = jy - 40
        for item_label, item_target in items:
            c.setFillColor(c_accent)
            c.setFont(F_REG, 8)
            c.drawString(jx + 12, ly, f"- {item_label}")
            c.linkRect(item_target, item_target, Rect=(jx + 10, ly - 3, jx + jw - 10, ly + 10), Border='[0 0 0]')
            ly -= 20

    c.showPage()

    # =========================================================================
    # SCREEN 1: LOGIN (SCR-01)
    # =========================================================================
    c.bookmarkPage("scr_login")
    draw_top_nav("SCR-01: Authentication & Role Selection", "Customer / Pro Common", "map_hub", "scr_cust_req")
    fx, fy, fw, fh = draw_mobile_frame()

    c.setFillColor(c_navy)
    c.rect(fx, fy + fh - 75, fw, 55, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 14)
    c.drawCentredString(fx + fw/2, fy + fh - 52, "BiTadilat")
    c.setFont(F_REG, 8)
    c.drawCentredString(fx + fw/2, fy + fh - 65, "Home Repair & Renovation Matching")

    c.setFillColor(c_text_dark)
    c.setFont(F_BOLD, 13)
    c.drawString(fx + 24, fy + fh - 110, "Welcome Back")
    c.setFont(F_REG, 9)
    c.setFillColor(c_text_muted)
    c.drawString(fx + 24, fy + fh - 126, "Sign in to manage your requests and jobs.")

    # Tab selection
    c.setFillColor(colors.HexColor("#EDF2F7"))
    c.roundRect(fx + 24, fy + fh - 175, fw - 48, 36, 6, fill=1, stroke=0)
    c.setFillColor(c_accent)
    c.roundRect(fx + 26, fy + fh - 173, (fw - 52)/2, 32, 5, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 9.5)
    c.drawCentredString(fx + 24 + (fw-48)/4, fy + fh - 153, "Customer")
    c.setFillColor(c_text_dark)
    c.drawCentredString(fx + 24 + 3*(fw-48)/4, fy + fh - 153, "Professional")
    c.linkRect("sel_pro", "scr_pro_feed", Rect=(fx + 24 + (fw-48)/2, fy + fh - 175, fx + fw - 24, fy + fh - 139), Border='[0 0 0]')

    fields = [("Email or Phone", "ata@example.com", fy + fh - 235), ("Password", "••••••••••••", fy + fh - 295)]
    for lbl, val, pos_y in fields:
        c.setFillColor(c_text_dark)
        c.setFont(F_BOLD, 9)
        c.drawString(fx + 24, pos_y + 24, lbl)
        c.setFillColor(colors.white)
        c.setStrokeColor(c_border)
        c.roundRect(fx + 24, pos_y, fw - 48, 32, 4, fill=1, stroke=1)
        c.setFillColor(c_text_dark)
        c.setFont(F_REG, 9)
        c.drawString(fx + 34, pos_y + 11, val)

    c.setFillColor(c_green)
    c.roundRect(fx + 24, fy + fh - 355, fw - 48, 38, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 10.5)
    c.drawCentredString(fx + fw/2, fy + fh - 332, "Log In as Customer ->")
    c.linkRect("btn_login_cust", "scr_cust_req", Rect=(fx + 24, fy + fh - 355, fx + fw - 24, fy + fh - 317), Border='[0 0 0]')

    c.setFillColor(c_accent)
    c.setFont(F_REG, 9)
    c.drawCentredString(fx + fw/2, fy + fh - 390, "Switch to Service Professional Login")
    c.linkRect("link_login_pro", "scr_pro_feed", Rect=(fx + 30, fy + fh - 400, fx + fw - 30, fy + fh - 380), Border='[0 0 0]')

    c.drawCentredString(fx + fw/2, fy + fh - 425, "Administrator Web Access Portal")
    c.linkRect("link_login_admin", "scr_admin_verif", Rect=(fx + 30, fy + fh - 435, fx + fw - 30, fy + fh - 415), Border='[0 0 0]')

    c.showPage()

    # =========================================================================
    # SCREEN 2: NEW REQUEST (SCR-02)
    # =========================================================================
    c.bookmarkPage("scr_cust_req")
    draw_top_nav("SCR-02: Create Service Request", "Customer Journey", "scr_login", "scr_cust_match")
    fx, fy, fw, fh = draw_mobile_frame()

    c.setFillColor(c_navy)
    c.rect(fx, fy + fh - 65, fw, 45, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 11)
    c.drawString(fx + 16, fy + fh - 43, "New Service Request")
    c.setFont(F_REG, 9)
    c.drawRightString(fx + fw - 16, fy + fh - 43, "[TR | EN]")

    c.setFillColor(c_text_dark)
    c.setFont(F_BOLD, 9)
    c.drawString(fx + 16, fy + fh - 88, "1. Trade Category:")
    c.setFillColor(colors.white)
    c.setStrokeColor(c_border)
    c.roundRect(fx + 16, fy + fh - 114, fw - 32, 24, 4, fill=1, stroke=1)
    c.setFillColor(c_text_dark)
    c.setFont(F_REG, 9)
    c.drawString(fx + 24, fy + fh - 106, "Plumbing Repair (Selected)")

    c.setFont(F_BOLD, 9)
    c.drawString(fx + 16, fy + fh - 138, "2. Urgency Level:")
    c.setFillColor(colors.HexColor("#FFF5F5"))
    c.setStrokeColor(colors.HexColor("#FEB2B2"))
    c.roundRect(fx + 16, fy + fh - 165, (fw - 40)/2, 24, 4, fill=1, stroke=1)
    c.setFillColor(colors.HexColor("#C53030"))
    c.setFont(F_BOLD, 8.5)
    c.drawCentredString(fx + 16 + (fw-40)/4, fy + fh - 157, "(o) Urgent Fix")

    c.setFillColor(colors.white)
    c.setStrokeColor(c_border)
    c.roundRect(fx + 24 + (fw-40)/2, fy + fh - 165, (fw - 40)/2, 24, 4, fill=1, stroke=1)
    c.setFillColor(c_text_muted)
    c.setFont(F_REG, 8.5)
    c.drawCentredString(fx + 24 + 3*(fw-40)/4, fy + fh - 157, "( ) Planned Renovation")

    c.setFillColor(c_text_dark)
    c.setFont(F_BOLD, 9)
    c.drawString(fx + 16, fy + fh - 188, "3. Istanbul District & Area:")
    c.setFillColor(colors.white)
    c.setStrokeColor(c_border)
    c.roundRect(fx + 16, fy + fh - 214, fw - 32, 24, 4, fill=1, stroke=1)
    c.setFillColor(c_text_dark)
    c.setFont(F_REG, 9)
    c.drawString(fx + 24, fy + fh - 206, "Kadıköy  ->  Moda Mahallesi")

    c.setFont(F_BOLD, 9)
    c.drawString(fx + 16, fy + fh - 238, "4. Problem Scope Description:")
    c.setFillColor(colors.white)
    c.setStrokeColor(c_border)
    c.roundRect(fx + 16, fy + fh - 300, fw - 32, 54, 4, fill=1, stroke=1)
    c.setFillColor(c_text_dark)
    c.setFont(F_REG, 8)
    c.drawString(fx + 24, fy + fh - 256, "Clean water pipe burst under bathroom sink.")
    c.drawString(fx + 24, fy + fh - 270, "Water is leaking quickly. Need replacement valve.")
    c.drawString(fx + 24, fy + fh - 284, "Requires immediate on-site arrival tonight.")

    c.setFont(F_BOLD, 9)
    c.drawString(fx + 16, fy + fh - 322, "5. Photo Attachments (Max 5):")
    for i in range(5):
        c.setFillColor(colors.HexColor("#EDF2F7"))
        c.roundRect(fx + 16 + i * 58, fy + fh - 370, 50, 40, 4, fill=1, stroke=0)
        c.setFillColor(c_text_muted)
        c.setFont(F_REG, 7.5)
        c.drawCentredString(fx + 41 + i * 58, fy + fh - 352, f"Photo {i+1}")

    c.setFillColor(c_green)
    c.roundRect(fx + 16, fy + fh - 435, fw - 32, 38, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 10.5)
    c.drawCentredString(fx + fw/2, fy + fh - 422, "Find Matching Specialists ->")
    c.linkRect("btn_find_spec", "scr_cust_match", Rect=(fx + 16, fy + fh - 435, fx + fw - 16, fy + fh - 397), Border='[0 0 0]')

    c.showPage()

    # =========================================================================
    # SCREEN 3: MATCHING RESULTS (SCR-03)
    # =========================================================================
    c.bookmarkPage("scr_cust_match")
    draw_top_nav("SCR-03: Rule-Based Matching Results", "Customer Journey", "scr_cust_req", "scr_cust_offers")
    fx, fy, fw, fh = draw_mobile_frame()

    c.setFillColor(c_navy)
    c.rect(fx, fy + fh - 65, fw, 45, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 11)
    c.drawString(fx + 16, fy + fh - 43, "Eligible Specialists (Kadıköy)")

    c.setFillColor(colors.HexColor("#EBF8FF"))
    c.roundRect(fx + 16, fy + fh - 95, fw - 32, 24, 4, fill=1, stroke=0)
    c.setFillColor(c_accent)
    c.setFont(F_BOLD, 8.5)
    c.drawString(fx + 24, fy + fh - 88, "2 Specialists meet your criteria & location")

    cards = [
        ("Mehmet Usta - Kadıköy Tesisat", "4.9 (42 reviews)", "Within 1.5 km | Plumbing Specialist", "Offers on-site inspection in ~45 mins", "scr_pro_profile"),
        ("Ahmet Usta - UstaSu Tesisat", "4.7 (19 reviews)", "Within 3.2 km | General Plumber", "Declared active in Kadıköy & Üsküdar", "scr_pro_profile")
    ]
    card_y = fy + fh - 110
    for name, rating, loc, status, prof_link in cards:
        c.setFillColor(colors.white)
        c.setStrokeColor(c_border)
        c.roundRect(fx + 16, card_y - 100, fw - 32, 95, 6, fill=1, stroke=1)
        
        c.setFillColor(c_text_dark)
        c.setFont(F_BOLD, 9.5)
        c.drawString(fx + 26, card_y - 20, name)
        
        c.setFillColor(colors.HexColor("#D69E2E"))
        c.setFont(F_BOLD, 8.5)
        c.drawString(fx + 26, card_y - 34, rating)

        c.setFillColor(c_text_muted)
        c.setFont(F_REG, 7.5)
        c.drawString(fx + 26, card_y - 48, loc)
        c.drawString(fx + 26, card_y - 60, status)

        c.setFillColor(c_accent)
        c.roundRect(fx + 26, card_y - 88, (fw - 64)/2, 22, 3, fill=1, stroke=0)
        c.setFillColor(colors.white)
        c.setFont(F_BOLD, 7.5)
        c.drawCentredString(fx + 26 + (fw - 64)/4, card_y - 82, "View Profile")
        c.linkRect(f"vp_{name[:3]}", prof_link, Rect=(fx + 26, card_y - 88, fx + 26 + (fw - 64)/2, card_y - 66), Border='[0 0 0]')

        c.setFillColor(c_green)
        c.roundRect(fx + 34 + (fw - 64)/2, card_y - 88, (fw - 64)/2, 22, 3, fill=1, stroke=0)
        c.setFillColor(colors.white)
        c.setFont(F_BOLD, 7.5)
        c.drawCentredString(fx + 34 + 3*(fw - 64)/4, card_y - 82, "Compare Offers")
        c.linkRect(f"co_{name[:3]}", "scr_cust_offers", Rect=(fx + 34 + (fw - 64)/2, card_y - 88, fx + fw - 26, card_y - 66), Border='[0 0 0]')

        card_y -= 112

    c.setFillColor(c_blue)
    c.roundRect(fx + 16, fy + 35, fw - 32, 34, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 9.5)
    c.drawCentredString(fx + fw/2, fy + 46, "View Incoming Offers ->")
    c.linkRect("btn_goto_offers", "scr_cust_offers", Rect=(fx + 16, fy + 35, fx + fw - 16, fy + 69), Border='[0 0 0]')

    c.showPage()

    # =========================================================================
    # SCREEN 4: OFFER COMPARISON (SCR-04)
    # =========================================================================
    c.bookmarkPage("scr_cust_offers")
    draw_top_nav("SCR-04: Structured Offer Comparison", "Customer Journey", "scr_cust_match", "scr_pro_profile")
    fx, fy, fw, fh = draw_mobile_frame()

    c.setFillColor(c_navy)
    c.rect(fx, fy + fh - 65, fw, 45, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 11)
    c.drawString(fx + 16, fy + fh - 43, "Compare Structured Offers")

    c.setFillColor(c_text_dark)
    c.setFont(F_REG, 8.5)
    c.drawString(fx + 16, fy + fh - 80, "Offers for Request #501 (Plumbing Repair):")

    offers = [
        ("Mehmet Usta", "850 TL", "400 TL", "1.250 TL", "Tonight 22:00", "Includes brass valve & leak test", True),
        ("Ahmet Usta", "950 TL", "500 TL", "1.450 TL", "Tomorrow 09:30", "Includes copper fitting replacement", False)
    ]
    oy = fy + fh - 95
    for pro_name, labor, mat, total, arr_time, notes, is_best in offers:
        c.setFillColor(colors.white)
        c.setStrokeColor(c_green if is_best else c_border)
        c.roundRect(fx + 16, oy - 145, fw - 32, 140, 6, fill=1, stroke=1)

        c.setFillColor(c_blue)
        c.setFont(F_BOLD, 10)
        c.drawString(fx + 26, oy - 20, pro_name)

        if is_best:
            c.setFillColor(c_green)
            c.roundRect(fx + fw - 95, oy - 22, 65, 14, 3, fill=1, stroke=0)
            c.setFillColor(colors.white)
            c.setFont(F_BOLD, 7)
            c.drawCentredString(fx + fw - 62, oy - 18, "EARLIEST")

        c.setFillColor(c_text_dark)
        c.setFont(F_REG, 8)
        c.drawString(fx + 26, oy - 38, f"Labor: {labor}   |   Materials: {mat}")
        c.setFont(F_BOLD, 9.5)
        c.drawString(fx + 26, oy - 54, f"Proposed Total Price: {total}")

        c.setFont(F_REG, 7.5)
        c.setFillColor(c_text_muted)
        c.drawString(fx + 26, oy - 70, f"Committed Arrival: {arr_time}")
        c.drawString(fx + 26, oy - 84, f"Notes: {notes}")

        # Accept button
        c.setFillColor(c_green)
        c.roundRect(fx + 26, oy - 128, (fw - 64)/2, 26, 4, fill=1, stroke=0)
        c.setFillColor(colors.white)
        c.setFont(F_BOLD, 8)
        c.drawCentredString(fx + 26 + (fw - 64)/4, oy - 120, "Accept Offer ->")
        c.linkRect(f"acc_{pro_name[:3]}", "scr_appointment", Rect=(fx + 26, oy - 128, fx + 26 + (fw - 64)/2, oy - 102), Border='[0 0 0]')

        # View Profile link
        c.setFillColor(c_accent)
        c.roundRect(fx + 34 + (fw - 64)/2, oy - 128, (fw - 64)/2, 26, 4, fill=1, stroke=0)
        c.setFillColor(colors.white)
        c.setFont(F_BOLD, 8)
        c.drawCentredString(fx + 34 + 3*(fw - 64)/4, oy - 120, "View Profile")
        c.linkRect(f"prof_{pro_name[:3]}", "scr_pro_profile", Rect=(fx + 34 + (fw - 64)/2, oy - 128, fx + fw - 26, oy - 102), Border='[0 0 0]')

        oy -= 155

    c.showPage()

    # =========================================================================
    # SCREEN 5: PROFESSIONAL PUBLIC PROFILE (SCR-05)
    # =========================================================================
    c.bookmarkPage("scr_pro_profile")
    draw_top_nav("SCR-05: Professional Public Profile", "Customer Journey", "scr_cust_offers", "scr_appointment")
    fx, fy, fw, fh = draw_mobile_frame()

    c.setFillColor(c_navy)
    c.rect(fx, fy + fh - 65, fw, 45, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 11)
    c.drawString(fx + 16, fy + fh - 43, "Professional Profile")

    c.setFillColor(colors.HexColor("#EDF2F7"))
    c.circle(fx + 55, fy + fh - 105, 24, fill=1, stroke=0)
    c.setFillColor(c_navy)
    c.setFont(F_BOLD, 12)
    c.drawCentredString(fx + 55, fy + fh - 110, "MU")

    c.setFillColor(c_text_dark)
    c.setFont(F_BOLD, 11)
    c.drawString(fx + 95, fy + fh - 95, "Mehmet Usta")
    c.setFont(F_REG, 8.5)
    c.setFillColor(c_text_muted)
    c.drawString(fx + 95, fy + fh - 109, "Master Plumber & Pipe Specialist")
    
    c.setFillColor(c_green)
    c.setFont(F_BOLD, 8)
    c.drawString(fx + 95, fy + fh - 123, "[VERIFIED PROFILE]")

    stats = [("4.9", "Rating (42)"), ("98%", "On-Time Rate"), ("12 yrs", "Experience")]
    sx = fx + 20
    for val, lbl in stats:
        c.setFillColor(colors.HexColor("#F7FAFC"))
        c.setStrokeColor(c_border)
        c.roundRect(sx, fy + fh - 180, 85, 42, 4, fill=1, stroke=1)
        c.setFillColor(c_blue)
        c.setFont(F_BOLD, 11)
        c.drawCentredString(sx + 42, fy + fh - 156, val)
        c.setFillColor(c_text_muted)
        c.setFont(F_REG, 7.5)
        c.drawCentredString(sx + 42, fy + fh - 172, lbl)
        sx += 96

    c.setFillColor(c_text_dark)
    c.setFont(F_BOLD, 9)
    c.drawString(fx + 20, fy + fh - 200, "Bio & Trade Credentials:")
    c.setFillColor(c_text_muted)
    c.setFont(F_REG, 8)
    c.drawString(fx + 20, fy + fh - 215, "Specialized in emergency pipe repairs, water heaters, and")
    c.drawString(fx + 20, fy + fh - 227, "bathroom pipe renovations in Kadıköy and Anatolian side.")

    c.setFillColor(c_text_dark)
    c.setFont(F_BOLD, 9)
    c.drawString(fx + 20, fy + fh - 250, "Recent Verified Customer Reviews:")

    reviews = [
        ("Ata H. (Moda)", "★ 5.0", "Fast arrival, cleanly resolved broken faucet."),
        ("Zeynep K. (Caddebostan)", "★ 5.0", "Replaced main valve without making a mess.")
    ]
    ry = fy + fh - 268
    for reviewer, star, comment in reviews:
        c.setFillColor(colors.white)
        c.setStrokeColor(c_border)
        c.roundRect(fx + 20, ry - 38, fw - 40, 36, 4, fill=1, stroke=1)
        c.setFillColor(c_text_dark)
        c.setFont(F_BOLD, 8)
        c.drawString(fx + 28, ry - 14, reviewer)
        c.setFillColor(colors.HexColor("#D69E2E"))
        c.drawString(fx + fw - 65, ry - 14, star)
        c.setFillColor(c_text_muted)
        c.setFont(F_REG, 7.5)
        c.drawString(fx + 28, ry - 28, comment)
        ry -= 46

    c.setFillColor(c_green)
    c.roundRect(fx + 20, fy + 35, fw - 40, 34, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 9.5)
    c.drawCentredString(fx + fw/2, fy + 46, "Book Appointment with Mehmet Usta ->")
    c.linkRect("btn_book_mu", "scr_appointment", Rect=(fx + 20, fy + 35, fx + fw - 20, fy + 69), Border='[0 0 0]')

    c.showPage()

    # =========================================================================
    # SCREEN 6: APPOINTMENT SCHEDULING (SCR-06)
    # =========================================================================
    c.bookmarkPage("scr_appointment")
    draw_top_nav("SCR-06: Appointment Scheduling", "Customer Journey", "scr_pro_profile", "scr_chat_job")
    fx, fy, fw, fh = draw_mobile_frame()

    c.setFillColor(c_navy)
    c.rect(fx, fy + fh - 65, fw, 45, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 11)
    c.drawString(fx + 16, fy + fh - 43, "Schedule Arrival Slot")

    c.setFillColor(c_text_dark)
    c.setFont(F_BOLD, 9)
    c.drawString(fx + 20, fy + fh - 85, "Selected Professional:")
    c.setFont(F_REG, 8.5)
    c.drawString(fx + 20, fy + fh - 100, "Mehmet Usta (Kadıköy Tesisat) - Offer: 1.250 TL")

    c.setFont(F_BOLD, 9)
    c.drawString(fx + 20, fy + fh - 128, "Select Date & Arrival Window:")

    dates = [("Today (14 Oct)", True), ("Tomorrow (15 Oct)", False), ("Thu (16 Oct)", False)]
    dx = fx + 20
    for d_txt, is_sel in dates:
        c.setFillColor(c_accent if is_sel else colors.HexColor("#EDF2F7"))
        c.roundRect(dx, fy + fh - 165, 88, 26, 4, fill=1, stroke=0)
        c.setFillColor(colors.white if is_sel else c_text_dark)
        c.setFont(F_BOLD, 7.5)
        c.drawCentredString(dx + 44, fy + fh - 153, d_txt)
        dx += 96

    slots = [
        ("22:00 - 22:30 (Committed in Offer)", True),
        ("22:30 - 23:00", False),
        ("Tomorrow 09:00 - 10:00", False)
    ]
    sy = fy + fh - 180
    for s_txt, s_sel in slots:
        c.setFillColor(colors.HexColor("#EBF8FF") if s_sel else colors.white)
        c.setStrokeColor(c_accent if s_sel else c_border)
        c.roundRect(fx + 20, sy - 30, fw - 40, 26, 4, fill=1, stroke=1)
        c.setFillColor(c_blue if s_sel else c_text_dark)
        c.setFont(F_BOLD if s_sel else F_REG, 8)
        c.drawString(fx + 32, sy - 17, f"{(s_sel and '(o)' or '( )')}  {s_txt}")
        sy -= 36

    c.setFillColor(c_text_dark)
    c.setFont(F_BOLD, 9)
    c.drawString(fx + 20, fy + fh - 305, "Service Location Confirmation:")
    c.setFillColor(colors.HexColor("#F7FAFC"))
    c.setStrokeColor(c_border)
    c.roundRect(fx + 20, fy + fh - 365, fw - 40, 52, 4, fill=1, stroke=1)
    c.setFillColor(c_text_dark)
    c.setFont(F_REG, 8)
    c.drawString(fx + 28, fy + fh - 325, "Moda Cad. No: 42 D: 6, Kadıköy / Istanbul")
    c.drawString(fx + 28, fy + fh - 340, "Contact: Ata H. (+90 555 *** ** 04)")

    c.setFillColor(c_green)
    c.roundRect(fx + 20, fy + 35, fw - 40, 36, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 9.5)
    c.drawCentredString(fx + fw/2, fy + 47, "Confirm Appointment & Start Job ->")
    c.linkRect("btn_conf_app", "scr_chat_job", Rect=(fx + 20, fy + 35, fx + fw - 20, fy + 71), Border='[0 0 0]')

    c.showPage()

    # =========================================================================
    # SCREEN 7: IN-APP CHAT (SCR-07)
    # =========================================================================
    c.bookmarkPage("scr_chat_job")
    draw_top_nav("SCR-07: In-App Chat & Active Job", "Execution Journey", "scr_appointment", "scr_cust_job_progress")
    fx, fy, fw, fh = draw_mobile_frame()

    c.setFillColor(c_navy)
    c.rect(fx, fy + fh - 65, fw, 45, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 10.5)
    c.drawString(fx + 16, fy + fh - 38, "Chat: Mehmet Usta")
    c.setFont(F_REG, 8)
    c.drawString(fx + 16, fy + fh - 52, "Active Job #501 (Plumbing Repair - Kadıköy)")

    messages = [
        ("Pro", "21:42", "Good evening. I have loaded the brass valve and I am on my way.", False),
        ("Customer", "21:44", "Thank you Mehmet Usta. 3rd floor, apartment marked Atay.", True),
        ("Pro", "22:01", "I have just arrived at the building entrance.", False),
        ("Customer", "22:02", "Buzzing the door open now.", True)
    ]
    my = fy + fh - 85
    for sender, t_stamp, m_text, is_me in messages:
        bw = 200
        bx = fx + fw - bw - 20 if is_me else fx + 20
        c.setFillColor(c_accent if is_me else colors.HexColor("#EDF2F7"))
        c.roundRect(bx, my - 42, bw, 36, 6, fill=1, stroke=0)
        c.setFillColor(colors.white if is_me else c_text_dark)
        c.setFont(F_BOLD, 7)
        c.drawString(bx + 8, my - 14, f"{sender} • {t_stamp}")
        c.setFont(F_REG, 7.5)
        c.drawString(bx + 8, my - 28, m_text[:38])
        if len(m_text) > 38:
            c.drawString(bx + 8, my - 38, m_text[38:])
        my -= 52

    # Message input area
    c.setFillColor(colors.white)
    c.setStrokeColor(c_border)
    c.roundRect(fx + 16, fy + 80, fw - 32, 28, 4, fill=1, stroke=1)
    c.setFillColor(c_text_muted)
    c.setFont(F_REG, 8)
    c.drawString(fx + 24, fy + 90, "Type a secure message...")

    # Action navigation
    c.setFillColor(c_blue)
    c.roundRect(fx + 16, fy + 35, fw - 32, 34, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 9.5)
    c.drawCentredString(fx + fw/2, fy + 46, "Track Job Progress & Status ->")
    c.linkRect("btn_goto_progress", "scr_cust_job_progress", Rect=(fx + 16, fy + 35, fx + fw - 16, fy + 69), Border='[0 0 0]')

    c.showPage()

    # =========================================================================
    # SCREEN 8: CUSTOMER JOB PROGRESS (SCR-08)
    # (Role-separated: ONLY Customer actions shown)
    # =========================================================================
    c.bookmarkPage("scr_cust_job_progress")
    draw_top_nav("SCR-08: Customer Job Tracking", "Customer Journey", "scr_chat_job", "scr_complete_confirm")
    fx, fy, fw, fh = draw_mobile_frame()

    c.setFillColor(c_navy)
    c.rect(fx, fy + fh - 65, fw, 45, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 11)
    c.drawString(fx + 16, fy + fh - 43, "Customer Job Tracking #501")

    # Banner showing status
    c.setFillColor(colors.HexColor("#EBF8FF"))
    c.roundRect(fx + 16, fy + fh - 100, fw - 32, 28, 4, fill=1, stroke=0)
    c.setFillColor(c_accent)
    c.setFont(F_BOLD, 8.5)
    c.drawString(fx + 24, fy + fh - 88, "Status: Professional Reported Work Finished")

    steps_cust = [
        ("1. Offer Accepted", "14 Oct 21:30 - Agreed: 1.250 TL", True),
        ("2. Arrival & Started", "14 Oct 22:05 - On site at Moda", True),
        ("3. Pipe Replaced", "14 Oct 22:40 - Brass valve installed", True),
        ("4. Work Finished by Pro", "Awaiting your inspection & sign-off", True),
        ("5. Completed", "Pending customer inspection & sign-off", False)
    ]
    sy = fy + fh - 120
    for s_name, s_time, s_done in steps_cust:
        c.setFillColor(c_green if s_done else colors.HexColor("#CBD5E0"))
        c.circle(fx + 30, sy - 8, 7, fill=1, stroke=0)
        c.setFillColor(c_text_dark if s_done else c_text_muted)
        c.setFont(F_BOLD, 8.5)
        c.drawString(fx + 48, sy - 5, s_name)
        c.setFont(F_REG, 7.5)
        c.drawString(fx + 48, sy - 17, s_time)
        sy -= 38

    # Customer-Only Permitted Actions
    c.setFillColor(c_green)
    c.roundRect(fx + 20, fy + fh - 350, fw - 40, 36, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 9.5)
    c.drawCentredString(fx + fw/2, fy + fh - 338, "Confirm Job Completion ->")
    c.linkRect("btn_cust_confirm", "scr_complete_confirm", Rect=(fx + 20, fy + fh - 350, fx + fw - 20, fy + fh - 314), Border='[0 0 0]')

    c.setFillColor(c_accent)
    c.roundRect(fx + 20, fy + fh - 395, fw - 40, 32, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 9)
    c.drawCentredString(fx + fw/2, fy + fh - 384, "Open Chat with Mehmet Usta")
    c.linkRect("btn_chat_cust", "scr_chat_job", Rect=(fx + 20, fy + fh - 395, fx + fw - 20, fy + fh - 363), Border='[0 0 0]')

    c.setFillColor(c_amber)
    c.roundRect(fx + 20, fy + fh - 435, fw - 40, 30, 4, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 8.5)
    c.drawCentredString(fx + fw/2, fy + fh - 425, "Report Issue / File Complaint")
    c.linkRect("btn_rep_issue", "scr_cust_complaint", Rect=(fx + 20, fy + fh - 435, fx + fw - 20, fy + fh - 405), Border='[0 0 0]')

    # Cancellation Rule Note (BR08: direct cancel allowed only before work starts)
    c.setFillColor(c_text_muted)
    c.setFont(F_REG, 7.5)
    c.drawCentredString(fx + fw/2, fy + fh - 475, "Direct cancellation is permitted only before work starts.")
    c.drawCentredString(fx + fw/2, fy + fh - 488, "For issues with completed work, file a complaint above.")

    c.showPage()

    # =========================================================================
    # SCREEN 9: CANCELLATION CONFIRMATION DIALOG (SCR-09)
    # (Addresses Usability NFR: explicit confirmation before cancelling)
    # =========================================================================
    c.bookmarkPage("scr_cancel_confirm")
    draw_top_nav("SCR-09: Cancellation Confirmation", "Customer / Pro Common", "scr_cust_job_progress", "scr_complete_confirm")
    fx, fy, fw, fh = draw_mobile_frame()

    c.setFillColor(c_navy)
    c.rect(fx, fy + fh - 65, fw, 45, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 11)
    c.drawString(fx + 16, fy + fh - 43, "Cancel Job Confirmation")

    # Modal card simulation
    c.setFillColor(colors.HexColor("#FFF5F5"))
    c.setStrokeColor(colors.HexColor("#FEB2B2"))
    c.roundRect(fx + 16, fy + fh - 145, fw - 32, 70, 6, fill=1, stroke=1)
    
    c.setFillColor(c_red)
    c.setFont(F_BOLD, 10.5)
    c.drawString(fx + 26, fy + fh - 95, "Are you sure you want to cancel Job #501?")
    c.setFillColor(c_text_dark)
    c.setFont(F_REG, 8)
    c.drawString(fx + 26, fy + fh - 112, "Direct cancellation is permitted before work starts.")
    c.drawString(fx + 26, fy + fh - 125, "The assigned specialist will be notified immediately.")

    c.setFont(F_BOLD, 9)
    c.drawString(fx + 20, fy + fh - 165, "Please Select Cancellation Reason:")
    
    reasons = [
        ("(o) Scheduling conflict / Changed plans", True),
        ("( ) Problem resolved independently", False),
        ("( ) Specialist failed to show up / Unresponsive", False),
        ("( ) Emergency / Unforeseen circumstances", False)
    ]
    ry = fy + fh - 185
    for r_txt, r_sel in reasons:
        c.setFillColor(c_text_dark if r_sel else c_text_muted)
        c.setFont(F_BOLD if r_sel else F_REG, 8)
        c.drawString(fx + 26, ry, r_txt)
        ry -= 24

    c.setFont(F_BOLD, 8.5)
    c.drawString(fx + 20, fy + fh - 280, "Additional Notes (Optional):")
    c.setFillColor(colors.white)
    c.setStrokeColor(c_border)
    c.roundRect(fx + 20, fy + fh - 340, fw - 40, 50, 4, fill=1, stroke=1)
    c.setFillColor(c_text_muted)
    c.setFont(F_REG, 8)
    c.drawString(fx + 28, fy + fh - 305, "Provide context for dispute records...")

    # Confirmation Actions
    c.setFillColor(c_red)
    c.roundRect(fx + 20, fy + fh - 400, fw - 40, 36, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 9.5)
    c.drawCentredString(fx + fw/2, fy + fh - 388, "Confirm Job Cancellation")
    c.linkRect("btn_do_cancel", "scr_cust_req", Rect=(fx + 20, fy + fh - 400, fx + fw - 20, fy + fh - 364), Border='[0 0 0]')

    c.setFillColor(colors.HexColor("#EDF2F7"))
    c.roundRect(fx + 20, fy + fh - 445, fw - 40, 32, 6, fill=1, stroke=0)
    c.setFillColor(c_text_dark)
    c.setFont(F_BOLD, 9)
    c.drawCentredString(fx + fw/2, fy + fh - 434, "<- No, Keep Job Active")
    c.linkRect("btn_keep_job", "scr_cust_job_progress", Rect=(fx + 20, fy + fh - 445, fx + fw - 20, fy + fh - 413), Border='[0 0 0]')

    c.showPage()

    # =========================================================================
    # SCREEN 10: COMPLETION CONFIRMATION (SCR-10)
    # (Addresses Usability NFR: confirmation dialog before completing)
    # =========================================================================
    c.bookmarkPage("scr_complete_confirm")
    draw_top_nav("SCR-10: Completion Confirmation", "Customer Journey", "scr_cust_job_progress", "scr_review_rating")
    fx, fy, fw, fh = draw_mobile_frame()

    c.setFillColor(c_navy)
    c.rect(fx, fy + fh - 65, fw, 45, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 11)
    c.drawString(fx + 16, fy + fh - 43, "Confirm Job Completion")

    c.setFillColor(c_text_dark)
    c.setFont(F_BOLD, 11)
    c.drawString(fx + 20, fy + fh - 95, "Has the work been completed?")
    c.setFont(F_REG, 8.5)
    c.setFillColor(c_text_muted)
    c.drawString(fx + 20, fy + fh - 110, "Please inspect the repaired sink and leak before signing off.")

    c.setFillColor(colors.HexColor("#F7FAFC"))
    c.setStrokeColor(c_border)
    c.roundRect(fx + 20, fy + fh - 215, fw - 40, 95, 6, fill=1, stroke=1)
    c.setFillColor(c_text_dark)
    c.setFont(F_BOLD, 9)
    c.drawString(fx + 30, fy + fh - 135, "Job #501 Summary:")
    c.setFont(F_REG, 8)
    c.drawString(fx + 30, fy + fh - 150, "Technician: Mehmet Usta (Kadıköy Tesisat)")
    c.drawString(fx + 30, fy + fh - 165, "Agreed Price: 1.250 TL (Labor 850 TL + Materials 400 TL)")
    c.drawString(fx + 30, fy + fh - 180, "Service: Pipe burst fix & replacement brass valve")
    c.drawString(fx + 30, fy + fh - 195, "Status: Marked Finished by Technician at 22:40")

    c.setFillColor(c_green)
    c.roundRect(fx + 20, fy + fh - 275, fw - 40, 38, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 9.5)
    c.drawCentredString(fx + fw/2, fy + fh - 262, "Yes, Confirm Work & Rate Specialist ->")
    c.linkRect("btn_confirm_done", "scr_review_rating", Rect=(fx + 20, fy + fh - 275, fx + fw - 20, fy + fh - 237), Border='[0 0 0]')

    c.setFillColor(c_amber)
    c.roundRect(fx + 20, fy + fh - 325, fw - 40, 32, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 8.5)
    c.drawCentredString(fx + fw/2, fy + fh - 314, "Problem Found / File Complaint")
    c.linkRect("btn_file_comp", "scr_cust_complaint", Rect=(fx + 20, fy + fh - 325, fx + fw - 20, fy + fh - 293), Border='[0 0 0]')

    c.showPage()

    # =========================================================================
    # SCREEN 11: REVIEW & RATING (SCR-11)
    # =========================================================================
    c.bookmarkPage("scr_review_rating")
    draw_top_nav("SCR-11: Review & Rating Submission", "Customer Journey", "scr_complete_confirm", "scr_cust_complaint")
    fx, fy, fw, fh = draw_mobile_frame()

    c.setFillColor(c_navy)
    c.rect(fx, fy + fh - 65, fw, 45, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 11)
    c.drawString(fx + 16, fy + fh - 43, "Rate & Review Service")

    c.setFillColor(c_text_dark)
    c.setFont(F_BOLD, 10.5)
    c.drawString(fx + 20, fy + fh - 95, "How was your experience with Mehmet Usta?")

    c.setFillColor(colors.HexColor("#D69E2E"))
    c.setFont(F_BOLD, 18)
    c.drawCentredString(fx + fw/2, fy + fh - 130, "★  ★  ★  ★  ★")
    c.setFillColor(c_text_muted)
    c.setFont(F_REG, 8.5)
    c.drawCentredString(fx + fw/2, fy + fh - 148, "5.0 out of 5 Stars (Excellent)")

    c.setFillColor(c_text_dark)
    c.setFont(F_BOLD, 9)
    c.drawString(fx + 20, fy + fh - 175, "Detailed Feedback Comments:")
    c.setFillColor(colors.white)
    c.setStrokeColor(c_border)
    c.roundRect(fx + 20, fy + fh - 265, fw - 40, 80, 4, fill=1, stroke=1)
    c.setFillColor(c_text_dark)
    c.setFont(F_REG, 8)
    c.drawString(fx + 28, fy + fh - 200, "Arrived right on time for an urgent night repair.")
    c.drawString(fx + 28, fy + fh - 215, "Replaced valve cleanly and tested pressure thoroughly.")
    c.drawString(fx + 28, fy + fh - 230, "Very polite and transparent pricing. Highly recommended!")

    c.setFillColor(c_green)
    c.roundRect(fx + 20, fy + fh - 325, fw - 40, 38, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 10)
    c.drawCentredString(fx + fw/2, fy + fh - 312, "Submit Verified Review ->")
    c.linkRect("btn_sub_rev", "map_hub", Rect=(fx + 20, fy + fh - 325, fx + fw - 20, fy + fh - 287), Border='[0 0 0]')

    c.showPage()

    # =========================================================================
    # SCREEN 12: CUSTOMER COMPLAINT FILING (SCR-12)
    # =========================================================================
    c.bookmarkPage("scr_cust_complaint")
    draw_top_nav("SCR-12: Customer Complaint Filing", "Customer Support", "scr_cust_job_progress", "scr_cust_complaint_success")
    fx, fy, fw, fh = draw_mobile_frame()

    c.setFillColor(c_navy)
    c.rect(fx, fy + fh - 65, fw, 45, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 11)
    c.drawString(fx + 16, fy + fh - 43, "File Customer Complaint")

    c.setFillColor(c_text_dark)
    c.setFont(F_BOLD, 10)
    c.drawString(fx + 20, fy + fh - 95, "Alternative Scenario: File Complaint for Job #504:")

    c.setFont(F_BOLD, 8.5)
    c.drawString(fx + 20, fy + fh - 125, "Select Reason:")
    c.setFillColor(colors.white)
    c.setStrokeColor(c_border)
    c.roundRect(fx + 20, fy + fh - 155, fw - 40, 26, 4, fill=1, stroke=1)
    c.setFillColor(c_text_dark)
    c.setFont(F_REG, 8.5)
    c.drawString(fx + 28, fy + fh - 146, "Professional did not arrive at appointment")

    c.setFont(F_BOLD, 8.5)
    c.drawString(fx + 20, fy + fh - 175, "Describe Situation:")
    c.setFillColor(colors.white)
    c.setStrokeColor(c_border)
    c.roundRect(fx + 20, fy + fh - 255, fw - 40, 70, 4, fill=1, stroke=1)
    c.setFillColor(c_text_dark)
    c.setFont(F_REG, 8)
    c.drawString(fx + 28, fy + fh - 195, "We agreed on 14:00 arrival.")
    c.drawString(fx + 28, fy + fh - 210, "Professional has not answered chat for 2 hours.")

    # Fixed Link: Submitting complaint leads to Customer Confirmation screen, NOT Admin console!
    c.setFillColor(c_amber)
    c.roundRect(fx + 20, fy + fh - 310, fw - 40, 36, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 10)
    c.drawCentredString(fx + fw/2, fy + fh - 298, "Submit to Support Team ->")
    c.linkRect("btn_sub_comp", "scr_cust_complaint_success", Rect=(fx + 20, fy + fh - 310, fx + fw - 20, fy + fh - 274), Border='[0 0 0]')

    c.showPage()

    # =========================================================================
    # SCREEN 13: CUSTOMER COMPLAINT SUCCESS (SCR-13)
    # (Role-appropriate post-submission screen for customer)
    # =========================================================================
    c.bookmarkPage("scr_cust_complaint_success")
    draw_top_nav("SCR-13: Complaint Submitted Status", "Customer Support", "scr_cust_complaint", "scr_pro_feed")
    fx, fy, fw, fh = draw_mobile_frame()

    c.setFillColor(c_navy)
    c.rect(fx, fy + fh - 65, fw, 45, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 11)
    c.drawString(fx + 16, fy + fh - 43, "Dispute Filed Successfully")

    c.setFillColor(colors.HexColor("#FEFCBF"))
    c.setStrokeColor(colors.HexColor("#ECC94B"))
    c.roundRect(fx + 16, fy + fh - 150, fw - 32, 75, 6, fill=1, stroke=1)
    
    c.setFillColor(colors.HexColor("#744210"))
    c.setFont(F_BOLD, 10.5)
    c.drawString(fx + 26, fy + fh - 95, "Case #CMP-104 Created (Job #504)")
    c.setFont(F_REG, 8)
    c.drawString(fx + 26, fy + fh - 112, "Your dispute report regarding Job #504 has been logged.")
    c.drawString(fx + 26, fy + fh - 126, "Our platform moderation team will review case records and chat history.")
    c.drawString(fx + 26, fy + fh - 140, "Both parties' chat and appointment logs are preserved.")

    c.setFillColor(c_text_dark)
    c.setFont(F_BOLD, 9)
    c.drawString(fx + 20, fy + fh - 175, "What Happens Next:")
    
    info_points = [
        "1. Administrator checks arrival timestamps & chat trail.",
        "2. Professional is prompted to provide status explanation.",
        "3. Job state is held in dispute; no penalties if justified.",
        "4. You will receive in-app notification upon resolution."
    ]
    py = fy + fh - 195
    for pt in info_points:
        c.setFillColor(c_text_dark)
        c.setFont(F_REG, 8)
        c.drawString(fx + 24, py, pt)
        py -= 18

    c.setFillColor(c_accent)
    c.roundRect(fx + 20, fy + fh - 310, fw - 40, 36, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 9.5)
    c.drawCentredString(fx + fw/2, fy + fh - 298, "<- Back to Job Tracking")
    c.linkRect("btn_ret_job", "scr_cust_job_progress", Rect=(fx + 20, fy + fh - 310, fx + fw - 20, fy + fh - 274), Border='[0 0 0]')

    c.setFillColor(colors.HexColor("#EDF2F7"))
    c.roundRect(fx + 20, fy + fh - 360, fw - 40, 32, 6, fill=1, stroke=0)
    c.setFillColor(c_text_dark)
    c.setFont(F_BOLD, 8.5)
    c.drawCentredString(fx + fw/2, fy + fh - 349, "Return to Main Menu")
    c.linkRect("btn_ret_menu", "map_hub", Rect=(fx + 20, fy + fh - 360, fx + fw - 20, fy + fh - 328), Border='[0 0 0]')

    c.showPage()

    # =========================================================================
    # SCREEN 14: PRO FEED (SCR-14)
    # =========================================================================
    c.bookmarkPage("scr_pro_feed")
    draw_top_nav("SCR-14: Pro Feed & Opportunities", "Professional Journey", "scr_login", "scr_pro_make_offer")
    fx, fy, fw, fh = draw_mobile_frame()

    c.setFillColor(c_navy)
    c.rect(fx, fy + fh - 65, fw, 45, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 11)
    c.drawString(fx + 16, fy + fh - 43, "Matched Requests (Pro Feed)")
    c.setFont(F_BOLD, 8.5)
    c.drawRightString(fx + fw - 16, fy + fh - 43, "[Status: Active]")

    # Filter Bar
    c.setFillColor(colors.HexColor("#EDF2F7"))
    c.roundRect(fx + 16, fy + fh - 100, fw - 32, 26, 4, fill=1, stroke=0)
    c.setFillColor(c_accent)
    c.setFont(F_BOLD, 8)
    c.drawString(fx + 24, fy + fh - 92, "Filters: [Plumbing] [Kadıköy, Üsküdar] [Urgent]")

    c.setFillColor(colors.white)
    c.setStrokeColor(colors.HexColor("#FEB2B2"))
    c.roundRect(fx + 16, fy + fh - 230, fw - 32, 120, 6, fill=1, stroke=1)
    
    c.setFillColor(c_red)
    c.setFont(F_BOLD, 8)
    c.drawString(fx + 26, fy + fh - 120, "[URGENT] Pipe burst under bathroom sink")
    
    c.setFillColor(c_text_dark)
    c.setFont(F_BOLD, 9)
    c.drawString(fx + 26, fy + fh - 135, "Location: Kadıköy, Moda (~1.2 km away)")
    
    c.setFillColor(c_text_muted)
    c.setFont(F_REG, 7.5)
    c.drawString(fx + 26, fy + fh - 150, "Customer: Ata H. | Needed: Tonight ASAP")
    c.drawString(fx + 26, fy + fh - 164, "Photos: 2 Attached (Brass connection burst)")

    c.setFillColor(c_green)
    c.roundRect(fx + 26, fy + fh - 215, fw - 52, 28, 4, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 8.5)
    c.drawCentredString(fx + fw/2, fy + fh - 206, "Prepare Structured Offer ->")
    c.linkRect("btn_feed_offer", "scr_pro_make_offer", Rect=(fx + 26, fy + fh - 215, fx + fw - 26, fy + fh - 187), Border='[0 0 0]')

    # Pro Navigation links
    c.setFillColor(c_blue)
    c.roundRect(fx + 16, fy + fh - 280, fw - 32, 32, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 8.5)
    c.drawCentredString(fx + fw/2, fy + fh - 269, "Manage Profile & Availability ->")
    c.linkRect("btn_goto_prof_edit", "scr_pro_profile_edit", Rect=(fx + 16, fy + fh - 280, fx + fw - 16, fy + fh - 248), Border='[0 0 0]')

    c.setFillColor(c_accent)
    c.roundRect(fx + 16, fy + fh - 325, fw - 32, 32, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 8.5)
    c.drawCentredString(fx + fw/2, fy + fh - 314, "View Active Job Execution (#501) ->")
    c.linkRect("btn_goto_pro_exec", "scr_pro_job_progress", Rect=(fx + 16, fy + fh - 325, fx + fw - 16, fy + fh - 293), Border='[0 0 0]')

    c.showPage()

    # =========================================================================
    # SCREEN 15: PRO OFFER BUILDER (SCR-15)
    # =========================================================================
    c.bookmarkPage("scr_pro_make_offer")
    draw_top_nav("SCR-15: Structured Offer Builder", "Professional Journey", "scr_pro_feed", "scr_pro_offer_success")
    fx, fy, fw, fh = draw_mobile_frame()

    c.setFillColor(c_navy)
    c.rect(fx, fy + fh - 65, fw, 45, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 11)
    c.drawString(fx + 16, fy + fh - 43, "Build Structured Offer")

    c.setFillColor(c_text_dark)
    c.setFont(F_BOLD, 8.5)
    c.drawString(fx + 20, fy + fh - 85, "Target Request: #501 (Kadıköy Plumbing Repair)")

    c.setFont(F_BOLD, 8.5)
    c.drawString(fx + 20, fy + fh - 115, "1. Itemized Labor Fee (TL):")
    c.setFillColor(colors.white)
    c.setStrokeColor(c_border)
    c.roundRect(fx + 20, fy + fh - 143, fw - 40, 24, 4, fill=1, stroke=1)
    c.setFillColor(c_text_dark)
    c.setFont(F_REG, 9)
    c.drawString(fx + 30, fy + fh - 135, "850 TL")

    c.setFont(F_BOLD, 8.5)
    c.drawString(fx + 20, fy + fh - 175, "2. Estimated Materials Fee (TL):")
    c.setFillColor(colors.white)
    c.roundRect(fx + 20, fy + fh - 203, fw - 40, 24, 4, fill=1, stroke=1)
    c.setFillColor(c_text_dark)
    c.drawString(fx + 30, fy + fh - 195, "400 TL (Brass replacement valve)")

    c.setFont(F_BOLD, 8.5)
    c.drawString(fx + 20, fy + fh - 235, "3. Earliest Arrival Commitment:")
    c.setFillColor(colors.white)
    c.roundRect(fx + 20, fy + fh - 263, fw - 40, 24, 4, fill=1, stroke=1)
    c.setFillColor(c_text_dark)
    c.drawString(fx + 30, fy + fh - 255, "Today, 14 October at 22:00")

    c.setFont(F_BOLD, 8.5)
    c.drawString(fx + 20, fy + fh - 295, "4. Scope Clarifications / Work Plan:")
    c.setFillColor(colors.white)
    c.roundRect(fx + 20, fy + fh - 355, fw - 40, 50, 4, fill=1, stroke=1)
    c.setFillColor(c_text_dark)
    c.setFont(F_REG, 8)
    c.drawString(fx + 30, fy + fh - 320, "Will replace damaged valve, fit seal, and conduct pressure test.")

    # Fixed Link: Submitting offer leads to Pro Offer Success screen, NOT Customer offer comparison!
    c.setFillColor(c_green)
    c.roundRect(fx + 20, fy + fh - 405, fw - 40, 36, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 10)
    c.drawCentredString(fx + fw/2, fy + fh - 393, "Send Structured Offer (Proposed Total: 1.250 TL) ->")
    c.linkRect("btn_send_bid", "scr_pro_offer_success", Rect=(fx + 20, fy + fh - 405, fx + fw - 20, fy + fh - 369), Border='[0 0 0]')

    c.showPage()

    # =========================================================================
    # SCREEN 16: PRO OFFER SUBMITTED CONFIRMATION (SCR-16)
    # (Role-appropriate post-submission screen for professional)
    # =========================================================================
    c.bookmarkPage("scr_pro_offer_success")
    draw_top_nav("SCR-16: Pro Offer Submitted Status", "Professional Journey", "scr_pro_make_offer", "scr_pro_profile_edit")
    fx, fy, fw, fh = draw_mobile_frame()

    c.setFillColor(c_navy)
    c.rect(fx, fy + fh - 65, fw, 45, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 11)
    c.drawString(fx + 16, fy + fh - 43, "Offer Sent Successfully")

    c.setFillColor(colors.HexColor("#C6F6D5"))
    c.setStrokeColor(colors.HexColor("#38A169"))
    c.roundRect(fx + 16, fy + fh - 150, fw - 32, 75, 6, fill=1, stroke=1)
    
    c.setFillColor(colors.HexColor("#22543D"))
    c.setFont(F_BOLD, 10.5)
    c.drawString(fx + 26, fy + fh - 95, "Offer #OFF-882 Delivered to Customer")
    c.setFont(F_REG, 8)
    c.drawString(fx + 26, fy + fh - 112, "Your 1.250 TL proposal has been sent to Ata H. (Kadıköy).")
    c.drawString(fx + 26, fy + fh - 126, "Offer valid until arrival window (22:00). Rechecked on acceptance.")
    c.drawString(fx + 26, fy + fh - 140, "You will be alerted instantly when the customer accepts.")

    c.setFillColor(c_text_dark)
    c.setFont(F_BOLD, 9)
    c.drawString(fx + 20, fy + fh - 175, "Active Bid Summary:")
    
    pro_bid_info = [
        ("Trade Request", "#501 - Urgent Bathroom Pipe Repair"),
        ("Itemized Labor", "850 TL"),
        ("Estimated Materials", "400 TL (Brass valve)"),
        ("Customer Location", "Kadıköy, Moda (~1.2 km away)"),
        ("Status", "Awaiting Customer Acceptance")
    ]
    by = fy + fh - 195
    for lbl, val in pro_bid_info:
        c.setFillColor(c_text_muted)
        c.setFont(F_REG, 8)
        c.drawString(fx + 24, by, f"{lbl}:")
        c.setFillColor(c_text_dark)
        c.setFont(F_BOLD, 8)
        c.drawString(fx + 130, by, val)
        by -= 18

    c.setFillColor(c_green)
    c.roundRect(fx + 20, fy + fh - 320, fw - 40, 36, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 9.5)
    c.drawCentredString(fx + fw/2, fy + fh - 308, "Return to Matched Requests Feed ->")
    c.linkRect("btn_ret_feed", "scr_pro_feed", Rect=(fx + 20, fy + fh - 320, fx + fw - 20, fy + fh - 284), Border='[0 0 0]')

    c.setFillColor(c_accent)
    c.roundRect(fx + 20, fy + fh - 370, fw - 40, 32, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 8.5)
    c.drawCentredString(fx + fw/2, fy + fh - 359, "Manage Profile & Availability")
    c.linkRect("btn_goto_prof_from_bid", "scr_pro_profile_edit", Rect=(fx + 20, fy + fh - 370, fx + fw - 20, fy + fh - 338), Border='[0 0 0]')

    c.showPage()

    # =========================================================================
    # SCREEN 17: PRO PROFILE & AVAILABILITY EDITING (SCR-17)
    # (Missing management screen requested by user)
    # =========================================================================
    c.bookmarkPage("scr_pro_profile_edit")
    draw_top_nav("SCR-17: Profile & Availability Config", "Professional Journey", "scr_pro_offer_success", "scr_pro_job_progress")
    fx, fy, fw, fh = draw_mobile_frame()

    c.setFillColor(c_navy)
    c.rect(fx, fy + fh - 65, fw, 45, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 11)
    c.drawString(fx + 16, fy + fh - 43, "Edit Profile & Availability")

    # Availability toggle
    c.setFillColor(colors.HexColor("#EBF8FF"))
    c.roundRect(fx + 16, fy + fh - 105, fw - 32, 32, 6, fill=1, stroke=0)
    c.setFillColor(c_green)
    c.roundRect(fx + 20, fy + fh - 101, (fw - 40)/2, 24, 4, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 8)
    c.drawCentredString(fx + 20 + (fw - 40)/4, fy + fh - 92, "(o) Active / Ready")
    
    c.setFillColor(c_text_muted)
    c.setFont(F_REG, 8)
    c.drawCentredString(fx + 20 + 3*(fw - 40)/4, fy + fh - 92, "( ) Busy / On Break")

    c.setFillColor(c_text_dark)
    c.setFont(F_BOLD, 8.5)
    c.drawString(fx + 16, fy + fh - 128, "1. Trade Skills & Categories:")
    c.setFont(F_REG, 8)
    c.drawString(fx + 24, fy + fh - 144, "[x] Plumbing Repair   [x] Drain Cleaning   [ ] Electrical")

    c.setFont(F_BOLD, 8.5)
    c.drawString(fx + 16, fy + fh - 170, "2. Service Coverage Districts (Istanbul):")
    c.setFillColor(colors.white)
    c.setStrokeColor(c_border)
    c.roundRect(fx + 16, fy + fh - 198, fw - 32, 24, 4, fill=1, stroke=1)
    c.setFillColor(c_text_dark)
    c.setFont(F_REG, 8)
    c.drawString(fx + 24, fy + fh - 190, "Kadıköy, Üsküdar, Ataşehir (+ Add District)")

    c.setFont(F_BOLD, 8.5)
    c.drawString(fx + 16, fy + fh - 222, "3. Working Hours & Emergency Availability:")
    c.setFillColor(colors.white)
    c.roundRect(fx + 16, fy + fh - 250, fw - 32, 24, 4, fill=1, stroke=1)
    c.setFillColor(c_text_dark)
    c.setFont(F_REG, 8)
    c.drawString(fx + 24, fy + fh - 242, "Mon - Sat: 08:30 - 23:00 (Emergency calls enabled)")

    c.setFont(F_BOLD, 8.5)
    c.drawString(fx + 16, fy + fh - 275, "4. Professional Bio & Experience Summary:")
    c.setFillColor(colors.white)
    c.roundRect(fx + 16, fy + fh - 340, fw - 32, 58, 4, fill=1, stroke=1)
    c.setFillColor(c_text_dark)
    c.setFont(F_REG, 7.5)
    c.drawString(fx + 24, fy + fh - 298, "12 years residential plumbing and valve maintenance.")
    c.drawString(fx + 24, fy + fh - 312, "Equipped with pipe camera and electric snake tools.")
    c.drawString(fx + 24, fy + fh - 326, "Serving Kadıköy and Anatolian side residential areas.")

    c.setFillColor(c_green)
    c.roundRect(fx + 16, fy + fh - 395, fw - 32, 36, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 9.5)
    c.drawCentredString(fx + fw/2, fy + fh - 383, "Save Profile & Update Availability ->")
    c.linkRect("btn_save_pro_prof", "scr_pro_feed", Rect=(fx + 16, fy + fh - 395, fx + fw - 16, fy + fh - 359), Border='[0 0 0]')

    c.showPage()

    # =========================================================================
    # SCREEN 18: PRO JOB EXECUTION (SCR-18)
    # (Role-separated: ONLY Professional actions shown)
    # =========================================================================
    c.bookmarkPage("scr_pro_job_progress")
    draw_top_nav("SCR-18: Pro Job Execution & Milestones", "Professional Journey", "scr_pro_profile_edit", "scr_admin_verif")
    fx, fy, fw, fh = draw_mobile_frame()

    c.setFillColor(c_navy)
    c.rect(fx, fy + fh - 65, fw, 45, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 11)
    c.drawString(fx + 16, fy + fh - 43, "Job Execution #501 (Pro Mode)")

    c.setFillColor(colors.HexColor("#EBF8FF"))
    c.roundRect(fx + 16, fy + fh - 100, fw - 32, 28, 4, fill=1, stroke=0)
    c.setFillColor(c_accent)
    c.setFont(F_BOLD, 8.5)
    c.drawString(fx + 24, fy + fh - 88, "Current Status: Work In-Progress on site")

    steps_pro = [
        ("1. Offer Accepted", "Customer accepted proposed total 1.250 TL", True),
        ("2. Arrival Checked In", "Checked in at Moda address 22:05", True),
        ("3. Repair in Progress", "Damaged brass valve replaced", True),
        ("4. Mark Work Finished", "Submit sign-off request to customer", False),
        ("5. Completed", "Awaiting customer inspection & sign-off", False)
    ]
    sy = fy + fh - 120
    for s_name, s_time, s_done in steps_pro:
        c.setFillColor(c_green if s_done else colors.HexColor("#CBD5E0"))
        c.circle(fx + 30, sy - 8, 7, fill=1, stroke=0)
        c.setFillColor(c_text_dark if s_done else c_text_muted)
        c.setFont(F_BOLD, 8.5)
        c.drawString(fx + 48, sy - 5, s_name)
        c.setFont(F_REG, 7.5)
        c.drawString(fx + 48, sy - 17, s_time)
        sy -= 38

    # Professional-Only Permitted Actions
    c.setFillColor(c_green)
    c.roundRect(fx + 20, fy + fh - 350, fw - 40, 36, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 9.5)
    c.drawCentredString(fx + fw/2, fy + fh - 338, "Mark Work Finished (Notify Client) ->")
    c.linkRect("btn_pro_mark_done", "scr_pro_feed", Rect=(fx + 20, fy + fh - 350, fx + fw - 20, fy + fh - 314), Border='[0 0 0]')

    c.setFillColor(c_accent)
    c.roundRect(fx + 20, fy + fh - 395, fw - 40, 32, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 9)
    c.drawCentredString(fx + fw/2, fy + fh - 384, "Open Chat with Customer (Ata H.)")
    c.linkRect("btn_chat_pro", "scr_chat_job", Rect=(fx + 20, fy + fh - 395, fx + fw - 20, fy + fh - 363), Border='[0 0 0]')

    # In-progress cancellation rule (BR08: requires complaint review)
    c.setFillColor(c_amber)
    c.setFont(F_REG, 8.5)
    c.drawCentredString(fx + fw/2, fy + fh - 445, "Report On-Site Dispute / Issue")
    c.linkRect("btn_pro_dispute", "scr_cust_complaint", Rect=(fx + 30, fy + fh - 455, fx + fw - 30, fy + fh - 435), Border='[0 0 0]')

    c.showPage()

    # =========================================================================
    # SCREEN 19: ADMIN PROFILE REVIEW (SCR-19)
    # (Cleaned: Basic profile review, NO MERNIS claims, Approve/Reject)
    # =========================================================================
    c.bookmarkPage("scr_admin_verif")
    draw_top_nav("SCR-19: Admin Profile Review", "Administrator Web Portal", "scr_pro_job_progress", "scr_admin_disputes")

    dw_x, dw_y, dw_w, dw_h = 45, 45, PAGE_WIDTH - 90, 630
    c.setFillColor(colors.white)
    c.setStrokeColor(c_border)
    c.roundRect(dw_x, dw_y, dw_w, dw_h, 8, fill=1, stroke=1)

    c.setFillColor(c_navy)
    c.roundRect(dw_x, dw_y + dw_h - 45, dw_w, 45, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 11.5)
    c.drawString(dw_x + 20, dw_y + dw_h - 28, "BiTadilat Admin Panel  |  Professional Profile Review")

    # Portal Tab Bar
    c.setFont(F_REG, 8.5)
    c.drawString(dw_x + dw_w - 280, dw_y + dw_h - 28, "[Profile Reviews]   [Disputes]   [Accounts]")
    c.linkRect("adm_tab_disp", "scr_admin_disputes", Rect=(dw_x + dw_w - 190, dw_y + dw_h - 32, dw_x + dw_w - 130, dw_y + dw_h - 20), Border='[0 0 0]')
    c.linkRect("adm_tab_acc", "scr_admin_accounts", Rect=(dw_x + dw_w - 125, dw_y + dw_h - 32, dw_x + dw_w - 60, dw_y + dw_h - 20), Border='[0 0 0]')

    c.setFillColor(colors.HexColor("#F7FAFC"))
    c.roundRect(dw_x + 25, dw_y + dw_h - 230, dw_w - 50, 170, 6, fill=1, stroke=0)

    c.setFillColor(c_navy)
    c.setFont(F_BOLD, 10.5)
    c.drawString(dw_x + 40, dw_y + dw_h - 75, "Applicant Information (Pending Review)")

    fields = [
        ("Applicant Name:", "Mehmet Demir (Mehmet Usta)"),
        ("Trade Category:", "Plumbing & Heating Maintenance"),
        ("Declared Service Areas:", "Istanbul (Kadıköy, Üsküdar, Ataşehir)"),
        ("Experience Summary:", "12 years residential plumbing experience"),
        ("Submitted Document Sample:", "plumbing_trade_certificate_sample.jpg (Visual Reference)"),
        ("Verification Status:", "Awaiting Administrator Manual Profile Inspection")
    ]
    fy_pos = dw_y + dw_h - 98
    for lbl, val in fields:
        c.setFillColor(c_text_dark)
        c.setFont(F_BOLD, 8.5)
        c.drawString(dw_x + 40, fy_pos, lbl)
        c.setFont(F_REG, 8.5)
        c.drawString(dw_x + 220, fy_pos, val)
        fy_pos -= 20

    # Document Inspection Area
    c.setFillColor(colors.white)
    c.setStrokeColor(c_border)
    c.roundRect(dw_x + 25, dw_y + 110, dw_w - 50, 195, 6, fill=1, stroke=1)
    
    c.setFillColor(c_blue)
    c.setFont(F_BOLD, 9.5)
    c.drawString(dw_x + 40, dw_y + 280, "Document Preview & Internal Verification Checklist:")
    
    checklist = [
        "[ ] Visual check: Document photo matches applicant's declared name and trade category.",
        "[ ] Clarity check: No signs of manipulation or illegible low-resolution text.",
        "[ ] Contact confirmation: Phone number confirmed during registration.",
        "[ ] Declared districts verified within Istanbul municipal coverage boundaries."
    ]
    cy = dw_y + 255
    for item in checklist:
        c.setFillColor(c_text_dark)
        c.setFont(F_REG, 8)
        c.drawString(dw_x + 40, cy, item)
        cy -= 22

    # Action Buttons: Approve / Reject
    c.setFillColor(c_green)
    c.roundRect(dw_x + 40, dw_y + 40, 180, 36, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 10)
    c.drawCentredString(dw_x + 130, dw_y + 53, "Approve Profile ->")
    c.linkRect("btn_appr_pro", "scr_admin_disputes", Rect=(dw_x + 40, dw_y + 40, dw_x + 220, dw_y + 76), Border='[0 0 0]')

    c.setFillColor(c_red)
    c.roundRect(dw_x + 240, dw_y + 40, 180, 36, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 10)
    c.drawCentredString(dw_x + 330, dw_y + 53, "Reject Application ✕")
    c.linkRect("btn_rej_pro", "scr_admin_disputes", Rect=(dw_x + 240, dw_y + 40, dw_x + 420, dw_y + 76), Border='[0 0 0]')

    c.showPage()

    # =========================================================================
    # SCREEN 20: ADMIN DISPUTES (SCR-20)
    # =========================================================================
    c.bookmarkPage("scr_admin_disputes")
    draw_top_nav("SCR-20: Admin Dispute & Complaints", "Administrator Web Portal", "scr_admin_verif", "scr_admin_accounts")

    dw_x, dw_y, dw_w, dw_h = 45, 45, PAGE_WIDTH - 90, 630
    c.setFillColor(colors.white)
    c.setStrokeColor(c_border)
    c.roundRect(dw_x, dw_y, dw_w, dw_h, 8, fill=1, stroke=1)

    c.setFillColor(c_navy)
    c.roundRect(dw_x, dw_y + dw_h - 45, dw_w, 45, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 11.5)
    c.drawString(dw_x + 20, dw_y + dw_h - 28, "BiTadilat Admin Panel  |  Dispute & Complaint Center")

    # Portal Tab Bar
    c.setFont(F_REG, 8.5)
    c.drawString(dw_x + dw_w - 280, dw_y + dw_h - 28, "[Profile Reviews]   [Disputes]   [Accounts]")
    c.linkRect("adm_tab_prof", "scr_admin_verif", Rect=(dw_x + dw_w - 280, dw_y + dw_h - 32, dw_x + dw_w - 200, dw_y + dw_h - 20), Border='[0 0 0]')
    c.linkRect("adm_tab_acc2", "scr_admin_accounts", Rect=(dw_x + dw_w - 125, dw_y + dw_h - 32, dw_x + dw_w - 60, dw_y + dw_h - 20), Border='[0 0 0]')

    c.setFillColor(colors.HexColor("#FFF5F5"))
    c.setStrokeColor(colors.HexColor("#FEB2B2"))
    c.roundRect(dw_x + 25, dw_y + dw_h - 200, dw_w - 50, 140, 6, fill=1, stroke=1)

    c.setFillColor(c_red)
    c.setFont(F_BOLD, 10.5)
    c.drawString(dw_x + 40, dw_y + dw_h - 75, "Active Dispute Case #CMP-104  |  Job #504 (Electrical Repair - Alternative Scenario)")

    d_info = [
        ("Complainant:", "Zeynep K. (Customer)"),
        ("Respondent:", "Ali Kaya (Professional - Ali Usta)"),
        ("Reported Issue:", "Specialist failed to arrive at agreed appointment window (14:00)"),
        ("Audit Logs:", "Appointment scheduled for 14:00. Chat shows last ping at 13:40."),
        ("Status:", "Under Review by Platform Administrator")
    ]
    dy = dw_y + dw_h - 96
    for lbl, val in d_info:
        c.setFillColor(c_text_dark)
        c.setFont(F_BOLD, 8)
        c.drawString(dw_x + 40, dy, lbl)
        c.setFont(F_REG, 8)
        c.drawString(dw_x + 180, dy, val)
        dy -= 18

    # Audit Trail
    c.setFillColor(colors.HexColor("#F7FAFC"))
    c.roundRect(dw_x + 25, dw_y + 110, dw_w - 50, 195, 6, fill=1, stroke=0)
    c.setFillColor(c_blue)
    c.setFont(F_BOLD, 9.5)
    c.drawString(dw_x + 40, dw_y + 280, "Timestamped Action & Chat Audit Logs:")

    logs = [
        ("13:15:00", "Customer accepted Ali Usta's structured offer (650 TL)."),
        ("14:00:00", "Appointment arrival window reached."),
        ("14:25:00", "Customer sent in-app message: 'Any update on your arrival?'"),
        ("14:45:00", "Customer submitted Dispute Complaint #CMP-104.")
    ]
    ly = dw_y + 255
    for t_stamp, log_txt in logs:
        c.setFillColor(c_accent)
        c.setFont(F_BOLD, 7.5)
        c.drawString(dw_x + 40, ly, t_stamp)
        c.setFillColor(c_text_dark)
        c.setFont(F_REG, 7.5)
        c.drawString(dw_x + 105, ly, log_txt)
        ly -= 22

    # Administrative Resolution Actions
    actions = [
        ("Issue Formal Warning", c_amber, "adm_warn", "scr_admin_accounts"),
        ("Cancel Disputed Job", c_blue, "adm_cancel_job", "scr_admin_accounts"),
        ("Dismiss Dispute", c_text_muted, "adm_dismiss", "scr_admin_accounts")
    ]
    ax = dw_x + 40
    for a_label, a_col, a_name, a_target in actions:
        c.setFillColor(a_col)
        c.roundRect(ax, dw_y + 40, 140, 36, 6, fill=1, stroke=0)
        c.setFillColor(colors.white)
        c.setFont(F_BOLD, 8.5)
        c.drawCentredString(ax + 70, dw_y + 53, a_label)
        c.linkRect(a_name, a_target, Rect=(ax, dw_y + 40, ax + 140, dw_y + 76), Border='[0 0 0]')
        ax += 155

    c.showPage()

    # =========================================================================
    # SCREEN 21: ADMIN ACCOUNT MANAGEMENT (SCR-21)
    # (Missing management screen requested by user)
    # =========================================================================
    c.bookmarkPage("scr_admin_accounts")
    draw_top_nav("SCR-21: Admin User & Pro Accounts", "Administrator Web Portal", "scr_admin_disputes", "scr_promo_web")

    dw_x, dw_y, dw_w, dw_h = 45, 45, PAGE_WIDTH - 90, 630
    c.setFillColor(colors.white)
    c.setStrokeColor(c_border)
    c.roundRect(dw_x, dw_y, dw_w, dw_h, 8, fill=1, stroke=1)

    c.setFillColor(c_navy)
    c.roundRect(dw_x, dw_y + dw_h - 45, dw_w, 45, 6, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 11.5)
    c.drawString(dw_x + 20, dw_y + dw_h - 28, "BiTadilat Admin Panel  |  User & Professional Account Management")

    # Portal Tab Bar
    c.setFont(F_REG, 8.5)
    c.drawString(dw_x + dw_w - 280, dw_y + dw_h - 28, "[Profile Reviews]   [Disputes]   [Accounts]")
    c.linkRect("adm_tab_prof2", "scr_admin_verif", Rect=(dw_x + dw_w - 280, dw_y + dw_h - 32, dw_x + dw_w - 200, dw_y + dw_h - 20), Border='[0 0 0]')
    c.linkRect("adm_tab_disp2", "scr_admin_disputes", Rect=(dw_x + dw_w - 190, dw_y + dw_h - 32, dw_x + dw_w - 130, dw_y + dw_h - 20), Border='[0 0 0]')

    # Summary KPI Metric Cards
    kpi_cards = [
        ("Total Users", "1.420", c_navy),
        ("Active Pros", "310", c_green),
        ("Pending Reviews", "18", c_amber),
        ("Suspended", "7", c_red)
    ]
    kx = dw_x + 25
    for k_title, k_val, k_col in kpi_cards:
        c.setFillColor(colors.HexColor("#F7FAFC"))
        c.setStrokeColor(c_border)
        c.roundRect(kx, dw_y + dw_h - 110, 105, 50, 4, fill=1, stroke=1)
        c.setFillColor(k_col)
        c.setFont(F_BOLD, 13)
        c.drawCentredString(kx + 52, dw_y + dw_h - 85, k_val)
        c.setFillColor(c_text_muted)
        c.setFont(F_REG, 7.5)
        c.drawCentredString(kx + 52, dw_y + dw_h - 100, k_title)
        kx += 120

    # Search and Filter bar
    c.setFillColor(colors.HexColor("#EDF2F7"))
    c.roundRect(dw_x + 25, dw_y + dw_h - 150, dw_w - 50, 28, 4, fill=1, stroke=0)
    c.setFillColor(c_text_dark)
    c.setFont(F_REG, 8)
    c.drawString(dw_x + 35, dw_y + dw_h - 141, "Search Users: [ Mehmet Demir                       ]   Filter: [All Roles v]   [Status v]")

    # User Accounts Data Table
    table_y = dw_y + dw_h - 170
    c.setFillColor(c_navy)
    c.rect(dw_x + 25, table_y - 20, dw_w - 50, 20, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 7.5)
    c.drawString(dw_x + 35, table_y - 14, "User ID")
    c.drawString(dw_x + 95, table_y - 14, "Name & Contact")
    c.drawString(dw_x + 215, table_y - 14, "Role")
    c.drawString(dw_x + 285, table_y - 14, "District")
    c.drawString(dw_x + 355, table_y - 14, "Status")
    c.drawString(dw_x + 420, table_y - 14, "Administrative Action")

    accounts = [
        ("USR-101", "Mehmet Demir (+90 532 ***)", "Professional", "Kadıköy", "Active", c_green, "[Suspend]"),
        ("USR-102", "Ata Herdem (+90 555 ***)", "Customer", "Kadıköy", "Active", c_green, "[Suspend]"),
        ("USR-103", "Ali Kaya (+90 544 ***)", "Professional", "Üsküdar", "Suspended", c_red, "[Reactivate]"),
        ("USR-104", "Ahmet Yılmaz (+90 533 ***)", "Professional", "Beşiktaş", "Active", c_green, "[Suspend]"),
        ("USR-105", "Zeynep Korkmaz (+90 505 ***)", "Customer", "Kadıköy", "Active", c_green, "[Suspend]")
    ]
    row_y = table_y - 42
    for uid, uname, urole, udist, ustat, scol, uact in accounts:
        c.setFillColor(colors.HexColor("#F7FAFC") if (accounts.index((uid, uname, urole, udist, ustat, scol, uact)) % 2 == 0) else colors.white)
        c.rect(dw_x + 25, row_y - 6, dw_w - 50, 22, fill=1, stroke=0)
        
        c.setFillColor(c_text_dark)
        c.setFont(F_REG, 7.5)
        c.drawString(dw_x + 35, row_y + 2, uid)
        c.drawString(dw_x + 95, row_y + 2, uname)
        c.drawString(dw_x + 215, row_y + 2, urole)
        c.drawString(dw_x + 285, row_y + 2, udist)

        c.setFillColor(scol)
        c.setFont(F_BOLD, 7.5)
        c.drawString(dw_x + 355, row_y + 2, ustat)

        c.setFillColor(c_accent)
        c.setFont(F_BOLD, 7.5)
        c.drawString(dw_x + 420, row_y + 2, f"[View Log]   {uact}")
        row_y -= 24

    # Bottom Admin Controls (Directory management)
    c.setFillColor(c_blue)
    c.roundRect(dw_x + 35, dw_y + 35, 170, 34, 4, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 8.5)
    c.drawCentredString(dw_x + 120, dw_y + 47, "Refresh Directory")

    c.setFillColor(c_accent)
    c.roundRect(dw_x + 225, dw_y + 35, 170, 34, 4, fill=1, stroke=0)
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 8.5)
    c.drawCentredString(dw_x + 310, dw_y + 47, "View Account Details")

    c.showPage()

    # =========================================================================
    # SCREEN 22: PROMOTIONAL WEBSITE (SCR-22)
    # (Fixed text wrapping, no overflowing columns, clean fonts and badges)
    # =========================================================================
    c.bookmarkPage("scr_promo_web")
    draw_top_nav("SCR-22: Promotional Showcase Website", "Public Web Showcase", "scr_admin_accounts", "map_hub")

    dw_x, dw_y, dw_w, dw_h = 35, 40, PAGE_WIDTH - 70, 650
    c.setFillColor(colors.white)
    c.setStrokeColor(c_border)
    c.roundRect(dw_x, dw_y, dw_w, dw_h, 8, fill=1, stroke=1)

    # Hero Banner
    c.setFillColor(c_navy)
    c.roundRect(dw_x, dw_y + dw_h - 160, dw_w, 160, 8, fill=1, stroke=0)

    # Web Navbar
    c.setFillColor(colors.white)
    c.setFont(F_BOLD, 15)
    c.drawString(dw_x + 30, dw_y + dw_h - 35, "BiTadilat")
    c.setFont(F_REG, 8.5)
    c.drawRightString(dw_x + dw_w - 30, dw_y + dw_h - 35, "Features    How It Works    For Technicians    FAQ    [TR | EN]")

    # Hero Headline
    c.setFont(F_BOLD, 17)
    c.drawString(dw_x + 30, dw_y + dw_h - 78, "Reliable Home Repairs Across Istanbul.")
    c.setFont(F_REG, 10)
    c.drawString(dw_x + 30, dw_y + dw_h - 100, "Match with local repair and renovation specialists. Structured offers, transparent trust.")

    # App Store Badges (Clean vector styling, no emojis or broken glyphs)
    c.setFillColor(colors.white)
    c.roundRect(dw_x + 30, dw_y + dw_h - 145, 140, 28, 4, fill=1, stroke=0)
    c.setFillColor(c_navy)
    c.setFont(F_BOLD, 8.5)
    c.drawCentredString(dw_x + 100, dw_y + dw_h - 136, "App Store  [iOS]")

    c.setFillColor(colors.white)
    c.roundRect(dw_x + 185, dw_y + dw_h - 145, 140, 28, 4, fill=1, stroke=0)
    c.setFillColor(c_navy)
    c.drawCentredString(dw_x + 255, dw_y + dw_h - 136, "Google Play  [Android]")

    # 3 Column Pillars (With automatic text wrapping to prevent any column overflow)
    features = [
        ("Urgent or Planned Needs",
         "Post an emergency repair or plan a future home renovation project in your district."),
        ("Transparent Structured Quotes",
         "Compare itemized labor and material costs with clear arrival time commitments."),
        ("Empowering Local Trades",
         "Aligned with UN SDG 8: Helping Istanbul craftsmen reach local customers and organize work.")
    ]
    card_w = 158
    card_h = 135
    card_gap = 18
    start_x = dw_x + 25
    card_y = dw_y + dw_h - 320

    for i, (f_title, f_desc) in enumerate(features):
        cx = start_x + i * (card_w + card_gap)
        c.setFillColor(colors.HexColor("#F7FAFC"))
        c.setStrokeColor(c_border)
        c.roundRect(cx, card_y, card_w, card_h, 6, fill=1, stroke=1)
        
        c.setFillColor(c_blue)
        c.setFont(F_BOLD, 9)
        c.drawString(cx + 12, card_y + card_h - 22, f_title)
        
        c.setFillColor(c_text_muted)
        c.setFont(F_REG, 7.8)
        
        # Safe word-wrapping inside column boundaries
        lines = wrap_text_lines(f_desc, F_REG, 7.8, card_w - 24)
        line_y = card_y + card_h - 44
        for l in lines:
            c.drawString(cx + 12, line_y, l)
            line_y -= 15

    # Secondary Content Area: How BiTadilat Works
    hw_y = dw_y + dw_h - 355
    c.setFillColor(c_navy)
    c.setFont(F_BOLD, 12)
    c.drawString(dw_x + 30, hw_y, "How It Works in 3 Simple Steps:")

    steps = [
        ("1. Create Request", "Describe your problem, select your district, and upload photos."),
        ("2. Compare Quotes", "Review itemized labor and material fees from matched local pros."),
        ("3. Confirm & Review", "Inspect completed work, confirm completion, and rate your pro.")
    ]
    sx = dw_x + 30
    for s_title, s_desc in steps:
        c.setFillColor(colors.HexColor("#EDF2F7"))
        c.roundRect(sx, hw_y - 95, 155, 80, 4, fill=1, stroke=0)
        c.setFillColor(c_accent)
        c.setFont(F_BOLD, 8.5)
        c.drawString(sx + 10, hw_y - 20, s_title)
        c.setFillColor(c_text_dark)
        c.setFont(F_REG, 7.5)
        slines = wrap_text_lines(s_desc, F_REG, 7.5, 135)
        sly = hw_y - 40
        for sl in slines:
            c.drawString(sx + 10, sly, sl)
            sly -= 14
        sx += 175

    # Web Footer
    c.setFillColor(colors.HexColor("#EDF2F7"))
    c.rect(dw_x, dw_y, dw_w, 40, fill=1, stroke=0)
    c.setFillColor(c_text_muted)
    c.setFont(F_REG, 8)
    c.drawCentredString(dw_x + dw_w/2, dw_y + 16, "(C) 2026 BiTadilat Graduation Project  •  Feyziye Schools Foundation Işık University Software Engineering")

    c.showPage()
    c.save()
    print(f"Successfully generated navigable prototype PDF at {output_filename}")

if __name__ == "__main__":
    create_navigable_mockups_pdf()
