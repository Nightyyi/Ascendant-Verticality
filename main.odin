package nhidle

import "core:fmt"
import "core:math"
import "core:mem"
import "core:os"
import imui "libs/imui"
import rl "vendor:raylib"

machines :: enum {
	none,
	crafting_table,
}

item :: struct {
	id:   i32,
	name: string,
}

global_items :: [dynamic]item

recipe :: struct {
	box:     [9]i32,
	machine: machines,
}

push_item :: proc(global_i: ^global_items, i_item: item) {
	append_elem(global_i, i_item)
}

print_recipe :: proc(i_recipe: recipe, global_i: global_items) {
	for y in 0 ..< 3 {
		for x in 0 ..< 3 {
			fmt.print(global_i[i_recipe.box[y * 3 + x]].name, "|")
		}
		fmt.print("\n")
	}
	fmt.print("machine: ", i_recipe.machine)

}

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}


	iron := item{0, "iron"}
	gold := item{1, "gold"}

	value := "boubou"
	text := "hello _ your cool"
	ui_elem := imui.ui_element {
		value_ptr = value,
		text      = text,
	}
	value = "xeno"
	imui.build_ui_element(ui_elem)

	GLOBAL_items := global_items{}
	push_item(&GLOBAL_items, iron)
	push_item(&GLOBAL_items, gold)
	recipe_z := recipe {
		box     = [9]i32{0, 0, 0, 1, 1, 1, 0, 0, 0},
		machine = machines.none,
	}
	// print_recipe(recipe_z, GLOBAL_items)
	screen := imui.init_mui()
	test := imui.ui_panel {
		x             = 10,
		y             = 10,
		w             = 200,
		h             = 200,
    layout_string = "{{{!,!,!},!,!}}",
	}
	RUNNING := true
	for RUNNING {
		rl.BeginDrawing()
		rl.ClearBackground(rl.Color{49, 36, 58, 255})
		
    rl.EndDrawing()
	}
}
