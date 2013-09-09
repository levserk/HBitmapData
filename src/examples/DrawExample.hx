package examples;

/**
 * ...
 * @author levserk
 */

import flash.geom.Rectangle;
import flash.Lib;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
 
class DrawExample extends Sprite {

	public function new() {
		Lib.current.stage.addChild(this);
		
		var bd:BitmapData = new BitmapData(100, 100, true, 0x00000000);
		bd.fillRect(new Rectangle(0,0,75,75), 0xFF1D1DDC);
		var bp:Bitmap = new Bitmap(bd);
		addChild(bp);
		
		var hbd:HBitmapData = new HBitmapData(bd);
		
		// set alpha 0.5 for rectangle(0, 0, 50, 50)
		for (xx in 0...50) {
			for (yy in 0...50) {
				// get pixel color in (xx, yy)
				var color:UInt = hbd.getPixelBGRA(xx, yy);
				// set pixel color
				hbd.setPixelBGRA(xx, yy, HBitmapData.setAlfaToBGRA(color, 127));
			}
		}
		
		//create other HBitmapData, fill red, alpha 0.6
		bd.fillRect(bd.rect, 0x99FF0000);
		var hbds:HBitmapData = new HBitmapData(bd);
		
		// draw part this HBitmapData over first HBitmapData
		hbd.drawHBitmapData(hbds, 25, 25, true, new Rectangle(0,0,50,100));
		
		// load changes to bitmap bp
		hbd.loadBitmapData();
		
		super();
		
	}
	
}