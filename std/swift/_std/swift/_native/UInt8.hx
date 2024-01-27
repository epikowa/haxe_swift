package swift._native;

@:native('UInt8')
extern class UInt8 {
    static inline function toInt(uint:UInt8):Int {
        return cast Syntax.code('Int(uint)');
    }
}