function open_menu()
  print("enter menu")
  gamestate = gamestates.menu
end

function draw_menu()
  draw_menubox(menu_options)
end

function quit_menu()
  gamestate = gamestates.maingame
  print("quit menu")
end

function draw_menubox(menu_options)
  menu = menu or " "
  local colour = { 255, 155, 50, 255 }
  local menu_w = 8 * 16
  draw_box(camera.width - menu_w, 0, menu_w, camera.height, colour)

  for i = 1, #menu_options do
    draw_text(menu_options[i], camera.width - menu_w + 12, (i - 1) * 10 + 2)
  end
end