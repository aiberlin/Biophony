/*** example startupfile for NTMI and NTSS setup:

load NTSS first,
then NTMI without MainFX and without reboot

add several niceties
***/

// I want that sampleRate:
s.options.sampleRate = 48000;


q = q ? ();

// now load NTSS, which boots server
"~/src/aiberlin/Biophony/00_loadMe_NTSS.scd".standardizePath.loadPaths;

q.ntss.finalSetup = {
	// wait a bit
	0.1.wait;

	// then load NTMI, with special settings:
	NTMI.reboot = false;
	NTMI.usesMainFX = false;
	MainFX(s).proxy.set(\mainvol, 0.25);


	NTMI.run;
	NTMI.finalSetup = {
		//make sure they play directly:
		NTMI.processes.do(_.set(\amp, 0.25));
		q.ndef.groups.postcs;

		q.ndef.groupNames = [\ntssChan, \ntssPan, \NTMI];
		q.ndef.groups.put(\NTMI, NTMI.processes);

		WinBounds.addMake(\allNdefs, {
			w = Window("ndefs").front;
			w.view.layout = GridLayout.rows(
				*NTMI.processes.collect { |ndef|
					DragSource(w).object_(ndef) }.clump(4)
			);
		});

		Butz(\NTMI).remove(\miniNTMI);
		Butz(\NTMI).add(\allNdefs, { WinBounds.showOrMake(\allNdefs) });

	};
};

