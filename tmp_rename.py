import os

ROOT_DIR = '/Users/Shared/augmented-ai-apps/imdb'
EXCLUDE_DIRS = {'.git', 'build', '.dart_tool', 'macos/Flutter/ephemeral', 'ios/Pods', '.idea', 'linux/flutter/ephemeral', 'windows/flutter/ephemeral', '.vscode', 'tmp_rename.py'}

REPLACEMENTS = [
    ('neon_voyager', 'stream_scout'),
    ('neonvoyager', 'streamscout'),
    ('Neon Voyager', 'StreamScout'),
    ('NeonVoyager', 'StreamScout'),
    ('Neon Dev', 'StreamScout Dev'),
    ('Neon Stg', 'StreamScout Stg')
]

def is_excluded(path):
    rel_path = os.path.relpath(path, ROOT_DIR)
    parts = rel_path.split(os.sep)
    for ext in EXCLUDE_DIRS:
        if ext in parts:
            return True
        if '/' in ext:
            if rel_path.startswith(ext.replace('/', os.sep)):
                return True
    return False

def rename_content():
    changed_files = 0
    for root, dirs, files in os.walk(ROOT_DIR, topdown=True):
        dirs[:] = [d for d in dirs if not is_excluded(os.path.join(root, d))]
        for file in files:
            file_path = os.path.join(root, file)
            if file == 'tmp_rename.py' or file.endswith(('.png', '.jpg', '.jpeg', '.gif', '.icns', '.ico', '.keystore', '.jks', '.zip', '.tar.gz', '.pb')):
                continue
            
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()

                new_content = content
                for old, new in REPLACEMENTS:
                    new_content = new_content.replace(old, new)

                if content != new_content:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    changed_files += 1
            except UnicodeDecodeError:
                pass
            except Exception as e:
                pass
    print(f"Modified content in {changed_files} files.")

def rename_paths():
    changed_paths = 0
    for root, dirs, files in os.walk(ROOT_DIR, topdown=False):
        for name in files + dirs:
            file_path = os.path.join(root, name)
            if is_excluded(file_path):
                continue
            
            new_name = name
            for old, new in REPLACEMENTS:
                new_name = new_name.replace(old, new)
            
            if name != new_name:
                new_path = os.path.join(root, new_name)
                os.rename(file_path, new_path)
                changed_paths += 1
    print(f"Renamed {changed_paths} files/directories.")

if __name__ == '__main__':
    rename_content()
    rename_paths()
