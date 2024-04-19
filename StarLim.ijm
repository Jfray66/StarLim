/* " StarLim " v1.0
 * Identify foci per nucleus with images normalisation.
 * 
 * Made on the 08.2023.
 * 
 * Written by Jean-Yves Alejandro Frayssinhes at
 * Centre de Biologie et Recherche en Santé | CBRS François Denis, UMR CNRS 7276
 * Equipe B-NATION | B cell Nuclear ArchiTecture, Ig genes and ONcogenes
 * 2 rue du Pr Bernard Descottes, 87025 Limoges
 * Bureau 109, 1er étage
 * 
 * mail: jean-yves.frayssinhes@cnrs.fr
 */

macro "Convert and/or split Action Tool - C059T3e161" {
	Title = "Convert and/or split";
	Message = "The macro to convert/split channels is about to begin.\nPress OK to continue."
		waitForUser(Title, Message);
	do {

		run("Close All");

	Question = getBoolean("Convert any bioimage folder prior to start?");
if (Question == 1) {

	input = getDirectory("Select images folder that is to convert.");
	file = input + File.separator + "Images - Converted" + File.separator ;
	File.makeDirectory(file);
	output = getDirectory("Find and select the folder: Images - Converted");

		run("Convert...", "input=["+input+"] output=["+output+"] output_format=TIFF interpolation=Bilinear scale=1");

}
	Question2 = getBoolean("Split channel of any converted images folder?");
if (Question2 == 1) {

		run("Close All");

	input2 = getDirectory("Select images folder that is to split.");		// Ask the user to select a folder.
	list2 = getFileList(input2);											// The macro is going to get the list of files (& folders) in it.
	output_dir2 = input2 + File.separator + "Channels" + File.separator ;	// Create a folder to output the images splitted.
		File.makeDirectory(output_dir2);

setBatchMode(true);													// Activate batch mode
	for (i = 0; i < lengthOf(list2); i++) {							// Loop to process the list of files and define the "path".
	current_imagePath = input2+list2[i];							// Concatenation of "input2" and the "i" element of the array list2.
			if (!File.isDirectory(current_imagePath)){				// Check out the current file is not a directory.
		open(current_imagePath);									// If not, image is opened.
		getDimensions(width, height, channels, slices, frames);		// Get some info about image.
			if (channels > 1) {										// If it's a multi channel image, images are to split into the output directory.
		run("Split Channels");
	for (c = 1 ; c <= channels ; c++){									// Loop to process the list of channels of x image to save it into a subfolder.
		selectImage(c);													// Identify and select x channel from x image.
	currentImage_name = getTitle();										// Get the title of x channel.
	channel_subfolder = output_dir2 + File.separator + "Channel "+ c + File.separator;
		File.makeDirectory(channel_subfolder);							// Create a subfolder for x channel.
		saveAs("tif", channel_subfolder + currentImage_name);
}
} else {																						// If any single-channel image, save it directly OR display a message.
		waitForUser("Your attention is required", "Some single-channel images were detected.");	// saveAs("tif", output_dir2 + currentImage_name);
}
		run("Close All");																		// Close all images before opening the next one
}
}
setBatchMode(false);																			// Disable batch mode
		showMessage("If wanted, you can custom the color name of your folders.");
}
	dialog = Dialog.create("Another image folder to convert/split ?");				// The macro is going to ask the user if another image folder is to be split.
	Dialog.addMessage("Do you wish to convert/split images from another folder ?");
		Dialog.addChoice("Choose:", newArray("Yes", "No, I am done"));
		Dialog.show();
	choice = Dialog.getChoice();
	} while (choice == "Yes");														// As long the user says yes, the loop is processed again.
	Title2 = "Convert/split has ended";
	Message2 = "Press OK to Continue";
		showMessage(Title2, Message2);
}

macro "Normalisation" {
	Title = "Normalisation";
	Message = "Normalisation of channel is about to begin.\nPress OK to continue."
		waitForUser(Title, Message);
	do {

		run("Set Measurements...", "mean standard modal min redirect=None decimal=3");

	channel_name = getString("Your channel color is: ", "Blue");
	input = getDirectory("Select the not-normalised "+channel_name+" channel folder.");
	list = getFileList(input);
	output_dir = input + File.separator + "1 - Not-processed "+channel_name+" channels" + File.separator ;
		File.makeDirectory(output_dir);

	for (i = 0; i < lengthOf(list); i++) {
	current_imagePath = input+list[i];
		open(current_imagePath);
		run("Measure");
	currentImage_name = getTitle();
		saveAs("Tiff", output_dir + 1 + i + " "+channel_name+" " + currentImage_name);
}
	sum = 0;
	for (i = 0; i < nResults; i++) {
  	sum = sum + getResult("Mean", i);
}
	average = sum / nResults;
		print("Settings:\nThe first value calculated is the mean intensity of all images.\nAll images are going to be normalised to this value.");
		print("");
		print("Overall mean intensity: "+average);
	div_values = newArray("nResults");
	for (x = 0; x < nResults; x++) {
	div_values[x] = getResult("Mean", x) / average;
		print("Normalisation factor " + list[x] + ": " + div_values[x]);
}
	for (j = 0; j < nImages; j++) {
		selectImage(j+1);
		selectWindow("Log");
		run("Divide...", "value=" + div_values[j]);
		run("Measure");
		run("Fire");
		run("Save");
}
		selectWindow("Results");
		run("Close");
		selectWindow("Log");
		saveAs("Text", output_dir+"Log - "+channel_name);
		print("\\Clear");
		run("Close");
		run("Close All");
	dialog = Dialog.create("Question");
	Dialog.addMessage("Do you wish to normalise others channel?");
		Dialog.addChoice("Choose:", newArray("Yes", "No, I am done"));
		Dialog.show();
	choice = Dialog.getChoice();
	} while (choice == "Yes");
	Title2 = "Norm has ended";
	Message2 = "Press OK to Continue";
		showMessage(Title2, Message2);
}

macro "Background correction (Nuclei/cytoplasm) Action Tool - C059T3e163" {
	Title = "Background correction";
	Message = "Background subtraction of nuclei/cytoplasm channel is about to begin.\nPress OK to continue."
		waitForUser(Title, Message);
	do {

		run("Set Measurements...", "mean standard min redirect=None decimal=3");

	channel_color = getString("Your channel color is: ", "Blue");
	input = getDirectory("Select the not-processed "+channel_color+" channels folder");
	list = getFileList(input);
	output_dir = input + File.separator + "2 - Processed "+channel_color+" channels" + File.separator ;
		File.makeDirectory(output_dir);

	for (i = 0; i < lengthOf(list); i++) {
	current_imagePath = input+list[i];
	if (endsWith(current_imagePath, ".tif")) {
		open(current_imagePath);
} else {
	continue;
}
}
		showMessage("You are going to be asked to select randomly the background.\nThe selection tool is going to be automatically selected.");
	for (j = 0; j < nImages; j++) {
		selectImage(j+1);
		setTool("rectangle");
		waitForUser("Selection", "Select what is not a nucleus/cytoplasm, then press OK");
		run("Measure");
}
	sum = 0;
	for (i = 0; i < nResults; i++) {
  	sum = sum + getResult("Mean", i);
}
	average = sum / nResults;
		print("Settings:");
		print("This value calculated is the background mean intensity: "+average);
		print("That is the value to substract background to your images.");
		selectWindow("Log");
		run("Close All");

	Ball = getNumber("Max diameter estimated of your objects: ", 8);
		print("Rolling ball radius: "+Ball);
		print("The max length of your objects is defined as the rolling ball radius.");
		print("That's the size of the true positive staining.");
		selectWindow("Log");
		showMessage("A windows will show up in the end of the macro.\nPress Ok to run background correction.");

	setBatchMode(true);
	for (i = 0; i < lengthOf(list); i++) {
	current_imagePath = input+list[i];
	if (endsWith(current_imagePath, ".tif")) {
		showProgress(i+1, current_imagePath.length);
		open(current_imagePath);
}	else {
	continue;
}
	currentImage_name = getTitle();
		rename("1");
		run("Subtract...", "value="+average);
		run("Duplicate...", "title=2");
		selectImage("2");
		run("Subtract Background...", "rolling=Ball create sliding");
		imageCalculator("Subtract create", "1","2");
		selectImage("Result of 1");
		run("Fire");
		saveAs("Tiff", output_dir + currentImage_name);
		run("Close All");
}
	setBatchMode(false);
		selectWindow("Results");
		run("Close");
		selectWindow("Log");
		saveAs("Text", output_dir+"Log - "+channel_color);
		print("\\Clear");
		run("Close");
	dialog = Dialog.create("Question");
	Dialog.addMessage("Do you wish to process others nuclei/cytoplasm channel?");
		Dialog.addChoice("Choose:", newArray("Yes", "No, I am done"));
		Dialog.show();
	choice = Dialog.getChoice();
	} while (choice == "Yes");
	Title2 = "Correction has ended";
	Message2 = "Press OK to Continue";
		showMessage(Title2, Message2);
}

macro "Background correction (Particles) Action Tool - C059T3e164" {
	Title = "Background correction (Particles)";
	Message = "Background substraction of particles-containing channel is about to begin.\nPress OK to continue."
		waitForUser(Title, Message);
	do {

		run("Set Measurements...", "mean standard min redirect=None decimal=3");

	question1 = getBoolean("Do you have any control channel folder?");
	if (question1 == 1) {
	channel_name = getString("Your channel color is: ", "Green");
	input2 = getDirectory("Select the control not-processed "+channel_name" channels folder");
	list2 = getFileList(input2);
	input = getDirectory("Select also the not-processed "+channel_name+" channels folder");
	list = getFileList(input);
	output_dir = input + File.separator + "2 - Processed "+channel_name+" channels" + File.separator ;
		File.makeDirectory(output_dir);

	for (z = 0; z < lengthOf(list2); z++) {
	current_imagePath2 = input2+list2[z];
		if (endsWith(current_imagePath2, ".tif")) {
		open(current_imagePath2);
		selectImage(z+1);
		run("Measure");
}
else {
	continue;
}
}
	sum = 0;
	for (z = 0; z < nResults; z++) {
  	sum = sum + getResult("Mean", z);
}
	average = sum / nResults;
		print("Settings:");
		print("This value calculated is the background mean intensity: "+average);
		print("That is the value to substract background to your images.");
		run("Close All");

	Ball = getNumber("Define the Rolling ball radius: ", 1);
	Sigma1 = getNumber("Sigma 1: ", 1);
	Sigma2 = getNumber("Sigma 2: ", 2);
		print("Rolling ball radius: "+Ball);
		print("Sigma 1: "+Sigma1);
		print("Sigma 2: "+Sigma2);
		selectWindow("Log");

	setBatchMode(true);
	for (i = 0; i < lengthOf(list); i++) {
	current_imagePath = input+list[i];
		if (endsWith(current_imagePath, ".tif")) {
		open(current_imagePath);
}	else {
	continue;
}
	currentImage_name = getTitle();
		rename("1");
		run("Subtract...", "value="+average);
		run("Duplicate...", "title=2");
		selectImage("2");
		run("Subtract Background...", "rolling=Ball create sliding");
		imageCalculator("Subtract create", "1","2");
		selectImage("Result of 1");
		run("Duplicate...", "title=A");
		run("Duplicate...", "title=B");
		selectImage("B");
		run("Gaussian Blur...", "sigma="+Sigma2);
		selectImage("A");
		run("Gaussian Blur...", "sigma="+Sigma1);
		imageCalculator("Subtract create", "A","B");
		selectImage("Result of A");
		run("Orange Hot");
		saveAs("Tiff", output_dir + currentImage_name);
		run("Close All");
}
	setBatchMode(false);
}	else {
	channel_name = getString("Your channel color is: ", "Green");
	input = getDirectory("Select the not-processed "+channel_name+" channels folder");
	list = getFileList(input);
	output_dir = input + File.separator + "2 - Processed "+channel_name+" channels" + File.separator ;
		File.makeDirectory(output_dir);

	for (i = 0; i < lengthOf(list); i++) {
	current_imagePath = input+list[i];
	if (endsWith(current_imagePath, ".tif")){
		open(current_imagePath);
} else {
	continue;
}
}
		showMessage("You are going to be asked to select randomly the background.\nThe selection tool is going to be automatically selected.");
	for (j = 0; j < nImages; j++) {
		selectImage(j+1);
		setTool("rectangle");
		waitForUser("Selection", "Select what is not your particles, then press OK");
		run("Measure");
}
	sum = 0;
	for (i = 0; i < nResults; i++) {
  	sum = sum + getResult("Mean", i);
}
	average = sum / nResults;
		print("Settings:");
		print("This value calculated is the background mean intensity: "+average);
		print("That is the value to substract background to your images.");
		run("Close All");

	Ball = getNumber("Max diameter estimated of your objects: ", 1);
	Sigma1 = getNumber("Sigma 1: ", 1);
	Sigma2 = getNumber("Sigma 2: ", 2);
		print("Rolling ball radius: "+Ball);
		print("Sigma 1: "+Sigma1);
		print("Sigma 2: "+Sigma2);
		print("The max length of your objects is defined as the rolling ball radius.");
		print("That's the size of the true positive staining.");
		selectWindow("Log");
		showMessage("A windows will show up in the end of the macro.\nPress Ok to run background correction.");

	setBatchMode(true);
	for (i = 0; i < lengthOf(list); i++) {
	current_imagePath = input+list[i];
		if (endsWith(current_imagePath, ".tif")) {
		open(current_imagePath);
}	else {
	continue;
}
	currentImage_name = getTitle();
		rename("1");
		run("Subtract...", "value="+average);
		run("Duplicate...", "title=2");
		selectImage("2");
		run("Subtract Background...", "rolling=Ball create sliding");
		imageCalculator("Subtract create", "1","2");
		selectImage("Result of 1");
		run("Duplicate...", "title=A");
		run("Duplicate...", "title=B");
		selectImage("B");
		run("Gaussian Blur...", "sigma="+Sigma2);
		selectImage("A");
		run("Gaussian Blur...", "sigma="+Sigma1);
		imageCalculator("Subtract create", "A","B");
		selectImage("Result of A");
		run("Orange Hot");
		saveAs("Tiff", output_dir + currentImage_name);
		run("Close All");
}
	setBatchMode(false);
}
		selectWindow("Results");
		run("Close");
		selectWindow("Log");
		saveAs("Text", output_dir+"Log - "+channel_name);
		print("\\Clear");
		run("Close");
	dialog = Dialog.create("Question");
	Dialog.addMessage("Do you wish to process others particles-containing channel?");
		Dialog.addChoice("Choose:", newArray("Yes", "No, I am done"));
		Dialog.show();
	choice = Dialog.getChoice();
	} while (choice == "Yes");
	Title2 = "Correction has ended";
	Message2 = "Press OK to Continue";
		showMessage(Title2, Message2);
}

macro "Counting (Nuclei/cytoplasm) Action Tool - C059T3e165" {
	Title = "Counting (Nuclei/cytoplasm)";
	Message = "Nuclei/cytoplasm segmentation is about to begin.\nPress OK to continue."
		waitForUser(Title, Message);
	do {

		run("Set Measurements...", "mean standard min redirect=None decimal=3");

	channel_color = getString("Your channel color is: ", "Blue");
	input = getDirectory("Select the processed-"+channel_color+" channels folder");
	list = getFileList(input);
	output_dir = input + File.separator + "3 - Data "+channel_color+" channels" + File.separator;
		File.makeDirectory(output_dir);

	// Initialise first variables
		print("Parameters:");
	nImage = lengthOf(list);
	sum = 0;
	
	for (i = 0; i < nImage; i++) {
	current_imagePath = input + list[i];
	if (endsWith(current_imagePath, ".tif")) {
		open(current_imagePath);
}	else {
	continue;
}
		setAutoThreshold("Otsu dark no-reset");
		setThreshold(0, 65535,"over/under");
		run("Threshold...");
		waitForUser("Set the lowest threshold", "1 - Select the algorithm you wish (Default, Li, Otsu etc...).\n2 - Press auto.\n3 - Slide the top bar until all objects are segmented.\n4 - Once satisfied, press OK");
		getThreshold(lower, upper);
		print("Lowest threshold value " + list[i] + ": " + lower);
			sum += lower;															// Accumulate lower threshold values.
}
			average = sum / nImage;													// Calculate the average lower threshold value.
		print("Average lower threshold value through all images: "+average);
		print("The average lower threshold calculated will distinguish what is a true positive from what is a true negative staining.");
		print("It is going to be a constant for all of your images.");
		print("");
		selectWindow("Log");
		run("Close All");

	// Initialise second variable
	Param = "User settings";
	var threshold = average;
	var min = 0;
	var max = 500;
	var min1 = 0;
	var max2 = 1;
	var default = 0.5;
	Dialog.create("User settings");
	Dialog.addMessage("Those parameters below can be user-defined.");
		Dialog.addMessage("Average lowest threshold can be read from the log windows.");
		Dialog.addNumber("Lowest threshold: ", threshold);
		Dialog.addMessage("Size of your object (Lenght^2)");
		Dialog.addSlider("Size [min]: ", min, max, 15);
		Dialog.addSlider("Size [max]: ", min, max, 100);
		Dialog.addMessage("Roundness of your object (range [0-1])");
		Dialog.addSlider("Circularity [min]: ", min1, max2, default);
		Dialog.addSlider("Circularity [max}: ", min1, max2, default);
	Dialog.show();
	Low_Threshold = Dialog.getNumber();
	minSize = Dialog.getNumber();
	maxSize = Dialog.getNumber();
	minCircularity = Dialog.getNumber();
	maxCircularity = Dialog.getNumber();

		print("User-defined parameters:");
		print("Threshold minimun: "+Low_Threshold);
		print("Size (min): "+minSize);
		print("Size (max): "+maxSize);
		print("Circularity (min): "+minCircularity);
		print("Circularity (max): "+maxCircularity);
		print("");

	for (i = 0; i < lengthOf(list); i++) {
	current_imagePath = input+list[i];
	if (endsWith(current_imagePath, ".tif")) {
		open(current_imagePath);
}	else {
	continue;
}
	currentImage_name = getTitle();
		run("Duplicate...", "title=Blue");
		setThreshold(Low_Threshold, upper, "raw");
		run("Create Mask");
//		run("Open");
		run("Fill Holes");
		run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction limit display redirect=Blue decimal=4");

	Question = getBoolean("Do you wish to run Watershed?");
	if (Question == 1) {
		run("Watershed");
}
		run("Analyze Particles...", "size="+minSize+"-"+maxSize+"circularity="+minCircularity+"-"+maxCircularity+"show=Masks exclude add");
		selectImage(currentImage_name);
		setThreshold(Low_Threshold, upper, "raw");
		run("ROI Manager...");
	Group = roiManager("count");
	if (Group >= 1) {
		run("ROI Manager...");
	for (x = 0 ; x < Group; x++) {
		roiManager("Select", x);
		roiManager("Rename", 1 + x + " Nucleus");
		roiManager("Set Color", 1 + x + "yellow");
}
		selectImage(currentImage_name);
		setThreshold(Low_Threshold, upper, "raw");
		roiManager("Select", newArray());
		run("Select All");
		roiManager("Measure");
		selectWindow("Results");
		saveAs("Results", output_dir+currentImage_name+"-Nuclei datas.tsv");
		run("Clear Results");
		run("Close");
		roiManager("Select", newArray());
		run("Select All");
		roiManager("Save", output_dir + currentImage_name + "-ROI nuclei.zip");
		selectImage(currentImage_name);
		roiManager("Show None");
		roiManager("Show All");
		roiManager("Show All without labels");
		roiManager("Show All with labels");
		resetThreshold;
		run("ROI Manager...");
		selectImage(currentImage_name);

	Title2 = "Observation";
	Message2 = "Observe all nuclei/cytoplasm identified.\nThen press OK.";
		waitForUser(Title2, Message2);
		run("ROI Manager...");
		roiManager("delete");
		run("Close All");
}	else {
		print("No objects were found into: "+currentImage_name);
		run("Close All");
}
}
		selectWindow("Log");
		saveAs("Text", output_dir+"Log - "+channel_color);
		print("\\Clear");
		run("Close");
		close("Threshold");
		close("ROI Manager");

	dialog = Dialog.create("Question");
	Dialog.addMessage("Do you wish to segment others nuclei/cytoplasm channel ?");
		Dialog.addChoice("Choose:", newArray("Yes", "No, I am done"));
		Dialog.show();
	choice = Dialog.getChoice();
	} while (choice == "Yes");
	Title3 = "Counting has ended";
	Message3 = "Press OK to Continue";
		showMessage(Title3, Message3);
}

macro "Counting (Particles) Action Tool - C059T3e166" {
	Title = "Counting (Particles)";
	Message = "Particles segmentation is about to begin.\nPress OK to continue."
		waitForUser(Title, Message);
	do {

		run("Set Measurements...", "mean standard min redirect=None decimal=3");

	channel_name = getString("Your channel color is: ", "Green");
	input = getDirectory("Select the processed-"+channel_name+" channels folder");
	list = getFileList(input);
	output_dir = input + File.separator + "3 - Data "+channel_name+" channels" + File.separator;
		File.makeDirectory(output_dir);

	// Initialise the first variable: Threshold.
		print("Parameters:");
	nImage = lengthOf(list);
	sum = 0;

	for (i = 0; i < nImage; i++) {
	current_imagePath = input + list[i];
	if (endsWith(current_imagePath, ".tif")) {
		open(current_imagePath);
}	else {
	continue;
}
		run("6_shades");
		setAutoThreshold("Otsu dark no-reset");
		setThreshold(0, 65535,"over/under");
		run("Threshold...");
		waitForUser("Set the lowest threshold", "1 - Select the algorithm you wish (Default, Li, Otsu etc...).\n2 - Press auto.\n3 - Slide the top bar until all objects are segmented.\n4 - Once satisfied, press OK");
		getThreshold(lower, upper);
			print("Lowest threshold value"+list[i]+": "+lower);
			sum += lower;															// Accumulate lower threshold values.
}
			average = sum / nImage;													// Calculate the average lower threshold value.
		print("Average lower threshold value through all images: " + average);
		print("The average lower threshold calculated will distinguish what is a true positive from what is a true negative staining.");
		print("It is going to be a constant for all of your images.");
		print("");
		selectWindow("Log");
		run("Close All");

	// lowest threshold is defined by the user.
	Param = "User settings";
	var threshold = average;
	var min = 0;
	var max = 500;
	var min1 = 0;
	var max2 = 1;
	var default = 0.5;
	Dialog.create("User settings");
	Dialog.addMessage("Those parameters below can be user-defined.");
		Dialog.addMessage("Average lowest threshold can be read from the log windows.");
		Dialog.addNumber("Lowest threshold: ", threshold);
		Dialog.addMessage("Size of your object (Lenght^2)");
		Dialog.addSlider("Size [min]: ", min, max, 0);
		Dialog.addSlider("Size [max]: ", min, max, 5);
		Dialog.addMessage("Roundness of your object (range [0-1])");
		Dialog.addSlider("Circularity [min]: ", min1, max2, default);
		Dialog.addSlider("Circularity [max}: ", min1, max2, default);
	Dialog.show();
	Low_Threshold = Dialog.getNumber();
	minSize = Dialog.getNumber();
	maxSize = Dialog.getNumber();
	minCircularity = Dialog.getNumber();
	maxCircularity = Dialog.getNumber();

		print("User-defined parameters:");
		print("Threshold minimun: "+Low_Threshold);
		print("Size (min): "+minSize);
		print("Size (max): "+maxSize);
		print("Circularity (min): "+minCircularity);
		print("Circularity (max): "+maxCircularity);
		print("");

	// Particles counting begins.
	for (i = 0; i < lengthOf(list); i++) {
	current_imagePath = input+list[i];
	if (endsWith(current_imagePath, ".tif")) {
		open(current_imagePath);
}	else {
	continue;
}
	currentImage_name = getTitle();
		run("Duplicate...", "title="+channel_name);
		setThreshold(Low_Threshold, upper, "raw");
		run("Create Mask");	//	run("Tile");
		run("Fill Holes");
		run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction limit display redirect="+channel_name+" decimal=4");
	showMessage("You are going to be ask to select for a ROI.zip folder.\nIt is a folder located in nuclei segmented (3 - .... Datas).\nNB: ROI = Region of interest.");

	// Nuclei ROI folder selection.	//	run("ROI Manager...");
	ROI_folder = File.openDialog("Select nuclei ROI folder to identify particles per nucleus.");
		roiManager("Open", ROI_folder);
		roiManager("Select", newArray());
	ROI_to_group = roiManager("count");
		selectImage("mask");
		run("Analyze Particles...", "size="+minSize+"-"+maxSize+"circularity="+minCircularity+"-"+maxCircularity+"show=Masks exclude clear"); //		run("Tile");
		selectImage("Mask of mask");
		setAutoThreshold("Default");

setBatchMode(true);
	// Grouping of particles.
	for (x = 0 ; x < ROI_to_group; x++) {
		selectImage("Mask of mask");
		roiManager("Select", x);
	roi_name = Roi.getName;
		run("Analyze Particles...", "size="+minSize+"-"+maxSize+"circularity="+minCircularity+"-"+maxCircularity+" show=Masks clear");
		selectImage("Mask of Mask of mask");
		run("Invert");
		run("Create Selection");
	if (getValue("selection.size") == 0) {
		run("Select None");
		close();
		print("No particles found on: "+currentImage_name+" "+roi_name);
		continue;
	} else {
		roiManager("Add");
		close();
	}
}
setBatchMode(false);

	// Erasing of previous ROI nuclei list and renaming
		run("ROI Manager...");
		roiManager("Select", newArray());
	ROI_selection = roiManager("count");
		for (x = ROI_selection-1; x >= 0; x--) {
		roiManager("Select", x);
	Nucleus_ROI_to_delete = Roi.getName;
		if (matches (Nucleus_ROI_to_delete, ".*Nucleus*")) {
		roiManager ("Delete");
	continue;
	}
}
	Pre_count = roiManager("count");
	if (Pre_count >=1 ) {
		run("ROI Manager...");
		roiManager("Select", newArray());
	ROI_to_group = roiManager("count");
	for (b = 0 ; b < ROI_to_group; b++) {
		roiManager("Select", b);
		roiManager("Rename", 1+b+"-group");
		roiManager("Set Color", 1+b+"blue");
}
		roiManager("Select", newArray());
		roiManager("Save", output_dir+currentImage_name+"-ROI particules.zip");
		selectImage(currentImage_name);
		roiManager("Show None");
		roiManager("Show All");
		roiManager("Show All without labels");
		roiManager("Show All with labels");
		resetThreshold;

	Title2 = "Observation";
	Message2 = "Observe all particles identified.\nLeft ctrl + zoom in.\nThen press OK.";
		waitForUser(Title2, Message2);
		roiManager("delete");

	// Particles statistic
		run("ROI Manager...");
		roiManager("Open", ROI_folder);

		roiManager("Select", newArray());
	ROI_to_measure = roiManager("count");

	for (y = 0 ; y < ROI_to_measure; y++) {
		selectImage(channel_name);
		setThreshold(Low_Threshold, upper, "raw");
		roiManager("Select", y);
		run("Analyze Particles...", "size="+minSize+"-"+maxSize+"circularity="+minCircularity+"-"+maxCircularity+"show=Nothing display exclude summarize add composite");
}
		selectWindow("Results");
		saveAs("Results", output_dir+currentImage_name+"-Particules datas.tsv");
		run("Close");
		selectWindow("Summary");
		saveAs("Results", output_dir+currentImage_name+"-Particules summary.tsv");
		run("Close");
		roiManager("delete");
		run("Close All");
}	else {
		print("None particles found into: "+currentImage_name);
		run("Close All");
}
}
		selectWindow("Log");
		saveAs("Text", output_dir+"Log - "+channel_name);
		print("\\Clear");
		run("Close");
		close("Threshold");
		close("ROI Manager");

	dialog = Dialog.create("Question");
	Dialog.addMessage("Do you wish to particle counting others channel ?");
		Dialog.addChoice("Choose:", newArray("Yes", "No, I am done"));
		Dialog.show();
	choice = Dialog.getChoice();
	} while (choice == "Yes");
	Title3 = "Counting has ended";
	Message3 = "Press OK to Continue";
		showMessage(Title3, Message3);
}

macro "Western Blot - Action Tool T0808WTe808B" {
	input = getDirectory("Folder where Western Blots images are stored and datas will be saved");
	list = getFileList(input);

	for (j = 0; j < list.length; j++) {
		open(input+list[j]);
		run("Duplicate...", "title=1");
		run("Duplicate...", "title=2");
		run("Invert");
		run("Duplicate...", "title=3");
		run("Subtract Background...", "rolling=70 create sliding");
		imageCalculator("Subtract create", "2","3");
		selectImage("Result of 2");
		setAutoThreshold("Otsu dark");
		run("Threshold...");
	title = "1";
	message = "Set the threshold, then press OK.";
		waitForUser(title, message);
		run("Create Mask");
		run("Open");
		run("Fill Holes");
		run("Erode");
		run("Dilate");
		setTool("rectangle");
	title2 = "2";
	message2 = "Select the lane that contains your protein of interest, then press OK.";
		waitForUser(title2, message2);
		run("Set Measurements...", "integrated redirect=None decimal=3");
		run("Analyze Particles...", "size=5-Infinity add");
		run("ROI Manager...");
	Group = roiManager("count");
	for (z=0 ; z<Group; z++) {
		roiManager("Select", z);
		roiManager("Rename", 1+z+" "+"Protein");
	}
		selectImage("1");
		roiManager("Select", newArray());
		roiManager("Measure");
		selectWindow("Results");
		saveAs("Results", input+j+1+"-Lane.tsv");
		run("Clear Results");
		run("Close");
		roiManager("Select", newArray());
		run("Select All");
		roiManager("Save", input+j+1+"-Lane.zip");
		roiManager("delete");
		run("Close All");
}
}