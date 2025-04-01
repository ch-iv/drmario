from pathlib import Path

def read_ppm(file_path: Path) -> tuple[int, int, list[list[tuple[int, int, int]]]]:
    with open(file_path, 'rb') as f:
        header = f.readline().decode().strip()
        if header not in ('P3', 'P6'):
            raise ValueError('Unsupported PPM format: {}'.format(header))

        dimensions = f.readline().decode().strip()
        while dimensions.startswith('#'):
            dimensions = f.readline().decode().strip()

        width, height = map(int, dimensions.split())
        max_color = int(f.readline().decode().strip())

        if max_color != 255:
            raise ValueError('Only max color value of 255 is supported')

        pixels = []

        if header == 'P3':
            for _ in range(height):
                row = []
                for _ in range(width):
                    r = int(f.readline().strip())
                    g = int(f.readline().strip())
                    b = int(f.readline().strip())
                    row.append((r, g, b))
                pixels.append(row)

        elif header == 'P6':
            raw_data = f.read(width * height * 3)
            for y in range(height):
                row = []
                for x in range(width):
                    i = (y * width + x) * 3
                    r, g, b = raw_data[i:i + 3]
                    row.append((r, g, b))
                pixels.append(row)

        return width, height, pixels


def rgb_to_hex(rgb):
    if not (isinstance(rgb, tuple) and len(rgb) == 3):
        raise ValueError("Input must be a tuple of three integers (R, G, B)")
    r, g, b = rgb
    if not all(0 <= value <= 255 for value in (r, g, b)):
        raise ValueError("Each color value must be between 0 and 255")

    return f'0x{r:02X}{g:02X}{b:02X}'


def get_input_assets() -> list[Path]:
    return list((Path(__file__).parent / "assets").iterdir())

def map_color(color: tuple[int, int, int], filename: str) -> tuple[int, int, int]:
    if filename.startswith("pill_") or filename.startswith("virus_"):
        tmp = filename.split("_")
        filename = f"{tmp[0]}_{tmp[1]}"
    color_map = {
        "pill_blue": {
            (255, 0, 0): (96, 160, 255),
            (0, 255, 0): (232, 208, 32),
        },
        "pill_yellow": {
            (255, 0, 0): (232, 208, 32),
            (0, 255, 0): (96, 160, 255),
        },
        "pill_red": {
            (255, 0, 0): (216, 64, 96),
            (0, 255, 0): (232, 208, 32),
        },
        "virus_blue": {
            (255, 0, 0): (96, 160, 255),
            (0, 255, 0): (232, 208, 32),
        },
        "virus_yellow": {
            (255, 0, 0): (232, 208, 32),
            (0, 255, 0): (96, 160, 255),
        },
        "virus_red": {
            (255, 0, 0): (216, 64, 96),
            (0, 255, 0): (232, 208, 32),
        },
   }

    filename_color_map = color_map.get(filename, {})

    if color not in filename_color_map:
        return color

    return filename_color_map[color]


def main():
    for path in get_input_assets():
        width, height, pixels = read_ppm(path)
        asset_name = path.name.removesuffix(".ppm")
        asset_names = [asset_name]
        if asset_name.startswith("pill_") or asset_name.startswith("virus_"):
            pill = asset_name.split("_")
            asset_names = [f"{pill[0]}_{color}_{pill[1]}" for color in ["red", "blue", "yellow"]]
        for asset_name in asset_names:
            words = ""
            n = 0
            for x in range(width):
                for y in range(height):
                    color = pixels[y][x]
    
                    if color != (0, 0, 0):
                        if n % 8 == 0 and n != 0:
                            words += "\n"
    
                        color = map_color(color, asset_name)
    
    
                        words += f"{rgb_to_hex((0, 0, x))}, {rgb_to_hex((0, 0, y))}, {rgb_to_hex(color)}, "
                        n += 1
    
            words.removesuffix(", ")
            asset_name = asset_name.removesuffix("_")    
            with open(f"{asset_name}.c", "w") as f:
                f.write(
                    f"asset_{asset_name}_size: .word {n}\n"
                    f"asset_{asset_name}_data: .word\n"
                    f"{words}"
                )   

if __name__ == '__main__':
    main()

