resource "routeros_ip_dns_adlist" "hagezi_multi_pro_plus_plus" {
  url        = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.plus.txt"
  ssl_verify = false
}

resource "routeros_ip_dns_adlist" "hagezi_threat_intelligence_feed" {
  url        = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/tif.txt"
  ssl_verify = false
}

resource "routeros_ip_dns_adlist" "hagezi_no_safe_search" {
  url        = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/nosafesearch.txt"
  ssl_verify = false
}

resource "routeros_ip_dns_adlist" "blocklistproject_no_safe_search" {
  url        = "https://raw.githubusercontent.com/blocklistproject/Lists/refs/heads/master/ads.txt"
  ssl_verify = false
}

resource "routeros_ip_dns_adlist" "blocklistproject_smart_tv" {
  url        = "https://raw.githubusercontent.com/blocklistproject/Lists/refs/heads/master/smart-tv.txt"
  ssl_verify = false
}

resource "routeros_ip_dns_adlist" "blocklistproject_adobe" {
  url        = "https://raw.githubusercontent.com/blocklistproject/Lists/refs/heads/master/adobe.txt"
  ssl_verify = false
}

resource "routeros_ip_dns_adlist" "blocklistproject_tiktok" {
  url        = "https://raw.githubusercontent.com/blocklistproject/Lists/refs/heads/master/tiktok.txt"
  ssl_verify = false
}

resource "routeros_ip_dns_adlist" "blocklistproject_youtube" {
  url        = "https://raw.githubusercontent.com/blocklistproject/Lists/refs/heads/master/youtube.txt"
  ssl_verify = false
}

resource "routeros_ip_dns_adlist" "blocklistproject_facebook" {
  url        = "https://raw.githubusercontent.com/blocklistproject/Lists/refs/heads/master/facebook.txt"
  ssl_verify = false
}

resource "routeros_ip_dns_record" "dns_record_minis00" {
  name     = "minis00.lan"
  address  = "10.70.30.10"
  type     = "A"
}

resource "routeros_ip_dns_record" "dns_record_minis01" {
  name     = "minis01.lan"
  address  = "10.70.30.12"
  type     = "A"
}

resource "routeros_ip_dns_record" "dns_record_minis02" {
  name     = "minis02.lan"
  address  = "10.70.30.14"
  type     = "A"
}

resource "routeros_ip_dns_record" "dns_record_minis03" {
  name     = "minis03.lan"
  address  = "10.70.30.16"
  type     = "A"
}

