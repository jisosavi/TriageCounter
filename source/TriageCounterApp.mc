using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Timer;

class TriageCounterApp extends Application.AppBase {
    private var _view;
    private var _timer;
 
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        _timer = new Timer.Timer();
        _timer.start(method(:onTimer), 1000, true);
    }

    function onStop(state) {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }

    function getInitialView() {
        _view = new TriageCounterView();
        return [_view, new TriageCounterDelegate(_view)];
    }

    // Explicitly declare return type as Void
    function onTimer() as Void {
        if (_view != null) {
            _view.updateTimer();
            WatchUi.requestUpdate();
        }
    }
}

function getApp() as TriageCounterApp {
    return Application.getApp() as TriageCounterApp;
}