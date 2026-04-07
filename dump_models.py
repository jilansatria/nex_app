import dis
import marshal
import glob
import sys

for pyc_path in glob.glob("app/models/__pycache__/*.cpython-310.pyc"):
    print(f"--- DUMPING: {pyc_path} ---")
    with open(pyc_path, "rb") as f:
        f.read(16) # Skip the 16 byte header for Python 3.7+
        try:
            code = marshal.load(f)
            # We don't need full instruction dump, just names and constants to see column definitions
            print("NAMES:", code.co_names)
            print("CONSTS:", code.co_consts)
            
            # Inspect class definitions inside
            for const in code.co_consts:
                if type(const).__name__ == 'code':
                    print(f"  CLASS {const.co_name} NAMES:", const.co_names)
                    print(f"  CLASS {const.co_name} CONSTS:", const.co_consts)
        except Exception as e:
            print(f"Error parsing {pyc_path}: {e}")
