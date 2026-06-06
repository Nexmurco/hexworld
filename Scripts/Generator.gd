extends Object
class_name Generator

const PHI: float = (1 + sqrt(5)) / 2;

var ico_verts = {
    0: Vector3(1, 1/PHI,  0),
    1: Vector3(1, -1/PHI, 0),
    2: Vector3(-1, 1/PHI, 0),
    3: Vector3(-1, -1/PHI, 0),
    4: Vector3(1/PHI, 0, 1),
    5: Vector3(-1/PHI, 0, 1),
    6: Vector3(1/PHI, 0, -1),
    7: Vector3(-1/PHI, 0, -1),
    8: Vector3(0, 1, 1/PHI),
    9: Vector3(0, 1, -1/PHI),
    10: Vector3(0, -1, 1/PHI),
    11: Vector3(0, -1, -1/PHI)
}

func get_icosohedron_edges(vert_set):
    var ico_edges = {}
    var adj_dist = get_min_distance_from_first(vert_set)
    
    for i in vert_set:
        for j in vert_set:
            if i == j:
                continue
            var v_dist = vert_set[i].distance_to(vert_set[j])
            if abs(v_dist - adj_dist) < 0.0001:
                if i not in ico_edges:
                    ico_edges[i] = []
                ico_edges[i].append(j)
    
    return ico_edges

func get_icosohedron_faces(ico_edges):
    var ico_faces = {}
    
    for i in range(12):
        #traverse two steps and see if there is a return
        for j in ico_edges[i]:
            if j < i:
                continue
            for k in ico_edges[j]:
                if k < j:
                    continue
                if i in ico_edges[k]:
                    ico_faces[ico_faces.size()] = [i,j,k]
    return ico_faces


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



func get_min_distance_from_first(vert_set):
    var distances = {}
    var adj_dist = 100000
    var v0 = vert_set[0]
    for i in vert_set:
        if i == 0:
            continue
        var v = vert_set[i]
        var d = v0.distance_to(v)
        if d in distances:
            distances[d] += 1
        else:
            distances[d] = 1
        if d > 0.0001 and d < adj_dist:
            adj_dist = d
    return adj_dist




static func create_edge_partitions(solid: Solid, v1: Vertex, v2: Vertex, partitions: int):
    var vert_id_list = []

    var prev_vert = v1
    var curr_vert = v2

    vert_id_list.append(v1.id)
    
    var new_positions = generate_arc_points(v1.coordinates, v2.coordinates, partitions)

    for i in range(new_positions.size()):
        
        #add new vertex to vertices
        curr_vert = solid.create_vertex_at_position(new_positions[i])

        vert_id_list.append(curr_vert.id)
        
        
        #NEED TO REWORK THIS PROCESS FOR FACE GENERATION
        #overwrite partition_set value with the vert id after the position has been recorded
        #partition_set[i] = curr_vert
                
        #create new edges
        solid.add_edge(prev_vert, curr_vert)
        solid.add_edge_child(v1.id, v2.id, curr_vert.id)
        

        #NEED TO REWORK EDGE TRACKING
        #add new vert as child of edge
        #Utility.push_back_dict_array(solid.parent.edge_to_children, [vert1, vert2], curr_vert)
        
        #update node for loop
        prev_vert = curr_vert

    #connect up newest generated vert with v2
    solid.add_edge(prev_vert, v2)

    vert_id_list.append(v2.id)
    return vert_id_list

static func convert_edge_coord(edge_number, i, j, partitions):
    var x: int
    var y: int

    if edge_number == 0:
        x = i - j
        y = i
    
    elif edge_number == 1:
        x = partitions - i
        y = partitions - j
    
    elif edge_number == 2:
        x = j
        y = partitions + j - i
    
    else:
        return null
    return [x, y]



static func create_interior_partitions(solid, edges, partitions):
    var prev_set = null
    var curr_set = null
    #store each point as a set of coords
    var points = {}
    var tri_coord_to_vert_id = {}

    for e in range(edges.size()):
        for i in range(partitions+1):
            #with the first value, do nothing, it should be the same point
            if i == 0:
                continue
            
            var edge_vert_1 = solid.get_vertex(edges[e][i])
            var edge_vert_2 = solid.get_vertex(edges[e-1][partitions - i])


            if i == partitions:
                curr_set = edges[e-2]
            
            else:
                if e == 0:
                    curr_set = create_edge_partitions(solid, edge_vert_1, edge_vert_2, i)
                else:
                    curr_set = generate_arc_points(edge_vert_1.coordinates, edge_vert_2.coordinates, i)
                    curr_set.push_front(edge_vert_1.id)
                    curr_set.push_back(edge_vert_2.id)


            for j in range(1, curr_set.size()-1):
                var position
                #get trianglular coordinate
                var triangular_coord = convert_edge_coord(e, i, j, partitions)


                #first time through create the connections between verts
                if e == 0:
                    var vert_id = curr_set[j]
                    var prev_id_1 = prev_set[j-1]
                    var prev_id_2 = prev_set[j]
                    solid.add_edge_by_ids(vert_id, prev_id_1)
                    solid.add_edge_by_ids(vert_id, prev_id_2)

                    #track the tri coord to the vert
                    tri_coord_to_vert_id[triangular_coord] = curr_set[j]
                    position = solid.get_vertex(curr_set[j]).coordinates
                else:
                    position = curr_set[j]
                #create a set of coordinates to get a centroid of
                #we will tie it together with the tri coord to vert dict later
                if i > 1 and i < partitions:
                    Utility.push_back_dict_array(points, triangular_coord, position)

            prev_set = curr_set
    
    #update the positiion of each vert using the centroid of the calculated points
    for tri_coord in points:
        solid.vertices[tri_coord_to_vert_id[tri_coord]].coordinates = SphereMath.centroid(points[tri_coord])



static func create_faces(solid):
    for v1 in solid.vertices.values():
        #traverse two steps and see if there is a return
        for v2 in v1.adjacent_vertices.values():
            if v2.id <= v1.id:
                continue
            for v3 in v2.adjacent_vertices.values():
                if v3.id <= v2.id:
                    continue
                if v1.id in v3.adjacent_vertices:
                    #assign face
                    var face = solid.create_face()
                    face.add_vertices([v1, v2, v3])
                    v1.add_face(face)
                    v2.add_face(face)
                    v3.add_face(face)

                    Utility.push_back_dict_array(solid.edge_to_faces, [v1.id, v2.id], face)
                    Utility.push_back_dict_array(solid.edge_to_faces, [v1.id, v3.id], face)
                    Utility.push_back_dict_array(solid.edge_to_faces, [v2.id, v3.id], face)


static func generate_triangle_chunk(solid: Solid, p1: Vertex, p2: Vertex, p3: Vertex, partitions: int = 2):
    solid.add_vertex(p1)
    solid.add_vertex(p2)
    solid.add_vertex(p3)
    
    create_interior_partitions(
        solid, 
        [create_edge_partitions(solid, p1, p2, partitions), 
        create_edge_partitions(solid, p2, p3, partitions),
        create_edge_partitions(solid, p3, p1, partitions)],
        partitions)

    create_faces(solid)


static func get_unique_vert_from_children(vertex, used_vertices):
    for child in vertex.children_vertices:
        if child.id not in used_vertices.keys():
            #immediately return unique child
            used_vertices.append(child.id)
            return child
    #no unused / unique child found, so return null
    return null

static func set_adjacent_faces_from_edges(solid):
    for face in solid.faces.values():
        #get its 3 edges
        var f = face.vertices.keys()
        f.sort()
        for e in [[f[0],f[1]], [f[0],f[2]], [f[1],f[2]]]:
            var face_set = solid.edge_to_faces[e]
            if face_set.size() > 1:
                #ico faces | hex verts
                var ico_face_1 = solid.edge_to_faces[e][0]
                var ico_face_2 = solid.edge_to_faces[e][1]
                solid.set_adjacent_faces(ico_face_1, ico_face_2)

static func push_verts_to_dual_faces(solid_receiver, solid_sender):
    var f1
    var f2
    for v in solid_sender.vertices.values():
        if v.id in solid_receiver.faces:
            f1 = solid_receiver.faces[v.id]
        else:
            f1 = solid_receiver.create_face_with_id(v.id)
        
        f1.center_coordinates = v.coordinates


        #connect the adjacent verts as adjacent faces
        for adj_v in v.adjacent_vertices.values():
            if adj_v.id in solid_receiver.faces:
                f2 = solid_receiver.faces[adj_v.id]
            else:
                f2 = solid_receiver.create_face_with_id(adj_v.id)
            solid_receiver.set_adjacent_faces(f1, f2)

static func push_faces_to_dual_verts(solid_receiver, solid_sender):
    var v1
    var v2
    for face in solid_sender.faces.values():
        if face.id in solid_receiver.vertices:
            v1 = solid_receiver.vertices[face.id]
        else:
            v1 = solid_receiver.create_vertex_id(face.id)
        
        var vert_pos_array = []
        for v in face.vertices.values():
            vert_pos_array.append(v.coordinates)
        
        v1.coordinates = SphereMath.centroid(vert_pos_array)

        #add connected faces to the receiver verts
        #sourced from the sender verts
        for vert in face.vertices.values():
            if vert.id in solid_receiver.faces:
                var f = solid_receiver.faces[vert.id]
                v1.add_face(f)
                f.add_vertex(v1)
                                

        for adj_face in face.adjacent_faces.values():
            if adj_face.id in solid_receiver.vertices:
                v2 = solid_receiver.vertices[adj_face.id]
            else:
                v2 = solid_receiver.create_vertex_id(adj_face.id)
            solid_receiver.add_edge(v1, v2)
    

static func sorted_face_verts(face) -> Array:
    var vert_set = face.vertices.keys()

    #used hex verts tracks the parent level vertices that have been traversed
    var traversed_verts = []

    #prev and curr used for traversal
    var prev_vert = face.vertices[vert_set[0]]
    var curr_vert = null
    for i in range(vert_set.size()):
        traversed_verts.append(prev_vert.id)

        for adj_vert in prev_vert.adjacent_vertices.values():
            if(adj_vert.id not in traversed_verts and adj_vert.id in vert_set):
                curr_vert = adj_vert
                break

        prev_vert = curr_vert
    
    #check to make sure final verts are adjacent
    if traversed_verts[0] in face.vertices[traversed_verts[-1]].adjacent_vertices:
        return traversed_verts
    
    #no closed loop
    return []


static func populate_hex_from_ico(hex, ico):

    push_verts_to_dual_faces(hex, ico)

    set_adjacent_faces_from_edges(ico)

    push_faces_to_dual_verts(hex, ico)


    #sort each hex face
    #create a duplicate of the hex face with original verts

    #populate hex faces with vertices in sorted traversal order
    for face in hex.faces.values():
        


        var face_verts = sorted_face_verts(face)

        if face_verts.size() > 0:

            #clear the dictionary and replace with new duplicated verts
            face.vertices.clear()
            face.color = Color(randf(), randf(), randf(), 1.0)
            face.height = 900 + randf() * 20
            
            #insert new verts into the solid
            #replace all hex verts with new ones
            var curr_vert
            var prev_vert = hex.vertices[face_verts[-1]].clone()
            face.add_vertex(prev_vert)
            prev_vert.add_face(face)
            hex.add_vertex(prev_vert)
            var stored_id = prev_vert.id

            for i in face_verts.size():
                #create duplicate of vert
                if i == face_verts.size() - 1:
                    curr_vert = hex.vertices[stored_id]
                else:
                    curr_vert = hex.vertices[face_verts[i]].clone()
                    hex.add_vertex(curr_vert)
                face.add_vertex(curr_vert)
                curr_vert.add_face(face)
                hex.add_edge(curr_vert, prev_vert)
                
                #add vert id in order
                face.vertex_ids.append(curr_vert.id)
                
                prev_vert = curr_vert
