# %%
import os
import zipfile
import shutil

runner_app_path = "build/ios/iphoneos/Runner.app"
if os.path.exists(runner_app_path):
    if os.path.exists("Payload"):
        shutil.rmtree("Payload")

    os.makedirs("Payload/Payload")
    shutil.copytree(runner_app_path, "Payload/Payload/Runner.app")

    def zip_folder(folder_path, zip_name):
        # create a ZipFile object
        with zipfile.ZipFile(zip_name, "w", zipfile.ZIP_DEFLATED) as zipf:
            # recursively add all files to the zip file
            for root, _, files in os.walk(folder_path):
                for file in files:
                    file_path = os.path.join(root, file)
                    zipf.write(file_path, os.path.relpath(file_path, folder_path))

    zip_folder("Payload", "ios-build.ipa")
    shutil.rmtree("Payload")
