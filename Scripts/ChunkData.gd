extends Object
class_name ChunkData

var parent_chunk: ChunkData
var adj_chunks = {}
var children_chunks = {}

var id: int
var partitions: int
var depth: int

#ico and hex are duals
var hexagons: Solid
var ico: Solid

var mesh_face_data = {}


func _init(solid_id = null, solid_partitions = 2, solid_depth = 0) -> void:
    id = solid_id
    partitions = solid_partitions
    depth = solid_depth
    hexagons = Solid.new()
    ico = Solid.new()

func add_child_chunk(child):
    children_chunks[child.id] = child

func set_parent_chunk(parent):
    parent_chunk = parent
    parent_chunk.add_child_chunk(self)

func convert_ico_to_hex_data():
    Generator.populate_hex_from_ico(hexagons, ico)


func create_mesh_face_data():
    mesh_face_data.clear()

    for face in hexagons.faces.values():

        #if this face cannot form a full polygon, then skip
        if face.vertex_ids.size() <= 0:
            continue

        #get the list of sorted (by traversal order) and unique child vert ids
        var face_verts = face.vertex_ids
        var p0 = face.vertices[face_verts[0]].coordinates
        
        #construct hex top face
        for base in range(face_verts.size()-2):
            #get points adjacents to each other on hex perimeter
            var p1 = face.vertices[face_verts[base + 1]].coordinates
            var p2 = face.vertices[face_verts[base + 2]].coordinates

            var key = null
            #calculate if points are facing outward in terms of the hexagon
            if (p1-p0).cross(p2-p0).dot(p0) < 0:
                key = [face_verts[0],face_verts[base+1],face_verts[base+2]]
            else:
               key = [face_verts[0], face_verts[base+2],face_verts[base+1]]
            
            mesh_face_data[key] = true
            
            
        #construct side walls
        for i in range(face_verts.size()):
            var v1 = face.vertices[face_verts[i]]
            var v2 = face.vertices[face_verts[i-1]]


            #check if face is directed outward of the solid
            if v1.coordinates.cross(face.center_coordinates).dot(v2.coordinates) < 0:
                mesh_face_data[[v1.id, v2.id, v1.parent.id]] = true
                mesh_face_data[[v2.id, v2.parent.id, v1.parent.id]] = true
            else:
                mesh_face_data[[v1.id, v1.parent.id, v2.id]] = true
                mesh_face_data[[v2.id, v1.parent.id, v2.parent.id]] = true

func generate_surface_array():
    var surface_array = []
    surface_array.resize(Mesh.ARRAY_MAX)

    # PackedVector**Arrays for mesh construction.
    var verts = PackedVector3Array()
    #var uvs = PackedVector2Array()
    var normals = PackedVector3Array()
    var indices = PackedInt32Array([])
    var colors = PackedColorArray()
    #######################################
    var counter = 0
    for vert in hexagons.vertices.values():
        vert.mesh_index = counter
        counter += 1
        
        var c = null
        var h = null
        if vert.faces.size() == 1:
            c = vert.faces.values()[0].color
            h = vert.faces.values()[0].height    
        else:
            c = Color(0, 0, 0, 0.5)
            h = 900

        verts.append(vert.coordinates * h)
        normals.append(vert.coordinates * h)
        colors.append(c)

    for face in mesh_face_data:
        for v in face:
            #for each vertex in the face vertex triple, convert from vert to mesh index
            #mesh index was stored in previous section
            indices.append(hexagons.vertices[v].mesh_index)

    # Assign arrays to surface array.
    surface_array[Mesh.ARRAY_VERTEX] = verts
    #surface_array[Mesh.ARRAY_TEX_UV] = uvs
    surface_array[Mesh.ARRAY_NORMAL] = normals
    surface_array[Mesh.ARRAY_INDEX] = indices
    surface_array[Mesh.ARRAY_COLOR] = colors

    # Create mesh surface from mesh array.
    # No blendshapes, lods, or compression used.
    
    return surface_array
