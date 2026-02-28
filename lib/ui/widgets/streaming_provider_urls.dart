const providerSearchUrls = <int, String>{
  // ─── Global Major Platforms ───────────────────────────────────────
  8: 'https://www.netflix.com/search?q={title}', // Netflix
  175: 'https://www.netflix.com/search?q={title}', // Netflix Kids
  1796: 'https://www.netflix.com/search?q={title}', // Netflix Standard with Ads
  9: 'https://www.amazon.com/s?k={title}&i=instant-video', // Amazon Prime Video (DE)
  10: 'https://www.amazon.com/s?k={title}&i=instant-video', // Amazon Video
  119:
      'https://www.amazon.com/s?k={title}&i=instant-video', // Amazon Prime Video (Global)
  337: 'https://www.disneyplus.com/search/{title}', // Disney Plus
  2: 'https://tv.apple.com/search?term={title}', // Apple TV Store
  350: 'https://tv.apple.com/search?term={title}', // Apple TV+
  3: 'https://play.google.com/store/search?q={title}&c=movies', // Google Play Movies
  192: 'https://www.youtube.com/results?search_query={title}', // YouTube
  188:
      'https://www.youtube.com/results?search_query={title}', // YouTube Premium
  531: 'https://www.paramountplus.com/search/?q={title}', // Paramount Plus
  582:
      'https://www.paramountplus.com/search/?q={title}', // Paramount+ Amazon Channel
  283: 'https://www.crunchyroll.com/search?q={title}', // Crunchyroll
  1899: 'https://www.max.com/search?q={title}', // Max (HBO Max)
  384: 'https://www.max.com/search?q={title}', // HBO Max (alternate ID)
  1825: 'https://www.max.com/search?q={title}', // HBO Max Amazon Channel
  11: 'https://mubi.com/films?q={title}', // MUBI
  100: 'https://guidedoc.tv/search?q={title}', // GuideDoc
  35: 'https://rakuten.tv/de/search?q={title}', // Rakuten TV
  // ─── US / North America ───────────────────────────────────────────
  15: 'https://www.hulu.com/search?q={title}', // Hulu
  386: 'https://www.peacocktv.com/search?q={title}', // Peacock Premium
  257: 'https://www.fubo.tv/search?q={title}', // fuboTV
  207: 'https://therokuchannel.roku.com/search/{title}', // The Roku Channel
  526: 'https://www.amcplus.com/search?q={title}', // AMC+
  230: 'https://www.crave.ca/search?q={title}', // Crave (Canada)
  212: 'https://www.hoopladigital.com/search?q={title}', // Hoopla (US/CA)
  // ─── UK / Ireland ─────────────────────────────────────────────────
  151: 'https://www.britbox.com/search?q={title}', // BritBox
  // ─── Australia / New Zealand ──────────────────────────────────────
  134: 'https://www.foxtel.com.au/now/search.html?q={title}', // Foxtel Now (AU)
  // ─── Germany / DACH ───────────────────────────────────────────────
  421: 'https://www.joyn.de/suche?q={title}', // Joyn
  298: 'https://www.rtl-plus.de/suche?q={title}', // RTL+
  178: 'https://www.magentatv.de/suche?q={title}', // MagentaTV
  30: 'https://www.wow.sky.de/suche/{title}', // WOW (Sky DE)
  29: 'https://www.sky.de/suche/{title}', // Sky Go (DE)
  20: 'https://www.maxdome.de/suche/{title}', // maxdome Store
  613: 'https://www.freenet-video.de/suche?q={title}', // freenet Video
  177: 'https://www.chili.com/de/search?q={title}', // Chili
  // German Public Broadcasters (free)
  234: 'https://www.arte.tv/de/search/?q={title}', // ARTE
  354: 'https://www.arte.tv/de/search/?q={title}', // ARTE (alternate ID)
  219: 'https://www.ardmediathek.de/suche/{title}', // ARD Mediathek
  36: 'https://www.zdf.de/suche?q={title}', // ZDF Mediathek (Legacy)
  537: 'https://www.zdf.de/suche?q={title}', // ZDF Mediathek
  // Switzerland
  150: 'https://www.blueplus.ch/de/search?q={title}', // blue TV (CH)
  691: 'https://www.playsuisse.ch/search?q={title}', // Play Suisse (CH)
  222: 'https://www.srf.ch/play/tv/suche?q={title}', // SRF Play (CH)
  210: 'https://www.sky.ch/de/search?q={title}', // Sky (CH)
  // ─── France ───────────────────────────────────────────────────────
  381: 'https://www.canalplus.com/recherche/?q={title}', // Canal+
  // ─── Spain ────────────────────────────────────────────────────────
  63: 'https://www.filmin.es/search?q={title}', // Filmin
  2241: 'https://ver.movistarplus.es/busqueda?q={title}', // Movistar Plus+
  149:
      'https://ver.movistarplus.es/busqueda?q={title}', // Movistar Plus+ Ficción Total
  // ─── Nordics (SE, NO, DK, FI) ────────────────────────────────────
  76: 'https://viaplay.com/search?q={title}', // Viaplay
  1773: 'https://www.skyshowtime.com/search?q={title}', // SkyShowtime
  620: 'https://www.dr.dk/drtv/soeg?q={title}', // DR TV (Denmark)
  // ─── Netherlands / Belgium ────────────────────────────────────────
  72: 'https://www.videoland.com/search?q={title}', // Videoland (NL)
  71: 'https://www.pathe-thuis.nl/search?q={title}', // Pathé Thuis (NL)
  297: 'https://www.ziggogo.tv/search?q={title}', // Ziggo TV (NL)
  // ─── Latin America (BR, MX, AR, CO, CL) ──────────────────────────
  167: 'https://www.clarovideo.com/buscar?q={title}', // Claro video
  339: 'https://www.movistartv.com/buscar?q={title}', // MovistarTV (AR)
  47: 'https://www.looke.com.br/search?q={title}', // Looke (BR)
  // ─── Japan ────────────────────────────────────────────────────────
  84: 'https://video.unext.jp/search?query={title}', // U-NEXT
  // ─── South Korea ──────────────────────────────────────────────────
  356: 'https://www.wavve.com/search?searchWord={title}', // wavve
  97: 'https://watcha.com/search?query={title}', // Watcha
  // ─── India ────────────────────────────────────────────────────────
  2336: 'https://www.hotstar.com/in/search?q={title}', // JioHotstar
  232: 'https://www.zee5.com/search?q={title}', // Zee5
  // ─── Turkey ───────────────────────────────────────────────────────
  342: 'https://puhutv.com/ara?q={title}', // puhutv
  // ─── Russia ────────────────────────────────────────────────────────
  115: 'https://okko.tv/search?query={title}', // Okko
  116: 'https://www.amediateka.ru/search?q={title}', // Amediateka
  // ─── Finland ───────────────────────────────────────────────────────
  323: 'https://areena.yle.fi/haku?q={title}', // Yle Areena
  338: 'https://www.ruutu.fi/haku?q={title}', // Ruutu
  // ─── Southeast Asia ────────────────────────────────────────────────
  158: 'https://www.viu.com/ott/search?q={title}', // Viu
  160: 'https://www.iflix.com/search?q={title}', // iflix
  159: 'https://www.catchplay.com/search?q={title}', // Catchplay
  // ─── Africa ───────────────────────────────────────────────────────
  55: 'https://www.showmax.com/search?q={title}', // ShowMax (ZA)
  // ─── Apple TV Channels (various sub-providers) ────────────────────
  1852: 'https://tv.apple.com/search?term={title}', // Britbox Apple TV
  1853: 'https://tv.apple.com/search?term={title}', // Paramount Plus Apple TV
  1854: 'https://tv.apple.com/search?term={title}', // AMC Plus Apple TV
  1855: 'https://tv.apple.com/search?term={title}', // Starz Apple TV
  // ─── Amazon Channels (various sub-providers) ──────────────────────
  528:
      'https://www.amazon.com/s?k={title}&i=instant-video', // AMC+ Amazon Channel
  1968:
      'https://www.amazon.com/s?k={title}&i=instant-video', // Crunchyroll Amazon
  583:
      'https://www.amazon.com/s?k={title}&i=instant-video', // MGM+ Amazon Channel
  // ─── Roku Channels (various sub-providers) ────────────────────────
  633: 'https://therokuchannel.roku.com/search/{title}', // Paramount+ Roku
  634: 'https://therokuchannel.roku.com/search/{title}', // Starz Roku
  635: 'https://therokuchannel.roku.com/search/{title}', // AMC+ Roku
  636: 'https://therokuchannel.roku.com/search/{title}', // MGM Plus Roku
};
