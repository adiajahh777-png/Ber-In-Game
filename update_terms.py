import os
import glob

terms_content = """<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Terms of Service - Berita Internasional Gamers</title>
    <meta name="description" content="Syarat dan Ketentuan layanan aplikasi agregator berita esports Berita Internasional Gamers.">
    <meta name="keywords" content="terms of service, syarat dan ketentuan, berita internasional gamers">
    <meta name="author" content="Adi gunawan">
    <meta name="theme-color" content="#6200EA">
    <meta property="og:title" content="Terms of Service - Berita Internasional Gamers">
    <meta property="og:description" content="Syarat dan Ketentuan layanan aplikasi agregator berita esports kami.">
    <meta property="og:type" content="website">
    <meta property="og:url" content="https://adiajahh777-png.github.io/Website-Saya/terms.html">
    <link rel="canonical" href="https://adiajahh777-png.github.io/Website-Saya/terms.html">
    <link rel="icon" type="image/x-icon" href="favicon.ico">
    <link rel="manifest" href="manifest.json">
    <meta name="robots" content="index, follow">
    <link rel="stylesheet" href="style.css">
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "WebSite",
      "name": "Berita Internasional Gamers",
      "url": "https://adiajahh777-png.github.io/Website-Saya/"
    }
    </script>
</head>
<body>
    <header>
        <nav class="nav-container" aria-label="Main Navigation">
            <a href="index.html" class="logo" style="font-size: 1.2rem;">Berita Internasional Gamers</a>
            <button class="menu-toggle" aria-label="Toggle navigation" aria-expanded="false">
                <span></span><span></span><span></span>
            </button>
            <ul class="nav-links">
                <li><a href="index.html">Home</a></li>
                <li><a href="about.html">About Us</a></li>
                <li><a href="contact.html">Contact Us</a></li>
                <li><a href="privacy.html">Privacy Policy</a></li>
                <li><a href="sources.html">Sumber Berita</a></li>
                <li><a href="copyright.html">Copyright</a></li>
                <li><a href="terms.html">Terms of Service</a></li>
            </ul>
        </nav>
    </header>

    <main>
        <section class="container page-section">
            <h1 class="page-title">Terms of Service</h1>
            
            <article class="content-card">
                <ul>
                    <li><strong>Berita Internasional Gamers</strong> adalah aplikasi agregator berita esports.</li>
                    <li>Seluruh artikel, gambar, logo, dan merek dagang tetap menjadi milik penerbit aslinya.</li>
                    <li>Aplikasi hanya menampilkan ringkasan berita dan tautan menuju sumber resmi.</li>
                    <li>Pengguna bertanggung jawab atas penggunaan informasi yang diperoleh.</li>
                    <li>Pengembang dapat memperbarui layanan dan syarat penggunaan sewaktu-waktu.</li>
                    <li>Pengembang tidak menjamin seluruh informasi selalu akurat karena berasal dari pihak ketiga.</li>
                </ul>
            </article>
        </section>
    </main>

    <footer class="site-footer">
        <div class="footer-container">
            <div class="footer-section">
                <h3>Berita Internasional Gamers</h3>
                <p>Berita Internasional Gamers merupakan aplikasi agregator berita esports yang mengambil berita dari berbagai sumber terpercaya. Seluruh hak cipta artikel tetap menjadi milik masing-masing penerbit.</p>
            </div>
            <div class="footer-section">
                <h3>Tautan Cepat</h3>
                <ul>
                    <li><a href="index.html">Home</a></li>
                    <li><a href="about.html">About Us</a></li>
                    <li><a href="contact.html">Contact Us</a></li>
                    <li><a href="privacy.html">Privacy Policy</a></li>
                    <li><a href="sources.html">Sumber Berita</a></li>
                    <li><a href="copyright.html">Copyright</a></li>
                    <li><a href="terms.html">Terms of Service</a></li>
                </ul>
            </div>
            <div class="footer-section">
                <h3>Kontak</h3>
                <p><strong>Email:</strong> <a href="mailto:adiajahh777@gmail.com" class="text-muted">adiajahh777@gmail.com</a></p>
                <p><strong>Lokasi:</strong> Pamekasan, Jawa Timur, Indonesia</p>
                <p><strong>Developer:</strong> Adi gunawan</p>
            </div>
        </div>
        <div class="footer-bottom">
            <p>Copyright &copy; 2026 Berita Internasional Gamers. Hak cipta dilindungi undang-undang.</p>
        </div>
    </footer>
    <script src="script.js"></script>
</body>
</html>"""

with open('terms.html', 'w', encoding='utf-8') as f:
    f.write(terms_content)

html_files = glob.glob('*.html')
for file in html_files:
    if file == 'terms.html': continue
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # URL replacement for all remaining files
    content = content.replace('https://beritainternasionalgamers.github.io/', 'https://adiajahh777-png.github.io/Website-Saya/')
    
    # Update navbar & footer. Replace <a href="copyright.html">Copyright</a> with Copyright and Terms
    nav_search = '<li><a href="copyright.html">Copyright</a></li>'
    nav_replace = '<li><a href="copyright.html">Copyright</a></li>\n                <li><a href="terms.html">Terms of Service</a></li>'
    
    if nav_search in content and '<li><a href="terms.html">Terms of Service</a></li>' not in content:
        content = content.replace(nav_search, nav_replace)

    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)
print('Done!')
