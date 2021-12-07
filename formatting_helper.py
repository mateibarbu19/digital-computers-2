import os

'''
This script recursively changes all files (.v and .vh) in the current directory and in its subdirectories making the following changes:
* adds verilator instructions to the top of the file for fixing minor warnings
* converts CRLF to LF

Usage: python3 formatting_helper.py
'''

# replacement strings
WINDOWS_LINE_ENDING = b'\r\n'
UNIX_LINE_ENDING = b'\n'

print("This script recursively adds a verilator instruction to all files in the current directory and its subdirectories.")
instructions = b'/* verilator lint_off UNUSED */\n/* verilator lint_off UNDRIVEN */\n/* verilator lint_off UNOPTFLAT */\n'

# get all .v and .vh files
files = [os.path.join(dp, f) for dp, dn, filenames in os.walk(".") for f in filenames if os.path.splitext(f)[1] == '.v' or os.path.splitext(f)[1] == '.vh']

# iterate through all files
for file in files:
  with open(file, 'rb') as f:
    content = f.read()

  with open(file, 'wb') as f:
    f.seek(0)
    # convert CRLF to LF
    content = content.replace(WINDOWS_LINE_ENDING, UNIX_LINE_ENDING)

    if (content.startswith(instructions)):
      f.write(content)
    else:
      f.write(instructions + content)