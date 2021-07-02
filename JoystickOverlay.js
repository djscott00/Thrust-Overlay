var dot2D = document.querySelector('#dot-2D');
var dot1D = document.querySelector('#dot-1D');

var boost = document.querySelector('#boost');
var drift = document.querySelector('#drift');


function UpdatePositions(pitchVal, yawVal, rollVal, boostActive, driftActive) {
    

    var rollNew = ((((rollVal * 1.00) + 1.00) / 2.00) * 100).toString() + '%';

	var xRadialLengthFactor = yawVal *   Math.sqrt( 1.00 - 0.50 * Math.pow(pitchVal,2) );
	var yRadialLengthFactor = pitchVal * Math.sqrt( 1.00 - 0.50 * Math.pow(yawVal,2) );

    var yawNew = ((((xRadialLengthFactor * 1.00) + 1.00) / 2.00) * 100).toString() + '%';
    var pitchNew = ((((yRadialLengthFactor * 1.00) + 1.00) / 2.00) * 100).toString() + '%';


    dot2D.style.top = pitchNew;
    dot2D.style.left = yawNew;
    dot1D.style.left = rollNew;

    if(boostActive) {
        boost.classList.add('activetext');
    }
    else {
        boost.classList.remove("activetext");
    }

    if(driftActive) {
        drift.classList.add('activetext');
    }
    else {
        drift.classList.remove("activetext");
    }    

    // alert(
    //     'yawVal: ' + yawVal + '\n' +
    //     'pitchVal: ' + pitchVal + '\n' +
    //     'xFactor: ' + xRadialLengthFactor + '\n' +
    //     'yFactor: ' + yRadialLengthFactor + '\n' +
    //     'Boost:' + boostActive + '\n' +
    //     'Drift:' + driftActive
    
    // );

}