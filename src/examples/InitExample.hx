package examples;

/**
 * ...
 * @author levserk
 */
import flash.Lib;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
 
class InitExample extends Sprite {

	public function new() {
		Lib.current.stage.addChild(this);
		
		var bd:BitmapData = new BitmapData(100, 100, true, 0x00ABF34F);
		bd.fillRect(bd.rect, 0xFF1D1DDC);
		var bp:Bitmap = new Bitmap(bd);
		addChild(bp);
		
		var hbd:HBitmapData = new HBitmapData(bd);
		
		super();
		
	}
	
}