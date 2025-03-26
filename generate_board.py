class Cell:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.sprite0 = 0
        self.sprite1 = 0
        self.anim_frame = 0
        self.meta = 0
        self.buffer0 = 0
        self.buffer1 = 0

    def __repr__(self):
        return bin(self.sprite1)
    
    def txt(self):
        return " ".join([
            hex(self.x),
            hex(self.y),
            hex(self.sprite0),
            hex(self.sprite1),
            hex(self.anim_frame),
            hex(self.meta),
            hex(self.buffer0),
            hex(self.buffer1),
        ])

def print_table(data):
    if not data:
        return

    # Find the maximum width for each column
    col_widths = [max(len(str(item)) for item in col) for col in zip(*data)]

    for row in data:
        # Format each row according to the column widths
        print(" ".join(f"{str(item).ljust(width)}" for item, width in zip(row, col_widths)))

def write_board(board, rows, cols, size):
    cells = []
    for row in board:
        for col in row:
            cells.append(col.txt())

    with open("board.c", "w") as f:
        f.write(f"board_size: .word {size}\n")
        f.write(f"board_height: .word {rows}\n")
        f.write(f"board_height_minus_one: .word {rows-1}\n")
        f.write(f"board_width: .word {cols}\n")
        f.write(f"board_width_minus_one: .word {cols-1}\n")
        f.write(f"board: .word {'\n'.join(cells)}")

rows = 16
columns = 8
board = [[Cell(j*8 + 12*8, i*8+9*8) for j in range(columns)] for i in range(rows)]

for y in range(rows):
    for x in range(columns):
        board[y][x].sprite1 |= 1 << 6
        board[y][x].sprite1 |= 1 << 1
        board[y][x].sprite0 |= 1
board[0][0].sprite1 |= 1 << 6
board[0][0].sprite1 |= 1 << 1
board[0][0].sprite0 &= 0
board[0][0].sprite0 |= 1 << 1


print_table(board)
write_board(board, rows, columns, columns * rows)
