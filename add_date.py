import os
import re

files = ['privacy.html', 'about.html', 'copyright.html', 'terms.html', 'disclaimer.html']
update_html = '\n            <p class="last-updated" style="text-align: center; color: #666; margin-top: -10px; margin-bottom: 20px; font-style: italic;">Last Updated: July 2026</p>'

for file in files:
    if os.path.exists(file):
        with open(file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        if 'class="page-title">' in content and 'Last Updated' not in content:
            content = re.sub(r'(<h1 class="page-title">.*?</h1>)', r'\1' + update_html, content, count=1)
            
            with open(file, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f'Updated {file}')
        elif 'Last Updated' in content:
            print(f'Already updated {file}')
        else:
            print(f'Could not find page-title in {file}')
    else:
        print(f'{file} not found')
