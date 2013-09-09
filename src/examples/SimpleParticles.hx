package examples;

/**
 * ...
 * @author levserk
 */

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flash.text.TextField;
 
class SimpleParticles extends Sprite {
	
	private var PIXEL_LIVE_TIME:UInt = 120;	// in Steps
	private var GRAVITY_FORCE:Float = 0.0008;
	private var PIXELS_COUNT:Int = 200;		// per Step
	private var POOL_MAX:UInt = 100000; 
	
	private var w:UInt = 800; 
	private var h:UInt = 800;
	private var cx:Int; 
	private var cy:Int;
	private var cfr:Int;
	private var time:Int;
	private var deltatim:Int;
	private var fps:Float;
	private var len:UInt;
	private var hbd:HBitmapData;
	
	private var pix:MPixel;
	private var pnext:MPixel;
	private var first:MPixel;
	private var last:MPixel;
	private var ppool:MPixel;
	private var poolCount:UInt = 0;
	
	private var tf:TextField;
		
	public function new() {
		tf = new TextField();
		tf.width = 150;
		tf.height = 30;
		addChild(tf);
		
		cx = Std.int(w * 0.5);
		cy = Std.int(h * 0.5);
		
		var bd:BitmapData = new BitmapData(w, h, true, 0x00ABF34F);
		var bp:Bitmap = new Bitmap(bd);
		addChild(bp); 
		hbd = new HBitmapData(bd);
		
		
		this.addEventListener(MouseEvent.MOUSE_MOVE, mouseClick);
		Lib.current.stage.addChild(this);
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, enterFrame);
		Lib.current.stage.addEventListener(Event.EXIT_FRAME, exitframe);	
		super();
	}
	
	public function enterFrame(e:Event):Void {
		if (cfr == 0) time = Lib.getTimer();
		cfr++;
		renderPixels();
		hbd.loadBitmapData();
	}
	
	public function exitframe(e:Event):Void {
		deltatim = Lib.getTimer() - time;
		if (cfr > 5&&deltatim>500){
			fps = cfr*1000 / deltatim;
			cfr = 0;
		}
	}
	
	private function renderPixels():Void {
		pix = first;
		var i:UInt = 0;  
		while (pix != null) {
			pnext = pix.next;
			if (pix.active) renderPixel(pix);
			if (!pix.active) removePixel(pix);
			pix = pnext;
			i++;
		}
		tf.text = ('fps: '+ Math.round(fps)+ ' particles: ' + i );
	}
	
	private inline function renderPixel(p:MPixel):Void {
		p.sx += ((cx - p.x) * GRAVITY_FORCE);
		p.sy += ((cy - p.y) * GRAVITY_FORCE);
		hbd.setPixelBGRA(pix.oldx, pix.oldy, 0x00000000);
		p.premove(p.sx, p.sy);
		if (p.nx!=p.oldx || p.ny!=p.oldy){
			if (!checkFree(p.nx, p.ny)) p.active = false;
			else p.move(p.sx, p.sy);
			hbd.setPixelBGRA(pix.oldx, pix.oldy, pix.color);
		}
	}
	
	public inline function checkFree(x:UInt, y:UInt):Bool {
		if (x <= 0 || x >= w || y <= 0 || y >= h) return false;
		else return true;
	}
	
	private function mouseClick(e:MouseEvent):Void {
		if (e.localX > 0 || e.localX < w || e.localY > 0 || e.localY < h){
			for (i in 0...PIXELS_COUNT)createPixel(e);
		}
	}
	
	private inline function createPixel(e:MouseEvent):Void {
		/* // ---  pool  ---
		 * if (ppool != null) {
			pix = ppool;
			ppool = ppool.prev;
			poolCount--;
			pix.next = null;
			pix.prev = null;
			pix.init(Std.int(e.localX), Std.int(e.localY), 
				     Std.int(0xFFFFFF * Math.random()) << 8 | 0xFF, Math.random() * 8 - 4, Math.random() * 8 - 4);
		} else */
		pix = createNewPixel(Std.int(e.localX), Std.int(e.localY));
		
		if (first == null) first = pix;
		else {
			last.next = pix;
			pix.prev = last;
		}
		last = pix;
	}
	
	private inline function removePixel(rpix:MPixel):Void {
		if (rpix.prev != null) rpix.prev.next = rpix.next;
		else first = rpix.next;
		if (rpix.next != null) rpix.next.prev = rpix.prev;
		
		/* // ---  pool  ---
		 * if (poolCount<POOL_MAX) {
			rpix.next = null;
			rpix.prev = ppool;
			ppool = rpix;
			poolCount++;
		}*/
	}
	
	private inline function createNewPixel(x:Int,y:Int):MPixel {
		return new MPixel(x, y, 
						  Std.int(0xFFFFFF * Math.random()) << 8 | 0xFF, 
						  Math.random() * 8 - 4, Math.random() * 8 - 4, 
						  PIXEL_LIVE_TIME);
	}
	
}


//--------------  Particle  ---------------


class MPixel {
	
	public var color:UInt;
	public var x:Float;
	public var y:Float;
	public var sx:Float;
	public var sy:Float;
	public var nx:UInt;
	public var ny:UInt;
	public var oldx:UInt;
	public var oldy:UInt;
	
	public var active:Bool = true;
	
	public var next:MPixel;
	public var prev:MPixel;
	
	public var alpha:Float = 1;
	public var FADE:Float = 0.01;
	
	public function new(x:UInt, y:UInt, color:UInt, sx:Float = 0, sy:Float = 0, liveTime = 300) {
		init(x, y, color, sx, sy);
		FADE = 1 / liveTime;
	}
	
	public inline function init(x:UInt, y:UInt, color:UInt, sx:Float = 0, sy:Float = 0):Void {
		this.x = x;
		this.y = y;
		this.sx = sx;
		this.sy = sy;
		this.color = color;
		oldx = x;
		oldy = y;
		active = true;
		alpha = 1;
	}
	
	public inline function premove(ssx:Float, ssy:Float):Void {
		nx = Std.int(x + ssx);
		ny = Std.int(y + ssy);
		alpha -= FADE;
		color = HBitmapData.setAlfaToBGRA(color, Std.int(0xFF * alpha));
		if (alpha < 0.05) active = false;
	}
	
	public inline function move(ssx:Float, ssy:Float):Void {
		x += ssx;
		y += ssy;
		oldx = nx;
		oldy = ny;
	}
	
	public inline function stop():Void {
		sx = 0;
		sy = 0;
	}
	
}