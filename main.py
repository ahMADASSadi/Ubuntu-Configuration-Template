import subprocess
import sys
from menu import display_menu,get_user_choice
def main(choise: int):
    """
    Runs the main shell file for installing the set apps.
    """
    if choise == 1:
        try:
            shell_path = "./core/install.sh"
            process = subprocess.Popen(
                ["/bin/bash", shell_path],
                stdin=sys.stdin,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )

            while True:
                output = process.stdout.readline()
                if output == "" and process.poll() is not None:
                    break
                if output:
                    print(output.strip())

            stderr = process.stderr.read()
            if stderr:
                print(f"Error: {stderr}", file=sys.stderr)

            process.wait()

        except FileNotFoundError:
            print(f"Error: Shell script not found at {
                shell_path}", file=sys.stderr)
        except Exception as e:
            print(f"An error occurred: {e}", file=sys.stderr)
    elif choise == 2:
        try:
            shell_path = "./core/ping.sh"
            process = subprocess.Popen(
                ["/bin/bash", shell_path],
                stdin=sys.stdin,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )

            while True:
                output = process.stdout.readline()
                if output == "" and process.poll() is not None:
                    break
                if output:
                    print(output.strip())

            stderr = process.stderr.read()
            if stderr:
                print(f"Error: {stderr}", file=sys.stderr)

            process.wait()

        except FileNotFoundError:
            print(f"Error: Shell script not found at {
                shell_path}", file=sys.stderr)
        except Exception as e:
            print(f"An error occurred: {e}", file=sys.stderr)
    
    elif choise == 3:
        pass


if __name__ == '__main__':
    display_menu()
    choice = get_user_choice()

    if not choice in ["q"]:
        main(choice)
    else:
        print("Exiting...")
        sys.exit(0)
