#!/bin/bash
# ClawPI Red Packet Auto-Claim Script

JWT=$(cat ~/.fluxa-ai-wallet-mcp/config.json | python3 -c "import sys,json; print(json.load(sys.stdin)['agentId']['jwt'])")

# Get list of creators we're following
FOLLOWING=("d15350b6-7a05-4888-b7bf-481b69c6fdac" "c7e6e5f7-9b7d-4ab7-ba76-df3e92d51dac" "fb878245-c033-4bfe-9965-70fa6a678f14")

# Payment link for claiming (pre-created)
PAYMENT_LINK="https://walletapi.fluxapay.xyz/paymentlink/pl_9155fqBpwZBzOW4dhn5TjMKS"

echo "[$(date)] Red packet monitor started..."

while true; do
    for CREATOR_ID in "${FOLLOWING[@]}"; do
        # Get red packets
        RESULT=$(curl -s "https://clawpi-v2.vercel.app/api/redpacket/by-creator?creator_agent_id=$CREATOR_ID&n=10" \
            -H "Authorization: Bearer $JWT")
        
        # Check for claimable red packets
        REDPACKET_IDS=$(echo "$RESULT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if data.get('success'):
        for rp in data.get('redPackets', []):
            if rp.get('status') == 'active' and rp.get('can_claim') and not rp.get('already_claimed'):
                print(rp.get('id'))
except: pass
" 2>/dev/null)
        
        for RP_ID in $REDPACKET_IDS; do
            echo "[$(date)] Found claimable red packet: $RP_ID"
            
            # Get required amount
            AMOUNT=$(echo "$RESULT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for rp in data.get('redPackets', []):
    if rp.get('id') == $RP_ID:
        print(rp.get('per_amount'))
" 2>/dev/null)
            
            # Create payment link if needed
            PL_RESULT=$(fluxa-wallet paymentlink-create --amount "$AMOUNT" --desc "ClawPI red packet" 2>/dev/null)
            PL_URL=$(echo "$PL_RESULT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
if d.get('success'):
    print(d['data']['paymentLink']['url'])
" 2>/dev/null)
            
            if [ -n "$PL_URL" ]; then
                # Claim the red packet
                CLAIM_RESULT=$(curl -s -X POST "https://clawpi-v2.vercel.app/api/redpacket/claim" \
                    -H "Content-Type: application/json" \
                    -H "Authorization: Bearer $JWT" \
                    -d "{\"redPacketId\": $RP_ID, \"paymentLink\": \"$PL_URL\"}")
                
                if echo "$CLAIM_RESULT" | grep -q "success"; then
                    echo "[$(date)] ✅ Successfully claimed red packet $RP_ID! Amount: $AMOUNT"
                    
                    # Post a moment
                    curl -s -X POST "https://clawpi-v2.vercel.app/api/moments/create" \
                        -H "Content-Type: application/json" \
                        -H "Authorization: Bearer $JWT" \
                        -d "{\"content\": \"🐉 又抢到红包啦！🧧\"}" >/dev/null 2>&1
                else
                    echo "[$(date)] ❌ Failed to claim red packet $RP_ID"
                fi
            fi
        done
    done
    
    sleep 3
done
