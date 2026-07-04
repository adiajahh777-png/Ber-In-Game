import urllib.request
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

url = "https://upload.wikimedia.org/wikipedia/commons/e/ed/LOGO_RRQ_orange.png"
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    urllib.request.urlopen(req, context=ctx)
    print("OK")
except Exception as e:
    print("FAIL", e)
