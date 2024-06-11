//Plot tracking data from a results table zeroed
//The required format is as generated by the Manual Tracking plugin 
//http://rsbweb.nih.gov/ij/plugins/track/track.html
//assuming Results table column headings: Track > Slice > X > Y


//Plot the graph
Plot.create("Scatter Plot", "X", "Y");
//You may want to determine your own limits in some way here
Plot.setLimits(-150, 150, -150, 150);

//get the track numbers in an array to use as the index
track_number = list_no_repeats ("Results", "Track");

//get number of tracks (Track)
Track = track_number.length;

//Work though the data a track at a time

for (i=0; i<track_number.length; i++){
//get the x, y values in an array
	values_x = newArray();
	values_y = newArray();
	
	euc_x = newArray(0);
	euc_y = newArray(0);
	
	for (j=0; j<nResults; j++) {

		if (getResultString("Track", j) == toString(track_number[i])){
			frames = Array.concat(frames, getResult("Frame", j));
			positions = Array.concat(positions, j);
			x_val = getResult("X", j);
			values_x = Array.concat(values_x, x_val);
			y_val = getResult("Y", j);
			values_y = Array.concat(values_y, y_val);
			}
		}

	//get first x and y value
	x_0 = values_x[0];
	y_0 = values_y[0];
	

	for (k=0; k<values_x.length; k++) {
		addToArray((values_x[k]-x_0), values_x, k);	
		addToArray((values_y[k]-y_0), values_y, k);	
	}
	
	x_0 = values_x[0];
	y_0 = values_y[0];
	x_max = values_x[values_x.length-1];
	y_max = values_y[values_y.length-1];
	euc_x = Array.concat(euc_x, x_0);
	euc_y = Array.concat(euc_y, y_0);
	euc_x = Array.concat(euc_x, x_max);
	euc_y = Array.concat(euc_y, y_max);
	
	//Plot each track       
        Plot.setColor("red");
        Plot.add("crosses", euc_x, euc_y);
        Plot.setColor("darkGray");
        Plot.add("lines", euc_x, euc_y);
		
	}

function list_no_repeats (table, heading) {
//Returns an array of the entries in a column without repeats to use as an index

//Check whether the table exists
	if (isOpen(table)) {

//get the entries in the column without repeats
		no_repeats = newArray(getResultString(heading, 0));

		for (i=0; i<nResults; i++) {
			occurence = getResultString(heading, i);
			for (j=0; j<no_repeats.length; j++) {
				if (occurence != no_repeats[j]) {
					flag = 0;
				} else {
						flag = 1;
					}
				}
			
			if (flag == 0) {
				occurence = getResultString(heading, i);
				no_repeats = Array.concat(no_repeats, occurence);	
			}
		}
	} else {
		Dialog.createNonBlocking("Error");
		Dialog.addMessage("No table with the title "+table+" found.");
		Dialog.show();
	}
	return no_repeats;
}

function addToArray(value, array, position) {
//allows one to update existing values in an array
//adds the value to the array at the specified position, expanding if necessary - returns the modified array
//From Richard Wheeler - http://www.richardwheeler.net/contentpages/text.php?gallery=ImageJ_Macros&file=Array_Tools&type=ijm
    
    if (position < lengthOf(array)) {
        array[position]=value;
    } else {
        temparray = newArray(position+1);
        for (i=0; i<lengthOf(array); i++) {
            temparray[i]=array[i];
        }
        temparray[position]=value;
        array=temparray;
    }
    return array;
}
