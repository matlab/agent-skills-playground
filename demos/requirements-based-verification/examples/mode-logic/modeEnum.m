classdef modeEnum < uint8
    enumeration
        Off(0)
        WaitForComms(1)
        Init(2)
        Calibration(3)
        ReadyForTO(4)
        TrackAlt(5)
        Track3D(6)
        LostBall(7)
        Land(8)
        Crash(9)
    end
end
