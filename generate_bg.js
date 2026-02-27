const fs = require('fs');

// Create a simple base64 PNG generator for the layers.
// Node doesn't natively have canvas without installing packages, 
// so we'll use a python script to generate the pixel-perfect layers using PIL instead.
