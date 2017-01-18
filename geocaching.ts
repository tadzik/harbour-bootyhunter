/// <reference path="qmlstuff.d.ts" />

class Booty {
    code:    string
    name:    string
    type:    string
    service: string

    lat:  number
    lon:  number

    meta: any

    constructor(json: any, service: string) {
        this.code = json['code']
        this.name = json['name']
        this.type = json['type']

        this.service = service

        var parts = json.location.split('|')
        this.lat  = parseFloat(parts[0])
        this.lon  = parseFloat(parts[1])

        this.meta = json
    }

    calculate_distance(lat: number, lon: number) {
        this.meta['distance']     = calc_distance(lat, lon, this.lat, this.lon)
        this.meta['distance_str'] = humanize_distance(this.meta['distance'])
    }

    calculate_bearing(lat: number, lon: number) {
        this.meta['bearing'] = calc_bearing(lat, lon, this.lat, this.lon)
    }
}

class Geocaching {
    nav_providers:       any
    current_lat:         number
    current_lon:         number
    nearest_booties:     Booty[] = []
    authorized_services: any
    dbh:                 Database
    oauthsucks:          any

    constructor(nav_providers: any, oauthsucks: any) {
        this.nav_providers = nav_providers
        this.nav_providers.positionSource.positionChanged.connect(() => {
            var loc = this.nav_providers.positionSource.position.coordinate
            this.current_lat = loc.latitude
            this.current_lon = loc.longitude
            for (var booty of this.nearest_booties) {
                booty.calculate_distance(this.current_lat, this.current_lon)
            }
            this.nearest_booties.sort((a, b) => { return a.meta.distance - b.meta.distance })
        })
        var loc = this.nav_providers.positionSource.position.coordinate
        this.current_lat = loc.latitude
        this.current_lon = loc.longitude

        this.dbh = LocalStorage.openDatabaseSync(
            "bootyhunterDB", "0.1", "a keyvalue disguised as SQL",
            1000, this.dbconfig)

        this.authorized_services = JSON.parse(this.db_get('authorized_services') || '{}')

        this.oauthsucks = oauthsucks
    }

    dbconfig(db: Database) : void {
        db.transaction((tx) => {
            tx.executeSql('CREATE TABLE IF NOT EXISTS Keyvals(key TEXT, value TEXT)')
        })
        db.changeVersion("", "0.1")
    }

    db_get(key: string) : string {
        var ret
        this.dbh.transaction((tx) => {
            var rs = tx.executeSql('SELECT value FROM Keyvals WHERE key = ?', [key])
            if (rs.rows.item(0)) ret = rs.rows.item(0).value
        })
        return ret
    }

    db_set(key: string, value: string) : void {
        if (this.db_get(key)) {
            this.dbh.transaction((tx) => {
                tx.executeSql('UPDATE Keyvals SET value = ? WHERE key = ?', [value, key])
            })
        } else {
            this.dbh.transaction((tx) => {
                tx.executeSql('INSERT INTO Keyvals (key, value) VALUES (?, ?)', [key, value])
            })
        }
    }

    store_keys(service: string, tokenKey: string, tokenSecret: string) : void {
        this.authorized_services[service] = [tokenKey, tokenSecret]
        this.db_set('authorized_services', JSON.stringify(this.authorized_services))
    }

    is_service_authorized(service: string) : boolean {
        return this.authorized_services[service] ? true : false
    }

    is_any_service_authorized() : boolean {
        // yep, it's a "if this.a_s.keys.length > 0" in a funny hat
        for (var k in this.authorized_services) {
            return true
        }
        return false
    }

    get_service_for(service_id: string) : any {
        return this.oauthsucks.get_service_for(service_id)
    }

    do_query(service_id: string, endpoint: string, payload: any, cb: any) : void {
        var service = this.get_service_for(service_id)
        var url = service.get_base_url() + endpoint + '?'
        for (var attr in payload) {
            url += attr + '=' + payload[attr] + '&'
        }
        url += 'consumer_key=' + service.get_consumer_key()
        var req = new XMLHttpRequest();
        req.onreadystatechange = () => {
            if (req.readyState == XMLHttpRequest.DONE) {
                // TODO handle API errors
                cb(req);
            }
        };
        req.open("GET", url)
        req.send()
    }

    get_nearest_booties(cb: any) : void {
        this.nearest_booties = []

        // what follow is Promise.allof() for cripples
        var service_cnt = 0
        for (var service_id in this.authorized_services) {
            service_cnt++
        }

        if (service_cnt == 0) {
            cb([{ error: "No services authorized" }])
        }

        var collected = 0
        var aggregator = (booties) => {
            for (var b of booties) {
                this.nearest_booties.push(b)
            }
            collected++
            if (collected == service_cnt) {
                this.nearest_booties.sort((a, b) => { return a.meta.distance - b.meta.distance })
                this.nearest_booties = this.nearest_booties.slice(0, 25)
                cb(this.nearest_booties)
            }
        }

        for (var service_id in this.authorized_services) {
            this.get_booties_at(service_id, this.current_lat, this.current_lon, (booties) => {
                aggregator(booties)
            })
        }
    }

    get_booties_at(service: string, lat: number, lon: number, cb: any) : void {
        var loc = lat + "|" + lon
        this.do_query(service, "caches/shortcuts/search_and_retrieve", {
            'search_method': 'services/caches/search/nearest',
            'search_params': '{"center": "' + loc + '", "limit": 25}',
            'retr_method': 'services/caches/geocaches',
            'retr_params': '{"fields": "code|name|location|type|status"}',
            'wrap': 'false',
        }, (req) => {
            var resp = JSON.parse(req.responseText)
            var booties = []
            for (var key in resp) {
                var booty = new Booty(resp[key], service)
                booty.calculate_distance(this.current_lat, this.current_lon)
                booties.push(booty)
            }
            cb(booties)
        });
    }

    get_booty_details(cache: Booty, cb: any) : void {
        this.do_query(cache.service, "caches/geocache", {
            'cache_code': cache.code,
            'fields': 'code|name|location|type|status|owner|founds|notfounds|size2|difficulty|terrain|description|hint2|last_found|date_hidden',
        }, (req) => {
            var resp = JSON.parse(req.responseText)
            cb(new Booty(resp, cache.service))
        });
    }

    get_nearest_booty() : Booty {
        if (this.nearest_booties.length == 0) return null
        var closest = this.nearest_booties[0]
        for (var booty of this.nearest_booties) {
            if (booty.meta.distance < closest.meta.distance) {
                closest = booty
            }
        }
        return closest
    }

    // returns a pair: a number of caches, and a string with humanized radius
    get_nearest_stats() : any[] {
        var tresholds = [500, 1000, 2000, 5000, 10000];
        for (var t of tresholds) {
            var count = 0
            for (var booty of this.nearest_booties) {
                if (booty.meta.distance < t) {
                    count++
                }
            }
            if (count > 0) {
                return [count, humanize_distance(t)]
            }
        }
        return [0, humanize_distance(tresholds[tresholds.length - 1])]
    }
}

function humanize_distance(distance: number) {
    if (distance < 1000) {
        return distance.toFixed() + "m"
    } else {
        distance /= 1000
        return <any>distance.toPrecision(4) / 1  + "km"
    }
}

// thank you, StackOverflow Derek (http://stackoverflow.com/a/18883819)
// returns value in meters
function calc_distance(lat1: number, lon1: number, lat2: number, lon2: number) : number {
    var R    = 6371000 // in meters
    var dLat = toRad(lat2-lat1)
    var dLon = toRad(lon2-lon1)
    var lat1 = toRad(lat1)
    var lat2 = toRad(lat2)

    var a    = Math.sin(dLat/2) * Math.sin(dLat/2) +
        Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2)
    var c    = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    var d    = R * c
    return d
}

function calc_bearing(lat1: number, lon1: number, lat2: number, lon2: number) : number {
    var dLat = lat2 - lat1;
    var dLon = lon2 - lon1;
    if (Math.abs(dLon) > 180) {
        if (lon1 < lon2) {
            lon1 += 360;
        } else {
            lon2 += 360;
        }
        dLon = lon2 - lon1;
    }
    var angle = toDeg(Math.atan2(dLat, dLon));
    angle = 360 - angle + 90;
    return (angle + 360) % 360;
}

function toRad(value: number) {
    return value * Math.PI / 180;
}

function toDeg(value: number) {
    return value * 180 / Math.PI;
}
