cd db_server
start "db_server" ..\crossover.exe

cd ..
cd log_server
start "log_server" ..\crossover.exe

cd ..
cd world_server
start "world_server" ..\crossover.exe

cd ..
cd map_server
start "map_server" ..\crossover.exe

cd ..
cd connect_server_mgr
start "connect_server_mgr" ..\crossover.exe

cd ..
cd connect_server
start "connect_server" ..\crossover.exe

cd ..
cd login_server
start "login_server" ..\crossover.exe

echo -------start finish----------------
