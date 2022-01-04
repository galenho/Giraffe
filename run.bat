cd db_server
start "db_server" ..\crossoverD.exe

cd ..
cd log_server
start "log_server" ..\crossoverD.exe

cd ..
cd world_server
start "world_server" ..\crossoverD.exe

cd ..
cd map_server
start "map_server" ..\crossoverD.exe

cd ..
cd connect_server_mgr
start "connect_server_mgr" ..\crossoverD.exe

cd ..
cd connect_server
start "connect_server" ..\crossoverD.exe

cd ..
cd login_server
start "login_server" ..\crossoverD.exe

echo -------start finish----------------
