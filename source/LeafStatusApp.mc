using Toybox.Application;

class LeafStatusApp extends Application.AppBase {

	hidden var mView;
	hidden var mWebRequestDelegate;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        mView = new LeafStatusView();
        mWebRequestDelegate = new WebRequestDelegate(mView);
        return [mView, mWebRequestDelegate];
    }

}