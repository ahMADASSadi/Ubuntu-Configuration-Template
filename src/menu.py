import os

logo = """
 █████  █████   █████████  ███████████                                                                                    
░░███  ░░███   ███░░░░░███░█░░░███░░░█                                                                                    
 ░███   ░███  ███     ░░░ ░   ░███  ░                                                                                     
 ░███   ░███ ░███             ░███                                                                                        
 ░███   ░███ ░███             ░███                                                                                        
 ░███   ░███ ░░███     ███    ░███                                                                                        
 ░░████████   ░░█████████     █████                                                                                       
  ░░░░░░░░     ░░░░░░░░░     ░░░░░                                                                                        
"""


def center_text(text: str) -> str:
    """
    Centers text for terminal output based on the terminal width.
    """
    terminal_width = os.get_terminal_size().columns
    lines = text.splitlines()
    centered_lines = [
        line.center(terminal_width) for line in lines
    ]
    return "\n".join(centered_lines)


def display_menu():
    """
    Displays a menu of options to the user.
    """
    
    menu_text = """
    Welcome to the Ubuntu Configuration Tool
    Please choose an option:
    0: See and Update the configuration file
    1: Install apps
    2: Test ping of the VPN servers

    q: Exit
    """
    
    try:
        from colorama import Fore, Style, init as colorama_init
        colorama_init()
        print(f"{Fore.CYAN}{center_text(logo)}{Style.RESET_ALL}")
        print(f"{Fore.MAGENTA}{menu_text}{Style.RESET_ALL}")
        
    except ImportError:
        print(f"{center_text(logo)}")
        print(f"{menu_text}")

def get_user_choice() -> int:
    """Gets the user's choice from the menu.

    Returns:
        int: The user's choice as an integer.
    """
    while True:
        try:
            choice = (input("Enter your choice: "))
            if not choice == "q":
                return int(choice)
            elif choice == "q":
                return choice
            else:
                print("Invalid choice. Please enter 1 or 2.")
        except ValueError:
            print("Invalid input. Please enter a number.")
