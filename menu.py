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


def display_menu():
    """Displays a menu of options to the user."""
    print(logo)
    print("Welcome to the Ubuntu Configuration Tool(UCT)")
    print("Please choose an option:")
    print("1: Install apps")
    print("2: Test ping of the vpn servers")

    print("q: Exit")


def get_user_choice() -> int:
    """Gets the user's choice from the menu.

    Returns:
        int: The user's choice as an integer.
    """
    while True:
        try:
            choice = int(input("Enter your choice (1 or 2): "))
            if choice in [1, 2]:
                return choice
            else:
                print("Invalid choice. Please enter 1 or 2.")
        except ValueError:
            print("Invalid input. Please enter a number.")
