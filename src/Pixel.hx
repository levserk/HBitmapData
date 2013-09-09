package ;

/**
 * ...
 * @author levserk
 */
class Pixel 
{
	public var a:UInt;
	public var r:UInt;
	public var g:UInt;
	public var b:UInt;
	
	public function new() 
	{
		
	}
	
	inline public function init(a:UInt, r:UInt, g:UInt, b:UInt):Void {
		this.a = a;
		this.r = r;
		this.b = b;
		this.g = g;
	}
	
	inline public function setARGB(argb:UInt):Void {
		a = (argb >> 24) & 0x000000FF;
		r = (argb >> 16) & 0x000000FF;
		g = (argb >> 8) & 0x000000FF;
		b =  argb & 0x000000FF;
	}
	
	inline public function setBGRA(bgra:UInt):Void {
		b = (bgra >> 24) & 0x000000FF;
		g = (bgra >> 16) & 0x000000FF;
		r = (bgra >> 8) & 0x000000FF;
		a =  bgra & 0x000000FF;
	}
	
	inline public function setAlpha(a:Float):Void {
		this.a = Std.int(0xFF * a); 
	}
	
	inline public function getARGB():UInt {
		return (a << 24) | (r << 16) | (g << 8) | b;
	}
	
	inline public function getBGRA():UInt {
		return (b << 24) | (g << 16) | (r << 8) | a;
	}
	
	inline public function getAlpha():Float {
		return a * 0.00392156862745098;
	}
	
	private var alf:Float;
	inline public function composition(pixel:Pixel):Void {
		alf = pixel.getAlpha();
		r = Std.int(r + alf * (pixel.r - r));
		g = Std.int(g + alf * (pixel.g - g));
		b = Std.int(b + alf * (pixel.b - b));
		a = Std.int(pixel.a + a * (1 - alf));	
	}
	
	inline public function toString():String {
		return 'alfa:' + StringTools.hex(a,2) + ' red:' +  StringTools.hex(r,2) + ' green:' +  StringTools.hex(g,2) + ' blue:' +  StringTools.hex(b,2);
	}
	
	
	
	
	
	public static function create(a:UInt, r:UInt, g:UInt, b:UInt):Pixel {
		var pixel:Pixel = new Pixel();
		pixel.init(a, r, g, b);
		return pixel;
	}
	
	public static function createARGB(argb:UInt):Pixel {
		var pixel:Pixel = new Pixel();
		pixel.setARGB(argb);
		return pixel;
	}
	
	public static function createBGRA(bgra:UInt):Pixel {
		var pixel:Pixel = new Pixel();
		pixel.setBGRA(bgra);
		return pixel;
	}	
}