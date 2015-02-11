## ALE
## ===

const ROM_DIR = "/home/zenna/Downloads/ale/ale_0_4/roms/"
space_invaders = "space_invaders"
run_cmd(game) = `ale -display_screen true -game_controller fifo $(joinpath(ROM_DIR, game)).bin`

function playgame(game)
  (so,si,pr) = readandwrite(run_cmd(game))
  # handshake
  screen = readline(so)
  @show screen
  rand(100000)
  handshake = println(si, "1,1,1,1")
  while true
    data = readline(so)
    @show data
    cmd = rand(DiscreteUniform(2,18))
    action = println(si, "3,18,1,1")
  end
end
