extends Object
class_name Utility


static func push_back_dict_array(dict, key, array_value):
        if key not in dict:
            dict[key] = []
        dict[key].push_back(array_value)

static func push_front_dict_array(dict, key, array_value):
        if key not in dict:
            dict[key] = []
        dict[key].push_front(array_value)
