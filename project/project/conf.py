# A configuration file for the Twisted Places proxy herd

# Google Places API key
API_KEY=""
API_URL="https://maps.googleapis.com/maps/api/place/nearbysearch/json?"

# TCP port numbers for each server instance (server ID: case sensitive)
PORT_NUM = {
    'Alford': 11550,
    'Ball': 11551,
    'Hamilton': 11552,
    'Holiday': 11553,
    'Welsh': 11554
}

# Neighbors for each server
NEIGHBORS = {
    'Alford': ['Hamilton', 'Welsh'],
    'Ball': ['Holiday', 'Welsh'],
    'Hamilton': ['Holiday', 'Alford'],
    'Holiday': ['Hamilton', 'Ball'],
    'Welsh': ['Alford', 'Ball']
}

SERVER_NAMES = ['Alford', 'Ball', 'Hamilton', 'Holiday', 'Welsh']

PROJ_TAG="Fall 2016"
