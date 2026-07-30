import os
import shutil
import datetime

build_dir = r'E:\InvoBharat\build'
dest_dir = r'C:\Users\suyas\AppData\Local\Programs\InvoBharat'

found_exe = None
for root, dirs, files in os.walk(build_dir):
    if 'invobharat.exe' in files:
        found_exe = os.path.join(root, 'invobharat.exe')
        found_folder = root
        print(f"Found compiled executable at: {found_folder}")
        
        # Copy all files from build output folder to dest_dir
        for f in os.listdir(found_folder):
            s_path = os.path.join(found_folder, f)
            d_path = os.path.join(dest_dir, f)
            if os.path.isdir(s_path):
                shutil.copytree(s_path, d_path, dirs_exist_ok=True)
            else:
                shutil.copy2(s_path, d_path)
        print("Successfully copied all build artifacts to installed app directory!")
        break

if not found_exe:
    print("NO invobharat.exe found in build folder! Triggering flutter build...")
    os.system(r'set "JAVA_HOME=C:\Program Files\Java\jdk-21.0.12" && flutter build windows --release')
    for root, dirs, files in os.walk(build_dir):
        if 'invobharat.exe' in files:
            found_folder = root
            for f in os.listdir(found_folder):
                s_path = os.path.join(found_folder, f)
                d_path = os.path.join(dest_dir, f)
                if os.path.isdir(s_path):
                    shutil.copytree(s_path, d_path, dirs_exist_ok=True)
                else:
                    shutil.copy2(s_path, d_path)
            print("Successfully compiled and copied release binary!")
            break

exe_dest = os.path.join(dest_dir, 'invobharat.exe')
if os.path.exists(exe_dest):
    mtime = os.path.getmtime(exe_dest)
    print(f"VERIFIED INSTALLED EXE MODIFIED TIME: {datetime.datetime.fromtimestamp(mtime)}")
