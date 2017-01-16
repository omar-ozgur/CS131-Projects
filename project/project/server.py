import datetime
import json
import os
import re
import sys

from conf import *
from twisted.internet import reactor, protocol
from twisted.python import log
from twisted.web.client import getPage

class HerdServerProtocol(protocol.Protocol):
    def dataReceived(self, data):

        # IAMAT command received
        if data.startswith("IAMAT"):
            try:
                
                # Get command arguments
                fields = data.split()
                if len(fields) != 4:
                    log.msg("Invalid IAMAT command received: {}".format(data))
                    self.transport.write("? {}".format(data))
                    return
                prefix, clientID, location, timestamp = fields
                log.msg("Received IAMAT command from client {}".format(clientID))

                # Check if the clientID is valid
                if "".join(clientID.split(" \t\r\n\f\v")) != clientID:
                    log.msg("Improper client ID in IAMAT command: {}".format(clientID))
                    self.transport.write("? {}".format(data))
                    return

                # Get time difference
                timeDifference = (datetime.datetime.utcnow() - datetime.datetime(1970, 1, 1)).total_seconds() - float(timestamp)
                if timeDifference >= 0:
                    timeDifference = "+{}".format(timeDifference)

                # Get and verify latitude and longitude
                latLng = "".join(location.split('+')).split('-')
                if len(latLng) != 2:
                    log.msg("Improper latitude and longitude in IAMAT command: {}".format(location))
                    self.transport.write("? {}".format(data))
                    return
                latitudeString = "{0}{1}".format(location[0], latLng[0])
                latitude = float(latitudeString)
                longitude = float("".join(location[len(latitudeString):]))
                if latitude < -90 or latitude > 90 or longitude < -180 or longitude > 180:
                    log.msg("Improper latitude and longitude boundaries in IAMAT command: {0} {1}".format(latitude, longitude))
                    self.transport.write("? {}".format(data))
                    return 

                # Send result to the client
                responseMessage = "AT {0} {1} {2} {3} {4}".format(self.factory.conf.serverName, timeDifference, clientID, location, timestamp)
                log.msg("Responding to IAMAT command with: {}".format(responseMessage))
                self.transport.write("{}\n".format(responseMessage))

                # Update the database if the client sends newer data
                updateTime = (datetime.datetime.utcnow() - datetime.datetime(1970, 1, 1)).total_seconds()
                if clientID not in self.factory.db or float(timestamp) >= float(self.factory.db[clientID]["timestamp"]):
                    log.msg("Updating saved data for client: {}".format(clientID))
                    self.factory.db[clientID] = {"timeDifference": timeDifference, "location": location, "timestamp": timestamp, "updateTime": updateTime}
        
                # Propagate the information to neighbors
                dbData = self.factory.db[clientID]
                propagationMessage = "AT {0} {1} {2} {3} {4} {5}".format(self.factory.conf.serverName, dbData["timeDifference"], clientID, dbData["location"], dbData["timestamp"], updateTime)
                for neighbor in self.factory.conf.neighbors[self.factory.conf.serverName]:
                    log.msg("Propagating AT message to neighbor {}".format(neighbor))
                    reactor.connectTCP('localhost', self.factory.conf.servers[neighbor], HerdClientFactory(propagationMessage))
            
            # Send an error if an exception occurs
            except Exception, e:
                log.msg("Invalid IAMAT command received: {}".format(data))
                self.transport.write("? {}".format(data))
                return

        # AT data received
        elif data.startswith("AT"):
            try:

                # Get command arguments
                fields = data.split()
                if len(fields) != 7:
                    log.msg("Invalid AT data received: {}".format(data))
                    self.transport.write("? {}".format(data))
                    return
                prefix, serverName, timeDifference, clientID, location, timestamp, updateTime = fields
                log.msg("Received AT message from neighbor {}".format(serverName))

                # Check if the clientID is valid
                if "".join(clientID.split(" \t\r\n\f\v")) != clientID:
                    log.msg("Invalid client ID in AT message: {}".format(clientID))
                    self.transport.write("? {}".format(data))
                    return

                # Check if the data should not be propagated
                if clientID in self.factory.db and self.factory.db[clientID] == {"timeDifference": timeDifference, "location": location, "timestamp": timestamp, "updateTime": updateTime}:
                    log.msg("The duplicate AT message will not be propagated further")
                    return

                # Save data in the local database
                if clientID not in self.factory.db or float(timestamp) >= float(self.factory.db[clientID]["timestamp"]) or updateTime != self.factory.db[clientID]["updateTime"]:
                    log.msg("Updating saved data for client {}".format(clientID))
                    self.factory.db[clientID] = {"timeDifference": timeDifference, "location": location, "timestamp": timestamp, "updateTime": updateTime}

                # Propagate data to neighbors
                dbData = self.factory.db[clientID]
                propagationMessage = "AT {0} {1} {2} {3} {4} {5}".format(self.factory.conf.serverName, dbData["timeDifference"], clientID, dbData["location"], dbData["timestamp"], updateTime)
                for neighbor in self.factory.conf.neighbors[self.factory.conf.serverName]:
                    if neighbor != serverName:
                        log.msg("Propagating AT message to neighbor {}".format(neighbor))
                        reactor.connectTCP('localhost', self.factory.conf.servers[neighbor], HerdClientFactory(propagationMessage))
                
            # Send an error if an exception occurs
            except Exception, e:
                log.msg("Invalid AT data received: {}".format(data))
                self.transport.write("? {}".format(data))
                return

        # WHATSAT command received
        elif data.startswith("WHATSAT"):
            try:

                # Get command arguments
                fields = data.split()
                if len(fields) != 4:
                    log.msg("Invalid WHATSAT command received: {}".format(data))
                    self.transport.write("? {}".format(data))
                    return
                prefix, clientID, radius, upperBound = fields
                log.msg("Received WHATSAT command from client {}".format(clientID))

                # Check if the radius is valid
                if float(radius) > 50 or float(radius) < 0:
                    log.msg("Invalid radius in WHATSAT command: {}".format(radius))
                    self.transport.write("? {}".format(data))
                    return

                # Check if the upper bound is valid
                if int(upperBound) > 20 or int(upperBound) < 0:
                    log.msg("Invalid upper bound in WHATSAT command: {}".format(upperBound))
                    self.transport.write("? {}".format(data))
                    return

                # Check if the clientID is valid
                if "".join(clientID.split(" \t\r\n\f\v")) != clientID:
                    log.msg("Invalid client ID in WHATSAT command: {}".format(clientID))
                    self.transport.write("? {}".format(data))
                    return

                # Get stored data for the client if it exists
                if clientID not in self.factory.db:
                    log.msg("No data is available for the specified client: {}".format(clientID))
                    self.transport.write("? {}".format(data))
                    return
                else:
                    dbData = self.factory.db[clientID]
                    location = dbData["location"]
                    latLng = "".join(location.split('+')).split('-')
                    location = "{0}{1},{2}{3}".format(location[0], latLng[0], location[len(latLng[0]) + 1], latLng[1])

                # Send response
                def sendResponse(response, this, ATMessage):
                    response = json.loads(response)
                    response["results"] = response["results"][:int(upperBound)]
                    response = json.dumps(response, indent=3)
                    response = "{}\n\n".format(re.sub('\n+', '\n', response).rstrip('\n'))
                    log.msg("Sending Google Places results")
                    this.transport.write(ATMessage)
                    this.transport.write(response)

                # Get Google Places data and send responses
                ATMessage = "AT {0} {1} {2} {3} {4}\n".format(self.factory.conf.serverName, dbData["timeDifference"], clientID, dbData["location"], dbData["timestamp"])
                log.msg("Requesting location information from Google Places")
                response = getPage("{0}location={1}&radius={2}&sensor=false&key={3}".format(self.factory.conf.apiURL, location, str((float(radius) * 1000)), self.factory.conf.apiKey))
                response.addCallback(sendResponse, self, ATMessage)

            # Send an error if an exception occurs
            except Exception, e:
                log.msg("Invalid WHATSAT command received: {}".format(data))
                self.transport.write("? {}".format(data))
                return

        # Command not recognized
        else:
            log.msg("Unrecognized command received")
            self.transport.write("? {}".format(data))

class HerdServerFactory(protocol.ServerFactory):
    protocol = HerdServerProtocol

    def __init__(self, conf):
        self.conf = conf
        self.db = {}
        log.startLogging(open('./logs/{}'.format(conf.serverName), 'w'))

    def startFactory(self):
        log.msg("Server started")
    
    def stopFactory(self):
        log.msg("Server stopped")

class HerdClientProtocol(protocol.Protocol):
    def connectionMade(self):
        self.transport.write(self.factory.data)
        self.transport.loseConnection()

class HerdClientFactory(protocol.ClientFactory):
    protocol = HerdClientProtocol

    def __init__(self, data):
        self.data = data

class Conf:
    def __init__(self):
        # Google Places API Key
        self.apiKey = None
        
        # Project tag
        self.projTag = None
        
        # Server names and port numbers
        self.servers = {}

def main():

    # Create a configuration object
    conf = Conf()
    conf.apiKey = API_KEY
    conf.apiURL = API_URL
    conf.projTag = PROJ_TAG
    conf.servers = PORT_NUM 
    conf.neighbors = NEIGHBORS
    
    # Check the command line arguments
    if len(sys.argv) != 2:
        print "error: invalid arguments"
        print "usage: python {} server_name".format(sys.argv[0])
        print "servers: {}".format(conf.servers.keys())
        exit(1)

    # Get the server name
    serverName = sys.argv[1]
    if serverName not in conf.servers:
        print "Error: Invalid server name"
        print "Servers: {}".format(conf.servers.keys())
        exit(1)
    conf.serverName = serverName
    conf.serverPort = conf.servers[serverName]

    # Start the factory
    factory = HerdServerFactory(conf)
    reactor.listenTCP(conf.serverPort, factory)
    reactor.run()

# Run only if the module was not imported
if __name__ == '__main__':
    main()
