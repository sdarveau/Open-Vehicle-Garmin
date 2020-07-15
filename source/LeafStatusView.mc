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
	
	var connectionAvailable = true;
	var credentialsSet = true;
	var connUnavailStr = "";
	var noCredentialsSetStr = "";
	var estimateStr = "";
	var idealStr = "";
	var chargeStoppedStr = "charge stopped";
	var chargingStr = "charging...";
	
    
    function initialize() {
        WatchUi.View.initialize();
        connUnavailStr = WatchUi.loadResource(Rez.Strings.ConnUnavail);
        noCredentialsSetStr = WatchUi.loadResource(Rez.Strings.NoCredentialsSet);
        estimateStr = WatchUi.loadResource(Rez.Strings.estimate);
        idealStr = WatchUi.loadResource(Rez.Strings.ideal);
        chargeStoppedStr = WatchUi.loadResource(Rez.Strings.chargeStopped);
        chargingStr = WatchUi.loadResource(Rez.Strings.charging);
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
        
        if ( !connectionAvailable ) {
        	dc.drawText(
	            dc.getWidth()/2,
	            dc.getHeight()/2,
	            Graphics.FONT_XTINY,
	            connUnavailStr,
	            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
	        );
	        return;
        }
        
        if (!credentialsSet) {
        	dc.drawText(
	            dc.getWidth()/2,
	            dc.getHeight()/2,
	            Graphics.FONT_XTINY,
	            noCredentialsSetStr,
	            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
	        );
	        return;
        }
        
        var batteryBack = new WatchUi.Bitmap({:rezId=>Rez.Drawables.battery_back, :locX=>0, :locY=>60});
        var batteryFront = new WatchUi.Bitmap({:rezId=>Rez.Drawables.battery_front, :locX=>0, :locY=>60});
        var batteryCoppertops = new WatchUi.Bitmap({:rezId=>Rez.Drawables.battery_coppertops, :locX=>0, :locY=>60});
        
        var bmpX = (dc.getWidth() / 2 - batteryBack.width / 2) + 5;
        
        batteryBack.locX = bmpX;
        batteryFront.locX = bmpX;
        batteryCoppertops.locX = bmpX;
        
        batteryBack.draw(dc);
        
        var newwidth = ((numPercent / 100) * (174-12) + 13);
        //dc.setColor(0xFF00FF, 0x000000);
		//dc.drawRectangle(bmpX, batteryBack.locY, newwidth, batteryBack.height);
        dc.setClip(bmpX, batteryBack.locY, newwidth, batteryBack.height);
        batteryFront.draw(dc);
        dc.clearClip();
        
        batteryCoppertops.draw(dc);
        
        var percentageLabel = View.findDrawableById("id_percentage");
        percentageLabel.setText(percentage);
        var fontHeight = dc.getFontHeight(Graphics.FONT_SMALL);
        percentageLabel.locY = batteryFront.locY + batteryFront.height / 2 - (fontHeight / 2);
        percentageLabel.draw(dc);
        
        var chargeStateLabel = View.findDrawableById("id_charge_state");
        chargeStateLabel.setText(chargeState);
        chargeStateLabel.locY = batteryBack.locY + batteryBack.height + 10;
        chargeStateLabel.setFont(Graphics.FONT_XTINY);
        chargeStateLabel.draw(dc);
        
        var estimatedRangeLabel = View.findDrawableById("id_estimated_range");
        estimatedRangeLabel.setText(estimateStr + ": " + estimatedRange);
        estimatedRangeLabel.locY = chargeStateLabel.locY + chargeStateLabel.height;
        estimatedRangeLabel.draw(dc);
       
       	var idealRangeLabel = View.findDrawableById("id_ideal_range");
        idealRangeLabel.setText(idealStr + ": " + idealRange); 
        idealRangeLabel.locY = estimatedRangeLabel.locY + estimatedRangeLabel.height;
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
        	numPercent = 0.0;
        	percentage = "";
            chargeState = data;
        }
        else if (data instanceof Dictionary) {
			numPercent = data["soc"].toDouble();
            percentage = data["soc"].toLong().toString() + "%"; //cast to long to remove the decimal
            chargeState = data["chargestate"].equals("stopped") ? chargeStoppedStr : chargingStr;
            estimatedRange = data["estimatedrange"] + " km";
            idealRange = data["idealrange"] + " km";
            connectionAvailable = true;
        }
        else {
        	System.println("Unexpected data: " + data);
        }
	     
	    WatchUi.requestUpdate();
    }

}
