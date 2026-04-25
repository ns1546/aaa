import os
import zipfile

def create_zip():
    zipf = zipfile.ZipFile('smart_image_app_fixed.zip', 'w', zipfile.ZIP_DEFLATED)
    for root, dirs, files in os.walk('.'):
        # Exclude existing zips and hidden folders
        if '.git' in root or '.gemini' in root:
            continue
        for file in files:
            if file.endswith('.zip') or file.endswith('.py'):
                continue # Don't pack the script or other zips
            
            filepath = os.path.join(root, file)
            # Create a clean archive name using forward slashes
            arcname = os.path.relpath(filepath, '.').replace('\\', '/')
            zipf.write(filepath, arcname)
    zipf.close()

if __name__ == '__main__':
    create_zip()
    print("Zip created via Python.")
