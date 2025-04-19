#!/bin/bash

docker compose exec -T configSrv mongosh --port 27017 << 'EOF'
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
exit();
EOF


docker compose exec -T shard10 mongosh --port 27100 << 'EOF'
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard10:27100" },
        { _id : 1, host : "shard11:27101" },
        { _id : 2, host : "shard12:27102" },
      ]
    }
);
exit();
EOF

docker compose exec -T shard20 mongosh --port 27200 << 'EOF'
rs.initiate(
    {
      _id : "shard2",
      members: [
        { _id : 0, host : "shard20:27200" },
        { _id : 1, host : "shard21:27201" },
        { _id : 2, host : "shard22:27202" },
      ]
    }
  );
exit();
EOF

docker compose exec -T mongos_router mongosh --port 27020 << 'EOF'
sh.addShard( "shard1/shard10:27100");
sh.addShard( "shard2/shard20:27200");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )

use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i}); 
exit();
EOF 