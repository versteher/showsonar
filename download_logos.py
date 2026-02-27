import re
import os
import urllib.request
import urllib.error

domains = {
    'netflix_logo.png': 'netflix.com',
    'disney_plus_logo.png': 'disneyplus.com',
    'amazon_prime_logo.png': 'primevideo.com',
    'apple_tv_logo.png': 'tv.apple.com',
    'paramount_plus_logo.png': 'paramountplus.com',
    'crunchyroll_logo.png': 'crunchyroll.com',
    'hbo_max_logo.png': 'max.com',
    'mubi_logo.png': 'mubi.com',
    'hulu_logo.png': 'hulu.com',
    'peacock_logo.png': 'peacocktv.com',
    'fubo_logo.png': 'fubo.tv',
    'crave_logo.png': 'crave.ca',
    'britbox_logo.png': 'britbox.com',
    'rtl_logo.png': 'plus.rtl.de',
    'joyn_logo.png': 'joyn.de',
    'wow_logo.png': 'wowtv.de',
    'magenta_logo.png': 'magentatv.de',
    'ard_logo.png': 'ardmediathek.de',
    'zdf_logo.png': 'zdf.de',
    'arte_logo.png': 'arte.tv',
    'srf_logo.png': 'srf.ch',
    'playsuisse_logo.png': 'playsuisse.ch',
    'dr_logo.png': 'dr.dk',
    'canal_plus_logo.png': 'canalplus.com',
    'movistar_logo.png': 'ver.movistarplus.es',
    'filmin_logo.png': 'filmin.es',
    'viaplay_logo.png': 'viaplay.com',
    'skyshowtime_logo.png': 'skyshowtime.com',
    'videoland_logo.png': 'videoland.com',
    'yle_logo.png': 'areena.yle.fi',
    'foxtel_logo.png': 'foxtel.com.au',
    'showmax_logo.png': 'showmax.com',
    'claro_logo.png': 'clarovideo.com',
    'unext_logo.png': 'video.unext.jp',
    'wavve_logo.png': 'wavve.com',
    'watcha_logo.png': 'watcha.com',
    'hotstar_logo.png': 'hotstar.com',
    'zee5_logo.png': 'zee5.com',
    'viu_logo.png': 'viu.com',
    'iflix_logo.png': 'iflix.com',
    'puhutv_logo.png': 'puhutv.com',
    'okko_logo.png': 'okko.tv',
}

file_path = '/Users/Shared/augmented-ai-apps/imdb/lib/data/models/streaming_provider.dart'
assets_dir = '/Users/Shared/augmented-ai-apps/imdb/assets/images/'

os.makedirs(assets_dir, exist_ok=True)

with open(file_path, 'r') as f:
    content = f.read()

matches = re.findall(r"logoPath:\s*'assets/images/([^']+)'", content)

downloaded = 0
for match in set(matches):
    domain = domains.get(match)
    if not domain:
        name_part = match.replace('_logo.png', '').replace('_', '')
        domain = name_part + '.com'
    
    # Try clearbit first, then fallback to google favicon
    urls = [
        f"https://logo.clearbit.com/{domain}?size=128",
        f"https://www.google.com/s2/favicons?domain={domain}&sz=128"
    ]
    
    out_path = os.path.join(assets_dir, match)
    
    success = False
    for url in urls:
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req) as response, open(out_path, 'wb') as out_file:
                out_file.write(response.read())
            
            # check if file is too small (e.g. google generic earth icon or empty)
            if os.path.getsize(out_path) > 1000: 
                success = True
                print(f"Downloaded {match} from {url}")
                downloaded += 1
                break
        except Exception as e:
            continue
            
    if not success:
        print(f"Failed to find high-quality logo for {match}, leaving empty fallback.")

print(f"Downloaded {downloaded} logos out of {len(set(matches))}.")
