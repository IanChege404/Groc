#!/usr/bin/env python3
"""
Generate Pro Grocery app icon PNGs from design specs.
Creates adaptive icon foreground and splash screen assets.
"""
from PIL import Image, ImageDraw, ImageFont
import math
import os

def create_app_icon_foreground(size=512):
    """Create adaptive icon foreground (cart on transparent background)."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Scale factor
    s = size / 512.0
    
    # Cart parameters
    cart_left = int(130 * s)
    cart_right = int(370 * s)
    cart_top = int(140 * s)
    cart_bottom = int(360 * s)
    handle_top = int(120 * s)
    wheel_y = int(390 * s)
    wheel_r = int(28 * s)
    
    # Colors
    white = (255, 255, 255, 255)
    green_dark = (46, 125, 50, 255)
    red = (244, 67, 54, 255)
    orange = (255, 152, 0, 255)
    yellow = (255, 235, 59, 255)
    leaf_green = (76, 175, 80, 255)
    
    line_w = int(20 * s)
    
    # Draw cart body (trapezoid shape)
    # Left side of basket
    draw.line([(cart_left, handle_top), (cart_left + int(30*s), cart_bottom)], fill=white, width=line_w)
    # Right side of basket  
    draw.line([(cart_right - int(30*s), handle_top), (cart_right, cart_bottom)], fill=white, width=line_w)
    # Bottom of basket
    draw.line([(cart_left - int(10*s), cart_bottom), (cart_right + int(10*s), cart_bottom)], fill=white, width=line_w)
    
    # Handle
    draw.line([(cart_right - int(30*s), handle_top), (cart_right + int(60*s), handle_top)], fill=white, width=line_w)
    draw.line([(cart_right + int(60*s), handle_top), (cart_right + int(30*s), cart_bottom - int(40*s))], fill=white, width=line_w)
    
    # Wheels
    whl_x1 = cart_left + int(40*s)
    whl_x2 = cart_right - int(40*s)
    draw.ellipse([whl_x1 - wheel_r, wheel_y - wheel_r, whl_x1 + wheel_r, wheel_y + wheel_r], fill=white)
    draw.ellipse([whl_x2 - wheel_r, wheel_y - wheel_r, whl_x2 + wheel_r, wheel_y + wheel_r], fill=white)
    # Wheel centers
    center_r = int(8 * s)
    draw.ellipse([whl_x1 - center_r, wheel_y - center_r, whl_x1 + center_r, wheel_y + center_r], fill=green_dark)
    draw.ellipse([whl_x2 - center_r, wheel_y - center_r, whl_x2 + center_r, wheel_y + center_r], fill=green_dark)
    
    # Items in cart - Apple
    apple_x, apple_y = int(220*s), int(250*s)
    apple_r = int(26*s)
    draw.ellipse([apple_x - apple_r, apple_y - apple_r, apple_x + apple_r, apple_y + apple_r], fill=red)
    # Apple leaf
    draw.ellipse([apple_x + int(4*s), apple_y - apple_r - int(12*s), apple_x + int(18*s), apple_y - apple_r + int(2*s)], fill=leaf_green)
    
    # Orange
    org_x, org_y = int(290*s), int(260*s)
    org_r = int(22*s)
    draw.ellipse([org_x - org_r, org_y - org_r, org_x + org_r, org_y + org_r], fill=orange)
    # Orange highlight
    hl_r = int(14*s)
    draw.ellipse([org_x - hl_r, org_y - hl_r, org_x + hl_r, org_y + hl_r], outline=(255, 183, 77, 255), width=int(2*s))
    
    # Banana (curved line)
    banana_pts = []
    for i in range(20):
        t = i / 19.0
        x = int((150 + 40 * t) * s)
        y = int((260 - 30 * math.sin(t * math.pi)) * s)
        banana_pts.append((x, y))
    if len(banana_pts) > 1:
        draw.line(banana_pts, fill=yellow, width=int(10*s))
    
    return img


def create_app_icon_background(size=512):
    """Create adaptive icon background (solid green)."""
    img = Image.new('RGBA', (size, size), (46, 125, 50, 255))
    return img


def create_splash_logo(width=400, height=200):
    """Create splash screen logo with cart + text."""
    img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Colors
    white = (255, 255, 255, 255)
    green = (46, 125, 50, 255)
    green_light = (76, 175, 80, 255)
    
    # Draw small cart icon on left
    cx, cy = 60, height // 2
    scale = 0.4
    
    # Mini cart
    draw.line([(cx-20, cy-30), (cx-10, cy+10)], fill=white, width=4)
    draw.line([(cx+20, cy-30), (cx+30, cy+10)], fill=white, width=4)
    draw.line([(cx-15, cy+10), (cx+35, cy+10)], fill=white, width=4)
    draw.line([(cx+20, cy-30), (cx+40, cy-30)], fill=white, width=4)
    
    # Wheels
    draw.ellipse([cx-8, cy+14, cx+2, cy+24], fill=white)
    draw.ellipse([cx+22, cy+14, cx+32, cy+24], fill=white)
    
    # Text
    try:
        # Try to use a nice font
        font_large = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 48)
        font_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 20)
    except:
        font_large = ImageFont.load_default()
        font_small = ImageFont.load_default()
    
    # "eGrocery" text
    text_x = 100
    draw.text((text_x, cy - 35), "e", fill=green_light, font=font_large)
    bbox = draw.textbbox((text_x, cy - 35), "e", font=font_large)
    grocery_x = bbox[2] + 2
    draw.text((grocery_x, cy - 35), "Grocery", fill=white, font=font_large)
    
    # Tagline
    draw.text((text_x + 10, cy + 20), "your daily needs", fill=(200, 200, 200, 200), font=font_small)
    
    return img


def main():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    
    # Ensure output directories exist
    icon_dir = os.path.join(base_dir, "assets", "icon")
    os.makedirs(icon_dir, exist_ok=True)
    
    # Generate adaptive icon foreground
    print("Generating adaptive icon foreground...")
    fg = create_app_icon_foreground(512)
    fg.save(os.path.join(icon_dir, "adaptive_icon_foreground.png"))
    
    # Generate adaptive icon background
    print("Generating adaptive icon background...")
    bg = create_app_icon_background(512)
    bg.save(os.path.join(icon_dir, "adaptive_icon_background.png"))
    
    # Generate splash logo
    print("Generating splash screen logo...")
    splash = create_splash_logo(400, 200)
    splash.save(os.path.join(base_dir, "assets", "images", "app_logo_splash.png"))
    
    # Generate a high-res icon for flutter_launcher_icons
    print("Generating high-res app icon (1024x1024)...")
    icon = create_app_icon_foreground(1024)
    # Composite onto green background
    bg_large = create_app_icon_background(1024)
    bg_large.paste(icon, (0, 0), icon)
    bg_large.save(os.path.join(icon_dir, "app_icon_1024.png"))
    
    print("Done! Generated:")
    print(f"  - {icon_dir}/adaptive_icon_foreground.png")
    print(f"  - {icon_dir}/adaptive_icon_background.png") 
    print(f"  - assets/images/app_logo_splash.png")
    print(f"  - {icon_dir}/app_icon_1024.png")
    print("\nNext: Run 'dart run flutter_launcher_icons' to generate all platform icons")


if __name__ == "__main__":
    main()