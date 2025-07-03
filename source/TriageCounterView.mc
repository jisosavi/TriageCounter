using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Time;
using Toybox.Math;
using Toybox.Lang;

class TriageCounterView extends WatchUi.View {
    private var _count0;
    private var _count1;
    private var _count2;
    private var _count3;
    private var _timerRunning;
    private var _timerStartTime;
    private var _timerPausedElapsed;
    private var _flashTimer;
    private var _flashStartTime;
    private const FLASH_DURATION = 20; // milliseconds
    
    // Colors
    private const COLOR_LIGHT_GREEN = 0x90EE90;
    private const COLOR_LIGHT_YELLOW = 0xFFFF99;
    private const COLOR_LIGHT_RED = 0xFFB6C1;
    private const COLOR_DARK_GRAY = 0x1C1C1C;
    private const COLOR_LIGHT_GRAY = 0xD3D3D3;
    private const COLOR_WHITE = Graphics.COLOR_WHITE;
    private const COLOR_BLACK = Graphics.COLOR_BLACK;

    function initialize() {
        View.initialize();
        _count0 = 0;
        _count1 = 0;
        _count2 = 0;
        _count3 = 0;
        _timerRunning = false;
        _timerStartTime = 0;
        _timerPausedElapsed = 0;
        _flashTimer = false;
        _flashStartTime = 0;
    }

    function onLayout(dc) {
        // No layout resource needed - we're drawing everything programmatically
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var zoneHeight = height / 5;
        
        // Check if flash should end
        if (_flashTimer && System.getTimer() - _flashStartTime > FLASH_DURATION) {
            _flashTimer = false;
            WatchUi.requestUpdate();
        }
        
        dc.clear();
        
        // Draw zones
        drawZone(dc, 0, COLOR_LIGHT_RED, COLOR_BLACK, _count0, 0, width, zoneHeight, centerX);
        drawZone(dc, 1, COLOR_LIGHT_YELLOW, COLOR_BLACK, _count1, zoneHeight, width, zoneHeight, centerX);
        drawZone(dc, 2, COLOR_LIGHT_GREEN, COLOR_BLACK, _count2, zoneHeight * 2, width, zoneHeight, centerX);
        drawZone(dc, 3, COLOR_DARK_GRAY, COLOR_WHITE, _count3, zoneHeight * 3, width, zoneHeight, centerX);
        
        // Draw timer zone
        drawTimerZone(dc, zoneHeight * 4, width, zoneHeight, centerX);
    }
    
    function getCount(index) {
        if (index == 0) { return _count0; }
        else if (index == 1) { return _count1; }
        else if (index == 2) { return _count2; }
        else if (index == 3) { return _count3; }
        else { return 0; }
    }
    
    function setCount(index, value) {
        if (index == 0) { _count0 = value; }
        else if (index == 1) { _count1 = value; }
        else if (index == 2) { _count2 = value; }
        else if (index == 3) { _count3 = value; }
    }

    function drawZone(dc, zoneIndex, bgColor, textColor, count, y, width, height, centerX) {
        // Draw background
        dc.setColor(bgColor, bgColor);
        dc.fillRectangle(0, y, width, height);
        
        // Draw count in center
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX - 18, y + height / 2, Graphics.FONT_LARGE, count.format("%03d"), 
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        
        // Draw reset button closer to the center (to the right of the number)
        var buttonRadius = height * 0.25;
        var buttonX = centerX + 45; // Positioned to the right of center
        var buttonY = y + height / 2;
        
        // Account for round screen - adjust button position if too close to edge
        var maxRadius = width / 2 - 20; // Leave some margin from edge
        if (buttonX + buttonRadius > centerX + maxRadius * 0.7) {
            buttonX = centerX + maxRadius * 0.7 - buttonRadius;
        }
        
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(buttonX, buttonY, buttonRadius.toNumber());
        dc.drawText(buttonX, buttonY, Graphics.FONT_XTINY, "R", 
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawTimerZone(dc, y, width, height, centerX) {
        // Determine colors based on flash state
        var bgColor = COLOR_WHITE;
        var textColor = COLOR_BLACK;
        
        if (_flashTimer) {
            // Invert colors for flash effect
            bgColor = COLOR_LIGHT_GRAY;
            textColor = COLOR_WHITE;
        }
        
        // Draw background
        dc.setColor(bgColor, bgColor);
        dc.fillRectangle(0, y, width, height);
        
        // Calculate elapsed time
        var elapsedSeconds = getElapsedSeconds();
        var hours = (elapsedSeconds / 3600).toNumber();
        var minutes = ((elapsedSeconds % 3600) / 60).toNumber();
        var seconds = (elapsedSeconds % 60).toNumber();
        
        // Draw timer shifted left and up for better balance with reset button
        var timerText = hours.format("%02d") + ":" + minutes.format("%02d") + ":" + seconds.format("%02d");
        var timerX = centerX - 15; // Shift 15 pixels to the left
        var timerY = y + height / 2 - 5; // Shift 5 pixels up
        
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(timerX, timerY, Graphics.FONT_SMALL, timerText, 
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        
        // Draw reset button closer to the center (to the right of the timer)
        var buttonRadius = height * 0.25;
        var buttonX = centerX + 55; // Positioned closer since font is smaller
        var buttonY = y + height / 2 - 5;
        
        // Account for round screen - adjust button position if too close to edge
        var maxRadius = width / 2 - 20; // Leave some margin from edge
        if (buttonX + buttonRadius > centerX + maxRadius * 0.7) {
            buttonX = centerX + maxRadius * 0.7 - buttonRadius;
        }
        
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(buttonX, buttonY, buttonRadius.toNumber());
        dc.drawText(buttonX, buttonY, Graphics.FONT_XTINY, "R", 
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function handleTap(x, y) {
        var width = System.getDeviceSettings().screenWidth;
        var height = System.getDeviceSettings().screenHeight;
        var centerX = width / 2;
        var zoneHeight = height / 5;
        var zoneIndex = (y / zoneHeight).toNumber();
        
        if (zoneIndex >= 5) {
            return; // Out of bounds
        }
        
        // Calculate button position for this zone
        var buttonRadius = zoneHeight * 0.25;
        var buttonX;
        if (zoneIndex == 4) {
            buttonX = centerX + 55; // Timer zone button (adjusted for smaller font)
        } else {
            buttonX = centerX + 45; // Counter zone buttons
        }
        
        // Adjust for round screen
        var maxRadius = width / 2 - 20;
        if (buttonX + buttonRadius > centerX + maxRadius * 0.7) {
            buttonX = centerX + maxRadius * 0.7 - buttonRadius;
        }
        
        var buttonCenterY = (zoneIndex * zoneHeight) + zoneHeight / 2;
        var distToButton = Math.sqrt(Math.pow(x - buttonX, 2) + Math.pow(y - buttonCenterY, 2));
        
        if (distToButton <= buttonRadius) {
            // Reset button tapped
            if (zoneIndex < 4) {
                setCount(zoneIndex, 0);
            } else {
                // Reset timer
                _timerRunning = false;
                _timerStartTime = 0;
                _timerPausedElapsed = 0;
            }
        } else {
            // Zone tapped
            if (zoneIndex < 4) {
                // Increment counter
                var currentCount = getCount(zoneIndex);
                setCount(zoneIndex, (currentCount + 1) % 1000);
            } else {
                // Toggle timer (start/stop)
                toggleTimer();
                // Start flash effect
                _flashTimer = true;
                _flashStartTime = System.getTimer();
            }
        }
        
        WatchUi.requestUpdate();
    }

    function toggleTimer() {
        if (_timerRunning) {
            // Pause timer - save elapsed time
            _timerPausedElapsed = getElapsedSeconds();
            _timerRunning = false;
        } else {
            // Start timer
            _timerStartTime = System.getTimer();
            _timerRunning = true;
        }
    }

    function getElapsedSeconds() {
        if (_timerRunning) {
            return _timerPausedElapsed + ((System.getTimer() - _timerStartTime) / 1000);
        } else {
            return _timerPausedElapsed;
        }
    }

    function updateTimer() {
        if (_timerRunning) {
            WatchUi.requestUpdate();
        }
    }
}