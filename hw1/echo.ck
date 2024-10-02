//-----------------------------------------------------------------------------
// echo.ck
// desc: press the space bar max_ctr times with any rhythm. An echo will play echo_num times
// to run: `chuck echo.ck`
//
// author: Samantha Liu
// Based on: kb.ck by Ge
//-----------------------------------------------------------------------------
4 => int max_ctr;
3 => int echo_num;


// ----- keyboard setup -----
Hid hi;
HidMsg msg;

// which keyboard
0 => int device;
// get from command line
if( me.args() ) me.arg(0) => Std.atoi => device;

// open keyboard (get device number from command line)
if( !hi.openKeyboard( device ) ) me.exit();
<<< "keyboard '" + hi.name() + "' ready", "" >>>;


// ----- sound setup -----
BlitSquare sin => NRev rev => dac;
0 => sin.gain;

0 => int ctr;
time start_times[max_ctr+1];
time end_times[max_ctr];
int midi[max_ctr];


// ----- recorder -----
while( ctr < max_ctr )
{
    // wait on event
    hi => now;

    // get one or more messages
    while( hi.recv( msg ) )
    {

        if (msg.which == 44) { // space bar 
            // check for action type
            if( msg.isButtonDown() )
            {
                now => start_times[ctr];
                Math.random2(48, 72) => midi[ctr]; // set notes randomly
            }
            else
            {
                now => end_times[ctr];
                ctr++;
                <<< ctr, "" >>>;
            }
        }
    }
}

1::second => now;
now => start_times[max_ctr];

<<< "Recorder is done!" >>>;


// ----- echo -----
for (int i; i < echo_num; i++) {
    for (int j; j < max_ctr; j++) {
        0.2 / (i+1) / (i+1) => sin.gain; // decreasing gain
        Std.mtof(midi[j]) => sin.freq; // same notes as previously set
        0.1 * (i+1) => rev.mix; // increaing reverb
        end_times[j] - start_times[j] => now;
        0 => sin.gain;
        start_times[j+1] - end_times[j] => now;
    }
}


