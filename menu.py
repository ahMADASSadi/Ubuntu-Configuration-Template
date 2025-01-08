from colorama import init as colorama_init
from colorama import Fore,Back
from colorama import Style
import os

colorama_init()
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
    """Displays a menu of options to the user."""
    # Display the logo
    print(f"{Back.BLACK}{Fore.CYAN}{center_text(logo)}{Style.RESET_ALL}")

    # Display the menu options
    menu_text = """
Welcome to the Ubuntu Configuration Tool (UCT)
Please choose an option:
0: See and Update the configuration file
1: Install apps
2: Test ping of the VPN servers

q: Exit
"""
    print(f"{Fore.MAGENTA}{center_text(menu_text)}{Style.RESET_ALL}")



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
