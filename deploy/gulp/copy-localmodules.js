//Used for copying the local_modules to the nod_modules folder. Trigger at the postinstall event from the main packages.json

var ncp = require('ncp').ncp;
ncp.limit = 16;

ncp('local_modules/', 'node_modules/');

