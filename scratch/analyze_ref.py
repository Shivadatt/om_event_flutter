from PIL import Image

im = Image.open(r'd:\om_event_python\om_event\assets\images\card_crop.png').convert('RGB')
pixels = im.load()
w, h = im.size

# Let's inspect columns
for x_start in range(7, 965, 10):
    cnt = 0
    for x in range(x_start, min(x_start + 10, 965)):
        for y in range(25, 160):
            r, g, b = pixels[x, y]
            if r > 120 or g > 120 or b > 120:
                cnt += 1
    if cnt > 20:
        bar = '#' * (cnt // 25)
        print(f"x={x_start-7:3d}..{x_start-7+10:3d}: cnt={cnt:4d} | {bar}")
