
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
    Receive // 1
}

enum MSG {
	bwin,
	cwin,
	msg,
	sig,
	blose,
	close,
	busy,
	free
}



enum ACTOR {
    Alice, // 0
    Bob, // 1
    Charlie, // 2
    Dana // 3
}



struct Event {
    ACTOR initiator;
    ACTION action;
    ACTOR target;
	MSG msg;
}


library States {
    uint8 internal constant COUNT = 19;

    function get(uint i) internal pure returns (STATE) {
		require(i < COUNT);
        return STATE(i);
    }


	function set_remove(STATE[] storage states, STATE state) public  {
		
			for (uint256 i = 0; i < states.length; i++) {
				if (states[i] == state) {
					states[i] = states[states.length - 1];
					states.pop();
				}
			}
				
	}

	function set_remove(STATE[] storage states, STATE[] memory to_remove) public  {
		
			for (uint256 i = 0; i < to_remove.length; i++) {
				set_remove(states, to_remove[i]);
			}
				
	}




	function set_find(STATE[] memory states, STATE state) public pure returns(int256) {
		
			for (uint256 i = 0; i < states.length; i++) {
				if (states[i] == state) {
					return int256(i);
				}
			}
		
			return -1;
				
	}


	function set_of(STATE a) public pure returns(STATE[] memory)  {
		
			STATE[] memory temp = new STATE[](1);
			temp[0] = a;
			return temp;
				
	}


	function set_of(STATE a, STATE b) public pure returns(STATE[] memory) {
		
			STATE[] memory temp = new STATE[](2);
			temp[0] = a;
			temp[1] = b;
			return temp;
				
	}


	function set_join(STATE[] memory a, STATE[] memory b) public pure returns(STATE[] memory) {
		
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
}



// function alt_pack(Alt memory a) returns (uint256) {
// 	return alt_pack(a.first, a.second);

// }

library Incomp {

	struct Rel {
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

	function add(Rel storage pr, STATE s1, STATE s2) public {
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

	function remove(Rel storage pr, STATE s) public {
		for (uint idx=0; idx<States.COUNT; idx++) {
			STATE t = States.get(idx);
			uint256 key = alt_pack(s, t);
			delete pr.pairs[key];
		}
	}

	function update(Rel storage pr, STATE s, STATE[] memory new_alt) public {
		
		for (uint i=0; i<States.COUNT; i++) {
			STATE t = States.get(i);

			// check whether pair (s,t) or (t,s) are in the incomp relation
			uint key = alt_pack(s, t);

			if (pr.pairs[key]) {
				// replace (s,t) or (t,s) with (a,t) for any a in new_alt
				delete pr.pairs[key];

				for (uint j=0; j<new_alt.length; j++) {	
					STATE a = new_alt[j];
					uint new_key = alt_pack(a, t);
					pr.pairs[new_key] = true;
				}
			}
		}
		
	}

	function alt_to(Rel  storage pr, STATE s) public view returns (STATE[] memory) {
		return pr.to_prune[s];
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
	    
// 	        int found = States.set_find(pr.to_prune[pr.keys[idx]], source);
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

function apply_pass(STATE[] storage states, Incomp.Rel storage pr, STATE lhs, /* Event memory ev, */ STATE rhs) returns (bool) {
	require(lhs != rhs);

	int256 pos = States.set_find(states, lhs); 
	if (pos >= 0) { 
	
		states[uint256(pos)] = rhs;
		STATE[] memory to_prune = Incomp.alt_to(pr, lhs);
		States.set_remove(states, to_prune);
	
		// // remove all the alternatives from the prune relation
		// STATE[] memory to_prune = pr.to_prune[lhs];	        
		// for (uint idx=0; idx<to_prune.length; idx++) {
		// 	pr_remove(pr, to_prune[idx]);
		// 	States.set_remove(states, to_prune[idx]);
		// }
		// remove also the source state from the prune relation
		
		//pr_remove(pr, lhs);
		Incomp.update(pr, lhs, States.set_of(rhs));
		
		return true;
	} 

	return false;
	        
}



function apply_merge(STATE[] storage states, Incomp.Rel storage pr, STATE lhs1, STATE lhs2, STATE rhs) returns (bool) {
	require(lhs1 != rhs);
	require(lhs2 != rhs);

    if (apply_passthrough(states, pr, lhs1, rhs)) {
        return true;
    } else if (apply_passthrough(states, pr, lhs2, rhs)) {
        return true;
    } 

	return false;

}

function apply_fork(STATE[] storage states, Incomp.Rel storage pr, STATE lhs, STATE rhs1, STATE rhs2) returns (bool)  {
	require(lhs != rhs1);
	require(lhs != rhs2);

	int256 pos_lhs = States.set_find(states, lhs);

	if (pos_lhs >= 0) {

		STATE source = states[uint256(pos_lhs)];
		states[uint256(pos_lhs)] = rhs1;
		states.push(rhs2);

		// pr_update(pr, source, States.set_of(rhs1, rhs2));
		Incomp.update(pr, source, States.set_of(rhs1, rhs2));
		return true;
	} 

	return false;
	        
}


function apply_join(STATE[] storage states, Incomp.Rel storage pr, STATE lhs1, STATE lhs2, STATE rhs) returns (bool)  {
	require(lhs1 != rhs);
	require(lhs2 != rhs);

	int256 pos1 = States.set_find(states, lhs1); 
	
	if (pos1 >= 0) { 
		int256 pos2 = States.set_find(states, lhs2); 
		if (pos2 >= 0) { 
			
			states[uint256(pos1)] = rhs;
			states[uint256(pos2)] = states[states.length - 1];
			states.pop();
			//pr_update(pr, lhs1, States.set_of(rhs));
			Incomp.update(pr, lhs1, States.set_of(rhs));
			// pr_update(pr, lhs2, States.set_of(rhs));
			Incomp.update(pr, lhs2, States.set_of(rhs));
			return true;
		} 
		
	}

	return false;

	        
}


function apply_choice(STATE[] storage states, Incomp.Rel storage pr, STATE lhs, STATE rhs1, STATE rhs2) returns (bool) {
	require(lhs != rhs1);
	require(lhs != rhs2);


	int256 pos = States.set_find(states, lhs);
	
	if (pos >= 0) {
		// STATE[] memory to_prune = pr.to_prune[source];
	
		states[uint256(pos)] = rhs1;
		states.push(rhs2);
	
		// pr_update(pr, source, States.set_of(rhs1, rhs2));
	
		//pr_add(pr, rhs1, States.set_union(to_prune, States.set_of(rhs2)));
		Incomp.add(pr, rhs1, rhs2);
		// pr_add(pr, rhs2, States.set_union(to_prune, States.set_of(rhs1)));
		Incomp.update(pr, lhs, States.set_of(rhs1, rhs2));

		return true;
	} 

	return false;
	        
}


function apply_passthrough(STATE[] storage states, Incomp.Rel storage pr, STATE lhs, STATE rhs)  returns (bool) {
	require(lhs != rhs);
	
	int256 pos = States.set_find(states, lhs); 
	if (pos >= 0) {
		STATE source = states[uint256(pos)];
		states[uint256(pos)] = rhs;
		// if (source != rhs) { /* pr_update(pr, source, States.set_of(rhs)); */ }

		Incomp.update(pr, lhs, States.set_of(rhs));
		return true;
	} 
		
	return false;
            
}


function apply_end(STATE[] storage states, Incomp.Rel storage pr, uint256 lhs)  {
	
	    STATE source = states[lhs];
	    states[lhs] = states[states.length - 1];
	    states.pop();
	
		// pr_remove(pr, source);
		Incomp.remove(pr, source);
	        
}


function apply_send_receive(STATE[] storage states, Incomp.Rel storage pr, uint256 lhs, STATE rhs)  {
	
	    STATE source = states[lhs];
	
	    states[lhs] = rhs;
	
		// remove all the alternatives from the prune relation
		STATE[] memory to_prune = pr.to_prune[source];	        
		for (uint idx=0; idx<to_prune.length; idx++) {
			// pr_remove(pr, to_prune[idx]);
			States.set_remove(states, to_prune[idx]);
		}
		// remove also the source state from the prune relation
		// pr_remove(pr, source);

	        
}


function action_to_string(ACTION a) pure returns (string memory) {
	if (a == ACTION.Send) { return '!'; } else if (a == ACTION.Receive) { return '?'; }
}


function participant_to_string(ACTOR p) pure returns (string memory) {
	if (p == ACTOR.Charlie) { return 'Charlie'; } else if (p == ACTOR.Dana) { return 'Dana'; } else if (p == ACTOR.Bob) { return 'Bob'; } else if (p == ACTOR.Alice) { return 'Alice'; } else return '??';
}

function ev_equal(Event calldata task, ACTION action, ACTOR initiator, ACTOR target, MSG _msg) pure returns (bool) {
	return task.action == action && task.initiator == initiator && task.target == target && task.msg == _msg;
}


function task_to_string(Event memory t) pure returns (string memory) {
	
	            string memory initiator = participant_to_string(t.initiator);
	            string memory action = action_to_string(t.action);
	            string memory target = participant_to_string(t.target);
	
	            return string(abi.encodePacked(initiator, action, target));
	
	        
}


function task_arr_to_string(Event[] memory ar) pure returns (string[] memory) {
	
	    string[] memory result = new string[](ar.length);
	    for (uint idx=0; idx<ar.length; idx++) {
	        Event memory t = ar[idx];
	        
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
	Incomp.Rel pr;
	Event[] input;
	Event[] output;
	Event[] buffer;

	constructor() {
		states.push(STATE.x0);
		check_no_input();
	}
	
	
	function check_no_input() public {

		
		bool dirty = false;
		
		do {
		    dirty = false;
		        
		
		    // merge : x0 + x18 = x1 
			if (apply_merge(states, pr, STATE.x0, STATE.x18, STATE.x1)) { dirty = true; }		    
		
		    // fork: x1 = x2 | x3 
		    if (apply_fork(states, pr, STATE.x1, STATE.x2, STATE.x3)) { dirty = true; }
		
		    // internal/external choice: x2 = x4 & x7 
		    if (apply_choice(states, pr, STATE.x2, STATE.x4, STATE.x7)) {  dirty = true; } 
		
		    // merge : x8 + x9 = x10 
			if (apply_merge(states, pr, STATE.x8, STATE.x9, STATE.x10)) { dirty = true; }
		
		    // fork: x10 = x14 | x12 
		    if (apply_fork(states, pr, STATE.x10, STATE.x14, STATE.x12)) { dirty = true; }
		
		    // join: x12 | x13 = x15 
			if (apply_join(states, pr, STATE.x12, STATE.x13, STATE.x15)) { dirty = true; }
		
		    // join: x14 | x16 = x18 
			if (apply_join(states, pr, STATE.x14, STATE.x16, STATE.x18)) { dirty = true; }
		} while (dirty); 
	}
	
	
	function check_task(Event calldata ev) public {
		
		
		input.push(ev);
		
		// Receive : x4 = Charlie?cwin(int)<-Alice; x6 
		if (ev_equal(ev, ACTION.Receive, ACTOR.Charlie, ACTOR.Bob, MSG.cwin) && apply_pass(states, pr, STATE.x4, /* task, */ STATE.x6)) { output.push(ev); check_no_input(); return; } 
		
		// Send : x6 = Charlie!blose(int)->Bob; x8 
		if (ev_equal(ev, ACTION.Send, ACTOR.Charlie, ACTOR.Bob, MSG.blose) && apply_pass(states, pr, STATE.x6, /* task, */ STATE.x8)) { output.push(ev); check_no_input(); return; 		} 
		
		// Receive : x7 = Charlie?close(int)<-x8 Bob; x9 
		if (ev_equal(ev, ACTION.Receive, ACTOR.Charlie, ACTOR.Bob, MSG.close) && apply_pass(states, pr, STATE.x7, /* task, */ STATE.x9)) { output.push(ev); check_no_input(); return; }
		
		// Send : x3 = Charlie!busy(int)->Dana; task, x13 
		if (ev_equal(ev, ACTION.Send, ACTOR.Charlie, ACTOR.Dana, MSG.busy) && apply_pass(states, pr, STATE.x3, /* task, */ STATE.x13)) { output.push(ev); check_no_input(); return; } 
		
		// Send : x15 = Charlie!msg(int)->task, Alice; x16 
		if (ev_equal(ev, ACTION.Send, ACTOR.Charlie, ACTOR.Alice, MSG.msg) && apply_pass(states, pr, STATE.x15, /* task, */ STATE.x16)) { output.push(ev); check_no_input(); return; }
		
		// otherwise, add to task, buffer
		
		buffer.push(ev);
	}
	
	
	function getStates() public view returns(STATE[] memory) {
		return states;
	}
	
	
	function getInput() public view returns(Event[] memory) {
		return input;
	}
	
	
	function getOutput() public view returns(Event[] memory) {
		return output;
	}
	
	
	function getBuffer() public view returns(Event[] memory) {
		return buffer;
	}
	
	
	// function getIncompKeys() public view returns(STATE[] memory) {
	// 	return pr.keys;
	// }
	
	
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
	Incomp.Rel pr;
	Event[] input;
	Event[] output;
	Event[] buffer;

	constructor() {
		states.push(STATE.x0);
		check_no_input();
	}
	
	
	function check_no_input() public {
		bool dirty = false;
		
		do {
		    dirty = false;
		        
		
		    // merge : x0 + x18 = x1 
		    if (apply_merge(states, pr, STATE.x0, STATE.x18, STATE.x1)) { dirty = true; }

		    // fork: x1 = x2 | x3 
		    if (apply_fork(states, pr, STATE.x1, STATE.x2, STATE.x3)) { dirty = true; }
		
		    // internal/external choice: x2 = x8 & x9 
		    if (apply_choice(states, pr, STATE.x2, STATE.x8, STATE.x9)) { dirty = true; } 
		
		    // merge : x8 + x9 = x10 
		    if (apply_merge(states, pr, STATE.x8, STATE.x9, STATE.x10)) { dirty = true; }
		
		    // fork: x10 = x14 | x12 
		    if (apply_fork(states, pr, STATE.x10, STATE.x14, STATE.x12)) { dirty = true; }
		
		    // join: x12 | x13 = x16 
			if (apply_join(states, pr, STATE.x12, STATE.x13, STATE.x16)) { dirty = true; }
		
		    // join: x14 | x16 = x17 
			if (apply_join(states, pr, STATE.x14, STATE.x16, STATE.x17)) { dirty = true; }
		} while (dirty); 
	}
	
	
	function check_task(Event calldata ev) public {
				
		input.push(ev);
		
		        
		
		// Receive : x3 = Dana?busy(int)<-Charlie; x13 
		if (ev_equal(ev, ACTION.Receive, ACTOR.Dana, ACTOR.Charlie, MSG.busy) && apply_pass(states, pr, STATE.x3, /* task, */ STATE.x13)) { output.push(ev); check_no_input(); return; } 

		// Receive : x17 = Dana?free(int)<-Alice; x18 
		if (ev_equal(ev, ACTION.Receive, ACTOR.Dana, ACTOR.Alice, MSG.free) && apply_pass(states, pr, STATE.x17, /* task, */ STATE.x18)) { output.push(ev); check_no_input(); return; } 
		
		// otherwise, add to buffer
		
		buffer.push(ev);
	}
	
	
	
	function getStates() public view returns(STATE[] memory) {
		return states;
	}
	
	
	function getInput() public view returns(Event[] memory) {
		return input;
	}
	
	
	function getOutput() public view returns(Event[] memory) {
		return output;
	}
	
	
	function getBuffer() public view returns(Event[] memory) {
		return buffer;
	}
	
	
	// function getIncompKeys() public view returns(STATE[] memory) {
	// 	return pr.keys;
	// }
	
	
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
	Incomp.Rel pr;
	Event[] input;
	Event[] output;
	Event[] buffer;

	constructor() {
		states.push(STATE.x0);
		check_no_input();
	}
	
	

	function check_no_input() public {

		
		bool dirty = false;
		
		do {
		    dirty = false;
		        
		
		    // merge : x0 + x18 = x1 
			if (apply_merge(states, pr, STATE.x0, STATE.x18, STATE.x1)) { dirty = true; }

		    // fork: x1 = x2 | x13 
		    if (apply_fork(states, pr, STATE.x1, STATE.x2, STATE.x13)) { dirty = true; }
		
		    // internal/external choice: x2 = x6 & x5 
		    if (apply_choice(states, pr, STATE.x2, STATE.x6, STATE.x5)) { dirty = true; } 
		
		    // merge : x8 + x9 = x10 
			if (apply_merge(states, pr, STATE.x8, STATE.x9, STATE.x10)) { dirty = true; }

		    // fork: x10 = x11 | x12 
            if (apply_fork(states, pr, STATE.x10, STATE.x11, STATE.x12)) { dirty = true; }
		
		    // join: x12 | x13 = x16 
			if (apply_join(states, pr, STATE.x12, STATE.x13, STATE.x16)) { dirty = true; }
		
		    // join: x14 | x16 = x18 
			if (apply_join(states, pr, STATE.x14, STATE.x16, STATE.x18)) { dirty = true; }
		} while (dirty); 
	}
	
	
	function check_task(Event calldata ev) public {
		
		input.push(ev);
		
		// Receive : x5 = Bob?bwin(int)<-Alice; x7 
		if (ev_equal(ev, ACTION.Receive, ACTOR.Bob, ACTOR.Alice, MSG.bwin) && apply_pass(states, pr, STATE.x5, /* task, */ STATE.x7)) { output.push(ev); check_no_input(); return; } 
		
		// Receive : x6 = Bob?blose(int)<-Charlie; x8 
		if (ev_equal(ev, ACTION.Receive, ACTOR.Bob, ACTOR.Charlie, MSG.blose) && apply_pass(states, pr, STATE.x6, /* task, */ STATE.x8)) { output.push(ev); check_no_input(); return; } 

		// Send : x7 = Bob!close(int)->Charlie; x9 
		if (ev_equal(ev, ACTION.Send, ACTOR.Bob, ACTOR.Charlie, MSG.close) && apply_pass(states, pr, STATE.x7, /* task, */ STATE.x9)) { output.push(ev); check_no_input(); return; } 
		
		// Send : x11 = Bob!sig(int)->Alice; x14 
		if (ev_equal(ev, ACTION.Send, ACTOR.Bob, ACTOR.Alice, MSG.sig) && apply_pass(states, pr, STATE.x11, /* task, */ STATE.x14)) { output.push(ev); check_no_input(); return; } 
		
		// otherwise, add to buffer
		
		buffer.push(ev);
	}
	
	
	function getStates() public view returns(STATE[] memory) {
		return states;
	}
	
	
	function getInput() public view returns(Event[] memory) {
		return input;
	}
	
	
	function getOutput() public view returns(Event[] memory) {
		return output;
	}
	
	
	function getBuffer() public view returns(Event[] memory) {
		return buffer;
	}
	
	
	// function getIncompKeys() public view returns(STATE[] memory) {
	// 	return pr.keys;
	// }
	
	
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
	Incomp.Rel pr;
	Event[] input;
	Event[] output;
	Event[] buffer;

	constructor() {
		states.push(STATE.x0);
		check_no_input();
	}
	
	
	function check_no_input() public {
		
		bool dirty = false;
		
		do {
		    dirty = false;
		        
		
		    // merge : x0 + x18 = x1 
			if (apply_merge(states, pr, STATE.x0, STATE.x18, STATE.x1)) { dirty = true; }

		    // fork: x1 = x2 | x13 
		    if (apply_fork(states, pr, STATE.x1, STATE.x2, STATE.x13)) { dirty = true; }
		
		    // internal/external choice: x2 = x4 (+) x5 
		    if (apply_choice(states, pr, STATE.x2, STATE.x4, STATE.x5)) { dirty = true; } 
		
		    // merge : x8 + x9 = x10 
			if (apply_merge(states, pr, STATE.x8, STATE.x9, STATE.x10)) { dirty = true; }

		    // fork: x10 = x11 | x12 
		    if (apply_fork(states, pr, STATE.x10, STATE.x11, STATE.x12)) { dirty = true; }
		
		    // join: x12 | x13 = x15 
			if (apply_join(states, pr, STATE.x12, STATE.x13, STATE.x15)) { dirty = true; }		

		    // join: x14 | x16 = x17 
			if (apply_join(states, pr, STATE.x14, STATE.x16, STATE.x17)) { dirty = true; }
		} while (dirty); 
	}
	
	
	function check_task(Event calldata ev) public {
		
		input.push(ev);
		
		        
		
		// Send : x4 = Alice!cwin(int)->Charlie; x8 
		if (ev_equal(ev, ACTION.Send, ACTOR.Alice, ACTOR.Charlie, MSG.cwin) && apply_pass(states, pr, STATE.x4, /* task, */ STATE.x8)) { output.push(ev); check_no_input(); return; } 

		// Send : x5 = Alice!bwin(int)->Bob; x9 
		if (ev_equal(ev, ACTION.Send, ACTOR.Alice, ACTOR.Bob, MSG.bwin) && apply_pass(states, pr, STATE.x5, /* task, */ STATE.x9)) { output.push(ev); check_no_input(); return; } 
		
		// Receive : x11 = Alice?sig(int)<-Bob; x14 
		if (ev_equal(ev, ACTION.Receive, ACTOR.Alice, ACTOR.Bob, MSG.sig) && apply_pass(states, pr, STATE.x11, /* task, */ STATE.x14)) { output.push(ev); check_no_input(); return; } 

		// Receive : x15 = Alice?msg(int)<-Charlie; x16 
		if (ev_equal(ev, ACTION.Receive, ACTOR.Alice, ACTOR.Charlie, MSG.msg) && apply_pass(states, pr, STATE.x15, /* task, */ STATE.x16)) { output.push(ev); check_no_input(); return; } 

		// Send : x17 = Alice!free(int)->Dana; x18 
		if (ev_equal(ev, ACTION.Send, ACTOR.Alice, ACTOR.Dana, MSG.free) && apply_pass(states, pr, STATE.x17, /* task, */ STATE.x18)) { output.push(ev); check_no_input(); return; } 
		
		
		// otherwise, add to buffer
		
		buffer.push(ev);
	}
	
	
	function getStates() public view returns(STATE[] memory) {
		return states;
	}
	
	
	function getInput() public view returns(Event[] memory) {
		return input;
	}
	
	
	function getOutput() public view returns(Event[] memory) {
		return output;
	}
	
	
	function getBuffer() public view returns(Event[] memory) {
		return buffer;
	}
	
	
	// function getIncompKeys() public view returns(STATE[] memory) {
	// 	return pr.keys;
	// }
	
	
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

