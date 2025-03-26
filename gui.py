import pygame
import sys

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
    
    print("Board saved to board.c")

# Constants for the editor
CELL_SIZE = 40
GRID_WIDTH = 8
GRID_HEIGHT = 16
SIDEBAR_WIDTH = 200
WINDOW_WIDTH = GRID_WIDTH * CELL_SIZE + SIDEBAR_WIDTH
WINDOW_HEIGHT = GRID_HEIGHT * CELL_SIZE

# Colors
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
GRAY = (200, 200, 200)
BLUE = (0, 0, 255)
RED = (255, 0, 0)
YELLOW = (255, 255, 0)
GREEN = (0, 255, 0)

# Pill type constants - representing values for sprite1
EMPTY = 0b00000000
LEFT = 0b01100000
RIGHT = 0b01010000
TOP = 0b01001000
BOTTOM = 0b01000100

# Pill color constants - representing values for sprite0
COLOR_RED = 0b00000001
COLOR_BLUE = 0b00000010
COLOR_YELLOW = 0b00000100

class Editor:
    def __init__(self):
        pygame.init()
        self.window = pygame.display.set_mode((WINDOW_WIDTH, WINDOW_HEIGHT))
        pygame.display.set_caption("Pill Game Level Editor")
        
        # Initialize board with empty cells
        self.board = [[Cell(j*8 + 12*8, i*8+9*8) for j in range(GRID_WIDTH)] for i in range(GRID_HEIGHT)]
        
        # Selection state
        self.selected_pill_type = EMPTY
        self.selected_pill_color = COLOR_RED
        
        # Font for text
        self.font = pygame.font.SysFont("Arial", 20)
        
    def run(self):
        running = True
        while running:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False
                elif event.type == pygame.MOUSEBUTTONDOWN:
                    self.handle_mouse_click(event)
            
            self.window.fill(BLACK)
            self.draw_grid()
            self.draw_sidebar()
            pygame.display.flip()
        
        pygame.quit()
    
    def draw_grid(self):
        for y in range(GRID_HEIGHT):
            for x in range(GRID_WIDTH):
                # Draw cell background
                pygame.draw.rect(self.window, WHITE, (x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE))
                pygame.draw.rect(self.window, GRAY, (x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE), 1)
                
                # Check if cell has a pill
                cell = self.board[y][x]
                
                # If both sprite0 and sprite1 are 0, the cell is empty
                if cell.sprite0 == 0 and cell.sprite1 == 0:
                    continue
                
                # Determine pill color based on sprite0
                if cell.sprite0 & COLOR_RED:
                    color = RED
                elif cell.sprite0 & COLOR_BLUE:
                    color = BLUE
                elif cell.sprite0 & COLOR_YELLOW:
                    color = YELLOW
                else:
                    continue  # No valid color
                
                center_x = x * CELL_SIZE + CELL_SIZE // 2
                center_y = y * CELL_SIZE + CELL_SIZE // 2
                radius = CELL_SIZE // 3
                
                # Draw pill based on sprite1
                if cell.sprite1 == LEFT:
                    pygame.draw.circle(self.window, color, (center_x - radius//2, center_y), radius)
                elif cell.sprite1 == RIGHT:
                    pygame.draw.circle(self.window, color, (center_x + radius//2, center_y), radius)
                elif cell.sprite1 == TOP:
                    pygame.draw.circle(self.window, color, (center_x, center_y - radius//2), radius)
                elif cell.sprite1 == BOTTOM:
                    pygame.draw.circle(self.window, color, (center_x, center_y + radius//2), radius)
    
    def draw_sidebar(self):
        sidebar_x = GRID_WIDTH * CELL_SIZE
        pygame.draw.rect(self.window, WHITE, (sidebar_x, 0, SIDEBAR_WIDTH, WINDOW_HEIGHT))
        
        # Title
        title = self.font.render("Pill Editor", True, BLACK)
        self.window.blit(title, (sidebar_x + 10, 10))
        
        # Pill Type Selection
        pygame.draw.line(self.window, BLACK, (sidebar_x + 10, 40), (sidebar_x + SIDEBAR_WIDTH - 10, 40), 2)
        type_title = self.font.render("Pill Type:", True, BLACK)
        self.window.blit(type_title, (sidebar_x + 10, 50))
        
        pill_types = [("Empty", EMPTY), ("Left", LEFT), ("Right", RIGHT), ("Top", TOP), ("Bottom", BOTTOM)]
        for i, (type_name, type_value) in enumerate(pill_types):
            y_pos = 80 + i * 30
            rect = pygame.Rect(sidebar_x + 10, y_pos, SIDEBAR_WIDTH - 20, 25)
            color = GRAY if self.selected_pill_type == type_value else WHITE
            pygame.draw.rect(self.window, color, rect)
            pygame.draw.rect(self.window, BLACK, rect, 1)
            text = self.font.render(type_name, True, BLACK)
            self.window.blit(text, (sidebar_x + 15, y_pos + 2))
        
        # Pill Color Selection
        pygame.draw.line(self.window, BLACK, (sidebar_x + 10, 230), (sidebar_x + SIDEBAR_WIDTH - 10, 230), 2)
        color_title = self.font.render("Pill Color:", True, BLACK)
        self.window.blit(color_title, (sidebar_x + 10, 240))
        
        color_data = [
            ("Red", COLOR_RED, RED),
            ("Blue", COLOR_BLUE, BLUE),
            ("Yellow", COLOR_YELLOW, YELLOW)
        ]
        
        for i, (name, value, display_color) in enumerate(color_data):
            y_pos = 270 + i * 30
            rect = pygame.Rect(sidebar_x + 10, y_pos, SIDEBAR_WIDTH - 20, 25)
            border_color = GRAY if self.selected_pill_color == value else WHITE
            pygame.draw.rect(self.window, border_color, rect)
            pygame.draw.rect(self.window, BLACK, rect, 1)
            # Color sample
            pygame.draw.rect(self.window, display_color, (sidebar_x + 15, y_pos + 5, 15, 15))
            text = self.font.render(name, True, BLACK)
            self.window.blit(text, (sidebar_x + 40, y_pos + 2))
        
        # Save Button
        save_y = WINDOW_HEIGHT - 50
        save_rect = pygame.Rect(sidebar_x + 10, save_y, SIDEBAR_WIDTH - 20, 40)
        pygame.draw.rect(self.window, GREEN, save_rect)
        pygame.draw.rect(self.window, BLACK, save_rect, 1)
        save_text = self.font.render("Save Board", True, BLACK)
        self.window.blit(save_text, (sidebar_x + 55, save_y + 10))
    
    def handle_mouse_click(self, event):
        x, y = event.pos
        sidebar_x = GRID_WIDTH * CELL_SIZE
        
        # Check if click is in the grid
        if x < sidebar_x and y < WINDOW_HEIGHT:
            grid_x = x // CELL_SIZE
            grid_y = y // CELL_SIZE
            cell = self.board[grid_y][grid_x]
            
            if self.selected_pill_type == EMPTY:
                # Set to empty - all values should be zero
                cell.sprite0 = 0
                cell.sprite1 = 0
            else:
                # Set pill type
                cell.sprite1 = self.selected_pill_type
                
                # Set pill color
                cell.sprite0 = self.selected_pill_color
        
        # Check if click is in the sidebar
        elif x >= sidebar_x:
            # Pill type selection
            pill_types = [EMPTY, LEFT, RIGHT, TOP, BOTTOM]
            for i, type_value in enumerate(pill_types):
                y_pos = 80 + i * 30
                if sidebar_x + 10 <= x <= sidebar_x + SIDEBAR_WIDTH - 10 and y_pos <= y <= y_pos + 25:
                    self.selected_pill_type = type_value
                    return
            
            # Pill color selection
            color_values = [COLOR_RED, COLOR_BLUE, COLOR_YELLOW]
            for i, color_value in enumerate(color_values):
                y_pos = 270 + i * 30
                if sidebar_x + 10 <= x <= sidebar_x + SIDEBAR_WIDTH - 10 and y_pos <= y <= y_pos + 25:
                    self.selected_pill_color = color_value
                    return
            
            # Save button
            save_y = WINDOW_HEIGHT - 50
            if sidebar_x + 10 <= x <= sidebar_x + SIDEBAR_WIDTH - 10 and save_y <= y <= save_y + 40:
                write_board(self.board, GRID_HEIGHT, GRID_WIDTH, GRID_WIDTH * GRID_HEIGHT)

def main():
    editor = Editor()
    editor.run()

if __name__ == "__main__":
    main()
