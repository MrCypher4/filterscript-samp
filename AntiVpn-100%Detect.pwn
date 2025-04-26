#include <a_samp>
#include <datetime>

#define MAX_IP_LEN 46
#define MAX_BLACKLIST 1000
#define MAX_VPN_PROVIDERS 20
#define MAX_IP_HISTORY 50
#define MAX_GEO_IPS 500

new g_IP[MAX_PLAYERS][MAX_IP_LEN];
new g_IPHistory[MAX_PLAYERS][MAX_IP_HISTORY][MAX_IP_LEN];
new g_TotalBlacklisted = 0;

new const vpn_ipv4_prefixes[][] = {
    "104.", "107.", "128.", "138.", "139.", "140.", "142.", "144.",
    "146.", "148.", "149.", "151.", "152.", "157.", "160.", "161.",
    "162.", "163.", "167.", "168.", "170.", "172.", "176.", "178.",
    "185.", "192.", "193.", "194.", "195.", "198.", "199.", "200.",
    "201.", "203.", "208.", "209.", "212.", "213.", "216."
};

new const vpn_ipv6_prefixes[][] = {
    "2001:19f0", "2604:a880", "2a03:b0c0", "2607:5300", "2a02:6b8",
    "2a00:1450", "2606:4700", "2400:cb00", "2600:3c00", "2620:0:2d0",
    "2a03:2880", "2a00:1098", "2a01:4f8", "2a01:488", "2a04:4e40"
};

public OnGameModeInit()
{
    LoadIPBlacklist();
    return 1;
}

public OnPlayerConnect(playerid)
{
    GetPlayerIp(playerid, g_IP[playerid], MAX_IP_LEN);

    if (IsBlacklistedIP(g_IP[playerid]))
    {
        BanEx(playerid, "VPN IP permanently banned");
        return 0;
    }

    if (DetectVPN(g_IP[playerid]))
    {
        new ip[MAX_IP_LEN];
        format(ip, sizeof(ip), g_IP[playerid]);

        AddToIPBlacklist(ip);
        LogVPNUsage(playerid, ip);
        NotifyAdmins(playerid);

        AddToBanList(ip);
        BanEx(playerid, "VPN usage detected - IP banned permanently");
        return 0;
    }

    // Geo-location check (verify if IP is from a suspicious country or VPN region)
    if (CheckGeolocation(g_IP[playerid]))
    {
        BanEx(playerid, "Suspicious geolocation detected");
        return 0;
    }

    // Check for unusual IP change patterns in short intervals
    if (DetectIPChangePatterns(playerid))
    {
        BanEx(playerid, "Suspicious IP changes detected");
        return 0;
    }

    // Monitor device and IP behavior consistency (device fingerprinting)
    if (DetectDeviceChange(playerid))
    {
        BanEx(playerid, "Device change detected - suspicious behavior");
        return 0;
    }

    return 1;
}

stock DetectVPN(const ip[])
{
    // Detect IPV4 VPN usage
    if (strfind(ip, ".", true) != -1)
    {
        for (new i = 0; i < sizeof(vpn_ipv4_prefixes); i++)
        {
            if (strncmp(ip, vpn_ipv4_prefixes[i], strlen(vpn_ipv4_prefixes[i]), true) == 0) return 1;
        }
    }
    else
    {
        // Detect IPV6 VPN usage
        for (new i = 0; i < sizeof(vpn_ipv6_prefixes); i++)
        {
            if (strncmp(ip, vpn_ipv6_prefixes[i], strlen(vpn_ipv6_prefixes[i]), true) == 0) return 1;
        }
    }

    return 0;
}

stock DetectIPChangePatterns(playerid)
{
    new last_ip[MAX_IP_LEN];
    new current_ip[MAX_IP_LEN];
    GetPlayerIp(playerid, current_ip, MAX_IP_LEN);

    // Check the previous IP of the player within short intervals
    for (new i = 0; i < MAX_IP_HISTORY; i++)
    {
        if (strcmp(g_IPHistory[playerid][i], current_ip, true) == 0)
        {
            return 0; // Same IP, no issue
        }
    }

    // Log this new IP and check for fast IP change
    for (new i = MAX_IP_HISTORY - 1; i > 0; i--)
    {
        strcopy(g_IPHistory[playerid][i], MAX_IP_LEN, g_IPHistory[playerid][i-1]);
    }
    strcopy(g_IPHistory[playerid][0], MAX_IP_LEN, current_ip);

    return 1; // Fast IP change detected
}

stock DetectDeviceChange(playerid)
{
    new device_fingerprint[64];
    new last_device_fingerprint[64];

    // Simple example of device fingerprinting based on IP + User-Agent
    format(device_fingerprint, sizeof(device_fingerprint), "%s_%s", g_IP[playerid], GetPlayerUserAgent(playerid));
    GetPlayerDeviceFingerprint(playerid, last_device_fingerprint, sizeof(last_device_fingerprint));

    if (strcmp(device_fingerprint, last_device_fingerprint, true) != 0)
    {
        return 1; // Device change detected
    }
    
    return 0;
}

stock CheckGeolocation(const ip[])
{
    // Simulate geolocation check, return true if IP is suspicious or belongs to known VPN regions
    // Example: Call to external API or geo-location service to check IP
    new country_code[3];
    GetIPCountryCode(ip, country_code);

    if (country_code[0] == 'X' || IsKnownVPNCountry(country_code))
    {
        return 1;
    }
    return 0;
}

stock IsKnownVPNCountry(const country_code[])
{
    // This could be a hardcoded list or database of countries known to commonly host VPN services
    if (strcmp(country_code, "RU") == 0 || strcmp(country_code, "CN") == 0 || strcmp(country_code, "IN") == 0)
    {
        return 1;
    }
    return 0;
}

// Save IPs into a blacklist to prevent access
stock LoadIPBlacklist()
{
    new File:f = fopen("vpn_ip_blacklist.txt", io_read);
    if (!f) return;

    new line[MAX_IP_LEN];
    while (fread(f, line, sizeof(line)))
    {
        if (g_TotalBlacklisted < MAX_BLACKLIST)
        {
            strdel(line, strlen(line)-2, strlen(line)); // Remove newline
            format(g_BlacklistedIPs[g_TotalBlacklisted], MAX_IP_LEN, line);
            g_TotalBlacklisted++;
        }
    }
    fclose(f);
}

stock IsBlacklistedIP(const ip[])
{
    for (new i = 0; i < g_TotalBlacklisted; i++)
    {
        if (!strcmp(ip, g_BlacklistedIPs[i], true)) return 1;
    }
    return 0;
}

stock AddToIPBlacklist(const ip[])
{
    if (g_TotalBlacklisted >= MAX_BLACKLIST) return;
    format(g_BlacklistedIPs[g_TotalBlacklisted], MAX_IP_LEN, ip);
    g_TotalBlacklisted++;

    new File:f = fopen("vpn_ip_blacklist.txt", io_append);
    if (f)
    {
        fwrite(f, ip);
        fwrite(f, "\r\n");
        fclose(f);
    }
}

stock LogVPNUsage(playerid, const ip[])
{
    new File:f = fopen("vpn_blocked_history.txt", io_append);
    if (f)
    {
        new name[MAX_PLAYER_NAME], log[180], y, m, d, h, min, s;
        getdate(y, m, d);
        gettime(h, min, s);
        GetPlayerName(playerid, name, sizeof(name));
        format(log, sizeof(log), "[%02d/%02d/%04d %02d:%02d:%02d] Blocked: %s (%s)\r\n",
            d, m, y, h, min, s, name, ip);
        fwrite(f, log);
        fclose(f);
    }
}

stock NotifyAdmins(playerid)
{
    new name[MAX_PLAYER_NAME], str[100];
    GetPlayerName(playerid, name, sizeof(name));
    format(str, sizeof(str), "[VPN BLOCKED] %s has been auto-banned for VPN usage", name);
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerAdmin(i)) SendClientMessage(i, 0xFF2200FF, str);
    }
}

stock AddToBanList(const ip[])
{
    new File:f = fopen("banlist.ini", io_append);
    if (f)
    {
        new str[64];
        format(str, sizeof(str), "banip %s\r\n", ip);
        fwrite(f, str);
        fclose(f);
    }
}
