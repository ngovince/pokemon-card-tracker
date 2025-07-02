// static/js/config.js - Fixed ngrok detection

const getApiBase = () => {
    const protocol = window.location.protocol; // http: or https:
    const hostname = window.location.hostname;
    const port = window.location.port;
    
    console.log('Current location:', {
        protocol: protocol,
        hostname: hostname,
        port: port,
        full: window.location.href
    });
    
    // If using ngrok (contains 'ngrok' in hostname)
    if (hostname.includes('ngrok')) {
        const apiBase = `${protocol}//${hostname}/api`;
        console.log('Detected ngrok, using:', apiBase);
        return apiBase;
    }
    
    // For local access (localhost or IP address)
    const actualPort = port || '8080';
    const apiBase = `${protocol}//${hostname}:${actualPort}/api`;
    console.log('Detected local access, using:', apiBase);
    return apiBase;
};

const API_BASE = getApiBase();

// Global state
let currentCardData = null;
let allCards = [];
let filteredCards = [];

// Debug: Show what we're using
console.log('🔧 API_BASE set to:', API_BASE);
console.log('🔧 Current URL:', window.location.href);