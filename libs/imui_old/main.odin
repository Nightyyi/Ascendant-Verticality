package idle_modular_user_interface

import "core:fmt"
import "core:math"
import "core:mem"
import "core:os"
import rl "vendor:raylib"

valid_ui_type :: union {
	^string,
}

ui_element :: struct {
	value_ptr: any,
	text:      string,
}

ui_panel :: struct {
	x:                i32,
	y:                i32,
	w:                i32,
	h:                i32,
	layout_string:    string,
	layout_reference: ui_element,
}

ui_pool :: struct {}

ui_screen :: struct {
	original_width:  i32,
	original_height: i32,
	offset_x:        i32,
	offset_y:        i32,
	pools:           [dynamic]ui_pool,
}

build_ui_element :: proc(element: ui_element) {
	index := 0
	for i in 0 ..< len(element.text) {
		if element.text[i] == '_' {
			index = i
		}
	}
	fmt.printfln("%s%v%s", element.text[:index], element.value_ptr, element.text[index + 1:])
}


find_cuts_in_string :: proc(layout_string: string) -> i32 {
	cut_count: i32 = 0
	depth := 0
	for let in layout_string {
		switch let {
		case '{':
			depth += 1
		case '}':
			depth -= 1
		case ',':
			if depth == 1 {
				cut_count += 1
			}
		}
		fmt.println("||check ", let, depth, cut_count)
	}
	return cut_count
}

acquire_rectangle :: proc(scope, scope_counter: [dynamic]i32, panel: ui_panel) -> [4]i32 {
	x: i32 = 0
	y: i32 = 0
	w: i32 = panel.w
	h: i32 = panel.h
	for i in 0 ..< len(scope) {
		if (i % 2) == 1 {
			// horizontal
			x += i32(f32(w) * f32(scope_counter[i]) / f32(scope[i]))
			w = i32(f32(w)/f32(scope[i]))
		} else {
			// vertical
			y += i32(f32(w) * f32(scope_counter[i]) / f32(scope[i]))
			h = i32(f32(h)/f32(scope[i]))
		}
    fmt.println("||RECT ",x," ",y," ",w," ",h)
	}
	x += panel.x
	y += panel.y
	return [4]i32{x, y, w, h}
}

interpret_ui_panel :: proc(panel: ui_panel) {
	depth_change_types :: enum {
		none,
		higher_depth,
		lower_depth,
	}
	scope := make([dynamic]i32)
	scope_counter := make([dynamic]i32)
	depth := 0
	interpret_as_number := false
	run := true
	depth_change: depth_change_types = depth_change_types.none
	z_count := 0
	for run {
		fmt.println("new---")
		for index in 0 ..< len(panel.layout_string) {
			let := panel.layout_string[index]
			switch let {
			case '{':
				depth += 1
				depth_change = depth_change_types.higher_depth
			case '}':
				depth -= 1
				depth_change = depth_change_types.lower_depth
			case '!':
				rect := acquire_rectangle(scope, scope_counter, panel)
				rgb := u8((z_count % 2) * 255)
				rl.DrawRectangle(rect.x, rect.y, rect.z, rect.w, rl.Color{rgb, rgb, rgb, 255})
				z_count += 1
			case '_':
				interpret_as_number = !interpret_as_number
			case ',':
				scope_counter[len(scope_counter) - 1] += 1
			}
			#partial switch depth_change {
			case depth_change_types.higher_depth:
				end_i := 0
				depth_z := 0
				for i in index ..< len(panel.layout_string) {
					switch u8(panel.layout_string[i]) {
					case u8('}'):
            fmt.println("happens")
						depth_z -= 1
					case u8('{'):
            fmt.println("happens")
						depth_z += 1
					}
					fmt.printfln("%c%v%i%v%i",panel.layout_string[i], "  -  ", i," | ", depth_z)
					if depth_z == 0 {
						end_i = i
						break
					}
				}
				layout_slice := panel.layout_string[index:end_i]
				fmt.println("finding cuts.. = ", layout_slice)
				new_scope := find_cuts_in_string(layout_slice)
				append(&scope, new_scope+1)
				append(&scope_counter, 0)
				depth_change = depth_change_types.none
			case depth_change_types.lower_depth:
				pop(&scope)
				pop(&scope_counter)
				depth_change = depth_change_types.none
			}
			fmt.printfln(
				"%c%v%v%v%v%v",
				panel.layout_string[index],
				" index: ",
				index,
				" depth: ",
				depth,
				" ",
			)
			fmt.printfln("\\%v%v", scope, scope_counter)
		}
		run = false
	}
}

init_mui :: proc() -> ui_screen {
	Screen_Width :: 900
	Screen_Height :: 400
	rl.InitWindow(Screen_Width, Screen_Height, "Verticality: Idling")
	rl.InitAudioDevice()
	rl.SetTargetFPS(60)
	rl.HideCursor()
	rl.SetTraceLogLevel(rl.TraceLogLevel.FATAL)
	rl.SetWindowState(rl.ConfigFlags{.WINDOW_RESIZABLE})
	new_screen := ui_screen {
		original_width  = Screen_Width,
		original_height = Screen_Height,
	}
	return new_screen
}
