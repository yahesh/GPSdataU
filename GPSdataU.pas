unit GPSdataU;

// Please, don't delete this comment. \\
(*
  Copyright Owner: Yahe
  Copyright Year : 2008-2018

  Unit   : GPSdataU (platform dependant)
  Version: 1.5c

  Contact E-Mail: hello@yahe.sh
*)
// Please, don't delete this comment. \\

(*
  Description:

  This unit contains an interface which handles NMEA messages.
*)

(*
  Change Log:

  [Version 1.5c] (10.11.2008 $--ZDA release)
  - $--ZDA record is now supported

  [Version 1.4c] (10.11.2008 F3507g release)
  - TInitInputEvent introduced
  - TInitOutputEvent introduced
  - OnInitInput introduced
  - OnInitOutput introduced
  - InitEricssonF3507g() introduced

  [Version 1.3c] (15.10.2008: talker id release)
  - talker id support added (no fix check for sequence "$--" anymore)
  - TalkerIDToDescription() introduced
  - all events now provide an ATalkerID parameter
  - DirectionToDescription() introduced
  - FAAModeIndicatorToDescription() introduced
  - GPSQualityIndicatorToDescription() introduced
  - ModeToDescription() introduced
  - SelectionModeToDescription() introduced
  - StatusToDescription() introduced
  - DateStringToDate() introduced
  - TimeStringToDate() introduced

  [Version 1.2c] (26.08.2008: sender release)
  - all events now provide an ASender parameter

  [Version 1.1c] (19.07.2008: synchronize release)
  - COM port is now used with synchronized option enabled
  - received data can be checked against their checksum

  [Version 1.0c] (16.07.2008: initial release)
  - initial source has been written
*)

interface

uses
  Windows,
  SysUtils,
  Controls,
  COMportU;

const
  GPSdataU_CopyrightOwner = 'Yahe';
  GPSdataU_CopyrightYear  = '2008-2018';
  GPSdataU_Name           = 'GPSdata';
  GPSdataU_ReleaseDate    = '10.11.2008';
  GPSdataU_ReleaseName    = '$--ZDA release';
  GPSdataU_Version        = '1.5c';

const
  CopyrightOwner = GPSdataU_CopyrightOwner;
  CopyrightYear  = GPSdataU_CopyrightYear;
  Name           = GPSdataU_Name;
  ReleaseDate    = GPSdataU_ReleaseDate;
  ReleaseName    = GPSdataU_ReleaseName;
  Version        = GPSdataU_Version;

type
  TGPSdata = class;

(*
  GGA - Global Positioning System Fix Data
  
  Time, Position and fix related data for a GPS receiver.

         1         2       3 4        5 6 7  8   9  10 11 12 13  14   15
         |         |       | |        | | |  |   |   | |   | |   |    |
  $--GGA,hhmmss.ss,llll.ll,a,yyyyy.yy,a,x,xx,x.x,x.x,M,x.x,M,x.x,xxxx*hh<CR><LF>

  Field Number:
    1) Universal Time Coordinated (UTC)
    2) Latitude
    3) N or S (North or South)
    4) Longitude
    5) E or W (East or West)
    6) GPS Quality Indicator,
       0 - fix not available,
       1 - GPS fix,
       2 - Differential GPS fix
       (values above 2 are 2.3 features)
       3 = PPS fix
       4 = Real Time Kinematic
       5 = Float RTK
       6 = estimated (dead reckoning)
       7 = Manual input mode
       8 = Simulation mode
    7) Number of satellites in view, 00 - 12
    8) Horizontal Dilution of precision (meters)
    9) Antenna Altitude above/below mean-sea-level (geoid) (in meters)
   10) Units of antenna altitude, meters
   11) Geoidal separation, the difference between the WGS-84 earth
       ellipsoid and mean-sea-level (geoid), "-" means mean-sea-level
       below ellipsoid
   12) Units of geoidal separation, meters
   13) Age of differential GPS data, time in seconds since last SC104
       type 1 or 9 update, null field when DGPS is not used
   14) Differential reference station ID, 0000-1023
   15) Checksum
*)
  TGGAdata = record
    Command                        : String; // '$--GGA'
    UTC                            : String; // 1)
    Latitude                       : String; // 2)
    Lat_NorthSouth                 : String; // 3)
    Longitude                      : String; // 4)
    Lon_EastWest                   : String; // 5)
    QualityIndicator               : String; // 6)
    SatelliteCount                 : String; // 7)
    HorizontalDilution             : String; // 8)
    AntennaAltitude                : String; // 9)
    AntennaAltitudeUnit            : String; // 10)
    GeoidalSeparation              : String; // 11)
    GeoidalSeparationUnit          : String; // 12)
    DifferentialDataAge            : String; // 13)
    DifferentialReferenceStationID : String; // 14)
    Checksum                       : String; // 15)
  end;

(*
  GLL - Geographic Position - Latitude/Longitude

  	     1       2 3        4 5         6 7  8
	       |       | |        | |         | |  |
  $--GLL,llll.ll,a,yyyyy.yy,a,hhmmss.ss,a,m,*hh<CR><LF>

  Field Number:
    1) Latitude
    2) N or S (North or South)
    3) Longitude
    4) E or W (East or West)
    5) Universal Time Coordinated (UTC)
    6) Status A - Data Valid, V - Data Invalid
    7) FAA mode indicator (NMEA 2.3 and later)
    8) Checksum
*)
  TGLLdata = record
    Command        : String; // '$--GLL'
    Latitude       : String; // 1)
    Lat_NorthSouth : String; // 2)
    Longitude      : String; // 3)
    Lon_EastWest   : String; // 4)
    UTC            : String; // 5)
    Status         : String; // 6)
    ModeIndicator  : String; // 7)
    CheckSum       : String; // 8)
  end;

(*
  GSA - GPS DOP and active satellites

  	     1 2 3 4                       14 15 16  17  18
  	     | | | |                       |  |  |   |   |
  $--GSA,a,a,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x.x,x.x,x.x*hh<CR><LF>

  Field Number:
    1) Selection mode
	         M=Manual, forced to operate in 2D or 3D
	         A=Automatic, 3D/2D
    2) Mode (1 = no fix, 2 = 2D fix, 3 = 3D fix)
    3) ID of 1st satellite used for fix
    4) ID of 2nd satellite used for fix
    ...
   14) ID of 12th satellite used for fix
   15) PDOP
   16) HDOP
   17) VDOP
   18) checksum
*)
  TGSAdata = record
    Command          : String; // '$--GSA'
    SelectionMode    : String; // 1)
    Mode             : String; // 2)
    FixSatelliteID1  : String; // 3)
    FixSatelliteID2  : String; // 4)
    FixSatelliteID3  : String; // 5)
    FixSatelliteID4  : String; // 6)
    FixSatelliteID5  : String; // 7)
    FixSatelliteID6  : String; // 8)
    FixSatelliteID7  : String; // 9)
    FixSatelliteID8  : String; // 10)
    FixSatelliteID9  : String; // 11)
    FixSatelliteID10 : String; // 12)
    FixSatelliteID11 : String; // 13)
    FixSatelliteID12 : String; // 14)
    PDOP             : String; // 15)
    HDOP             : String; // 16)
    VDOP             : String; // 17)
    Checksum         : String; // 18)
  end;

(*
  GSV - Satellites in view

  These sentences describe the sky position of a UPS satellite in view.
  Typically they're shipped in a group of 2 or 3.

	       1 2 3 4 5 6 7     n
	       | | | | | | |     |
  $--GSV,x,x,x,x,x,x,x,...*hh<CR><LF>

  Field Number:
    1) total number of GSV messages to be transmitted in this group
    2) 1-origin number of this GSV message  within current group
    3) total number of satellites in view (leading zeros sent)
    4) satellite PRN number (leading zeros sent)
    5) elevation in degrees (00-90) (leading zeros sent)
    6) azimuth in degrees to true north (000-359) (leading zeros sent)
    7) SNR in dB (00-99) (leading zeros sent)
    ... more satellite info quadruples like 4-7
    n) checksum
*)
  TGSVsatellite = record
    PRN       : String; // 4)
    Elevation : String; // 5)
    Azimuth   : String; // 6)
    SNR       : String; // 7)
  end;
  TGSVdata = record
    Command        : String;                 // '$--GSV'
    MessageCount   : String;                 // 1)
    MessageIndex   : String;                 // 2)
    SatelliteCount : String;                 // 3)
    Satellites     : array of TGSVsatellite; // 4) to n-1)
    Checksum       : String;                 // n)
  end;

(*
  RMC - Recommended Minimum Navigation Information
                                                            12
         1         2 3       4 5        6  7   8   9    10 11|  13
         |         | |       | |        |  |   |   |    |  | |  |
  $--RMC,hhmmss.ss,A,llll.ll,a,yyyyy.yy,a,x.x,x.x,xxxx,x.x,a,m,*hh<CR><LF>

  Field Number:
    1) UTC Time
    2) Status, V=Navigation receiver warning A=Valid
    3) Latitude
    4) N or S
    5) Longitude
    6) E or W
    7) Speed over ground, knots
    8) Track made good, degrees true
    9) Date, ddmmyy
   10) Magnetic Variation, degrees
   11) E or W
   12) FAA mode indicator (NMEA 2.3 and later)
   13) Checksum
*)
  TRMCdata = record
    Command           : String; // '$--RMC'
    UTC               : String; // 1)
    Status            : String; // 2)
    Latitude          : String; // 3)
    Lat_NorthSouth    : String; // 4)
    Longitude         : String; // 5)
    Lon_EastWest      : String; // 6)
    Speed             : String; // 7)
    TrackCorrection   : String; // 8)
    Date              : String; // 9)
    MagneticVariation : String; // 10)
    Var_EastWest      : String; // 11)
    ModeIndicator     : String; // 12)
    Checksum          : String; // 13)
  end;

(*
  VTG - Track made good and Ground speed

         1   2 3   4 5	 6 7   8 9  10
         |   | |   | |   | |   | |  |
  $--VTG,x.x,T,x.x,M,x.x,N,x.x,K,m,*hh<CR><LF>

  Field Number:
    1) Track Degrees
    2) T = True
    3) Track Degrees
    4) M = Magnetic
    5) Speed Knots
    6) N = Knots
    7) Speed Kilometers Per Hour
    8) K = Kilometers Per Hour
    9) FAA mode indicator (NMEA 2.3 and later)
   10) Checksum
*)
  TVTGdata = record
    Command        : String; // '$--VTG'
    TrackDegrees1  : String; // 1)
    True           : String; // 2)
    TrackDegrees2  : String; // 3)
    Magnetic       : String; // 4)
    SpeedKnots     : String; // 5)
    SpeedKnotsUnit : String; // 6)
    SpeedKpH       : String; // 7)
    SpeedKpHUnit   : String; // 8)
    ModeIndicator  : String; // 9)
    Checksum       : String; // 10)
  end;

(*
  ZDA - Time & Date - UTC, day, month, year and local time zone

	       1         2  3  4    5  6  7
         |         |  |  |    |  |  |
  $--ZDA,hhmmss.ss,xx,xx,xxxx,xx,xx*hh<CR><LF>

  Field Number:
    1) UTC time (hours, minutes, seconds, may have fractional subsecond)
    2) Day, 01 to 31
    3) Month, 01 to 12
    4) Year (4 digits)
    5) Local zone description, 00 to +- 13 hours
    6) Local zone minutes description, apply same sign as local hours
    7) Checksum
*)
  TZDAdata = record
    Command                    : String; // '$--ZDA'
    UTC                        : String; // 1)
    Day                        : String; // 2)
    Month                      : String; // 3)
    Year                       : String; // 4)
    LocalZoneDescriptor        : String; // 5)
    LocalZoneMinutesDescriptor : String; // 6)
    Checksum                   : String; // 7)
  end;

  TAfterSplitLineEvent  = procedure (const ASender : TObject; const ATalkerID : String; const AParts : array of String; const AChecksum : String) of Object;
  TBeforeSplitLineEvent = TReadLineEvent;
  TWrongChecksumEvent   = TReadLineEvent;

  TInitInputEvent  = TReadLineEvent;
  TInitOutputEvent = TReadLineEvent;

  TCommandMethod = record
    Command : String;
    Method  : TAfterSplitLineEvent;
  end;

  TGGAdataEvent = procedure (const ASender : TObject; const ATalkerID : String; const AData : TGGAdata) of Object;
  TGLLdataEvent = procedure (const ASender : TObject; const ATalkerID : String; const AData : TGLLdata) of Object;
  TGSAdataEvent = procedure (const ASender : TObject; const ATalkerID : String; const AData : TGSAdata) of Object;
  TGSVDataEvent = procedure (const ASender : TObject; const ATalkerID : String; const AData : TGSVdata) of Object;
  TRMCdataEvent = procedure (const ASender : TObject; const ATalkerID : String; const AData : TRMCdata) of Object;
  TVTGdataEvent = procedure (const ASender : TObject; const ATalkerID : String; const AData : TVTGdata) of Object;
  TZDAdataEvent = procedure (const ASender : TObject; const ATalkerID : String; const AData : TZDAdata) of Object;

  TGPSdata = class(TObject)
  private
  protected
    FCommandMethods           : array of TCommandMethod;
    FCOMport                  : TCOMport;
    FProceedWithWrongChecksum : Boolean;
    FValidateChecksum         : Boolean;

    FAfterSplitLineEvent  : TAfterSplitLineEvent;
    FBeforeSplitLineEvent : TBeforeSplitLineEvent;
    FGGAdataEvent         : TGGAdataEvent;
    FGLLdataEvent         : TGLLdataEvent;
    FGSAdataEvent         : TGSAdataEvent;
    FGSVDataEvent         : TGSVDataEvent;
    FInitInputEvent       : TInitInputEvent;
    FInitOutputEvent      : TInitOutputEvent;
    FParseErrorEvent      : TAfterSplitLineEvent;
    FRMCdataEvent         : TRMCdataEvent;
    FVTGdataEvent         : TVTGdataEvent;
    FWrongChecksumEvent   : TWrongChecksumEvent;
    FZDAdataEvent         : TZDAdataEvent;

    procedure ParseGGA(const ASender : TObject; const ATalkerID : String; const AParts : array of String; const AChecksum : String);
    procedure ParseGLL(const ASender : TObject; const ATalkerID : String; const AParts : array of String; const AChecksum : String);
    procedure ParseGSA(const ASender : TObject; const ATalkerID : String; const AParts : array of String; const AChecksum : String);
    procedure ParseGSV(const ASender : TObject; const ATalkerID : String; const AParts : array of String; const AChecksum : String);
    procedure ParseRMC(const ASender : TObject; const ATalkerID : String; const AParts : array of String; const AChecksum : String);
    procedure ParseVTG(const ASender : TObject; const ATalkerID : String; const AParts : array of String; const AChecksum : String);
    procedure ParseZDA(const ASender : TObject; const ATalkerID : String; const AParts : array of String; const AChecksum : String);

    procedure ParseLine(const ASender : TObject; const ALine : String);
    procedure SetCOMport(const AValue : TCOMport);
  public
    constructor Create;

    destructor Destroy; override;

    property COMport                  : TCOMport read FCOMport                  write SetCOMport;
    property ProceedWithWrongChecksum : Boolean  read FProceedWithWrongChecksum write FProceedWithWrongChecksum;
    property ValidateChecksum         : Boolean  read FValidateChecksum         write FValidateChecksum;

    property OnAfterSplitLine  : TAfterSplitLineEvent  read FAfterSplitLineEvent  write FAfterSplitLineEvent;
    property OnBeforeSplitLine : TBeforeSplitLineEvent read FBeforeSplitLineEvent write FBeforeSplitLineEvent;
    property OnGGAdata         : TGGAdataEvent         read FGGAdataEvent         write FGGAdataEvent;
    property OnGLLdata         : TGLLdataEvent         read FGLLdataEvent         write FGLLdataEvent;
    property OnGSAdata         : TGSAdataEvent         read FGSAdataEvent         write FGSAdataEvent;
    property OnGSVData         : TGSVDataEvent         read FGSVDataEvent         write FGSVDataEvent;
    property OnInitInput       : TInitInputEvent       read FInitInputEvent       write FInitInputEvent;
    property OnInitOutput      : TInitOutputEvent      read FInitOutputEvent      write FInitOutputEvent;
    property OnParseError      : TAfterSplitLineEvent  read FParseErrorEvent      write FParseErrorEvent;
    property OnRMCdata         : TRMCdataEvent         read FRMCdataEvent         write FRMCdataEvent;
    property OnVTGdata         : TVTGdataEvent         read FVTGdataEvent         write FVTGdataEvent;
    property OnWrongChecksum   : TWrongChecksumEvent   read FWrongChecksumEvent   write FWrongChecksumEvent;
    property OnZDAdata         : TZDAdataEvent         read FZDAdataEvent         write FZDAdataEvent;

    function InitEricssonF3507g : Boolean;

    class function DirectionToDescription(ADirection : String) : String;
    class function FAAModeIndicatorToDescription(AFAAModeIndicator : String) : String;
    class function GPSQualityIndicatorToDescription(AGPSQualityIndicator : String) : String;
    class function ModeToDescription(AMode : String) : String;
    class function SelectionModeToDescription(ASelectionMode : String) : String;
    class function StatusToDescription(AStatus : String) : String;
    class function TalkerIDToDescription(ATalkerID : String) : String;

    class function DateStringToDate(ADateString : String) : TDate;
    class function TimeStringToTime(ATimeString : String) : TTime;
  published
  end;

implementation

type
  TStringStringRecord = record
    Short : String;
    Long  : String;
  end;

const
  CUnknown = 'unknown';

{ TGPSdata }

procedure TGPSdata.ParseGGA(const ASender : TObject; const ATalkerID : String; const AParts: array of String; const AChecksum : String);
var
  LData : TGGAdata;
begin
  if (Length(AParts) > 0) then
    LData.Command := AParts[0]
  else
    LData.Command := '';
  if (Length(AParts) > 1) then
    LData.UTC := AParts[1]
  else
    LData.UTC := '';
  if (Length(AParts) > 2) then
    LData.Latitude := AParts[2]
  else
    LData.Latitude := '';
  if (Length(AParts) > 3) then
    LData.Lat_NorthSouth := AParts[3]
  else
    LData.Lat_NorthSouth := '';
  if (Length(AParts) > 4) then
    LData.Longitude := AParts[4]
  else
    LData.Longitude := '';
  if (Length(AParts) > 5) then
    LData.Lon_EastWest := AParts[5]
  else
    LData.Lon_EastWest := '';
  if (Length(AParts) > 6) then
    LData.QualityIndicator := AParts[6]
  else
    LData.QualityIndicator := '';
  if (Length(AParts) > 7) then
    LData.SatelliteCount := AParts[7]
  else
    LData.SatelliteCount := '';
  if (Length(AParts) > 8) then
    LData.HorizontalDilution := AParts[8]
  else
    LData.HorizontalDilution := '';
  if (Length(AParts) > 9) then
    LData.AntennaAltitude := AParts[9]
  else
    LData.AntennaAltitude := '';
  if (Length(AParts) > 10) then
    LData.AntennaAltitudeUnit := AParts[10]
  else
    LData.AntennaAltitudeUnit := '';
  if (Length(AParts) > 11) then
    LData.GeoidalSeparation := AParts[11]
  else
    LData.GeoidalSeparation := '';
  if (Length(AParts) > 12) then
    LData.GeoidalSeparationUnit := AParts[12]
  else
    LData.GeoidalSeparationUnit := '';
  if (Length(AParts) > 13) then
    LData.DifferentialDataAge := AParts[13]
  else
    LData.DifferentialDataAge := '';
  if (Length(AParts) > 14) then
    LData.DifferentialReferenceStationID := AParts[14]
  else
    LData.DifferentialReferenceStationID := '';

  LData.Checksum := AChecksum;
  if Assigned(FGGAdataEvent) then
    FGGAdataEvent(Self, ATalkerID, LData);
end;

procedure TGPSdata.ParseGLL(const ASender : TObject; const ATalkerID : String; const AParts: array of String; const AChecksum : String);
var
  LData : TGLLdata;
begin
  if (Length(AParts) > 0) then
    LData.Command := AParts[0]
  else
    LData.Command := '';
  if (Length(AParts) > 1) then
    LData.Latitude := AParts[1]
  else
    LData.Latitude := '';
  if (Length(AParts) > 2) then
    LData.Lat_NorthSouth := AParts[2]
  else
    LData.Lat_NorthSouth := '';
  if (Length(AParts) > 3) then
    LData.Longitude := AParts[3]
  else
    LData.Longitude := '';
  if (Length(AParts) > 4) then
    LData.Lon_EastWest := AParts[4]
  else
    LData.Lon_EastWest := '';
  if (Length(AParts) > 5) then
    LData.UTC := AParts[5]
  else
    LData.UTC := '';
  if (Length(AParts) > 6) then
    LData.Status := AParts[6]
  else
    LData.Status := '';
  if (Length(AParts) > 7) then
    LData.ModeIndicator := AParts[7]
  else
    LData.ModeIndicator := '';

  LData.CheckSum := AChecksum;
  if Assigned(FGLLdataEvent) then
    FGLLdataEvent(Self, ATalkerID, LData);
end;

procedure TGPSdata.ParseGSA(const ASender : TObject; const ATalkerID : String; const AParts: array of String; const AChecksum : String);
var
  LData : TGSAdata;
begin
  if (Length(AParts) > 0) then
    LData.Command := AParts[0]
  else
    LData.Command := '';
  if (Length(AParts) > 1) then
    LData.SelectionMode := AParts[1]
  else
    LData.SelectionMode := '';
  if (Length(AParts) > 2) then
    LData.Mode := AParts[2]
  else
    LData.Mode := '';
  if (Length(AParts) > 3) then
    LData.FixSatelliteID1 := AParts[3]
  else
    LData.FixSatelliteID1 := '';
  if (Length(AParts) > 4) then
    LData.FixSatelliteID2 := AParts[4]
  else
    LData.FixSatelliteID2 := '';
  if (Length(AParts) > 5) then
    LData.FixSatelliteID3 := AParts[5]
  else
    LData.FixSatelliteID3 := '';
  if (Length(AParts) > 6) then
    LData.FixSatelliteID4 := AParts[6]
  else
    LData.FixSatelliteID4 := '';
  if (Length(AParts) > 7) then
    LData.FixSatelliteID5 := AParts[7]
  else
    LData.FixSatelliteID5 := '';
  if (Length(AParts) > 8) then
    LData.FixSatelliteID6 := AParts[8]
  else
    LData.FixSatelliteID6 := '';
  if (Length(AParts) > 9) then
    LData.FixSatelliteID7 := AParts[9]
  else
    LData.FixSatelliteID7 := '';
  if (Length(AParts) > 10) then
    LData.FixSatelliteID8 := AParts[10]
  else
    LData.FixSatelliteID8 := '';
  if (Length(AParts) > 11) then
    LData.FixSatelliteID9 := AParts[11]
  else
    LData.FixSatelliteID9 := '';
  if (Length(AParts) > 12) then
    LData.FixSatelliteID10 := AParts[12]
  else
    LData.FixSatelliteID10 := '';
  if (Length(AParts) > 13) then
    LData.FixSatelliteID11 := AParts[13]
  else
    LData.FixSatelliteID11 := '';
  if (Length(AParts) > 14) then
    LData.FixSatelliteID12 := AParts[14]
  else
    LData.FixSatelliteID12 := '';
  if (Length(AParts) > 15) then
    LData.PDOP := AParts[15]
  else
    LData.PDOP := '';
  if (Length(AParts) > 16) then
    LData.HDOP := AParts[16]
  else
    LData.HDOP := '';
  if (Length(AParts) > 17) then
    LData.VDOP := AParts[17]
  else
    LData.VDOP := '';

  LData.Checksum := AChecksum;
  if Assigned(FGSAdataEvent) then
    FGSAdataEvent(Self, ATalkerID, LData);
end;

procedure TGPSdata.ParseGSV(const ASender : TObject; const ATalkerID : String; const AParts: array of String; const AChecksum : String);
var
  LData  : TGSVdata;
  LIndex : LongInt;
begin
  if (Length(AParts) > 0) then
    LData.Command := AParts[0]
  else
    LData.Command := '';
  if (Length(AParts) > 1) then
    LData.MessageCount := AParts[1]
  else
    LData.MessageCount := '';
  if (Length(AParts) > 2) then
    LData.MessageIndex := AParts[2]
  else
    LData.MessageIndex := '';
  if (Length(AParts) > 3) then
    LData.SatelliteCount := AParts[3]
  else
    LData.SatelliteCount := '';

  LIndex := 4;
  while (LIndex < Length(AParts)) do
  begin
    SetLength(LData.Satellites, Succ(Length(LData.Satellites)));

    if (Length(AParts) > (LIndex + 0)) then
      LData.Satellites[High(LData.Satellites)].PRN := AParts[(LIndex + 0)]
    else
      LData.Satellites[High(LData.Satellites)].PRN := '';
    if (Length(AParts) > (LIndex + 1)) then
      LData.Satellites[High(LData.Satellites)].Elevation := AParts[(LIndex + 1)]
    else
      LData.Satellites[High(LData.Satellites)].Elevation := '';
    if (Length(AParts) > (LIndex + 2)) then
      LData.Satellites[High(LData.Satellites)].Azimuth := AParts[(LIndex + 2)]
    else
      LData.Satellites[High(LData.Satellites)].Azimuth := '';
    if (Length(AParts) > (LIndex + 3)) then
      LData.Satellites[High(LData.Satellites)].SNR := AParts[(LIndex + 3)]
    else
      LData.Satellites[High(LData.Satellites)].SNR := '';

    Inc(LIndex, 4);
  end;

  LData.Checksum := AChecksum;
  if Assigned(FGSVdataEvent) then
    FGSVdataEvent(Self, ATalkerID, LData);
end;

procedure TGPSdata.ParseRMC(const ASender : TObject; const ATalkerID : String; const AParts: array of String; const AChecksum : String);
var
  LData : TRMCdata;
begin
  if (Length(AParts) > 0) then
    LData.Command := AParts[0]
  else
    LData.Command := '';
  if (Length(AParts) > 1) then
    LData.UTC := AParts[1]
  else
    LData.UTC := '';
  if (Length(AParts) > 2) then
    LData.Status := AParts[2]
  else
    LData.Status := '';
  if (Length(AParts) > 3) then
    LData.Latitude := AParts[3]
  else
    LData.Latitude := '';
  if (Length(AParts) > 4) then
    LData.Lat_NorthSouth := AParts[4]
  else
    LData.Lat_NorthSouth := '';
  if (Length(AParts) > 5) then
    LData.Longitude := AParts[5]
  else
    LData.Longitude := '';
  if (Length(AParts) > 6) then
    LData.Lon_EastWest := AParts[6]
  else
    LData.Lon_EastWest := '';
  if (Length(AParts) > 7) then
    LData.Speed := AParts[7]
  else
    LData.Speed := '';
  if (Length(AParts) > 8) then
    LData.TrackCorrection := AParts[8]
  else
    LData.TrackCorrection := '';
  if (Length(AParts) > 9) then
    LData.Date := AParts[9]
  else
    LData.Date := '';
  if (Length(AParts) > 10) then
    LData.MagneticVariation := AParts[10]
  else
    LData.MagneticVariation := '';
  if (Length(AParts) > 11) then
    LData.Var_EastWest := AParts[11]
  else
    LData.Var_EastWest := '';
  if (Length(AParts) > 12) then
    LData.ModeIndicator := AParts[12]
  else
    LData.ModeIndicator := '';

  LData.Checksum := AChecksum;
  if Assigned(FRMCdataEvent) then
    FRMCdataEvent(Self, ATalkerID, LData);
end;

procedure TGPSdata.ParseVTG(const ASender : TObject; const ATalkerID : String; const AParts: array of String; const AChecksum : String);
var
  LData : TVTGdata;
begin
  if (Length(AParts) > 0) then
    LData.Command := AParts[0]
  else
    LData.Command := '';
  if (Length(AParts) > 1) then
    LData.TrackDegrees1 := AParts[1]
  else
    LData.TrackDegrees1 := '';
  if (Length(AParts) > 2) then
    LData.True := AParts[2]
  else
    LData.True := '';
  if (Length(AParts) > 3) then
    LData.TrackDegrees2 := AParts[3]
  else
    LData.TrackDegrees2 := '';
  if (Length(AParts) > 4) then
    LData.Magnetic := AParts[4]
  else
    LData.Magnetic := '';
  if (Length(AParts) > 5) then
    LData.SpeedKnots := AParts[5]
  else
    LData.SpeedKnots := '';
  if (Length(AParts) > 6) then
    LData.SpeedKnotsUnit := AParts[6]
  else
    LData.SpeedKnotsUnit := '';
  if (Length(AParts) > 7) then
    LData.SpeedKpH := AParts[7]
  else
    LData.SpeedKpH := '';
  if (Length(AParts) > 8) then
    LData.SpeedKpHUnit := AParts[8]
  else
    LData.SpeedKpHUnit := '';
  if (Length(AParts) > 9) then
    LData.ModeIndicator := AParts[9]
  else
    LData.ModeIndicator := '';

  LData.Checksum := AChecksum;
  if Assigned(FVTGdataEvent) then
    FVTGdataEvent(Self, ATalkerID, LData);
end;

procedure TGPSdata.ParseZDA(const ASender : TObject; const ATalkerID : String; const AParts : array of String; const AChecksum : String);
var
  LData : TZDAdata;
begin
  if (Length(AParts) > 0) then
    LData.Command := AParts[0]
  else
    LData.Command := '';
  if (Length(AParts) > 1) then
    LData.UTC := AParts[1]
  else
    LData.UTC := '';
  if (Length(AParts) > 2) then
    LData.Day := AParts[2]
  else
    LData.Day := '';
  if (Length(AParts) > 3) then
    LData.Month := AParts[3]
  else
    LData.Month := '';
  if (Length(AParts) > 4) then
    LData.Year := AParts[4]
  else
    LData.Year := '';
  if (Length(AParts) > 5) then
    LData.LocalZoneDescriptor := AParts[5]
  else
    LData.LocalZoneDescriptor := '';
  if (Length(AParts) > 6) then
    LData.LocalZoneMinutesDescriptor := AParts[6]
  else
    LData.LocalZoneMinutesDescriptor := '';

  LData.Checksum := AChecksum;
  if Assigned(FZDAdataEvent) then
    FZDAdataEvent(Self, ATalkerID, LData);
end;

procedure TGPSdata.ParseLine(const ASender : TObject; const ALine : String);
  function ChecksumCorrect(const AString : String) : Boolean;
    function HexToInt(AHex : String) : LongInt;
    const
      CChars : array [0..15] of Char = ('0', '1', '2', '3', '4', '5', '6', '7',
                                        '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
    var
      LIndexA : LongInt;
      LIndexB : LongInt;
      LValue  : Byte;
    begin
      Result := 0;

      AHex := AnsiUpperCase(AHex);
      for LIndexA := 1 to Length(AHex) do
      begin
        LValue := 0;
        for LIndexB := Low(CChars) to High(CChars) do
        begin
          if (AHex[LIndexA] = CChars[LIndexB]) then
          begin
            LValue := LIndexB;

            Break;
          end;
        end;

        Result := Result * Length(CChars) + LValue;
      end;
    end;
  const
    CStart = '$';
    CStop  = '*';
  var
    LChecksum   : Byte;
    LCheckValue : Byte;
    LIndex      : LongInt;
    LStartPos   : LongInt;
    LStopPos    : LongInt;
  begin
    Result := false;

    LCheckValue := 0;
    LStartPos   := Pos(CStart, AString);
    LStopPos    := Pos(CStop, AString);
    if ((LStartPos > 0) and (LStopPos > 0) and (LStopPos > LStartPos)) then
    begin
      for LIndex := Succ(LStartPos) to Pred(LStopPos) do
        LCheckValue := LCheckValue xor Ord(AString[LIndex]);
      LChecksum := HexToInt(Copy(AString, Succ(LStopPos), Length(AString) - LStopPos));

      Result := (LCheckValue = LChecksum);
    end;
  end;
const
  CChecksum      = '*';
  CDivider       = ',';
  CStartSequence = '$--';
var
  LChecksum      : String;
  LIdent         : String;
  LIndex         : LongInt;
  LLine          : String;
  LParts         : array of String;
  LTalkerID      : String;
  LWrongChecksum : Boolean;
begin
  LTalkerID := '';

  if Assigned(FBeforeSplitLineEvent) then
    FBeforeSplitLineEvent(Self, ALine);

  LWrongChecksum := false;
  if (FValidateChecksum and (Pos(CChecksum, ALine) > 0)) then
  begin
    LWrongChecksum := not(ChecksumCorrect(ALine));
    if LWrongChecksum then
    begin
      if Assigned(FWrongChecksumEvent) then
        FWrongChecksumEvent(Self, ALine);
    end;
  end;

  if (not(LWrongChecksum) or ProceedWithWrongChecksum) then
  begin
    LLine := ALine;
    while (Pos(CDivider, LLine) > 0) do
    begin
      SetLength(LParts, Succ(Length(LParts)));
      LParts[High(LParts)] := Copy(LLine, 1, Pred(Pos(CDivider, LLine)));
      Delete(LLine, 1, Pos(CDivider, LLine));
    end;

    if (Length(LLine) > 0) then
    begin
      if (Pos(CChecksum, LLine) > 0) then
      begin
        SetLength(LParts, Succ(Length(LParts)));
        LParts[High(LParts)] := Copy(LLine, 1, Pred(Pos(CChecksum, LLine)));
        Delete(LLine, 1, Pos(CChecksum, LLine));

        LChecksum := LLine;
      end;
    end;

    if Assigned(FAfterSplitLineEvent) then
      FAfterSplitLineEvent(Self, LTalkerID, LParts, LChecksum);

    if (Length(LParts) > 0) then
    begin
      LIdent := LParts[0];
      if (Length(LIdent) > Length(CStartSequence)) then
      begin
        if (LIdent[1] = CStartSequence[1]) then
        begin
          LTalkerID := Copy(LIdent, 2, Pred(Length(CStartSequence)));

          LIdent := Copy(LIdent, Succ(Length(CStartSequence)),
                         Length(LIdent) - Length(CStartSequence));

          LIdent := AnsiUpperCase(Trim(LIdent));
          for LIndex := 0 to Pred(Length(FCommandMethods)) do
          begin
            if (LIdent = FCommandMethods[LIndex].Command) then
            begin
              FCommandMethods[LIndex].Method(ASender, LTalkerID, LParts, LChecksum);

              Break;
            end;
          end;
        end
        else
        begin
          if Assigned(FParseErrorEvent) then
            FParseErrorEvent(Self, LTalkerID, LParts, LCheckSum);
        end;
      end
      else
      begin
        if Assigned(FParseErrorEvent) then
          FParseErrorEvent(Self, LTalkerID, LParts, LChecksum);
      end;
    end;
  end;
end;

procedure TGPSdata.SetCOMport(const AValue : TCOMport);
begin
  FCOMport := AValue;
  if (FCOMport <> nil) then
  begin
    FCOMport.OnReadLine := ParseLine;
    FCOMport.Threaded   := true;
  end;
end;

constructor TGPSdata.Create;
begin
  inherited Create;

  FCOMport                  := nil;
  FProceedWithWrongChecksum := false;
  FValidateChecksum         := true;

  OnAfterSplitLine  := nil;
  OnBeforeSplitLine := nil;
  OnGGAdata         := nil;
  OnGLLdata         := nil;
  OnGSAdata         := nil;
  OnGSVData         := nil;
  OnInitInput       := nil;
  OnInitOutput      := nil;
  OnParseError      := nil;
  OnRMCdata         := nil;
  OnVTGdata         := nil;
  OnWrongChecksum   := nil;
  OnZDAdata         := nil;

  SetLength(FCommandMethods, 7);
  FCommandMethods[0].Command := 'GGA';
  FCommandMethods[0].Method  := ParseGGA;
  FCommandMethods[1].Command := 'GLL';
  FCommandMethods[1].Method  := ParseGLL;
  FCommandMethods[2].Command := 'GSA';
  FCommandMethods[2].Method  := ParseGSA;
  FCommandMethods[3].Command := 'GSV';
  FCommandMethods[3].Method  := ParseGSV;
  FCommandMethods[4].Command := 'RMC';
  FCommandMethods[4].Method  := ParseRMC;
  FCommandMethods[5].Command := 'VTG';
  FCommandMethods[5].Method  := ParseVTG;
  FCommandMethods[5].Command := 'ZDA';
  FCommandMethods[5].Method  := ParseZDA;
end;

destructor TGPSdata.Destroy;
begin
  FCOMport := nil;

  inherited Destroy;
end;

function TGPSdata.InitEricssonF3507g : Boolean;
  function NextLine : String;
  begin
    repeat
      Result := AnsiUpperCase(Trim(FCOMport.ReadLine));
    until (Result <> '');
  end;
const
  CCommandA = 'AT+CFUN=1';
  CCommandB = 'AT*E2GPSCTL=1,10,1';
  CCommandC = 'AT*E2GPSNPD';

  CResponseA = '+PACSP0';
  CResponseB = 'OK';
  CResponseC = 'GPGGA';
var
  LNextLine : String;
begin
  Result := false;

  if (FCOMport <> nil) then
  begin
    FCOMport.Threaded := false;
    try
      if FCOMport.PurgeBuffers then
      begin
        if Assigned(FInitOutputEvent) then
          FInitOutputEvent(Self, CCommandA);

        Result := FCOMport.WriteLine(CCommandA);
        if Result then
        begin
          LNextLine := NextLine;
          if Assigned(FInitInputEvent) then
            FInitInputEvent(Self, LNextLine);

          Result := (Pos(CResponseA, LNextLine) = 1);
          if Result then
          begin
            if Assigned(FInitOutputEvent) then
              FInitOutputEvent(Self, CCommandB);

            Result := FCOMport.WriteLine(CCommandB);
            if Result then
            begin
              LNextLine := NextLine;
              if Assigned(FInitInputEvent) then
                FInitInputEvent(Self, LNextLine);

              Result := (Pos(CResponseB, LNextLine) = 1);
              if Result then
              begin
                if Assigned(FInitOutputEvent) then
                  FInitOutputEvent(Self, CCommandC);

                Result := FCOMport.WriteLine(CCommandC);
                if Result then
                begin
                  LNextLine := NextLine;
                  if Assigned(FInitInputEvent) then
                    FInitInputEvent(Self, LNextLine);

                  Result := (Pos(CResponseC, LNextLine) = 1);
                end;
              end;
            end;
          end;
        end;
      end;
    finally
      FCOMport.Threaded := true;
    end;
  end;
end;

class function TGPSdata.DirectionToDescription(ADirection : String) : String;
const
  CDirection : array [0..3] of TStringStringRecord = ((Short : 'E'; Long : 'East'),
                                                      (Short : 'N'; Long : 'North'),
                                                      (Short : 'S'; Long : 'South'),
                                                      (Short : 'W'; Long : 'West'));
var
  LIndex : LongInt;
begin
  Result := CUnknown;

  ADirection := AnsiUpperCase(Trim(ADirection));
  for LIndex := 0 to Pred(Length(CDirection)) do
  begin
    if (ADirection = CDirection[LIndex].Short) then
    begin
      Result := CDirection[LIndex].Long;

      Break;
    end;
  end;
end;

class function TGPSdata.FAAModeIndicatorToDescription(AFAAModeIndicator : String) : String;
const
  CMode : array [0..5] of TStringStringRecord = ((Short : 'A'; Long : 'Autonomous mode'),
                                                 (Short : 'D'; Long : 'Differential Mode'),
                                                 (Short : 'E'; Long : 'Estimated (dead-reckoning) mode'),
                                                 (Short : 'M'; Long : 'Manual Input Mode'),
                                                 (Short : 'S'; Long : 'Simulated Mode'),
                                                 (Short : 'N'; Long : 'Data Not Valid'));
var
  LIndex : LongInt;
begin
  Result := CUnknown;

  AFAAModeIndicator := AnsiUpperCase(Trim(AFAAModeIndicator));
  for LIndex := 0 to Pred(Length(AFAAModeIndicator)) do
  begin
    if (AFAAModeIndicator = CMode[LIndex].Short) then
    begin
      Result := CMode[LIndex].Long;

      Break;
    end;
  end;
end;

class function TGPSdata.GPSQualityIndicatorToDescription(AGPSQualityIndicator : String) : String;
const
  CQuality : array [0..8] of TStringStringRecord = ((Short : '0'; Long : 'fix not available'),
                                                    (Short : '1'; Long : 'GPS fix'),
                                                    (Short : '2'; Long : 'Differential GPS fix'),
                                                    (Short : '3'; Long : 'PPS fix'),
                                                    (Short : '4'; Long : 'Real Time Kinematic'),
                                                    (Short : '5'; Long : 'Float RTK'),
                                                    (Short : '6'; Long : 'estimated (dead reckoning)'),
                                                    (Short : '7'; Long : 'Manual input mode'),
                                                    (Short : '8'; Long : 'Simulation mode'));
var
  LIndex : LongInt;
begin
  Result := CUnknown;

  AGPSQualityIndicator := AnsiUpperCase(Trim(AGPSQualityIndicator));
  for LIndex := 0 to Pred(Length(CQuality)) do
  begin
    if (AGPSQualityIndicator = CQuality[LIndex].Short) then
    begin
      Result := CQuality[LIndex].Long;

      Break;
    end;
  end;
end;

class function TGPSdata.ModeToDescription(AMode : String) : String;
const
  CMode : array [0..2] of TStringStringRecord = ((Short : '1'; Long : 'no fix'),
                                                 (Short : '2'; Long : '2D fix'),
                                                 (Short : '3'; Long : '3D fix'));
var
  LIndex : LongInt;
begin
  Result := CUnknown;

  AMode := AnsiUpperCase(Trim(AMode));
  for LIndex := 0 to Pred(Length(CMode)) do
  begin
    if (AMode = CMode[LIndex].Short) then
    begin
      Result := CMode[LIndex].Long;

      Break;
    end;
  end;
end;

class function TGPSdata.SelectionModeToDescription(ASelectionMode : String) : String;
const
  CSelection : array [0..1] of TStringStringRecord = ((Short : 'A'; Long : 'Automatic, 3D/2D'),
                                                      (Short : 'M'; Long : 'Manual, forced to operate in 2D or 3D'));
var
  LIndex : LongInt;
begin
  Result := CUnknown;

  ASelectionMode := AnsiUpperCase(Trim(ASelectionMode));
  for LIndex := 0 to Pred(Length(CSelection)) do
  begin
    if (ASelectionMode = CSelection[LIndex].Short) then
    begin
      Result := CSelection[LIndex].Long;

      Break;
    end;
  end;
end;

class function TGPSdata.StatusToDescription(AStatus : String) : String;
const
  CStatus : array [0..1] of TStringStringRecord = ((Short : 'A'; Long : 'Data Valid'),
                                                   (Short : 'V'; Long : 'Data Invalid'));
var
  LIndex : LongInt;
begin
  Result := CUnknown;

  AStatus := AnsiUpperCase(Trim(AStatus));
  for LIndex := 0 to Pred(Length(CStatus)) do
  begin
    if (AStatus = CStatus[LIndex].Short) then
    begin
      Result := CStatus[LIndex].Long;

      Break;
    end;
  end;
end;

class function TGPSdata.TalkerIDToDescription(ATalkerID : String) : String;
const
  CTalker : array [0..47] of TStringStringRecord = ((Short : 'AG'; Long : 'Autopilot - General'),
                                                    (Short : 'AP'; Long : 'Autopilot - Magnetic'),
                                                    (Short : 'CC'; Long : 'Computer - Programmed Calculator (outdated)'),
                                                    (Short : 'CD'; Long : 'Communications - Digital Selective Calling (DSC)'),
                                                    (Short : 'CM'; Long : 'Computer - Memory Data (outdated)'),
                                                    (Short : 'CS'; Long : 'Communications - Satellite'),
                                                    (Short : 'CT'; Long : 'Communications - Radio-Telephone (MF/HF)'),
                                                    (Short : 'CV'; Long : 'Communications - Radio-Telephone (VHF)'),
                                                    (Short : 'CX'; Long : 'Communications - Scanning Receiver'),
                                                    (Short : 'DE'; Long : 'DECCA Navigation (outdated)'),
                                                    (Short : 'DF'; Long : 'Direction Finder'),
                                                    (Short : 'EC'; Long : 'Electronic Chart Display & Information System (ECDIS)'),
                                                    (Short : 'EP'; Long : 'Emergency Position Indicating Beacon (EPIRB)'),
                                                    (Short : 'ER'; Long : 'Engine Room Monitoring Systems'),
                                                    (Short : 'GP'; Long : 'Global Positioning System (GPS)'),
                                                    (Short : 'HC'; Long : 'Heading - Magnetic Compass'),
                                                    (Short : 'HE'; Long : 'Heading - North Seeking Gyro'),
                                                    (Short : 'HN'; Long : 'Heading - Non North Seeking Gyro'),
                                                    (Short : 'II'; Long : 'Integrated Instrumentation'),
                                                    (Short : 'IN'; Long : 'Integrated Navigation'),
                                                    (Short : 'LA'; Long : 'Loran A (outdated)'),
                                                    (Short : 'LC'; Long : 'Loran C'),
                                                    (Short : 'MP'; Long : 'Microwave Positioning System (outdated)'),
                                                    (Short : 'OM'; Long : 'OMEGA Navigation System (outdated)'),
                                                    (Short : 'OS'; Long : 'Distress Alarm System (outdated)'),
                                                    (Short : 'RA'; Long : 'RADAR and/or ARPA'),
                                                    (Short : 'SD'; Long : 'Sounder, Depth'),
                                                    (Short : 'SN'; Long : 'Electronic Positioning System, other/general'),
                                                    (Short : 'SS'; Long : 'Sounder, Scanning'),
                                                    (Short : 'TI'; Long : 'Turn Rate Indicator'),
                                                    (Short : 'TR'; Long : 'TRANSIT Navigation System'),
                                                    (Short : 'VD'; Long : 'Velocity Sensor, Doppler, other/general'),
                                                    (Short : 'DM'; Long : 'Velocity Sensor, Speed Log, Water, Magnetic'),
                                                    (Short : 'VW'; Long : 'Velocity Sensor, Speed Log, Water, Mechanical'),
                                                    (Short : 'WI'; Long : 'Weather Instruments'),
                                                    (Short : 'YC'; Long : 'Transducer - Temperature (outdated)'),
                                                    (Short : 'YD'; Long : 'Transducer - Displacement, Angular or Linear (outdated)'),
                                                    (Short : 'YF'; Long : 'Transducer - Frequency (outdated)'),
                                                    (Short : 'YL'; Long : 'Transducer - Level (outdated)'),
                                                    (Short : 'YP'; Long : 'Transducer - Pressure (outdated)'),
                                                    (Short : 'YR'; Long : 'Transducer - Flow Rate (outdated)'),
                                                    (Short : 'YT'; Long : 'Transducer - Tachometer (outdated)'),
                                                    (Short : 'YV'; Long : 'Transducer - Volume (outdated)'),
                                                    (Short : 'YX'; Long : 'Transducer'),
                                                    (Short : 'ZA'; Long : 'Timekeeper - Atomic Clock'),
                                                    (Short : 'ZC'; Long : 'Timekeeper - Chronometer'),
                                                    (Short : 'ZQ'; Long : 'Timekeeper - Quartz'),
                                                    (Short : 'ZV'; Long : 'Timekeeper - Radio Update, WWV or WWVH'));
var
  LIndex : LongInt;
begin
  Result := CUnknown;

  ATalkerID := AnsiUpperCase(Trim(ATalkerID));
  for LIndex := 0 to Pred(Length(CTalker)) do
  begin
    if (ATalkerID = CTalker[LIndex].Short) then
    begin
      Result := CTalker[LIndex].Long;

      Break;
    end;
  end;
end;

class function TGPSdata.DateStringToDate(ADateString : String) : TDate;
var
  LDay   : LongInt;
  LMonth : LongInt;
  LYear  : LongInt;
begin
  Result := 0;

  ADateString := AnsiLowerCase(Trim(ADateString));
  if TryStrToInt(Copy(ADateString, 1, 2), LDay) then
  begin
    if TryStrToInt(Copy(ADateString, 3, 2), LMonth) then
    begin
      if TryStrToInt(Copy(ADateString, 5, 2), LYear) then
        Result := EncodeDate(LYear, LMonth, LDay);
    end;
  end;
end;

class function TGPSdata.TimeStringToTime(ATimeString : String) : TTime;
var
  LHour    : LongInt;
  LMinute  : LongInt;
  LMSecond : LongInt;
  LSecond  : LongInt;
begin
  Result := 0;

  ATimeString := AnsiLowerCase(Trim(ATimeString));
  if TryStrToInt(Copy(ATimeString, 1, 2), LHour) then
  begin
    if TryStrToInt(Copy(ATimeString, 3, 2), LMinute) then
    begin
      if TryStrToInt(Copy(ATimeString, 5, 2), LSecond) then
      begin
        if TryStrToInt(Copy(ATimeString, 8, 3), LMSecond) then
          Result := EncodeTime(LHour, LMinute, LSecond, LMSecond);
      end;
    end;
  end;
end;

end.
