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


# Create the return type.
type TNOAAWeather* = tuple[suggestedPickup : string, suggestedPickupPeriod : string, location : string, stationID : string,
                           latitude : string, longitude : string, observationTime : string, observationTimeRFC822 : string,
                           weather : string, temperatureString : string, tempF : string, tempC : string, relativeHumidity : string,
                           windString : string, windDir : string, windDegrees : string, windMph : string, windGustMph : string,
                           pressureString : string, pressureMb : string, pressureIn : string, dewpointString: string,
                           dewpointF : string, dewpointC : string, heatIndexString : string, heatIndexF : string, heatIndexC : string,
                           windchillString : string, windchillF : string, windchillC : string, visibilityMi : string,
                           iconUrlBase : string, iconUrlName : string, twoDayUrl : string, obUrl : string]


proc getWeather*(stationID : string): TNOAAWeather = 
    # Gets the weather data.