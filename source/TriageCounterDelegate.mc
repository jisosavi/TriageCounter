using Toybox.WatchUi;

class TriageCounterDelegate extends WatchUi.BehaviorDelegate {
    private var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        _view.handleTap(coords[0], coords[1]);
        return true;
    }
}