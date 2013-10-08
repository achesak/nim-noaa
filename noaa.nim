# NOAA weather API wrapper

# Written by Adam Chesak.
# Code released under the MIT open source license.

# Import modules.
import httpclient
import cgi
import strutils
import xmlparser
import xmltree
import streams


# Create the return types.
type TNOAAWeather* = tuple[suggestedPickup : string, suggestedPickupPeriod : string, location : string, stationID : string,
                           latitude : string, longitude : string, observationTime : string, observationTimeRFC822 : string,
                           weather : string, temperatureString : string, tempF : string, tempC : string, relativeHumidity : string,
                           windString : string, windDir : string, windDegrees : string, windMph : string, windKt : string,
                           pressureString : string, pressureMb : string, pressureIn : string, dewpointString: string,
                           dewpointF : string, dewpointC : string, heatIndexString : string, heatIndexF : string, heatIndexC : string,
                           windchillString : string, windchillF : string, windchillC : string, visibilityMi : string,
                           iconUrlBase : string, iconUrlName : string, twoDayHistoryUrl : string, obUrl : string]

type TNOAAStormInfo* = tuple[link : string, title : string, description : string, pubDate : string, guid : string]


proc getWeather*(stationID : string): TNOAAWeather = 
    # Gets the weather data.
    
    # Build the URL.
    var params : string = "http://www.weather.gov/xml/current_obs/" & stationID & ".xml"
    
    # Get the data.
    var response : string = getContent(params)
    
    # Remove the second line. Needed because of a problem with the xmlparser. Has been fixed,
    # but this line is left in for backwards compatability.
    response = response.replace("<?xml-stylesheet href=\"latest_ob.xsl\" type=\"text/xsl\"?>")
    
    # Parse the data.
    var xml : PXmlNode = parseXML(newStringStream(response))
    
    # Create the return object.
    var weather : TNOAAWeather
    weather.suggestedPickup = xml.child("suggested_pickup").innerText
    weather.suggestedPickupPeriod = xml.child("suggested_pickup_period").innerText
    weather.location = xml.child("location").innerText
    weather.stationID = xml.child("station_id").innerText
    weather.latitude = xml.child("latitude").innerText
    weather.longitude = xml.child("longitude").innerText
    weather.observationTime = xml.child("observation_time").innerText
    weather.observationTimeRFC822 = xml.child("observation_time_rfc822").innerText
    weather.weather = xml.child("weather").innerText
    weather.temperatureString = xml.child("temperature_string").innerText
    weather.tempF = xml.child("temp_f").innerText
    weather.tempC = xml.child("temp_c").innerText
    weather.relativeHumidity = xml.child("relative_humidity").innerText
    weather.windString = xml.child("wind_string").innerText
    weather.windDir = xml.child("wind_dir").innerText
    weather.windDegrees = xml.child("wind_degrees").innerText
    weather.windMph = xml.child("wind_mph").innerText
    weather.windKt = xml.child("wind_kt").innerText
    weather.pressureString = xml.child("pressure_string").innerText
    weather.pressureMb = xml.child("pressure_mb").innerText
    weather.pressureIn = xml.child("pressure_in").innerText
    weather.dewpointString = xml.child("dewpoint_string").innerText
    weather.dewpointF = xml.child("dewpoint_f").innerText
    weather.dewpointC = xml.child("dewpoint_c").innerText
    weather.visibilityMi = xml.child("visibility_mi").innerText
    weather.iconUrlBase = xml.child("icon_url_base").innerText
    weather.iconUrlName = xml.child("icon_url_name").innerText
    weather.twoDayHistoryUrl = xml.child("two_day_history_url").innerText
    weather.obUrl = xml.child("ob_url").innerText
    
    # Return the weather data.
    return weather


proc parseRSS(url : string): seq[TNOAAStormInfo] = 
    # Parses the RSS data items into the weather type.
    
    # Get the data.
    var response : string = getContent(url)
    
    # Parse the XML.
    var xml : PXmlNode = parseXML(newStringStream(response)).child("channel")
    var items : seq[PXmlNode] = xml.findAll("item")
    
    # Create the sequence.
    var watches = newSeq[TNOAAStormInfo](len(items))
    
    # Add the data to the sequence.
    for i in 0..high(items):
        
        # Create the return object.
        var item : TNOAAStormInfo
        item.link = items[i].child("link").innerText
        item.title = items[i].child("title").innerText
        item.description = items[i].child("description").innerText
        item.pubDate = items[i].child("pubDate").innerText
        item.guid = items[i].child("guid").innerText
        watches[i] = item
    
    # Return the sequence.
    return watches


proc getAllWatches*(): seq[TNOAAStormInfo] = 
    # Gets all the watch info.
    
    return parseRSS("http://www.spc.noaa.gov/products/spcrss.xml")


proc getTornados*(): seq[TNOAAStormInfo] = 
    # Gets tornado and severe thunderstorm info.
    
    return parseRSS("http://www.spc.noaa.gov/products/spcwwrss.xml")


proc getPDS*(): seq[TNOAAStormInfo] = 
    # Gets PDS (Particularly Dangerous Situation) info.
    
    return parseRSS("http://www.spc.noaa.gov/products/spcpdswwrss.xml")


proc getMesoscale*(): seq[TNOAAStormInfo] = 
    # Gets mesoscale discussions.
    
    return parseRSS("http://www.spc.noaa.gov/products/spcmdrss.xml")


proc getConvective*(): seq[TNOAAStormInfo] = 
    # Gets convective outlooks.
    
    return parseRSS("http://www.spc.noaa.gov/products/spcacrss.xml")


proc getMultimedia*(): seq[TNOAAStormInfo] = 
    # Gets multimedia briefings.
    
    return parseRSS("http://www.spc.noaa.gov/products/spcmbrss.xml")


proc getFires*(): seq[TNOAAStormInfo] = 
    # Gets fire info.
    
    return parseRSS("http://www.spc.noaa.gov/products/spcfwrss.xml")
