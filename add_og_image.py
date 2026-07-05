import os
import glob
import re

html_files = glob.glob('*.html')
meta_og_image = '    <meta property="og:image" content="https://adiajahh777-png.github.io/Website-Saya/logo.png">\n'

for file in html_files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if '<meta property="og:image"' not in content:
        # insert before </head>
        content = re.sub(r'(</head>)', meta_og_image + r'\1', content, count=1, flags=re.IGNORECASE)
        
        with open(file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'Added og:image to {file}')
    else:
        # If og:image is already there, we might need to replace it.
        # Let's replace the existing one just in case.
        content = re.sub(r'<meta property="og:image" content="[^"]*">\n?', meta_og_image, content)
        with open(file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'Replaced og:image in {file}')
