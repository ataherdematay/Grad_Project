import math
from PIL import Image, ImageDraw, ImageFont

def draw_use_case_diagram(output_path="figures/fig_use_case_model.png"):
    scale = 2
    w, h = 1380 * scale, 860 * scale
    img = Image.new("RGB", (w, h), (255, 255, 255))
    draw = ImageDraw.Draw(img)

    # Fonts
    font_path = "/System/Library/Fonts/Supplemental/Times New Roman.ttf"
    font_title = ImageFont.truetype(font_path, 16 * scale)
    font_actor = ImageFont.truetype(font_path, 13 * scale)
    font_uc = ImageFont.truetype(font_path, 11 * scale)
    font_stereo = ImageFont.truetype(font_path, 9.5 * scale)

    # Colors
    c_line = (27, 54, 93)         # #1B365D Dark Navy
    c_line_dashed = (60, 85, 120)
    c_box_bg = (250, 251, 253)
    c_box_border = (27, 54, 93)
    c_uc_bg = (248, 250, 253)
    c_actor_bg = (234, 239, 254)
    c_text = (15, 42, 74)

    # 1. System Boundary
    bx1, by1, bx2, by2 = 240 * scale, 45 * scale, 1140 * scale, 810 * scale
    draw.rectangle([bx1, by1, bx2, by2], fill=c_box_bg, outline=c_box_border, width=2 * scale)

    # Title
    draw.text((bx1 + 25 * scale, by1 + 18 * scale), "BiTadilat System Boundaries", font=font_title, fill=c_text)

    # 2. Actors Definition (Visual Paradigm style)
    actors = {
        "Customer": {
            "box": (35 * scale, 130 * scale, 185 * scale, 195 * scale),
            "label": "Customer",
            "anchor": (185 * scale, 162 * scale)
        },
        "ServiceProfessional": {
            "box": (35 * scale, 550 * scale, 185 * scale, 615 * scale),
            "label": "Service Professional",
            "anchor": (185 * scale, 582 * scale)
        },
        "Administrator": {
            "box": (1185 * scale, 345 * scale, 1335 * scale, 410 * scale),
            "label": "Administrator",
            "anchor": (1185 * scale, 377 * scale)
        }
    }

    # Draw Actor Boxes
    for a_id, a_data in actors.items():
        x1, y1, x2, y2 = a_data["box"]
        draw.rounded_rectangle([x1, y1, x2, y2], radius=6 * scale, fill=c_actor_bg, outline=c_line, width=math.ceil(1.5 * scale))
        draw.text((x1 + 14 * scale, y1 + 10 * scale), "«actor»", font=font_stereo, fill=c_text)
        draw.text((x1 + 14 * scale, y1 + 26 * scale), a_data["label"], font=font_actor, fill=c_text)

    # 3. Use Cases Definitions (Visual Paradigm layout)
    usecases = {
        # Column 1 (Left Column)
        "UC02": {"center": (400 * scale, 160 * scale), "rx": 115 * scale, "ry": 22 * scale, "text": "UC02: Create Service Request"},
        "UC11": {"center": (400 * scale, 260 * scale), "rx": 115 * scale, "ry": 22 * scale, "text": "UC11: Cancel Request / Job"},
        "UC01": {"center": (400 * scale, 370 * scale), "rx": 110 * scale, "ry": 22 * scale, "text": "UC01: Register & Login"},
        "UC07": {"center": (400 * scale, 480 * scale), "rx": 110 * scale, "ry": 22 * scale, "text": "UC07: Direct Messaging"},
        "UC04": {"center": (400 * scale, 580 * scale), "rx": 115 * scale, "ry": 22 * scale, "text": "UC04: Submit Structured Offer"},

        # Column 2 (Center Column)
        "UC03": {"center": (680 * scale, 160 * scale), "rx": 115 * scale, "ry": 22 * scale, "text": "UC03: Rule-Based Matching"},
        "UC05": {"center": (680 * scale, 270 * scale), "rx": 115 * scale, "ry": 22 * scale, "text": "UC05: Compare & Accept Offer"},
        "UC06": {"center": (680 * scale, 375 * scale), "rx": 115 * scale, "ry": 22 * scale, "text": "UC06: Schedule Appointment"},
        "UC08": {"center": (680 * scale, 480 * scale), "rx": 115 * scale, "ry": 22 * scale, "text": "UC08: Update Job Progress"},
        "UC09": {"center": (680 * scale, 585 * scale), "rx": 115 * scale, "ry": 22 * scale, "text": "UC09: Confirm Completion"},
        "UC10": {"center": (680 * scale, 695 * scale), "rx": 115 * scale, "ry": 22 * scale, "text": "UC10: Submit Review & Rating"},

        # Column 3 (Right Column)
        "UC12": {"center": (960 * scale, 330 * scale), "rx": 120 * scale, "ry": 22 * scale, "text": "UC12: Verify Pro Profile"},
        "UC13": {"center": (960 * scale, 430 * scale), "rx": 115 * scale, "ry": 22 * scale, "text": "UC13: Arbitrate Complaints"},
    }

    # Helper: connect actor to UC boundary point
    def connect(actor_pt, uc_id):
        uc = usecases[uc_id]
        cx, cy = uc["center"]
        rx, ry = uc["rx"], uc["ry"]
        ax, ay = actor_pt

        dx = ax - cx
        dy = ay - cy
        dist = math.hypot(dx, dy)
        if dist > 0:
            denom = math.sqrt((dx / rx)**2 + (dy / ry)**2)
            ex = cx + dx / denom
            ey = cy + dy / denom
            draw.line([ax, ay, ex, ey], fill=c_line, width=math.ceil(1.2 * scale))

    # Helper: dashed dependency
    def connect_dep(from_id, to_id, label, orient="h"):
        uc1 = usecases[from_id]
        uc2 = usecases[to_id]
        c1x, c1y = uc1["center"]
        c2x, c2y = uc2["center"]

        if orient == "h":
            sx, sy = c1x + uc1["rx"], c1y
            tx, ty = c2x - uc2["rx"], c2y
        else: # vertical
            sx, sy = c1x, c1y + uc1["ry"]
            tx, ty = c2x, c2y - uc2["ry"]

        total_dist = math.hypot(tx - sx, ty - sy)
        if total_dist == 0:
            return
        ux = (tx - sx) / total_dist
        uy = (ty - sy) / total_dist

        dash_len = 7 * scale
        gap_len = 4 * scale
        curr = 0
        while curr < total_dist - 10 * scale:
            p1 = (sx + ux * curr, sy + uy * curr)
            seg = min(dash_len, total_dist - 10 * scale - curr)
            p2 = (sx + ux * (curr + seg), sy + uy * (curr + seg))
            draw.line([p1, p2], fill=c_line_dashed, width=math.ceil(1.2 * scale))
            curr += dash_len + gap_len

        # Arrowhead
        ah_len = 9 * scale
        ah_w = 4.5 * scale
        px = tx - ux * ah_len
        py = ty - uy * ah_len
        nx = -uy * ah_w
        ny = ux * ah_w
        draw.line([px + nx, py + ny, tx, ty], fill=c_line_dashed, width=math.ceil(1.4 * scale))
        draw.line([px - nx, py - ny, tx, ty], fill=c_line_dashed, width=math.ceil(1.4 * scale))

        # Label
        mx = (sx + tx) / 2
        my = (sy + ty) / 2
        if orient == "h":
            draw.text((mx - 20 * scale, my - 13 * scale), f"«{label}»", font=font_stereo, fill=c_text)
        else:
            draw.text((mx + 6 * scale, my - 6 * scale), f"«{label}»", font=font_stereo, fill=c_text)

    # 4. Draw Straight Lines
    # Customer Connections
    c_pt = actors["Customer"]["anchor"]
    for uid in ["UC02", "UC11", "UC01", "UC05", "UC06", "UC07", "UC09", "UC10"]:
        connect(c_pt, uid)

    # Service Professional Connections
    p_pt = actors["ServiceProfessional"]["anchor"]
    for uid in ["UC04", "UC07", "UC01", "UC08", "UC09", "UC11", "UC06"]:
        connect(p_pt, uid)

    # Administrator Connections (Direct horizontal lines on the right)
    a_pt = actors["Administrator"]["anchor"]
    connect(a_pt, "UC12")
    connect(a_pt, "UC13")

    # Internal Dependencies
    connect_dep("UC02", "UC03", "triggers", "h")
    connect_dep("UC04", "UC05", "informs", "h")
    connect_dep("UC05", "UC06", "initiates", "v")
    connect_dep("UC09", "UC10", "unlocks", "v")

    # 5. Draw Use Case Ovals on Top
    for uc_id, uc in usecases.items():
        cx, cy = uc["center"]
        rx, ry = uc["rx"], uc["ry"]
        box = [cx - rx, cy - ry, cx + rx, cy + ry]
        draw.ellipse(box, fill=c_uc_bg, outline=c_line, width=math.ceil(1.4 * scale))
        
        t = uc["text"]
        bbox = draw.textbbox((0, 0), t, font=font_uc)
        tw = bbox[2] - bbox[0]
        th = bbox[3] - bbox[1]
        draw.text((cx - tw / 2, cy - th / 2 - 2 * scale), t, font=font_uc, fill=c_text)

    # Downscale for smooth antialiasing
    final_img = img.resize((1380, 860), Image.Resampling.LANCZOS)
    final_img.save(output_path, "PNG", dpi=(300, 300))
    print(f"Saved refined Visual Paradigm use case diagram to {output_path}")

if __name__ == "__main__":
    draw_use_case_diagram()
