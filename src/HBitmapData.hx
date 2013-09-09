package ;

/**
 * ...
 * @author levserk
 */

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.Lib;
import flash.Memory;
import flash.utils.ByteArray;

class HBitmapData 
{
	public function Width():UInt  { return w; } 
	public function Height():UInt { return h; } 
	
	public var next:HBitmapData;
	public var prev:HBitmapData;
	
	private var w:UInt;
	private var h:UInt;
	
	private var bitmapData:BitmapData;
	public function getBitmapData():BitmapData { return bitmapData; }
	
//------------  Memory	------------
	private static var memoryBytes:ByteArray;
	private static var memoryLength:UInt;
	public static var first:HBitmapData;
	public static var last:HBitmapData;
	public static var bdBytes:ByteArray = new ByteArray();
//------------------------	
	public var posMemory:UInt;	//bytes
	public var lenght:UInt;		//bytes
//------------------------	


	public function new(bitmapData:BitmapData) {
		this.bitmapData = bitmapData;
		w = Std.int(bitmapData.rect.width);
		h = Std.int(bitmapData.rect.height);
		lenght = w * h * 4;
		HBitmapData.addBitmapData(this);
		bitmapToMemory(bitmapData);
	}
	
	public function saveBitmapData(rect:Rectangle = null):Void {
		bitmapToMemory(bitmapData,rect);
	}
	
	public function loadBitmapData(rect:Rectangle = null):Void {
		memoryToBitmap(bitmapData, rect);
	}
	
	
	inline private function bitmapToMemory(bd:BitmapData, rect:Rectangle = null):Void {
		if (rect == null) rect = bd.rect;
		bdBytes = bd.getPixels(rect);
		bdBytes.position = 0; memoryBytes.position = 0; 
		bdBytes.readBytes(memoryBytes, posMemory); 
		bdBytes.position = 0; memoryBytes.position = 0; 
	}
	
	inline private function memoryToBitmap(bd:BitmapData, rect:Rectangle = null):Void {
		if (rect == null) rect = bd.rect;
		if (posMemory == 0) { 
			memoryBytes.position = 0; 
			bd.setPixels(rect, memoryBytes); 
		} else {
			bdBytes.length = lenght;
			bdBytes.writeBytes(memoryBytes, posMemory, lenght);
			bdBytes.position = 0;
			bd.setPixels(rect, bdBytes);
		}
	}
	
	inline public function getPosMemory(x:UInt, y:UInt):UInt {
		return posMemory + ((y * h) * 4) + (x * 4);
	}
	
	inline public function setPixelRGB(x:UInt, y:UInt, pix:UInt):Void {
		Memory.setI32(getPosMemory(x, y),RGBtoBGRA(pix));
	}
	
	inline public function setPixelARGB(x:UInt, y:UInt, pix:UInt):Void {
		Memory.setI32(getPosMemory(x, y),ARGBtoBGRA(pix));
	}
	
	inline public function setPixelBGRA(x:UInt, y:UInt, pix:UInt):Void {
		Memory.setI32(getPosMemory(x, y),pix);
	}
	
	inline public function setPixel(x:UInt, y:UInt, pixel:Pixel):Void {
		Memory.setI32(getPosMemory(x, y),pixel.getBGRA());
	}
	
	inline public function getPixelBGRA(x:UInt, y:UInt):UInt {
		return Memory.getI32(getPosMemory(x, y));
	}
	
	inline public function getPixel(x:UInt, y:UInt):Pixel {
		return Pixel.createBGRA(Memory.getI32(getPosMemory(x, y)));
	}
	
	
	inline public function drawHBitmapData(hbd:HBitmapData, x:UInt, y:UInt, compositing=true, rect:Rectangle = null):Void {
		if (rect == null) rect = hbd.getBitmapData().rect;
		var sx:UInt = cast(Math.min(w - x, rect.width), UInt);
		var sy:UInt = cast(Math.min(h - y, rect.height), UInt);
		var fx:UInt = Std.int(rect.x);
		var fy:UInt = Std.int(rect.y);
		var posFrom:UInt = 0;
		var posTo:UInt = 0;
		var forecolor:UInt;
		var forePix:Pixel = new Pixel();
		var backPix:Pixel = new Pixel();
		for (j in 0...sy) {
			posFrom = hbd.getPosMemory(fx, fy + j);
			posTo = getPosMemory(x, y + j);
			for (i in 0...sx) {
				forecolor = hbd.getPixelBGRA(fx + i, fy + j);
				if (forecolor & 0x000000FF > 0x01){
					if (!compositing || forecolor & 0x000000FF > 0xFD) setPixelBGRA(x + i, y + j, forecolor);
					else {
						forePix.setBGRA(hbd.getPixelBGRA(fx + i, fy + j));
						backPix.setBGRA(getPixelBGRA(x + i, y + j));
						backPix.composition(forePix);
						setPixel(x + i, y + j, backPix);
					}
				}
				posFrom += 4;
				posTo += 4;
			}
		}
	}

	
//------------  Static Memory	------------
	private static function initMemory(lenght:UInt):Void {
		if (lenght < 1024) lenght = 1024;
		//lenght *= 10;
		memoryBytes = new ByteArray();
		memoryBytes.length = lenght;
		memoryLength = lenght;
		memoryBytes.position = 0;
		Memory.select(memoryBytes);
	}
	
	public static function addBitmapData(hbd:HBitmapData):Void {
		if (memoryBytes == null) {
			initMemory(hbd.lenght);
			first = hbd;
			last = hbd;
			hbd.posMemory = 0;
		} else
		if (last != null) {
			hbd.posMemory = last.posMemory + last.lenght;
			if (cast(memoryLength - hbd.posMemory,UInt) < hbd.lenght) {
				memoryLength = hbd.posMemory + hbd.lenght;
				memoryBytes.length = memoryLength;
				memoryBytes.position = 0;
				Memory.select(memoryBytes);
			}
			last.next = hbd;
			hbd.prev = last;
			last = hbd;
		}
	}
	
	inline public static function setMemoryInt32(pos:UInt, val:UInt):Void {
		Memory.setI32(pos,val);
	}
	
	inline public static function getMemoryInt32(pos:UInt):UInt {
		return Memory.getI32(pos);
	}
	
	public static function selectMemory():Void {
		Memory.select(memoryBytes);
	}
	
	public static function defragmentation():Void {
		var hbd:HBitmapData = HBitmapData.first;
		if (first.next != null) {
			hbd = first.next;
			while (hbd != null) { 
				if (cast(hbd.posMemory - hbd.prev.posMemory,UInt) > hbd.prev.lenght) {
					moveHbitmapData(hbd, hbd.prev.posMemory + hbd.prev.lenght);
				}
			}
		}
	}
	private static function moveHbitmapData(hbd:HBitmapData, pos:UInt):Void {
		var i:UInt = 0;
		while (i < hbd.lenght) {
			Memory.setI32(pos + i, Memory.getI32(hbd.posMemory + i));
			i += 4;
		}
		hbd.posMemory = pos;
	}
	
//------------  Static Colors  ------------		
	// HBitmapData pixel color in int32, - RGBA
	inline public static function ARGBtoBGRA(argb:UInt):UInt {
		return ((argb & 0x000000FF) << 24) | ((argb & 0x00FF00) << 8) | ((argb & 0x00FF0000) >> 8) | (argb >> 24 & 0x000000FF);
	}
	
	inline public static function RGBtoBGRA(rgb:UInt, a:UInt = 0xFF):UInt {
		rgb = (a << 24) | rgb;
		return ((rgb & 0x000000FF) << 24) | ((rgb & 0x00FF00) << 8) | ((rgb & 0x00FF0000) >> 8) | (rgb >> 24 & 0x000000FF);
	}
	
	inline public static function setAlfaToBGRA(bgra:Int, alfa:Int=0xFF):UInt {
		return (bgra & 0xFFFFFF00) | alfa;
	}
	
	inline public static function BGRAgetAlfa(bgra:Int):Float {
		return (bgra & 0x000000FF) / 0xFF;
	}
	
	inline static function compositionBGRA(src:UInt, dst:UInt):UInt {
		var alf:Float = (src & 0x000000FF) * 0.00392156862745098;
		var rgb:UInt = Std.int((dst >> 8) * (1 - alf) + (src >> 8) * alf);
		var a:UInt = Std.int((src & 0x000000FF) + (dst & 0x000000FF) * (1 - alf));
		return (rgb << 8) | a;
	}
	
}