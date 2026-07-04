import urllib.request
import re
import json
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE


queries = [
    "RRQ Hoshi MPL Indonesia Season",
    "Bigetron Red Aliens PUBG",
    "Paper Rex Valorant",
    "Dota 2 Gameplay patch",
    "EVOS Glory MLBB"
]

results = []
for q in queries:
    url = "https://html.duckduckgo.com/html/?q=" + urllib.parse.quote(q + " image")
    req = urllib.request.Request(
        url, 
        data=None, 
        headers={
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
    )
    try:
        response = urllib.request.urlopen(req, context=ctx)
        html = response.read().decode('utf-8')
        # duckduckgo html image search often redirects or we can just grab first image src that looks like http
        imgs = re.findall(r'src="(//external-content\.duckduckgo\.com/iu/\?u=[^"]+)"', html)
        if imgs:
            results.append("https:" + imgs[0].replace("&amp;", "&"))
        else:
            results.append("Not found")
    except Exception as e:
        results.append(str(e))

print(json.dumps(results, indent=2))
