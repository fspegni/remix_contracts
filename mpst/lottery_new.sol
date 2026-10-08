
// SPDX-Licence-Identiier: CC-BY-NC-4.0	

pragma solidity >= 0.7.6;
pragma abicoder v2;


enum STATE {
    x0, // 0, 
    x1, // 1, 
    x10, // 2, 
    x11, // 3, 
    x12, // 4, 
    x13, // 5, 
    x14, // 6, 
    x15, // 7, 
    x16, // 8, 
    x17, // 9, 
    x18, // 10, 
    x2, // 11, 
    x3, // 12, 
    x4, // 13, 
    x5, // 14, 
    x6, // 15, 
    x7, // 16, 
    x8, // 17, 
    x9 // 18
}


enum ACTION {
    Send, // 0
    Receive, // 1
    WtSend, // 2
    WtReceive // 3
}


enum ACTOR {
    Alice, // 0
    Bob, // 1
    Charlie, // 2
    Dana // 3
}



struct Task {
    ACTOR initiator;
    ACTION action;
    ACTOR target;
}

// struct Alt {
// 	STATE first;
// 	STATE second;
// }


library States {
    uint8 internal constant COUNT = 19;

    function get(uint i) internal pure returns (STATE) {
		require(i < COUNT);
        return STATE(i);
    }
}

function states_arr_remove(STATE[] storage states, STATE state)  {
	
		for (uint256 i = 0; i < states.length; i++) {
			if (states[i] == state) {
				states[i] = states[states.length - 1];
				states.pop();
			}
		}
	        
}


function states_arr_find(STATE[] memory states, STATE state) pure returns(int256) {
	
	    for (uint256 i = 0; i < states.length; i++) {
	        if (states[i] == state) {
	            return int256(i);
	        }
	    }
	
	    return -1;
	        
}


function states_arr_of(STATE a) pure returns(STATE[] memory) {
	
	    STATE[] memory temp = new STATE[](1);
		temp[0] = a;
		return temp;
	        
}


function states_arr_of(STATE a, STATE b) pure returns(STATE[] memory) {
	
	    STATE[] memory temp = new STATE[](2);
		temp[0] = a;
		temp[1] = b;
		return temp;
	        
}


function states_arr_join(STATE[] memory a, STATE[] memory b) pure returns(STATE[] memory) {
	
		STATE[] memory temp = new STATE[](a.length + b.length);
		uint idx=0;
		for (idx=0; idx<a.length; idx++) {
			temp[idx] = a[idx];
		}
		for (uint jdx=0; jdx<b.length; jdx++) {
			temp[jdx+idx] = b[jdx];
		}
		return temp;
	        
}

// function alt_pack(Alt memory a) returns (uint256) {
// 	return alt_pack(a.first, a.second);

// }

library Incomp {

	struct IRel {
		// STATE[] keys;
		mapping(STATE => STATE[]) to_prune;
		// Alt[] pairs;
		mapping(uint256 => bool) pairs;
		
		// mapping (STATE => mapping(STATE => bool)) alternatives;
	}

	function alt_pack(STATE s1, STATE s2) public returns (uint256) {
		require(s1 < s2);
		return (uint256(s1) << 128) | uint256(s2);	
	}

	function add(IRel storage pr, STATE s1, STATE s2) public {
		require(s1 != s2);

		if (s2 > s1) {
			// swap
			STATE tmp = s1;
			s1 = s2;
			s2 = tmp;
		}

		// condition: s1 < s2
		uint256 key = alt_pack(s1, s2);

		if (pr.pairs[key]) {
			// already exists
			return;
		}

		pr.pairs[key] = true;
		pr.to_prune[s1].push(s2);
		pr.to_prune[s2].push(s1);
	}

	function remove(IRel storage pr, STATE s) public {
		for (uint idx=0; idx<States.COUNT; idx++) {
			STATE t = States.get(idx);
			uint256 key = alt_pack(s, t);
			delete pr.pairs[key];
		}
	}

	function update(IRel storage pr, STATE s, STATE[] memory new_alt) public {
		
		for (uint i=0; i<States.COUNT; i++) {
			STATE t = States.get(i);

			// check whether pair (s,t) or (t,s) are in the incomp relation
			uint key = alt_pack(s, t);

			if (pr.pairs[key]) {
				// replace (s,t) or (t,s) with (a,t) for any a in new_alt
				delete pr.pairs[key];

				for (uint j=0; j<new_alt.length; j++) {	
					STATE a = new_alt[j];
					uint new_key = alt_pack(s,a);
					pr.pairs[new_key] = true;
				}
			}
		}
		
	}

}

// function pr_add(Incomp storage pr, STATE source, STATE[] memory to_prune)  {
	
// 		// check1 : the state should not exist in the mapping
// 		require(pr.to_prune[source].length == 0); 
	
// 		// check 2 : the state should not exist in the keys
// 		for (uint idx=0; idx<pr.keys.length; idx++) {
// 			if (pr.keys[idx] == source) {
// 				revert("Unexpected error: state should not be in prune relation");
// 			}
// 		}
	
// 		pr.keys.push(source);
	
// 		pr.to_prune[source] = to_prune;
	        
// }


// function pr_remove(Incomp storage pr, STATE source)  {
	
// 		for (uint idx=0; idx<pr.keys.length; idx++) {
// 			STATE source1 = pr.keys[idx];
	
// 			if (source1 == source) {
// 				// remove source's alternative states
// 				pr.keys[idx] = pr.keys[pr.keys.length-1];
// 				pr.keys.pop();
	
// 				delete pr.to_prune[source];
// 			} else {
				
// 				// source1 != source => remove source from source1's alternative states (if present)
// 				for (uint jdx=0; jdx<pr.to_prune[source1].length; jdx++) {
// 					if (pr.to_prune[source1][jdx] == source) {
// 						pr.to_prune[source1][jdx] = pr.to_prune[source1][ pr.to_prune[source1].length - 1];
// 						pr.to_prune[source1].pop();
// 					}
// 				}
// 			}
// 		}
	        
// }


// function pr_update(Incomp storage pr, STATE source, STATE[] memory targets)  {
	
// 	    require(targets.length > 0, "Empty targets");
	
// 	    for (uint idx=0; idx<pr.keys.length; idx++) {
	    
// 	        int found = states_arr_find(pr.to_prune[pr.keys[idx]], source);
// 	        if (found >= 0) {
// 	            STATE[] storage old_targets = pr.to_prune[pr.keys[idx]];
// 	            old_targets[uint(found)] = targets[0];
	
// 	            for (uint j=1; j<targets.length; j++) {
// 	                old_targets.push(targets[j]);
// 	            }
// 	            pr.to_prune[source] = old_targets;
	
// 	            break;        
// 	        }
// 	    }
	        
// }

function apply_merge(STATE[] storage states, Incomp.IRel storage pr, STATE lhs1, STATE lhs2, STATE rhs) returns (bool) {
    
    if (apply_pass(states, pr, lhs1, rhs)) {
        return true;
    } else if (apply_pass(states, pr, lhs2, rhs)) {
        return true;
    } else {
        return false;
    }


}

function apply_fork(STATE[] storage states, Incomp.IRel storage pr, STATE lhs, STATE rhs1, STATE rhs2) returns (bool)  {
	
        int256 pos_lhs = states_arr_find(states, lhs);

        if (pos_lhs >= 0) {

	        STATE source = states[uint256(pos_lhs)];
	        states[uint256(pos_lhs)] = rhs1;
	        states.push(rhs2);
	        // pr_update(pr, source, states_arr_of(rhs1, rhs2));
			Incomp.update(pr, source, states_arr_of(rhs1, rhs2));
            return true;
        } else {
            return false;
        }
	        
}


function apply_join(STATE[] storage states, Incomp.IRel storage pr, uint256 lhs1, uint256 lhs2, STATE rhs)  {
	
	    STATE source1 = states[lhs1];
	    STATE source2 = states[lhs2];
	    states[lhs1] = rhs;
	    states[lhs2] = states[states.length - 1];
	    states.pop();
	    // pr_update(pr, source1, states_arr_of(rhs));
	    // pr_update(pr, source2, states_arr_of(rhs));
	        
}


function apply_choice(STATE[] storage states, Incomp.IRel storage pr, uint256 lhs, STATE rhs1, STATE rhs2)  {
	
	
		STATE source = states[lhs];
		// STATE[] memory to_prune = pr.to_prune[source];
	
		states[lhs] = rhs1;
		states.push(rhs2);
	
		// pr_update(pr, source, states_arr_of(rhs1, rhs2));
	
		//pr_add(pr, rhs1, states_arr_join(to_prune, states_arr_of(rhs2)));
		Incomp.add(pr, rhs1, rhs2);
		// pr_add(pr, rhs2, states_arr_join(to_prune, states_arr_of(rhs1)));
	        
}


function apply_pass(STATE[] storage states, Incomp.IRel storage pr, STATE lhs, STATE rhs)  returns (bool) {
	
        int256 pos = states_arr_find(states, lhs); 
        if (pos >= 0) {
            STATE source = states[uint256(pos)];
            states[uint256(pos)] = rhs;
            if (source != rhs) { /* pr_update(pr, source, states_arr_of(rhs)); */ }
            return true;
        } else {
            return false;
        }
	        
}


function apply_end(STATE[] storage states, Incomp.IRel storage pr, uint256 lhs)  {
	
	    STATE source = states[lhs];
	    states[lhs] = states[states.length - 1];
	    states.pop();
	
		// pr_remove(pr, source);
		Incomp.remove(pr, source);
	        
}


function apply_send_receive(STATE[] storage states, Incomp.IRel storage pr, uint256 lhs, STATE rhs)  {
	
	    STATE source = states[lhs];
	
	    states[lhs] = rhs;
	
		// remove all the alternatives from the prune relation
		STATE[] memory to_prune = pr.to_prune[source];	        
		for (uint idx=0; idx<to_prune.length; idx++) {
			// pr_remove(pr, to_prune[idx]);
			states_arr_remove(states, to_prune[idx]);
		}
		// remove also the source state from the prune relation
		// pr_remove(pr, source);

	        
}


function action_to_string(ACTION a) pure returns (string memory) {
	if (a == ACTION.Send) { return '!'; } else if (a == ACTION.Receive) { return '?'; } else if (a == ACTION.WtSend) { return '!*'; } else if (a == ACTION.WtReceive) { return '?*'; } else return '??';
}


function participant_to_string(ACTOR p) pure returns (string memory) {
	if (p == ACTOR.Charlie) { return 'Charlie'; } else if (p == ACTOR.Dana) { return 'Dana'; } else if (p == ACTOR.Bob) { return 'Bob'; } else if (p == ACTOR.Alice) { return 'Alice'; } else return '??';
}


function task_to_string(Task memory t) pure returns (string memory) {
	
	            string memory initiator = participant_to_string(t.initiator);
	            string memory action = action_to_string(t.action);
	            string memory target = participant_to_string(t.target);
	
	            return string(abi.encodePacked(initiator, action, target));
	
	        
}


function task_arr_to_string(Task[] memory ar) pure returns (string[] memory) {
	
	    string[] memory result = new string[](ar.length);
	    for (uint idx=0; idx<ar.length; idx++) {
	        Task memory t = ar[idx];
	        
	        //if (idx > 0) {
	        //    result = string(abi.encodePacked(result, ", "));
	        //}
	
	        //result = string(abi.encodePacked(result, task_to_string(t)));
	        result[idx] = task_to_string(t);
	    }
	
	    return result;
	        
}





contract Charlie {
	


	STATE[] states;
	Incomp.IRel pr;
	Task[] input;
	Task[] output;
	Task[] buffer;

	constructor() {
		states.push(STATE.x0);
		check_no_input();
	}
	
	

	function check_no_input() public {
		// TODO refactor
		// int256 pos1;
		// int256 pos2;
		
		bool dirty = false;
		
		do {
		    dirty = false;
		        
		
		    // merge : x0 + x18 = x1 
		    if(apply_merge(states, pr, STATE.x0, STATE.x18, STATE.x1)) { dirty = true; } 
		
		    // fork: x1 = x2 | x3 
		    if (apply_fork(states, pr, STATE.x1, STATE.x2, STATE.x3)) { dirty = true; }
		
		    // internal/external choice: x2 = x4 & x7 
		    // pos1 = states_arr_find(states, STATE.x2); if (pos1 >= 0) { apply_choice(states, pr, uint256(pos1), STATE.x4, STATE.x7); dirty = true; } 
		
		    // merge : x8 + x9 = x10 
		    if (apply_merge(states, pr, STATE.x8, STATE.x9, STATE.x10)) { dirty = true; } 
		
		    // fork: x10 = x14 | x12 
		    if (apply_fork(states, pr, STATE.x10, STATE.x14, STATE.x12)) { dirty = true; }
		
		    // join: x12 | x13 = x15 
		    // pos1 = states_arr_find(states, STATE.x12); if (pos1 >= 0) { pos2 = states_arr_find(states, STATE.x13); if (pos2 >= 0) { apply_join(states, pr, uint256(pos1), uint256(pos2), STATE.x15); dirty = true; } }
		
		    // join: x14 | x16 = x18 
		    // pos1 = states_arr_find(states, STATE.x14); if (pos1 >= 0) { pos2 = states_arr_find(states, STATE.x16); if (pos2 >= 0) { apply_join(states, pr, uint256(pos1), uint256(pos2), STATE.x18); dirty = true; } }
		} while (dirty); 
	}
	
	
	function check_task(Task calldata task) public {
		
		int256 pos;
		
		input.push(task);
		
		        
		
		// Receive : x4 = Charlie?cwin(int)<-Alice; x6 
		pos = states_arr_find(states, STATE.x4); if (pos >= 0) { if (task.action == ACTION.Receive && task.initiator == ACTOR.Charlie && task.target == ACTOR.Alice) { apply_send_receive(states, pr, uint256(pos), STATE.x6); output.push(task); check_no_input(); return; } else if (task.action == ACTION.WtReceive && task.initiator == ACTOR.Charlie && task.target == ACTOR.Alice) { apply_pass(states, pr, uint256(pos), STATE.x4); output.push(task); check_no_input(); return; } } 
		
		// Send : x6 = Charlie!blose(int)->Bob; x8 
		pos = states_arr_find(states, STATE.x6); if (pos >= 0) { if (task.action == ACTION.Send && task.initiator == ACTOR.Charlie && task.target == ACTOR.Bob) { apply_send_receive(states, pr, uint256(pos), STATE.x8); output.push(task); check_no_input(); return; } else if (task.action == ACTION.WtSend && task.initiator == ACTOR.Charlie && task.target == ACTOR.Bob) { apply_pass(states, pr, uint256(pos), STATE.x6); output.push(task); check_no_input(); return; } } 
		
		// Receive : x7 = Charlie?close(int)<-Bob; x9 
		pos = states_arr_find(states, STATE.x7); if (pos >= 0) { if (task.action == ACTION.Receive && task.initiator == ACTOR.Charlie && task.target == ACTOR.Bob) { apply_send_receive(states, pr, uint256(pos), STATE.x9); output.push(task); check_no_input(); return; } else if (task.action == ACTION.WtReceive && task.initiator == ACTOR.Charlie && task.target == ACTOR.Bob) { apply_pass(states, pr, uint256(pos), STATE.x7); output.push(task); check_no_input(); return; } } 
		
		// Send : x3 = Charlie!busy(int)->Dana; x13 
		pos = states_arr_find(states, STATE.x3); if (pos >= 0) { if (task.action == ACTION.Send && task.initiator == ACTOR.Charlie && task.target == ACTOR.Dana) { apply_send_receive(states, pr, uint256(pos), STATE.x13); output.push(task); check_no_input(); return; } else if (task.action == ACTION.WtSend && task.initiator == ACTOR.Charlie && task.target == ACTOR.Dana) { apply_pass(states, pr, uint256(pos), STATE.x3); output.push(task); check_no_input(); return; } } 
		
		// Send : x15 = Charlie!msg(int)->Alice; x16 
		pos = states_arr_find(states, STATE.x15); if (pos >= 0) { if (task.action == ACTION.Send && task.initiator == ACTOR.Charlie && task.target == ACTOR.Alice) { apply_send_receive(states, pr, uint256(pos), STATE.x16); output.push(task); check_no_input(); return; } else if (task.action == ACTION.WtSend && task.initiator == ACTOR.Charlie && task.target == ACTOR.Alice) { apply_pass(states, pr, uint256(pos), STATE.x15); output.push(task); check_no_input(); return; } } 
		
		check_no_input();
		
		// otherwise, add to buffer
		
		buffer.push(task);
	}
	
	
	function getStates() public view returns(STATE[] memory) {
		return states;
	}
	
	
	function getInput() public view returns(Task[] memory) {
		return input;
	}
	
	
	function getOutput() public view returns(Task[] memory) {
		return output;
	}
	
	
	function getBuffer() public view returns(Task[] memory) {
		return buffer;
	}
	
	
	function getIncompKeys() public view returns(STATE[] memory) {
		return pr.keys;
	}
	
	
	function getIncomp(STATE s) public view returns(STATE[] memory) {
		return pr.to_prune[s];
	}
	
	
	function getInputAsString() public view returns(string[] memory) {
		return task_arr_to_string(input);
	}
	
	
	function getOutputAsString() public view returns(string[] memory) {
		return task_arr_to_string(output);
	}
	
	
	function getBufferAsString() public view returns(string[] memory) {
		return task_arr_to_string(buffer);
	}
	
	
}  


contract Dana {
	

	





	STATE[] states;
	Incomp.IRel pr;
	Task[] input;
	Task[] output;
	Task[] buffer;

	constructor() {
		states.push(STATE.x0);
		check_no_input();
	}
	
	

	function check_no_input() public {
		// TODO refactor
		// int256 pos1;
		// int256 pos2;
		
		bool dirty = false;
		
		do {
		    dirty = false;
		        
		
		    // merge : x0 + x18 = x1 
		    if (apply_merge(states, pr, STATE.x0, STATE.x18, STATE.x1)) { dirty = true; }
		
		    // fork: x1 = x2 | x3 
		    if (apply_fork(states, pr, STATE.x1, STATE.x2, STATE.x3)) { dirty = true; }
		
		    // internal/external choice: x2 = x8 & x9 
		    // pos1 = states_arr_find(states, STATE.x2); if (pos1 >= 0) { apply_choice(states, pr, uint256(pos1), STATE.x8, STATE.x9); dirty = true; } 
		
		    // merge : x8 + x9 = x10 
		    if (apply_merge(states, pr, STATE.x8, STATE.x9, STATE.x10)) { dirty = true; }
		
		    // fork: x10 = x14 | x12 
		    if (apply_fork(states, pr, STATE.x10, STATE.x14, STATE.x12)) { dirty = true; }
		
		    // join: x12 | x13 = x16 
		    // pos1 = states_arr_find(states, STATE.x12); if (pos1 >= 0) { pos2 = states_arr_find(states, STATE.x13); if (pos2 >= 0) { apply_join(states, pr, uint256(pos1), uint256(pos2), STATE.x16); dirty = true; } }
		
		    // join: x14 | x16 = x17 
		    // pos1 = states_arr_find(states, STATE.x14); if (pos1 >= 0) { pos2 = states_arr_find(states, STATE.x16); if (pos2 >= 0) { apply_join(states, pr, uint256(pos1), uint256(pos2), STATE.x17); dirty = true; } }
		} while (dirty); 
	}
	
	
	function check_task(Task calldata task) public {
		
		int256 pos;
		
		input.push(task);
		
		        
		
		// Receive : x3 = Dana?busy(int)<-Charlie; x13 
		pos = states_arr_find(states, STATE.x3); if (pos >= 0) { if (task.action == ACTION.Receive && task.initiator == ACTOR.Dana && task.target == ACTOR.Charlie) { apply_send_receive(states, pr, uint256(pos), STATE.x13); output.push(task); check_no_input(); return; } else if (task.action == ACTION.WtReceive && task.initiator == ACTOR.Dana && task.target == ACTOR.Charlie) { apply_pass(states, pr, uint256(pos), STATE.x3); output.push(task); check_no_input(); return; } } 
		
		// Receive : x17 = Dana?free(int)<-Alice; x18 
		pos = states_arr_find(states, STATE.x17); if (pos >= 0) { if (task.action == ACTION.Receive && task.initiator == ACTOR.Dana && task.target == ACTOR.Alice) { apply_send_receive(states, pr, uint256(pos), STATE.x18); output.push(task); check_no_input(); return; } else if (task.action == ACTION.WtReceive && task.initiator == ACTOR.Dana && task.target == ACTOR.Alice) { apply_pass(states, pr, uint256(pos), STATE.x17); output.push(task); check_no_input(); return; } } 
		
		check_no_input();
		
		// otherwise, add to buffer
		
		buffer.push(task);
	}
	
	
	function getStates() public view returns(STATE[] memory) {
		return states;
	}
	
	
	function getInput() public view returns(Task[] memory) {
		return input;
	}
	
	
	function getOutput() public view returns(Task[] memory) {
		return output;
	}
	
	
	function getBuffer() public view returns(Task[] memory) {
		return buffer;
	}
	
	
	function getIncompKeys() public view returns(STATE[] memory) {
		return pr.keys;
	}
	
	
	function getIncomp(STATE s) public view returns(STATE[] memory) {
		return pr.to_prune[s];
	}
	
	
	function getInputAsString() public view returns(string[] memory) {
		return task_arr_to_string(input);
	}
	
	
	function getOutputAsString() public view returns(string[] memory) {
		return task_arr_to_string(output);
	}
	
	
	function getBufferAsString() public view returns(string[] memory) {
		return task_arr_to_string(buffer);
	}
	
	
}  


contract Bob {
	

	





	STATE[] states;
	Incomp.IRel pr;
	Task[] input;
	Task[] output;
	Task[] buffer;

	constructor() {
		states.push(STATE.x0);
		check_no_input();
	}
	
	

	function check_no_input() public {
		// TODO refactor
		// int256 pos1;
		// int256 pos2;
		
		bool dirty = false;
		
		do {
		    dirty = false;
		        
		
		    // merge : x0 + x18 = x1 
		    if (apply_pass(states, pr, STATE.x0, STATE.x18, STATE.x1)) { dirty = true; }
		
		    // fork: x1 = x2 | x13 
		    if (apply_fork(states, pr, STATE.x1, STATE.x2, STATE.x13)) { dirty = true; }
		
		    // internal/external choice: x2 = x6 & x5 
		    // pos1 = states_arr_find(states, STATE.x2); if (pos1 >= 0) { apply_choice(states, pr, uint256(pos1), STATE.x6, STATE.x5); dirty = true; } 
		
		    // merge : x8 + x9 = x10 
		    if (apply_merge(states, pr, STATE.x8, STATE.x9, STATE.x10)) { dirty = true; } 
		
		    // fork: x10 = x11 | x12 
            if (apply_fork(states, pr, STATE.x10, STATE.x11, STATE.x12)) { dirty = true; }
		
		    // join: x12 | x13 = x16 
		    // pos1 = states_arr_find(states, STATE.x12); if (pos1 >= 0) { pos2 = states_arr_find(states, STATE.x13); if (pos2 >= 0) { apply_join(states, pr, uint256(pos1), uint256(pos2), STATE.x16); dirty = true; } }
		
		    // join: x14 | x16 = x18 
		    // pos1 = states_arr_find(states, STATE.x14); if (pos1 >= 0) { pos2 = states_arr_find(states, STATE.x16); if (pos2 >= 0) { apply_join(states, pr, uint256(pos1), uint256(pos2), STATE.x18); dirty = true; } }
		} while (dirty); 
	}
	
	
	function check_task(Task calldata task) public {
		
		int256 pos;
		
		input.push(task);
		
		        
		
		// Receive : x5 = Bob?bwin(int)<-Alice; x7 
		pos = states_arr_find(states, STATE.x5); if (pos >= 0) { if (task.action == ACTION.Receive && task.initiator == ACTOR.Bob && task.target == ACTOR.Alice) { apply_send_receive(states, pr, uint256(pos), STATE.x7); output.push(task); check_no_input(); return; } else if (task.action == ACTION.WtReceive && task.initiator == ACTOR.Bob && task.target == ACTOR.Alice) { apply_pass(states, pr, uint256(pos), STATE.x5); output.push(task); check_no_input(); return; } } 
		
		// Receive : x6 = Bob?blose(int)<-Charlie; x8 
		pos = states_arr_find(states, STATE.x6); if (pos >= 0) { if (task.action == ACTION.Receive && task.initiator == ACTOR.Bob && task.target == ACTOR.Charlie) { apply_send_receive(states, pr, uint256(pos), STATE.x8); output.push(task); check_no_input(); return; } else if (task.action == ACTION.WtReceive && task.initiator == ACTOR.Bob && task.target == ACTOR.Charlie) { apply_pass(states, pr, uint256(pos), STATE.x6); output.push(task); check_no_input(); return; } } 
		
		// Send : x7 = Bob!close(int)->Charlie; x9 
		pos = states_arr_find(states, STATE.x7); if (pos >= 0) { if (task.action == ACTION.Send && task.initiator == ACTOR.Bob && task.target == ACTOR.Charlie) { apply_send_receive(states, pr, uint256(pos), STATE.x9); output.push(task); check_no_input(); return; } else if (task.action == ACTION.WtSend && task.initiator == ACTOR.Bob && task.target == ACTOR.Charlie) { apply_pass(states, pr, uint256(pos), STATE.x7); output.push(task); check_no_input(); return; } } 
		
		// Send : x11 = Bob!sig(int)->Alice; x14 
		pos = states_arr_find(states, STATE.x11); if (pos >= 0) { if (task.action == ACTION.Send && task.initiator == ACTOR.Bob && task.target == ACTOR.Alice) { apply_send_receive(states, pr, uint256(pos), STATE.x14); output.push(task); check_no_input(); return; } else if (task.action == ACTION.WtSend && task.initiator == ACTOR.Bob && task.target == ACTOR.Alice) { apply_pass(states, pr, uint256(pos), STATE.x11); output.push(task); check_no_input(); return; } } 
		
		check_no_input();
		
		// otherwise, add to buffer
		
		buffer.push(task);
	}
	
	
	function getStates() public view returns(STATE[] memory) {
		return states;
	}
	
	
	function getInput() public view returns(Task[] memory) {
		return input;
	}
	
	
	function getOutput() public view returns(Task[] memory) {
		return output;
	}
	
	
	function getBuffer() public view returns(Task[] memory) {
		return buffer;
	}
	
	
	function getIncompKeys() public view returns(STATE[] memory) {
		return pr.keys;
	}
	
	
	function getIncomp(STATE s) public view returns(STATE[] memory) {
		return pr.to_prune[s];
	}
	
	
	function getInputAsString() public view returns(string[] memory) {
		return task_arr_to_string(input);
	}
	
	
	function getOutputAsString() public view returns(string[] memory) {
		return task_arr_to_string(output);
	}
	
	
	function getBufferAsString() public view returns(string[] memory) {
		return task_arr_to_string(buffer);
	}
	
	
}  


contract Alice {
	

	





	STATE[] states;
	Incomp.IRel pr;
	Task[] input;
	Task[] output;
	Task[] buffer;

	constructor() {
		states.push(STATE.x0);
		check_no_input();
	}
	
	

	function check_no_input() public {
		
        // TODO remove pos1, pos2
		// int256 pos1;
		// int256 pos2;
		
		bool dirty = false;
		
		do {
		    dirty = false;
		        
		
		    // merge : x0 + x18 = x1 
		    if (apply_merge(states, pr, STATE.x0, STATE.x1)) { dirty = true; }
		
		    // fork: x1 = x2 | x13 
		    if (apply_fork(states, pr, STATE.x1, STATE.x2, STATE.x13)) { dirty = true; }
		
		    // internal/external choice: x2 = x4 (+) x5 
		    // pos1 = states_arr_find(states, STATE.x2); if (pos1 >= 0) { apply_choice(states, pr, uint256(pos1), STATE.x4, STATE.x5); dirty = true; } 
		
		    // merge : x8 + x9 = x10 
		    // pos1 = states_arr_find(states, STATE.x8); if (pos1 >= 0) { apply_pass(states, pr, uint256(pos1), STATE.x10); dirty = true; } else { pos2 = states_arr_find(states, STATE.x9); if (pos2 >= 0) { apply_pass(states, pr, uint256(pos2), STATE.x10); dirty = true; } }
		
		    // fork: x10 = x11 | x12 
		    if (apply_fork(states, pr, STATE.x10, STATE.x11, STATE.x12)) { dirty = true; }
		
		    // join: x12 | x13 = x15 
		    // pos1 = states_arr_find(states, STATE.x12); if (pos1 >= 0) { pos2 = states_arr_find(states, STATE.x13); if (pos2 >= 0) { apply_join(states, pr, uint256(pos1), uint256(pos2), STATE.x15); dirty = true; } }
		
		    // join: x14 | x16 = x17 
		    // pos1 = states_arr_find(states, STATE.x14); if (pos1 >= 0) { pos2 = states_arr_find(states, STATE.x16); if (pos2 >= 0) { apply_join(states, pr, uint256(pos1), uint256(pos2), STATE.x17); dirty = true; } }
		} while (dirty); 
	}
	
	
	function check_task(Task calldata task) public {
		
		int256 pos;
		
		input.push(task);
		
		        
		
		// Send : x4 = Alice!cwin(int)->Charlie; x8 
		pos = states_arr_find(states, STATE.x4); if (pos >= 0) { if (task.action == ACTION.Send && task.initiator == ACTOR.Alice && task.target == ACTOR.Charlie) { apply_send_receive(states, pr, uint256(pos), STATE.x8); output.push(task); check_no_input(); return; } else if (task.action == ACTION.WtSend && task.initiator == ACTOR.Alice && task.target == ACTOR.Charlie) { apply_pass(states, pr, uint256(pos), STATE.x4); output.push(task); check_no_input(); return; } } 
		
		// Send : x5 = Alice!bwin(int)->Bob; x9 
		pos = states_arr_find(states, STATE.x5); if (pos >= 0) { if (task.action == ACTION.Send && task.initiator == ACTOR.Alice && task.target == ACTOR.Bob) { apply_send_receive(states, pr, uint256(pos), STATE.x9); output.push(task); check_no_input(); return; } else if (task.action == ACTION.WtSend && task.initiator == ACTOR.Alice && task.target == ACTOR.Bob) { apply_pass(states, pr, uint256(pos), STATE.x5); output.push(task); check_no_input(); return; } } 
		
		// Receive : x11 = Alice?sig(int)<-Bob; x14 
		pos = states_arr_find(states, STATE.x11); if (pos >= 0) { if (task.action == ACTION.Receive && task.initiator == ACTOR.Alice && task.target == ACTOR.Bob) { apply_send_receive(states, pr, uint256(pos), STATE.x14); output.push(task); check_no_input(); return; } else if (task.action == ACTION.WtReceive && task.initiator == ACTOR.Alice && task.target == ACTOR.Bob) { apply_pass(states, pr, uint256(pos), STATE.x11); output.push(task); check_no_input(); return; } } 
		
		// Receive : x15 = Alice?msg(int)<-Charlie; x16 
		pos = states_arr_find(states, STATE.x15); if (pos >= 0) { if (task.action == ACTION.Receive && task.initiator == ACTOR.Alice && task.target == ACTOR.Charlie) { apply_send_receive(states, pr, uint256(pos), STATE.x16); output.push(task); check_no_input(); return; } else if (task.action == ACTION.WtReceive && task.initiator == ACTOR.Alice && task.target == ACTOR.Charlie) { apply_pass(states, pr, uint256(pos), STATE.x15); output.push(task); check_no_input(); return; } } 
		
		// Send : x17 = Alice!free(int)->Dana; x18 
		pos = states_arr_find(states, STATE.x17); if (pos >= 0) { if (task.action == ACTION.Send && task.initiator == ACTOR.Alice && task.target == ACTOR.Dana) { apply_send_receive(states, pr, uint256(pos), STATE.x18); output.push(task); check_no_input(); return; } else if (task.action == ACTION.WtSend && task.initiator == ACTOR.Alice && task.target == ACTOR.Dana) { apply_pass(states, pr, uint256(pos), STATE.x17); output.push(task); check_no_input(); return; } } 
		
		check_no_input();
		
		// otherwise, add to buffer
		
		buffer.push(task);
	}
	
	
	function getStates() public view returns(STATE[] memory) {
		return states;
	}
	
	
	function getInput() public view returns(Task[] memory) {
		return input;
	}
	
	
	function getOutput() public view returns(Task[] memory) {
		return output;
	}
	
	
	function getBuffer() public view returns(Task[] memory) {
		return buffer;
	}
	
	
	function getIncompKeys() public view returns(STATE[] memory) {
		return pr.keys;
	}
	
	
	function getIncomp(STATE s) public view returns(STATE[] memory) {
		return pr.to_prune[s];
	}
	
	
	function getInputAsString() public view returns(string[] memory) {
		return task_arr_to_string(input);
	}
	
	
	function getOutputAsString() public view returns(string[] memory) {
		return task_arr_to_string(output);
	}
	
	
	function getBufferAsString() public view returns(string[] memory) {
		return task_arr_to_string(buffer);
	}
	
	
}  

