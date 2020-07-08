using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.Timer;
using Toybox.Background;

class LeafStatusView extends WatchUi.View {

	var mainLayout;
	var numPercent = 0;
	var percentage = "";
	var chargeState = "";
	var estimatedRange = "";
	var idealRange = "";
	
    
    function initialize() {
        WatchUi.View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
    	mainLayout = Rez.Layouts.MainLayout(dc);
        setLayout(mainLayout);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {

    }

    // Update the view
    function onUpdate(dc) {
       System.println("onUpdate");
       
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        
        var batteryBack = new WatchUi.Bitmap({:rezId=>Rez.Drawables.battery_back, :locX=>0, :locY=>60});
        var batteryFront = new WatchUi.Bitmap({:rezId=>Rez.Drawables.battery_front, :locX=>0, :locY=>60});
        var batteryCoppertops = new WatchUi.Bitmap({:rezId=>Rez.Drawables.battery_coppertops, :locX=>0, :locY=>60});
        
        var bmpX = (dc.getWidth() / 2 - batteryBack.width / 2) + 5;
        
        batteryBack.locX = bmpX;
        batteryFront.locX = bmpX;
        batteryCoppertops.locX = bmpX;
        
        batteryBack.draw(dc);
        
        var level = ((numPercent / 100) * (batteryFront.width));
        //dc.setColor(0xFF00FF, 0x000000);
		//dc.drawRectangle(bmpX, batteryBack.locY, level - 18, batteryBack.height);
        dc.setClip(bmpX, batteryBack.locY, level - 18, batteryBack.height);
        batteryFront.draw(dc);
        dc.clearClip();
        
        batteryCoppertops.draw(dc);
        
        var percentageLabel = View.findDrawableById("id_percentage");
        percentageLabel.setText(percentage);
        percentageLabel.draw(dc);
        
        var chargeStateLabel = View.findDrawableById("id_charge_state");
        chargeStateLabel.setText(chargeState);
        chargeStateLabel.setFont(Graphics.FONT_XTINY);
        chargeStateLabel.draw(dc);
        
        var estimatedRangeLabel = View.findDrawableById("id_estimated_range");
        estimatedRangeLabel.setText("estimate: " + estimatedRange);
        estimatedRangeLabel.draw(dc);
       
       	var idealRangeLabel = View.findDrawableById("id_ideal_range");
        idealRangeLabel.setText("ideal: " + idealRange); 
        idealRangeLabel.draw(dc);
       
		// Call the parent onUpdate function to redraw the layout
        //View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
    
    function onLoading() {
        percentage = "";
        chargeState = "";
        estimatedRange = "";
        idealRange = "";
        WatchUi.requestUpdate();
    }
    
    function onReceive(data) {

		System.println("data received");
        if (data instanceof Lang.String) {
            percentage = data;
        }
        else if (data instanceof Dictionary) {
        	System.println("got a dictionary");

			numPercent = data["soc"].toDouble();
            percentage = data["soc"].toLong().toString() + "%"; //cast to long to remove the decimal
            chargeState = data["chargestate"];
            estimatedRange = data["estimatedrange"] + " km";
            idealRange = data["idealrange"] + " km";
        }
        else {
        	System.println("got something else" + data);
        }
	     
	    WatchUi.requestUpdate();
    }

}
