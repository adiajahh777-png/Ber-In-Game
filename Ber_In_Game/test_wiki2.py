import urllib.request
import re

def get_wiki_img(page):
    url = "https://en.wikipedia.org/wiki/" + page
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        html = urllib.request.urlopen(req).read().decode('utf-8')
        match = re.search(r'<meta property="og:image" content="([^"]+)"', html)
        return match.group(1) if match else "None"
    except Exception as e:
        return str(e)

print("PUBG:", get_wiki_img("PUBG:_Battlegrounds"))
print("Valorant:", get_wiki_img("Valorant"))
print("Dota 2:", get_wiki_img("Dota_2"))
print("MLBB:", get_wiki_img("Mobile_Legends:_Bang_Bang"))
