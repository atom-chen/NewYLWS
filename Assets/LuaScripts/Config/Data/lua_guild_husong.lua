local config = {
[1] = {
id = 1,
name = "普通",
num = 10000,
need_time = 1,
award = {{10012,20,},{10001,20000,},},
exposed_count = 1,
hardLevel = 1,
search_weight = 1,
},
[2] = {
id = 2,
name = "困难",
num = 60000,
need_time = 2,
award = {{10012,30,},{10001,30000,},},
exposed_count = 2,
hardLevel = 2,
search_weight = 3,
},
[3] = {
id = 3,
name = "极难",
num = 120000,
need_time = 3,
award = {{10012,50,},{10001,50000,},},
exposed_count = 3,
hardLevel = 3,
search_weight = 6,
},
}
return config