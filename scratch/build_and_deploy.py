import os
import shutil
import subprocess
import time
import datetime

print("1. Terminating any running invobharat.exe processes...")
subprocess.run("taskkill /F /IM invobharat.exe", shell=True, capture_output=True)
time.sleep(1)

print("2. Removing old build directory...")
build_path = r'E:\InvoBharat\build'
if os.path.exists(build_path):
    try:
        shutil.rmtree(build_path, ignore_errors=True)
        print("Cleaned build directory.")
    except Exception as e:
        print(f"Build clean warning: {e}")

print("3. Building Windows Release Application...")
env = os.environ.copy()
env["JAVA_HOME"] = r"C:\Program Files\Java\jdk-21.0.12"

result = subprocess.run(
    "flutter build windows --release",
    shell=True,
    cwd=r"E:\InvoBharat",
    env=env,
    capture_output=True,
    text=True
)

print(f"Flutter build return code: {result.returncode}")
if result.returncode != 0:
    print("BUILD STDOUT:\n", result.stdout[-1500:])
    print("BUILD STDERR:\n", result.stderr[-1500:])
else:
    print("Flutter Build Succeeded!")

# Find compiled release executable
release_exe = r'E:\InvoBharat\build\windows\x64\runner\Release\invobharat.exe'
release_dir = r'E:\InvoBharat\build\windows\x64\runner\Release'

if not os.path.exists(release_exe):
    # Search fallback paths
    for root, dirs, files in os.walk(r'E:\InvoBharat\build'):
        if 'invobharat.exe' in files:
            release_dir = root
            release_exe = os.path.join(root, 'invobharat.exe')
            break

print(f"Target release executable: {release_exe}")

if os.path.exists(release_exe):
    dest_dir = r'C:\Users\suyas\AppData\Local\Programs\InvoBharat'
    print(f"4. Deploying release files to {dest_dir}...")
    shutil.copytree(release_dir, dest_dir, dirs_exist_ok=True)
    
    dest_exe = os.path.join(dest_dir, 'invobharat.exe')
    mtime = os.path.getmtime(dest_exe)
    mod_time = datetime.datetime.fromtimestamp(mtime)
    print(f"\n=======================================================")
    print(f"SUCCESS: Deployed new release build!")
    print(f"Installed Executable: {dest_exe}")
    print(f"Last Modified Time:   {mod_time}")
    print(f"=======================================================")
else:
    print("CRITICAL ERROR: Release executable was not generated.")
