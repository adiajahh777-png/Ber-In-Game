import os
import glob
import re

html_files = glob.glob('*.html')
meta_robots = '    <meta name="robots" content="index, follow">\n'

for file in html_files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if '<meta name="robots"' not in content:
        # insert before </head>
        content = re.sub(r'(</head>)', meta_robots + r'\1', content, count=1, flags=re.IGNORECASE)
        
        with open(file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'Added meta robots to {file}')
    else:
        print(f'meta robots already exists in {file}')
