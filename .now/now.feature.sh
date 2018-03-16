#!/bin/bash
set -e

CLEAN_BRANCH_NAME=${CIRCLE_BRANCH//\//-};

JSON=$(cat <<EOF
{
    "name": "$CIRCLE_PROJECT_REPONAME-$CLEAN_BRANCH_NAME",
    "type": "npm",
    "forwardNpm": true,
    "dotenv": ".env.feature",
    "alias": [
        "$CLEAN_BRANCH_NAME.example.com"
    ]
}
EOF)

echo $JSON > .now/now.feature.json