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

//record the length and angle of each track
euc_angles = newArray();
euc_lengths = newArray();
weighted_angles = newArray();

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
	
	//get the strat and end of tracks for euclidean data	
	x_0 = values_x[0];
	y_0 = values_y[0];
	x_max = values_x[values_x.length-1];
	y_max = values_y[values_y.length-1];
	euc_x = Array.concat(euc_x, x_0);
	euc_y = Array.concat(euc_y, y_0);
	euc_x = Array.concat(euc_x, x_max);
	euc_y = Array.concat(euc_y, y_max);
	
	//record the track angle and length
	euc_ang = getAngle(x_0, y_0, x_max, y_max);
	euc_angles = Array.concat(euc_angles, euc_ang);
	euc_len = values_x.length;
	euc_lengths = Array.concat(euc_lengths, euc_len);
	
	//Plot each track       
        Plot.setColor("gray");
        Plot.add("dots", values_x, values_y);
        Plot.setColor("gray");
        Plot.add("lines", values_x, values_y);
        
    //Plot each euclidean track       
        Plot.setColor("red");
        Plot.add("crosses", euc_x, euc_y);
        Plot.setColor("red");
        Plot.add("lines", euc_x, euc_y);
	}
	
Plot.show();
	
//loop through the angles and lengths and weight the angles by length
for (i=0; i<euc_angles.length; i++) {
	w_ang = euc_angles[i];
	w_len = euc_lengths[i];
	for (j=0; j<w_len; j++) {
		weighted_angles = Array.concat(weighted_angles,w_ang);
	}
}

//Plot the weighted histogram
Plot.create("Histogram " + "of Weighted Angles", "Angle", "Freq");
Plot.setColor("blue", "#ddddff"); 
Plot.addHistogram(weighted_angles, 36, 18);
Plot.show();

//Print the data to the log
print("Angles");
Array.print(euc_angles);
print("Lengths");
Array.print(euc_lengths);
print("Weighted Angles");
Array.print(weighted_angles);

//////////////////////////////////////////////////////////////////////Functions///////////////////////////////////////////////////////////////////

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

 // Returns the angle in degrees between the specified line and the horizontal axis.
  function getAngle(x1, y1, x2, y2) {
      q1=0; q2orq3=2; q4=3; //quadrant
      dx = x2-x1;
      dy = y1-y2;
      if (dx!=0)
          angle = atan(dy/dx);
      else {
          if (dy>=0)
              angle = PI/2;
          else
              angle = -PI/2;
      }
      angle = (180/PI)*angle;
      if (dx>=0 && dy>=0)
           quadrant = q1;
      else if (dx<0)
          quadrant = q2orq3;
      else
          quadrant = q4;
      if (quadrant==q2orq3)
          angle = angle+180.0;
      else if (quadrant==q4)
          angle = angle+360.0;
      return angle;
  }
