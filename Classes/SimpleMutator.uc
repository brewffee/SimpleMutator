class SimpleMutator extends Mutator;

var bool bHasSpawned;

function PreBeginPlay() {
    Super.PreBeginPlay();
    bHasSpawned = false;
}

// Sends a message to the player when the match starts
function ModifyPlayer(Pawn Other) {
    Super.ModifyPlayer(Other);
    if (Other.bIsPlayer) {
        if (!bHasSpawned) {
            bHasSpawned = true;
            BroadcastMessage("Good luck!", true, 'CriticalEvent');
        }
    }
}

defaultproperties {
    // Instead of initializing here, we need the game to assign its value
    // before play starts (level load) While this renders the defaultproperties
    // block effectively useless, it's still nice to have here as reference
    bHasSpawned;
}
