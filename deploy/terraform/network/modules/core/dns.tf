resource "routeros_ip_dns_adlist" "multi_pro_plus_plus" {
  url        = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.plus.txt"
  ssl_verify = false
}

resource "routeros_ip_dns_adlist" "threat_intelligence_feed" {
  url        = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/tif.txt"
  ssl_verify = false
}

resource "routeros_ip_dns_adlist" "no_safe_search" {
  url        = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/nosafesearch.txt"
  ssl_verify = false
}
