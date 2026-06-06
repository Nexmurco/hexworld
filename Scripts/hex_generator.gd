extends Object
class_name HexGenerator

var edge_segments: int = 10
const interior_angle_edge: float = 1.0
#1.107149
const edge_segment_multiplier: float = 1.0
#0.809017
var sphere_size: float

const PHI: float = ( 1 + sqrt(5) ) /2;

var edge_with_positions = {}
var hex_id_to_transform = {}
var count: int = 0

var ico_verts = {
    "0": Vector3(1, 1/PHI,  0),
    "1": Vector3(1, -1/PHI, 0),
    "2": Vector3(-1, 1/PHI, 0),
    "3": Vector3(-1, -1/PHI, 0),
    "4": Vector3(1/PHI, 0, 1),
    "5": Vector3(-1/PHI, 0, 1),
    "6": Vector3(1/PHI, 0, -1),
    "7": Vector3(-1/PHI, 0, -1),
    "8": Vector3(0, 1, 1/PHI),
    "9": Vector3(0, 1, -1/PHI),
    "A": Vector3(0, -1, 1/PHI),
    "B": Vector3(0, -1, -1/PHI)
}

var face_list = [
    0, 1, 4,
    0, 4, 8,
    0, 8, 9,
    0, 9, 6,
    0, 6, 1
]

var vert_adj_dict = {
    "0": ["1","4","6","8","9"],
    "1": ["0","4","6","A","B"],
    "2": ["3","5","7","8","9"],
    "3": ["2","5","7","A","B"],
    "4": ["0","1","5","8","A"],
    "5": ["2","3","4","8","A"],
    "6": ["0","1","7","9","B"],
    "7": ["2","3","6","9","B"],
    "8": ["0","2","4","5","9"],
    "9": ["0","2","6","7","8"],
    "A": ["1","3","4","5","B"],
    "B": ["1","3","6","7","A"]
}

var ico_verts_to_faces = {
    "0": ["0", "1", "2", "3", "4"],
    "1": ["0", "4", "5", "6", "7"],
    "2": ["A", "B", "C", "I", "J"],
    "3": ["F", "G", "H", "I", "J"],
    "4": ["0", "1", "7", "8", "9"],
    "5": ["8", "9", "A", "H", "I"],
    "6": ["3", "4", "5", "D", "E"],
    "7": ["C", "D", "E", "F", "J"],
    "8": ["1", "2", "9", "A", "B"],
    "9": ["2", "3", "B", "C", "D"],
    "A": ["6", "7", "8", "G", "H"],
    "B": ["5", "6", "E", "F", "G"]
}

var ico_faces_to_verts = {
    "0": ["0","1","4"],
    "1": ["0","4","8"],
    "2": ["0","8","9"],
    "3": ["0","6","9"],
    "4": ["0","1","6"],
    "5": ["1","6","B"],
    "6": ["1","A","B"],
    "7": ["1","4","A"],
    "8": ["4","5","A"],
    "9": ["4","5","8"],
    "A": ["2","5","8"],
    "B": ["2","8","9"],
    "C": ["2","7","9"],
    "D": ["6","7","9"],
    "E": ["6","7","B"],
    "F": ["3","7","B"],
    "G": ["3","A","B"],
    "H": ["3","5","A"],
    "I": ["2","3","5"],
    "J": ["2","3","7"]
}

var face_adj_dict = {
    "0": ["1", "4", "7"],
    "1": ["0", "2", "9"],
    "2": ["1", "3", "B"],
    "3": ["2", "4", "D"],
    "4": ["0", "3", "5"],
    "5": ["4", "6", "E"],
    "6": ["5", "7", "G"],
    "7": ["0", "6", "8"],
    "8": ["7", "9", "H"],
    "9": ["1", "8", "A"],
    "A": ["9", "B", "I"],
    "B": ["2", "A", "C"],
    "C": ["B", "D", "J"],
    "D": ["3", "C", "E"],
    "E": ["5", "D", "F"],
    "F": ["E", "G", "J"],
    "G": ["6", "F", "H"],
    "H": ["8", "G", "I"],
    "I": ["A", "H", "J"],
    "J": ["C", "F", "I"]
}

func set_edge_segments(segments: int) -> void:
    edge_segments = segments
    sphere_size = edge_segments * edge_segment_multiplier / (1.2*interior_angle_edge)


static func generate_arc_segment_distances(interior_angle: float, radius: float, segment_count: int):
    var lengths = []
    lengths.append(0.0)
    for i in range(1, segment_count):
        var theta_i = i * interior_angle / segment_count
        var theta_o = (PI - interior_angle) / 2
        var theta_r = PI - (theta_i + theta_o)
        lengths.append(radius * sin(theta_i) / sin(theta_r))
        
    return lengths
        

static func generate_arc_points(cartesian_coord_1: Vector3, cartesian_coord_2: Vector3, segment_count: int):
        var spherical_1 = SphereMath.cartesian_to_spherical(cartesian_coord_1)
        var spherical_2 = SphereMath.cartesian_to_spherical(cartesian_coord_2)
        
        var directional_vector: Vector3 = cartesian_coord_2 - cartesian_coord_1
        directional_vector /= directional_vector.distance_to(Vector3.ZERO)
        
        var interior_angle = SphereMath.great_circle_interior_angle(spherical_1, spherical_2)
        var points = []
        
        for length in generate_arc_segment_distances(interior_angle, spherical_1.x, segment_count):
            var point: Vector3 = (cartesian_coord_1 + (length * directional_vector))
            point /= point.distance_to(Vector3.ZERO)
            point *= cartesian_coord_1.distance_to(Vector3.ZERO)
            points.append(point)
        points.remove_at(0)
        
        return points


func _init():
    pass

func generate_world():
    generate_vertices()
    generate_edges()
    generate_faces()

func generate_vertices():
    for vert_id in ico_verts:
        ico_verts[vert_id] = ico_verts[vert_id].normalized()
        ico_verts[vert_id] *= sphere_size
        var adj_vert_id = vert_adj_dict[vert_id][0]
        
        var vert_transform = Transform3D()
        vert_transform = vert_transform.translated(ico_verts[vert_id]).looking_at(Vector3.ZERO, -ico_verts[adj_vert_id])
        
        hex_id_to_transform[count] = vert_transform
        count += 1
    print("generating vertices - " + str(count))

func generate_edges():
    for vert_1 in vert_adj_dict:
        for vert_2 in vert_adj_dict[vert_1]:
            #edges must have different verts
            if vert_1 == vert_2:
                continue
            
            #only construct edges in alphanumeric order
            #this removes duplicates and removes trying to construct with double verts (like A-A)
            var edge_id
            if vert_1 < vert_2:
                edge_id = vert_1 + vert_2
            else:
                continue
            #generate segments for this edge
            var edge_points = generate_arc_points(ico_verts[vert_1], ico_verts[vert_2], edge_segments)
            
            edge_with_positions[edge_id] = edge_points
            
            for edge_point in edge_points:
                var hex_transform = Transform3D()
                hex_transform = hex_transform.translated(edge_point).looking_at(Vector3.ZERO, ico_verts[vert_1]).rotated(edge_point.normalized(), (PI/6))
                hex_id_to_transform[count] = hex_transform
                count += 1
    print("generating edges - " + str(count))
                
func generate_faces():
    for face in ico_faces_to_verts:
        var face_verts = ico_faces_to_verts[face]
        var edge_1 = face_verts[0] + face_verts[1]
        var edge_2 = face_verts[0] + face_verts[2]
        
        var edge_set_1 = edge_with_positions[edge_1]
        var edge_set_2 = edge_with_positions[edge_2]
        
        for i in range(0, edge_segments-1):
            #skip 0, since those hexes are adjacent already
            var edge_hex_1 = edge_set_1[i]
            var edge_hex_2 = edge_set_2[i]
            
            #var face_count = 0
            for hex_pos in generate_arc_points(edge_hex_1, edge_hex_2, i+1):
                var hex_transform = Transform3D()
                hex_transform = hex_transform.translated(hex_pos).looking_at(Vector3.ZERO, edge_hex_1).rotated(hex_pos.normalized(), (PI/6))
                hex_id_to_transform[count] = hex_transform
                count += 1
    print("generating faces - " + str(count))
