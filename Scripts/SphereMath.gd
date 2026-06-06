extends Object
class_name SphereMath


   
#spherical coordinate definition
#x is radius
#y is theta -> angle through the xz plane (inclination)
#z is phi -> angle down from north pole through vector given by theta (colatitude/azimuth)
static func cartesian_to_spherical(cartesian_coord: Vector3) -> Vector3:
    var theta
    var phi
    var radius = cartesian_coord.distance_to(Vector3.ZERO)
    if radius == 0:
        theta = 0
        phi = 0
    else:
        theta = atan2(cartesian_coord.y, cartesian_coord.x)
        phi = acos(cartesian_coord.z / radius)
    
    return Vector3(radius, theta, phi)
    
static func spherical_to_cartesian(spherical_coord: Vector3) -> Vector3:
    var x = spherical_coord.x * sin(spherical_coord.y) * sin(spherical_coord.z)
    var y = spherical_coord.x * cos(spherical_coord.y) * sin(spherical_coord.z)
    var z = spherical_coord.x * cos(spherical_coord.z)
    return Vector3(x, y, z)
        
#convert colatitude/azimuth to latitude and convert inclination to longitude
static func great_circle_interior_angle(spherical_coord_1: Vector3, spherical_coord_2: Vector3) -> float:
    var lat1 = (PI/2) - spherical_coord_1.z
    var lat2 = (PI/2) - spherical_coord_2.z
    var long1 = spherical_coord_1.y
    var long2 = spherical_coord_2.y
    
    var term1 = cos(lat1) * cos(lat2) * cos(long1 - long2)
    var term2 = sin(lat1) * sin(lat2)
    return acos(term1 + term2)
    
#just use angle_to?
static func vector_interior_angle(cartesian_coord_1: Vector3, cartesian_coord_2: Vector3) -> float:
    #this??
    #return cartesian_coord_1.angle_to(cartesian_coord_2)
    return acos(cartesian_coord_1.dot(cartesian_coord_2) / (cartesian_coord_1.length() * cartesian_coord_2.length()))
    
static func centroid(position_array):
    var new_vert = Vector3.ZERO
    for v in position_array:
        new_vert += v
    new_vert /= position_array.size()
    return new_vert.normalized()
