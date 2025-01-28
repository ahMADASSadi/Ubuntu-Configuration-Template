import subprocess
import sys
from src.menu import display_menu, get_user_choice


def run_shell_script(script_path):
    """
    Runs a shell script and displays its output in real-time.
    """
    try:
        process = subprocess.Popen(
            ["/bin/bash", script_path],
            stdout=sys.stdout,
            stderr=sys.stderr,
            text=True
        )
        process.wait()
    except FileNotFoundError:
        print(f"Error: Shell script not found at {
              script_path}", file=sys.stderr)
    except Exception as e:
        print(f"An error occurred while running the script: {
              e}", file=sys.stderr)


def view_or_edit_config(conf_path):
    """
    Displays the configuration file content and optionally allows editing in nano.
    """
    try:
        # Display the file contents
        with open(conf_path, "r") as f:
            config = f.read()
        subprocess.run(['clear'])
        print("\n--- Configuration File Contents ---")
        print(config)
        print("--- End of File ---\n")

        # Ask the user if they want to edit the file
        user_input = input(
            "Do you want to edit the file? (yes/no): ").strip().lower()
        if user_input in ("yes", "y"):
            subprocess.run(["nano", conf_path], check=True)
            print("File updated successfully.")
        else:
            print("No changes made to the file.")
    except FileNotFoundError:
        print(f"Error: Configuration file not found at {
              conf_path}", file=sys.stderr)
    except subprocess.CalledProcessError as e:
        print(f"Error: Failed to open nano: {e}", file=sys.stderr)
    except Exception as e:
        print(f"An unexpected error occurred: {e}", file=sys.stderr)


def main(choice):
    """
    Handles menu options based on user choice.
    """
    CONF_DIR = "./src/configurations/utc.conf"
    if choice == 0:
        view_or_edit_config(CONF_DIR)
    elif choice == 1:
        run_shell_script("./scripts/install.sh")
    elif choice == 2:
        run_shell_script("./scripts/ping.sh")
    elif choice == 3:
        print("Option 3 is not implemented.")
    else:
        print("Invalid choice. Please try again.")


if __name__ == '__main__':
    while True:
        subprocess.run(['clear'])
        display_menu()
        try:
            choice = get_user_choice()
            if not choice == "q":
                main(choice)
                input("\nPress Enter to return to the main menu...")

            else:
                print("\nExiting...")
                sys.exit(0)
        except ValueError:
            print(
                "Invalid input. Please enter a number corresponding to the menu options.")
        except KeyboardInterrupt:
            print("\nExiting...")
            sys.exit(0)
