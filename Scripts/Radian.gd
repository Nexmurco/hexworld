extends Object
class_name Radian

var radians: float = 0

func _init(r: float):
    radians = r
    reduce()

func set_radians(r: float) -> float:
    radians = r
    reduce()
    return radians

func add(addend: float) -> float:
    radians += addend
    reduce()
    return radians

func multiply(multiplicand: float) -> float:
    radians *= multiplicand
    reduce()
    return radians
    
func divide(dividend: float) -> float:
    radians /= dividend
    reduce()
    return radians

func reduce() -> float:
    while radians > 2 * PI:
        radians -= 2 * PI
    
    while radians < -2 * PI:
        radians += 2 * PI
        
    return radians
