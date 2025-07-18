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

ui_config :: struct {
	padding: bool,
	fit:     bool,
	grow:    bool,
}

ui_panel :: struct {
	x:          i32,
	y:          i32,
	x_relative: i32,
	y_relative: i32,
	w:          i32,
	h:          i32,
	config:     ui_config,
	element:    ui_element,
	children:   [dynamic]i32,
	parent:     i32,
	depth:      u8,
}

ui_pool :: struct {
	panels: [dynamic]ui_panel,
}

ui_screen :: struct {
	original_width:  i32,
	original_height: i32,
	offset_x:        i32,
	offset_y:        i32,
	pool:            ui_pool,
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

ui_layout_build :: proc(screen: ui_screen) {
	pool := screen.pool
	for panel in pool.panels {
		for children_panels_index in panel.children {
			children_panels := pool.panels[children_panels_index]
			children_panels.x = children_panels.x_relative + panel.x
			children_panels.y = children_panels.y_relative + panel.y
		}
	}
}

link_ui_panel :: proc(panel: ui_panel, screen: ^ui_screen){
  append(&screen.pool.panels, panel)
}

render_ui_screen :: proc(screen: ui_screen) {
	pool := screen.pool
	deepest_depth: u8 = 0
	for panel in pool.panels {
		for children_panels in panel.children {
			children_panel := pool.panels[children_panels]
			children_panel.depth = panel.depth + 1
			if children_panel.depth > deepest_depth {
				deepest_depth = children_panel.depth
			}
		}
	}
	z := 0
	for depth in 0 ..< deepest_depth {
		for panel in pool.panels {
			if panel.depth == depth {
				rgb := u8((z % 10) * 25)
				col := rl.Color{rgb, rgb, rgb, 255}
				rl.DrawRectangle(panel.x, panel.y, panel.w, panel.h, col)
				z += 1
			}
		}
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
