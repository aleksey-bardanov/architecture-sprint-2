#!/bin/bash

echo "Всего документов в базе данных: "
docker compose exec -T mongos_router mongosh --port 27020 --quiet << 'EOF'
use somedb;
db.helloDoc.countDocuments(); 
EOF
echo ""

echo "Шард №1 содержит: "
docker compose exec -T shard10 mongosh --port 27100 --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
EOF
echo ""

echo "Шард №2 содержит: "
docker compose exec -T shard20 mongosh --port 27200 --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
EOF
echo ""
