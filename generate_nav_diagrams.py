"""
Generate proper Navigational Path Diagrams for BiTadilat RAD.
Screens = named rectangles. Arrows = user-action transitions.
No decision diamonds. No activity-style nodes.
Uses Pillow for direct PNG output.
"""
import os
import math
import textwrap
from PIL import Image, ImageDraw, ImageFont

# ── Colours ────────────────────────────────────────────────────────────────
COL_BG     = "#F7FAFC"
COL_BOX    = "#1A365D"   # navy fill
COL_BOX_BD = "#2B6CB0"   # blue border
COL_SHAD   = "#CBD5E0"
COL_ARR    = "#2D3748"
COL_LBL    = "#92400E"   # dark amber for edge text
COL_TITLE  = "#0F2A4A"
COL_WHITE  = "#FFFFFF"
COL_LEGEND = "#718096"

FONT_PATHS = [
    '/System/Library/Fonts/Supplemental/Arial.ttf',
    '/System/Library/Fonts/Supplemental/Arial Bold.ttf',
    '/Library/Fonts/Arial.ttf',
    '/Library/Fonts/Arial Bold.ttf',
    '/System/Library/Fonts/Helvetica.ttc',
]

def load_fonts(regular_size, bold_size, small_size):
    reg_path = next((p for p in FONT_PATHS[::2] if os.path.exists(p)), None)
    bld_path = next((p for p in FONT_PATHS[1::2] if os.path.exists(p)), None)
    try:
        f_reg   = ImageFont.truetype(reg_path,   regular_size)
        f_bold  = ImageFont.truetype(bld_path or reg_path, bold_size)
        f_small = ImageFont.truetype(reg_path,   small_size)
    except Exception:
        f_reg = f_bold = f_small = ImageFont.load_default()
    return f_reg, f_bold, f_small


def hex2rgb(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))


def draw_rounded_rect(draw, x0, y0, x1, y1, r, fill, outline, lw=2):
    draw.rectangle([x0+r, y0, x1-r, y1], fill=fill)
    draw.rectangle([x0, y0+r, x1, y1-r], fill=fill)
    draw.ellipse([x0, y0, x0+2*r, y0+2*r], fill=fill)
    draw.ellipse([x1-2*r, y0, x1, y0+2*r], fill=fill)
    draw.ellipse([x0, y1-2*r, x0+2*r, y1], fill=fill)
    draw.ellipse([x1-2*r, y1-2*r, x1, y1], fill=fill)
    if outline and lw > 0:
        draw.rounded_rectangle([x0, y0, x1, y1], radius=r, outline=outline, width=lw)


def draw_arrow(draw, x0, y0, x1, y1, color, width=2):
    draw.line([(x0, y0), (x1, y1)], fill=color, width=width)
    ang = math.atan2(y1 - y0, x1 - x0)
    size = 9
    ax1 = (x1 - size * math.cos(ang - 0.45), y1 - size * math.sin(ang - 0.45))
    ax2 = (x1 - size * math.cos(ang + 0.45), y1 - size * math.sin(ang + 0.45))
    draw.polygon([(x1, y1), ax1, ax2], fill=color)


def edge_attach(bx, by, bw, bh, toward_x, toward_y):
    """Return point on box border closest to (toward_x, toward_y)."""
    cx, cy = bx + bw/2, by + bh/2
    dx, dy = toward_x - cx, toward_y - cy
    if dx == 0 and dy == 0:
        return cx, cy
    sx = (bw/2) / abs(dx) if dx != 0 else 1e9
    sy = (bh/2) / abs(dy) if dy != 0 else 1e9
    s = min(sx, sy)
    return cx + s*dx, cy + s*dy


def draw_nav_diagram(output_path, title, screens, edges, W=760, H=560):
    """
    screens: [(id, label_lines, cx, cy, bw, bh)]   cx/cy = centre
    edges:   [(from_id, to_id, label_str)]
    """
    f_reg, f_bold, f_small = load_fonts(15, 16, 11)

    img = Image.new("RGB", (W, H), COL_BG)
    d   = ImageDraw.Draw(img)

    # Title bar
    d.rectangle([0, 0, W, 36], fill=hex2rgb(COL_BOX))
    tw = d.textlength(title, font=f_bold)
    d.text(((W - tw) // 2, 9), title, font=f_bold, fill=hex2rgb(COL_WHITE))

    # Build lookup: id → (cx, cy, bw, bh)
    box_map = {}
    for (sid, lbl, cx, cy, bw, bh) in screens:
        box_map[sid] = (cx, cy, bw, bh)

    # Draw edges first
    ARROW_COL = hex2rgb(COL_ARR)
    LBL_COL   = hex2rgb(COL_LBL)
    BG_COL    = hex2rgb(COL_BG)

    for (fid, tid, lbl) in edges:
        if fid not in box_map or tid not in box_map:
            continue
        fx, fy, fw, fh = box_map[fid]
        tx, ty, tw2, th = box_map[tid]
        ex, ey = edge_attach(fx - fw/2, fy - fh/2, fw, fh, tx, ty)
        rx, ry = edge_attach(tx - tw2/2, ty - th/2, tw2, th, fx, fy)
        draw_arrow(d, int(ex), int(ey), int(rx), int(ry), ARROW_COL, width=2)

        # Edge label midpoint
        if lbl:
            mx, my = (ex + rx) / 2, (ey + ry) / 2
            lw = int(d.textlength(lbl, font=f_small))
            lh = 14
            pad = 3
            d.rectangle([int(mx - lw/2 - pad), int(my - lh/2 - 1),
                          int(mx + lw/2 + pad), int(my + lh/2 + 1)],
                         fill=BG_COL, outline=hex2rgb(COL_BOX_BD))
            d.text((int(mx - lw/2), int(my - lh/2 + 1)), lbl, font=f_small, fill=LBL_COL)

    # Draw screen boxes
    BOX_COL  = hex2rgb(COL_BOX)
    BOX_BD   = hex2rgb(COL_BOX_BD)
    SHAD_COL = hex2rgb(COL_SHAD)

    for (sid, lbl, cx, cy, bw, bh) in screens:
        x0, y0 = int(cx - bw/2), int(cy - bh/2)
        x1, y1 = int(cx + bw/2), int(cy + bh/2)
        # Shadow
        d.rounded_rectangle([x0+3, y0+3, x1+3, y1+3], radius=6, fill=SHAD_COL)
        # Box
        d.rounded_rectangle([x0, y0, x1, y1], radius=6, fill=BOX_COL, outline=BOX_BD, width=2)
        # Text
        lines = lbl.split('\n') if '\n' in lbl else textwrap.wrap(lbl, 16)
        lh = 16
        total_h = len(lines) * lh
        ty_start = int(cy - total_h/2 + 2)
        for line in lines:
            lw_px = int(d.textlength(line, font=f_reg))
            d.text((int(cx - lw_px/2), ty_start), line, font=f_reg, fill=hex2rgb(COL_WHITE))
            ty_start += lh

    # Legend
    leg_y = H - 22
    d.rounded_rectangle([12, leg_y - 6, 52, leg_y + 10], radius=3, fill=BOX_COL)
    d.text((14, leg_y - 5), "Screen", font=f_small, fill=hex2rgb(COL_WHITE))
    draw_arrow(d, 60, leg_y + 2, 100, leg_y + 2, ARROW_COL)
    d.text((105, leg_y - 5), "Navigation (user action)", font=f_small, fill=hex2rgb(COL_LEGEND))

    img.save(output_path, dpi=(150, 150))
    print(f"  ✓ {output_path}")


# ═══════════════════════════════════════════════════════════════════════════
# DIAGRAM DEFINITIONS
# ═══════════════════════════════════════════════════════════════════════════

def customer_journey():
    """Customer mobile app navigational path."""
    BW, BH = 130, 48
    screens = [
        ("s01", "SCR-01\nLogin / Role Select",        380, 60,  BW, BH),
        ("s02", "SCR-02\nCreate Service\nRequest",    120, 160, BW, BH),
        ("s03", "SCR-03\nMatching Results",           120, 260, BW, BH),
        ("s04", "SCR-04\nOffer Comparison",           320, 260, BW, BH),
        ("s05", "SCR-05\nProfessional Profile",       520, 260, BW, BH),
        ("s06", "SCR-06\nAppointment\nScheduling",    320, 360, BW, BH),
        ("s07", "SCR-07\nIn-App Chat",                120, 360, BW, BH),
        ("s08", "SCR-08\nJob Progress\n(Customer)",   320, 460, BW, BH),
        ("s09", "SCR-09\nCancellation\nConfirm",      120, 460, BW, BH),
        ("s10", "SCR-10\nCompletion Confirm",         520, 460, BW, BH),
        ("s11", "SCR-11\nReview & Rating",            520, 540, BW, BH),
        ("s12", "SCR-12\nFile Complaint",             650, 460, BW, BH),
        ("s13", "SCR-13\nComplaint Status",           650, 540, BW, BH),
    ]
    edges = [
        ("s01", "s02", "Create Request"),
        ("s02", "s03", "Submit"),
        ("s03", "s04", "View Offers"),
        ("s04", "s05", "View Profile"),
        ("s04", "s06", "Accept Offer"),
        ("s06", "s07", "Open Chat"),
        ("s06", "s08", "Job Starts"),
        ("s08", "s07", "Chat"),
        ("s08", "s09", "Cancel (pre-work)"),
        ("s08", "s10", "Confirm Completion"),
        ("s08", "s12", "Report Issue"),
        ("s10", "s11", "Submit Review"),
        ("s12", "s13", "Submit Complaint"),
    ]
    draw_nav_diagram("figures/fig_flow_customer.png",
                     "Figure 5 — Customer Mobile App: Navigational Path",
                     screens, edges, W=820, H=630)


def pro_journey():
    """Professional mobile app navigational path."""
    BW, BH = 130, 48
    screens = [
        ("s01", "SCR-01\nLogin / Role Select",         320, 60,  BW, BH),
        ("s14", "SCR-14\nMatched Requests\nFeed",      120, 180, BW, BH),
        ("s17", "SCR-17\nProfile & Avail.\nEdit",      520, 180, BW, BH),
        ("s05", "SCR-05\nView Request\nDetails",       120, 300, BW, BH),
        ("s15", "SCR-15\nStructured Offer\nBuilder",   120, 420, BW, BH),
        ("s16", "SCR-16\nOffer Submitted\nStatus",     120, 520, BW, BH),
        ("s18", "SCR-18\nJob Execution\n& Milestones", 370, 300, BW, BH),
        ("s07", "SCR-07\nIn-App Chat",                 370, 420, BW, BH),
    ]
    edges = [
        ("s01",  "s14",  "Pro Dashboard"),
        ("s01",  "s17",  "Edit Profile"),
        ("s14",  "s05",  "View Request"),
        ("s14",  "s17",  "Manage Profile"),
        ("s14",  "s18",  "Active Job"),
        ("s05",  "s15",  "Prepare Offer"),
        ("s15",  "s16",  "Send Offer"),
        ("s16",  "s14",  "Back to Feed"),
        ("s18",  "s07",  "Chat with Customer"),
        ("s18",  "s14",  "Work Finished"),
    ]
    draw_nav_diagram("figures/fig_flow_pro.png",
                     "Figure 6 — Professional Mobile App: Navigational Path",
                     screens, edges, W=680, H=620)


def admin_journey():
    """Administrator web panel navigational path."""
    BW, BH = 145, 50
    screens = [
        ("a19",  "SCR-19\nProfile Review\nQueue",           140, 100, BW, BH),
        ("a20",  "SCR-20\nDispute & Complaint\nCenter",     340, 100, BW, BH),
        ("a21",  "SCR-21\nAccount\nManagement",             540, 100, BW, BH),
        ("a19b", "SCR-19\nApprove / Reject\nProfile",       140, 240, BW, BH),
        ("a20b", "SCR-20\nCancel Job /\nWarn / Dismiss",    340, 240, BW, BH),
        ("a21b", "SCR-21\nSuspend /\nReactivate User",      540, 240, BW, BH),
    ]
    edges = [
        ("a19",  "a19b", "Review Profile"),
        ("a20",  "a20b", "Review Dispute"),
        ("a21",  "a21b", "Manage Account"),
        ("a19b", "a19",  "Next Case"),
        ("a20b", "a20",  "Next Case"),
        ("a21b", "a21",  "Back to Directory"),
    ]
    draw_nav_diagram("figures/fig_flow_admin.png",
                     "Figure 7 — Administrator Web Panel: Navigational Path",
                     screens, edges, W=700, H=360)


def promo_journey():
    """Promotional website navigational path."""
    BW, BH = 135, 50
    screens = [
        ("w1", "SCR-22\nLanding\n(Hero Section)",     160, 100, BW, BH),
        ("w2", "SCR-22\nHow It Works\nSection",       160, 230, BW, BH),
        ("w3", "SCR-22\nFor Technicians\nSection",    360, 100, BW, BH),
        ("w4", "SCR-22\nApp Download\n(CTA)",         360, 230, BW, BH),
        ("w5", "SCR-22\nFAQ Section",                 560, 100, BW, BH),
        ("w6", "SCR-01\nApp: Login /\nRegister",      560, 230, BW, BH),
    ]
    edges = [
        ("w1", "w2",  "Scroll Down"),
        ("w1", "w3",  "Nav: Technicians"),
        ("w1", "w5",  "Nav: FAQ"),
        ("w3", "w4",  "Download CTA"),
        ("w2", "w4",  "Download CTA"),
        ("w4", "w6",  "Open App"),
        ("w5", "w6",  "Open App"),
    ]
    draw_nav_diagram("figures/fig_flow_promo.png",
                     "Figure 8 — Promotional Website: Navigational Path",
                     screens, edges, W=720, H=360)


if __name__ == "__main__":
    os.makedirs("figures", exist_ok=True)
    customer_journey()
    pro_journey()
    admin_journey()
    promo_journey()
    print("\nAll navigational path diagrams generated.")
