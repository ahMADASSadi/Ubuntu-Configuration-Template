from typing import Optional
import subprocess
import sys


def main(shell_path:Optional[str]="./core/main.sh"):
    """Runs the main shell file for configurations

    Args:
        shell_path (Optional[str], optional): path to the shell file. Defaults to "./core/main.sh".
    """
    try:
        process = subprocess.Popen(
            ["/bin/zsh", shell_path],  
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
        print(f"Error: Shell script not found at {shell_path}", file=sys.stderr)
    except Exception as e:
        print(f"An error occurred: {e}", file=sys.stderr)



if __name__ == '__main__':
    if len(sys.argv) != 2:
        main()
    elif len(sys.argv) ==2:
        shell_path = sys.argv[1]
        main(shell_path)