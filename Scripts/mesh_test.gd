extends MeshInstance3D

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



func create_subdivided_edges(solid, vert1, vert2, partitions):
    var prev_node = vert1
    var curr_node = vert2
    var partition_set = HexGenerator.generate_arc_points(solid.vertices[vert1], solid.vertices[vert2], partitions)

    for i in range(partition_set.size()):
        curr_node = solid.vertices.size()
        
        #add new vertex to vertices
        solid.vertices[curr_node] = partition_set[i]
        
        #overwrite partition_set value with the vert id after the position has been recorded
        partition_set[i] = curr_node
                
        #create new edges
        Utility.push_back_dict_array(solid.edges, curr_node, prev_node)
        Utility.push_back_dict_array(solid.edges, prev_node, curr_node)
        
        #add new vert as child of edge
        Utility.push_back_dict_array(solid.parent.edge_to_children, [vert1, vert2], curr_node)
        
        #update node for loop
        prev_node = curr_node

    #connect up last vert with end vert
    curr_node = vert2
    Utility.push_back_dict_array(solid.edges, curr_node, prev_node)
    Utility.push_back_dict_array(solid.edges, prev_node, curr_node)
    
    return partition_set


func create_interior_face_elements(solid, face_id, partitions):
    var face = solid.parent.faces[face_id]
    
    var edge_left = solid.parent.edge_to_children[[face[0],face[1]]]
    var edge_right = solid.parent.edge_to_children[[face[0],face[2]]]
    var edge_bottom = solid.parent.edge_to_children[[face[1], face[2]]]
    
    var prev_set = null
    var curr_set = null
    
    for i in range(partitions):

        if i < partitions - 1:
            curr_set = create_subdivided_edges(solid, edge_left[i], edge_right[i], i+1)
        
        elif i == partitions - 1:
            curr_set = edge_bottom.duplicate(true)
        
        #connect new string of verts upwards diagonally across the face
        if i > 0:
            for j in curr_set.size():
                solid.edges[curr_set[j]].append(prev_set[j])
                solid.edges[prev_set[j]].append(curr_set[j])
                solid.edges[curr_set[j]].append(prev_set[j+1])
                solid.edges[prev_set[j+1]].append(curr_set[j])
        
        if i < partitions - 1:
            #append the edge parents to the partition sets with diagonal links
            curr_set.push_front(edge_left[i])
            curr_set.push_back(edge_right[i])
            prev_set = curr_set

func create_faces(solid):
    for i in range(solid.vertices.size()):
        #traverse two steps and see if there is a return
        for j in solid.edges[i]:
            if j <= i:
                continue
            for k in solid.edges[j]:
                if k <= j:
                    continue
                if i in solid.edges[k]:
                    #assign face
                    var face_id = solid.faces.size()
                    solid.faces[face_id] = [i,j,k]
                    
                    #assign edge to face
                    Utility.push_back_dict_array(solid.edge_to_faces, [i,j], face_id)
                    Utility.push_back_dict_array(solid.edge_to_faces, [i,k], face_id)
                    Utility.push_back_dict_array(solid.edge_to_faces, [j,k], face_id)
                    
                    #assign vert to face
                    Utility.push_back_dict_array(solid.vert_to_faces, i, face_id)
                    Utility.push_back_dict_array(solid.vert_to_faces, j, face_id)
                    Utility.push_back_dict_array(solid.vert_to_faces, k, face_id)



func _ready():
    print("Beginning Construction")
    
    var icosohedron = Solid.new()
    icosohedron.vertices = ico_verts
    icosohedron.edges = get_icosohedron_edges(icosohedron.vertices)
    icosohedron.faces = get_icosohedron_faces(icosohedron.edges)
    
    var info = {}
    info[0] = icosohedron
    
    var partitions = 3
    var depth = 5
    
    for depth_count in range(1, depth+1):
        print("Constructing Subdivision depth " + str(depth_count) + "/" + str(depth))
        #create new containers for edges, faces, and verts
        var curr_solid = Solid.new()
        var prev_solid = info[depth_count-1]
        info[depth_count] = curr_solid
        curr_solid.set_parent(prev_solid)
        
        #construct verts on prev edges and make new edges
        print("Subdividing Edges")
        for v1 in curr_solid.parent.vertices:
            for v2 in curr_solid.parent.edges[v1]:
                if v2 <= v1:
                    continue
                
                create_subdivided_edges(curr_solid, v1, v2, partitions)
 
        #Construct new interior vertices from connecting and partitioning new edge verts
        print("Subdividing Faces")
        for f in curr_solid.parent.faces:
            create_interior_face_elements(curr_solid, f, partitions)
        
        #construct faces
        create_faces(curr_solid)

    #create hexagonal structure
    var hex_solid = Solid.new()
    
    #convert each ico face into a hex vert
    var curr_ico = info[depth]

    #convert ico faces to hex verts
    print("Constructing Hexagonal Centroids")
    for f_id in curr_ico.faces:
        var id_offset = curr_ico.faces.size()
        
        var vert_array = []
        for v in curr_ico.faces[f_id]:
            vert_array.append(curr_ico.vertices[v])
        
        var pos = SphereMath.centroid(vert_array)
        
        #construct x = 4 copies of the id
        for i in range(4):
            hex_solid.vertices[(id_offset * i) + f_id] = pos
    
    print(hex_solid)
    #construct hex edges from adjacent faces
    
    #print("Constructing Hexagonal Edge Transverses")
    for face_id in curr_ico.faces:
        #get its 3 edges
        var f = curr_ico.faces[face_id]

        var face_edges = [[f[0],f[1]], [f[0],f[2]], [f[1],f[2]]]
        for e in face_edges:

            var v1 = curr_ico.edge_to_faces[e][0]
            var v2 = curr_ico.edge_to_faces[e][1]

            Utility.push_back_dict_array(hex_solid.edges, v1, v2)
            Utility.push_back_dict_array(hex_solid.edges, v2, v1)

    var vert_color = {}
    var vert_height = {}
    
    #Convert ico verts to hex faces
    print("Constructing Hexagonal Faces")
    var used_verts = {}
    
    for v in curr_ico.vertices:
        
        #generate face color
        #generate face height
        var face_color = Color(randf(), randf(), randf(), 1.0)
        var face_height = randf() * 25
        
        #use ico vert id as hex face id
        hex_solid.faces[v] = []
        
        var hex_vert_group = []
        for hex_vert in curr_ico.vert_to_faces[v]:
            hex_vert_group.append(hex_vert)
        
        #sort verts by adjacency
        var visit_list = []
        var finished_searching = false
        var curr_vert = hex_vert_group[0]
        
        while not finished_searching:
            var value = 0
            for i in range(1,4):
                value = curr_vert + (curr_ico.faces.size() * i)
                if value not in used_verts:
                    break
            
            hex_solid.faces[v].append(value)
            used_verts[value] = true
            
            visit_list.append(curr_vert)
            
            #grab a vert from the edge group
            finished_searching = true
            for adj_vert in hex_solid.edges[curr_vert]:
                if adj_vert in hex_vert_group and adj_vert not in visit_list:
                    curr_vert = adj_vert
                    finished_searching = false
                    break
        
        for vert in hex_solid.faces[v]:
            vert_color[vert] = face_color
            vert_height[vert] = face_height
    
    #get each face 
    #split face into sub triangles, and check if direction is toward origin
    var faces_oriented = {}
    
    for f_id in hex_solid.faces:
        var hex_face = hex_solid.faces[f_id]
        var p0 = hex_solid.vertices[hex_face[0]]
        var base = 0
        
        #construct hex top face
        while base + 2 < hex_face.size():
            var p1 = hex_solid.vertices[hex_face[base + 1]]
            var p2 = hex_solid.vertices[hex_face[base + 2]]
            var c = (p1-p0).cross(p2-p0).dot(p0)
            
            var key = null
            if(c < 0):
                key = [hex_face[0],hex_face[base+1],hex_face[base+2]]
            else:
               key = [hex_face[0], hex_face[base+2],hex_face[base+1]]
            
            faces_oriented[key] = true
            
            base += 1
            
        #construct side walls
        var hex_center = curr_ico.vertices[f_id]
        for i in range(hex_face.size()):
            var id_prev = hex_face[i - 1]
            var id = hex_face[i]
            var id_prev_base = hex_face[i-1] % curr_ico.faces.size()
            var id_base = hex_face[i] % curr_ico.faces.size()
            var p1 = hex_solid.vertices[id]
            var p2 = hex_solid.vertices[id_prev]
            var direction = p1.cross(hex_center).dot(p2)
            if direction < 0:
                faces_oriented[[id, id_prev, id_base]] = true
                faces_oriented[[id_prev, id_prev_base, id_base]] = true
            else:
                faces_oriented[[id, id_base, id_prev]] = true
                faces_oriented[[id_prev, id_base, id_prev_base]] = true
            
    
    
    var surface_array = []
    surface_array.resize(Mesh.ARRAY_MAX)

    # PackedVector**Arrays for mesh construction.
    var verts = PackedVector3Array()
    #var uvs = PackedVector2Array()
    var normals = PackedVector3Array()
    var indices = PackedInt32Array([])
    var colors = PackedColorArray()

    #######################################

    for face in faces_oriented:
        indices.append_array(face)
    
    #######################################
    var vert_list = hex_solid.vertices.duplicate(true)
    vert_list.sort()
    for vert in vert_list:
        var h_offset = vert_height[vert] if vert in vert_height else 0
        var color = vert_color[vert] if vert in vert_color else Color(0,0,0,0)
        var h = (900 + h_offset)
        var v = hex_solid.vertices[vert % hex_solid.vertices.size()] * h
         #* h
        verts.append(v)
        normals.append(v)
        colors.append(color)

    # Assign arrays to surface array.
    surface_array[Mesh.ARRAY_VERTEX] = verts
    #surface_array[Mesh.ARRAY_TEX_UV] = uvs
    surface_array[Mesh.ARRAY_NORMAL] = normals
    surface_array[Mesh.ARRAY_INDEX] = indices
    surface_array[Mesh.ARRAY_COLOR] = colors

    # Create mesh surface from mesh array.
    # No blendshapes, lods, or compression used.
    
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES , surface_array)
