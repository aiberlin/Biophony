/***
example startupfile for NTMI and NTSS setup:
- copy to
StartupFile.filesDir
- then adjust path!

this loads NTSS first,
then NTMI with no MainFX and no reboot.
adds a window for dragsources for NTMI processes,
so one can drag them to NTSS channels.

***/

// I want that sampleRate:
s.options.sampleRate = 48000;


q = q ? ();

// now load NTSS, which boots server
// adjust path to where you have it
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
		//make sure the NTMI sounds play directly:
		NTMI.processes.do(_.set(\amp, 0.25));
		q.ndef.groups.postcs;

		// prepare groups for new NdefMixer:
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
		Butz(\NTMI).actions.replace(\ndefMixer, Butz(\top).actions.at(\NdefMixer));

		Butz.curr = \NTSS;
		Butz.run(\N_T_S_S);
	};
};

