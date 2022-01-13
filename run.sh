cd world_server
tmux new-session -s crossover -n world_server -d '../crossoverD'

cd ../login_server
tmux new-window -n login_server -d '../crossoverD'

cd ../connect_server_mgr
tmux new-window -n connect_server_mgr -d '../crossoverD'

cd ../connect_server
tmux new-window -n connect_server -d '../crossoverD'

cd ../map_server
tmux new-window -n map_server -d '../crossoverD'

cd ../db_server
tmux new-window -n db_server -d '../crossoverD'

cd ../log_server
tmux new-window -n log_server -d '../crossoverD'

echo -------start finish----------------
