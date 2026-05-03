from urllib.parse import urlparse


_DOMAIN_TRUST: dict[str, float] = {
    "wikipedia.org": 0.85,
    "ko.wikipedia.org": 0.85,
    "en.wikipedia.org": 0.85,
    "britannica.com": 0.9,
    "nature.com": 0.95,
    "science.org": 0.95,
    "nih.gov": 0.95,
    "who.int": 0.9,
    "bbc.com": 0.85,
    "bbc.co.uk": 0.85,
    "reuters.com": 0.9,
    "apnews.com": 0.9,
    "nytimes.com": 0.85,
    "yna.co.kr": 0.85,
    "kbs.co.kr": 0.8,
    "mbc.co.kr": 0.8,
    "sbs.co.kr": 0.8,
    "chosun.com": 0.7,
    "donga.com": 0.7,
    "hani.co.kr": 0.7,
    "khan.co.kr": 0.7,
    "joongang.co.kr": 0.7,
}

_TLD_TRUST: dict[str, float] = {
    ".gov": 0.9,
    ".gov.uk": 0.9,
    ".go.kr": 0.9,
    ".edu": 0.8,
    ".ac.kr": 0.8,
    ".or.kr": 0.55,
    ".org": 0.55,
}

_LOW_TRUST_PATTERNS = ("blog.", "tistory.com", "naver.me", "brunch.co.kr")


def score(url: str) -> float:
    host = (urlparse(url).hostname or "").lower()
    if not host:
        return 0.3
    if host in _DOMAIN_TRUST:
        return _DOMAIN_TRUST[host]
    base = host[4:] if host.startswith("www.") else host
    if base in _DOMAIN_TRUST:
        return _DOMAIN_TRUST[base]
    for tld, val in _TLD_TRUST.items():
        if host.endswith(tld):
            return val
    for pat in _LOW_TRUST_PATTERNS:
        if pat in host:
            return 0.25
    return 0.4
