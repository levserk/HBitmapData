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
import flash.geom.Rectangle;
import flash.Lib;
import flash.text.TextField;
 
class ParticlesCollisionDetection extends Sprite {
	
	private var PIXEL_LIVE_TIME:UInt = 20;
	private var GRAVITY_FORCE:Float = 0.15;
	private var MOUSE_RADIUS:UInt = 10;
	
	private var w:UInt = 800; 
	private var h:UInt = 800;
	private var cfr:Int;
	private var time:Int;
	private var deltatim:Int;
	private var fps:Float;
	private var hbd:HBitmapData;
	private var phbd:HBitmapData;
	
	private var pix:MCPixel;
	private var pnext:MCPixel;
	private var colp:MCPixel;
	private var first:MCPixel;
	private var last:MCPixel;
	private var map:Map<Int,MCPixel>;
	
	private var oldMouseX:Float;
	private var oldMouseY:Float;
	private var vmx:Float;
	private var vmy:Float;
	
	private var tf:TextField;
	
	public function new() 
	{
		tf = new TextField();
		tf.width = 150;
		tf.height = 30;
		addChild(tf);
		
		map = new Map();
		
		var bd:BitmapData = new BitmapData(w, h, true, 0x00ABF34F);
		bd.fillRect(new Rectangle(w / 4, h / 4, w / 2, h / 2), 0xFF1D1DDC);
		var bp:Bitmap = new Bitmap(bd);
		addChild(bp); 
		hbd = new HBitmapData(bd);
		
		var bdpix:BitmapData = new BitmapData(w, h, true, 0x00000000);
		phbd = new HBitmapData(bdpix);
		
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
		drawPixels();
		hbd.loadBitmapData();
		clearPixels();
	}
	
	public function exitframe(e:Event):Void {
		deltatim = Lib.getTimer() - time;
		if (cfr > 5&&deltatim>500){
			fps = cfr*1000 / deltatim;
			cfr = 0;
		}
	}
	
	private inline  function renderPixels() {
		pix = first;
		var i:UInt = 0;  
		while (pix != null) {
			pnext = pix.next;
			if (pix.active) renderPixel(pix);
			if (!pix.active) removePixel(pix);
			pix = pnext;
			i++;
		}
		if (first!=null && !first.active) first = first.next;
		if (last!=null && !last.active) last = last.prev;
		tf.text = ('fps: '+ Math.round(fps)+ ' particles: ' + i );
	}
	
	private inline function renderPixel(p:MCPixel):Void {
		if (p.removing >= PIXEL_LIVE_TIME) p.active = false; 
		else {
			if (Math.abs(p.oldx - oldMouseX) < MOUSE_RADIUS && Math.abs(p.oldy - oldMouseY) < MOUSE_RADIUS) 
				p.collisionWithPoint(Std.int(oldMouseX), Std.int(oldMouseY), vmx, vmy, MOUSE_RADIUS);
				
			p.sy += GRAVITY_FORCE;	
			
			p.premove(p.sx, p.sy);
			if (p.nx!=p.oldx || p.ny!=p.oldy){
				if (!checkFree(p.nx, p.ny)) {
					colp = map.get(p.nx * w + p.ny);
					if (colp != null) p.collision(colp);
					else p.stop();
					p.removing++;
				} else {
					p.removing = 0;
					if (p.nx != p.oldx || p.ny != p.oldy) {
						phbd.setPixelBGRA(p.oldx, p.oldy, 0x00000000);
						phbd.setPixelBGRA(p.nx, p.ny, p.color);
					}
					map.remove(p.oldx * w + p.oldy);
					p.move(p.sx, p.sy);
					map.set(p.nx * w + p.ny, p);
				}
			} else {
				p.move(p.sx, p.sy);
				p.removing++;
			}
		}
	}
	
	public inline function checkFree(x:UInt, y:UInt):Bool {
		if (x <= 0 || x >= w || y <= 0 || y >= h 
			|| hbd.getPixelBGRA(x, y) & 0x000000FF > 1 || phbd.getPixelBGRA(x, y) & 0x000000FF > 1
		) return false;
		else return true;
	}
	
	public inline function getPixxColl(x:UInt, y:UInt):MCPixel {
		if (x > 0 && y > 0 && x < w && y < h && phbd.getPixelBGRA(x, y) & 0x000000FF > 1) {
			colp = first;
			while (colp != null) {
				if (colp.active && colp.oldx == x && colp.oldy == y) break;
				colp = colp.next;
			}
			if (colp==null || colp.oldx != x || colp.oldy != y) colp = null;
			return colp;
		} else return null;
	}
	
	private inline function drawPixels():Void {
		pix = first;
		while (pix != null) {
			if (pix.active) hbd.setPixelBGRA(pix.oldx, pix.oldy, pix.color);
			pix = pix.next;
		}
	}
	
	private inline function clearPixels():Void {
		pix = first;
		while (pix != null) {
			if (pix.active) hbd.setPixelBGRA(pix.oldx, pix.oldy, 0x00000000);
			pix = pix.next;
		}
	}
	
	private inline function removePixel(rpix:MCPixel):Void {
		if (rpix.prev != null) rpix.prev.next = rpix.next;
		else first = rpix.next;
		if (rpix.next != null) rpix.next.prev = rpix.prev;
		phbd.setPixelBGRA(rpix.oldx, rpix.oldy, 0x00000000);
		hbd.setPixelBGRA(rpix.oldx, rpix.oldy, rpix.color); 
		map.remove(rpix.oldx * w + rpix.oldy);
	}
	
	
	private function mouseClick(e:MouseEvent):Void {
		if (e.buttonDown){
			createNewPixel(e);
		}else createPixel(e, MOUSE_RADIUS);
		vmx = e.localX - oldMouseX;
		vmy = e.localY - oldMouseY;
		oldMouseX = e.localX;
		oldMouseY = e.localY;
	}
	
	private inline function createNewPixel(e:MouseEvent) {
		pix = new MCPixel(Std.int(e.localX), Std.int(e.localY), Std.int(0x00FFFFFF*Math.random()), Std.int( Math.random()*4 - 2 ), Std.int( Math.random()*4 - 2 ) );
		if (first == null) first = pix;
		else {
			last.next = pix;
			pix.prev = last;
		}
		last = pix;
	}
	
	private function createPixel(e:MouseEvent, rad:UInt = 2) {
		var color:UInt;
		for (x in Std.int(e.localX) - rad...Std.int(e.localX) + rad) {
			for (y in Std.int(e.localY) - rad...Std.int(e.localY) + rad) {
				if (x>0&&y>0&&cast(x,UInt)<w&&cast(y,UInt)<h){
					color = hbd.getPixelBGRA(x, y);
					if (color&0x000000FF>1){
						pix = new MCPixel(x, y, color, (e.localX - oldMouseX)*0.2, (e.localY - oldMouseY)*0.2 );
						hbd.setPixelBGRA(x, y, 0x00000000);
						if (first == null) first = pix;
						else {
							last.next = pix;
							pix.prev = last;
						}
						last = pix;
					}
				}
			}
		}
	}
}

class MCPixel {
	public var color:UInt;
	public var x:Float;
	public var y:Float;
	public var sx:Float;
	public var sy:Float;
	public var nx:UInt;
	public var ny:UInt;
	public var oldx:UInt;
	public var oldy:UInt;
	
	public var removing:UInt=0;
	
	public var active:Bool = true;
	
	public var next:MCPixel;
	public var prev:MCPixel;
	
	public function new(x:UInt,y:UInt,color:UInt,sx:Float=0,sy:Float=0) {
		this.x = x;
		this.y = y;
		this.sx = sx;
		this.sy = sy;
		this.color = color;
		oldx = x;
		oldy = y;
	}
	
	public inline function remove():Void {
		active = false;
		if (next != null && prev != null) { 
			next.prev = prev;
			prev.next = next;
		}
	}
	
	public inline function premove(ssx:Float, ssy:Float):Void {
		nx = Std.int(x + ssx);
		ny = Std.int(y + ssy);
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
	
	public inline function collision(p:MCPixel):Void {
		sx = (sx + p.sx * 0.5) * 0.65;
		sy = (sy + p.sy * 0.5) * 0.65;
		p.sx = (p.sx + sx * 0.5) * 0.65;
		p.sy = (p.sy + sy * 0.5) * 0.65;
	}
	
	private var angl:Float;
	public function collisionWithPoint(x:UInt, y:UInt,vx:Float,vy:Float, r:UInt = 2,upr:Float=1) {
		angl = Math.atan2(y - oldy, x - oldx);
		sx = Math.cos(angl) * sx+vx*0.5;
		sy = Math.sin(angl) * sy+vy*0.5;
	}
	
}