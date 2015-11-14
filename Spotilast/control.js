const selectors = {
    // last.fm home
    logout: 'form[name="logout"]',
    libraryRadio: '.stationlink[data-analytics-label="library"]',
    mixRadio: '.stationlink[data-analytics-label="mix"]',
    recsRadio: '.stationlink[data-analytics-label="recommended"]',
    playButton: '.js-play-pause',
    prevButton: '.js-previous',
    nextButton: '.js-next',
    loveButton: '.js-love',
    spotifyProvider: '.player-bar--provider-spotify',
    youtubeProvider: '.player-bar--provider-youtube',
    elapsed: '.js-progress-elapsed',
    remaining: '.js-progress-remaining',
    artist: '.player-bar-artist-name',
    track: '.player-bar-track-name',
    status: '.js-player-status',
    connectionFailedButton: '[data-modal-action="help"]',
    retryConnectionButton: '[data-modal-action="replay"]',
    // last.fm track page
    coverArt: '.cover-art',
    listenText: '.header-metadata-user-stats p',
    // last.fm artist page
    wiki: '.wiki-content',
    artistImage: '.avatar'
}

// common
function sendAppMessage(name, message) {
    console.log(name, message)
    try {
        webkit.messageHandlers[name].postMessage(message)
    } catch(err) {
        console.log('The native context does not exist yet')
    }
}

function getSelector(selector) {
    var el = document.querySelector(selector)
    if (el) {
        return el
    } else {
        sendAppMessage("error", "failed to find element " + selector)
    }
}

function clickButton(key) {
    var el = getSelector(selectors[key])
    if (el) el.click()
}

// Home page

function readState() {
    sendAppMessage('state', {
                   playing: isPlaying(),
                   loved: isLoved(),
                   trackInfo: trackInfo(),
                   provider: provider(),
                   status: playerStatus()
                   })
}

function isPlaying() {
    var el = getSelector(selectors.playButton)
    if (el) {
        return /pause/i.test(el.innerText)
    }
}

function isLoved() {
    var el = getSelector(selectors.loveButton)
    if (el) {
        return /unlove/i.test(el.innerText)
    }
}

function trackInfo() {
    if (!isPlaying()) return {}
    var artistEl = getSelector(selectors.artist)
    var trackEl = getSelector(selectors.track)
    var elapsedEl = getSelector(selectors.elapsed)
    var remainingEl = getSelector(selectors.remaining)
    
    return {
        artist: artistEl.innerText,
        artistUrl: artistEl.href,
        title: trackEl.innerText,
        url: trackEl.href,
        elapsed: elapsedEl.innerText,
        remaining: remainingEl.innerText
    }
}

function provider() {
    var spotify = document.querySelector(selectors.spotifyProvider)
    var youtube = document.querySelector(selectors.youtubeProvider)
    if (spotify) {
        return 'spotify'
    } else if (youtube) {
        return 'youtube'
    } else {
        return 'unknown'
    }
}

function playerStatus() {
    var el = getSelector(selectors.status)
    var connectionFailedEl = document.querySelector(selectors.connectionFailedButton)
    var retryConnectionEl = document.querySelector(selectors.retryConnectionButton)
    if (connectionFailedEl || retryConnectionEl) {
        return "Connection failed"
    } else if (el) {
        return el.innerText
    }
}

function retryConnection() {
    var connectionFailedEl = document.querySelector(selectors.connectionFailedButton)
    var retryConnectionEl = document.querySelector(selectors.retryConnectionButton)
    if (connectionFailedEl) {
        clickButton('connectionFailedButton')
        setTimeout(retryConnection, 100)
    } else if (retryConnectionEl) {
        clickButton('retryConnectionButton')
    } else {
        setTimeout(retryConnection, 100)
    }
}

setInterval(function() {
    readState()
}, 500)

// Track page
function getTrackInfo() {
    var coverArtEl = getSelector(selectors.coverArt)
    var listenEl = getSelector(selectors.listenText)
    if (coverArtEl && listenEl) {
        sendAppMessage("trackInfo", { art: coverArtEl.src, listenText: listenEl.innerText })
    }
}

// Artist page
function getArtistInfo() {
    var wikiEl = getSelector(selectors.wiki)
    var imgEl = getSelector(selectors.artistImage)
    if (wikiEl && imgEl) {
        sendAppMessage("artistInfo", { wiki: wikiEl.innerText, avatar: imgEl.src })
    }
}

(function() {
 if (document.querySelector(selectors.logout)) {
    sendAppMessage("login", "true")
 } else {
    sendAppMessage("login", "false")
 }
})