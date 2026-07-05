import urllib.request
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

urls = [
    "https://upload.wikimedia.org/wikipedia/commons/e/ed/LOGO_RRQ_orange.png",
    "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7d/PlayerUnknown%27s_Battlegrounds_logo.svg/512px-PlayerUnknown%27s_Battlegrounds_logo.svg.png",
    "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/Valorant_logo_-_pink_color_version.svg/512px-Valorant_logo_-_pink_color_version.svg.png",
    "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Dota_2_icon.png/512px-Dota_2_icon.png",
    "https://upload.wikimedia.org/wikipedia/en/thumb/1/1a/Mobile_Legends_Bang_Bang_logo.png/512px-Mobile_Legends_Bang_Bang_logo.png"
]

for u in urls:
    try:
        urllib.request.urlopen(u, context=ctx)
        print("OK", u)
    except Exception as e:
        print("FAIL", u, e)
