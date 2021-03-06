/* T1008300 SAS Forum: Parsing json data ( WPS/PROC-R)

  WORKING CODE (This should work for many JSON stuctures?)
  WPS/PROC-R

     jsn <- as.data.frame(fromJSON(paste(readLines("d:/json/psc5.json"), collapse="")));
     jsnxpo<-cbind(names(jsn),t(jsn));


see
https://communities.sas.com/t5/General-SAS-Programming/Parsing-json-data/m-p/399736

JSON text file
see
https://goo.gl/qRmvF8
https://communities.sas.com/t5/General-SAS-Programming/Parsing-json-data/m-p/399736?attachment-id=12541



HAVE  d:/json/psc5.json  (download from link)
==============================================

{"company_number":"10869580",
   "data":
      {"etag":"f327a09d5a3a08af72b03211f3a2e148814d75dd"
      ,"kind":"persons-with-significant-control-statement"
      ,"links": {"self":"/company/10869580/persons-with-significant-control-statements/JZsKO5aylMYjxLssqF12Cyy0eFg"}
      ,"notified_on":"2017-07-17"
      ,"ceased_on":"2016-04-07"
      ,"statement":"no-individual-or-entity-with-signficant-control"}}
... repeating


WANT  SAS dataset WORK.WANT
============================

WORK.WANT Middle Observation(57 ) of want - Total Obs 114
(ran through utl_optlen to

   -- CHARACTER --

  Variable name    Type   Length   Trucated value

  COMPANY_NUMBER      C    8       07358636
  DATAETAG            C    40      d528362596f8defe...
  DATAKIND            C    42      persons-with-sig..
  DATASELF            C    89      /company/0735863..
  DATANOTIFIED_ON     C    10      2016-04-06
  DATASTATEMENT       C    47      no-individual-or..
  DATACEASED_ON       C    10      2016-04-07
  TOTOBS              C    16      114


FIRST TWO OBS


   COMPANY_
    NUMBER                     DATAETAG                                     DATAKIND

   10869580    f327a09d5a3a08af72b03211f3a2e148814d75dd    persons-with-significant-control-statement
   10869582    83f75b47516bb1c7bac875c7f97134cb51711f2d    persons-with-significant-control-statement
   ...
                                                                                            DATANOTIFIED_
   DATASELF                                                                                       ON

   /company/10869580/persons-with-significant-control-statements/JZsKO5aylMYjxLssqF12Cyy0eFg   2017-07-17
   /company/10869582/persons-with-significant-control-statements/5xQ7ZCMaLDHOX6G5PG1b9vOZd34   2017-07-17

   DATASTATEMENT

    no-individual-or-entity-with-signficant-control
    no-individual-or-entity-with-signficant-control


   DATASTATEMENT                                     DATACEASED_
                                                         ON

   no-individual-or-entity-with-signficant-control   2016-04-07
   no-individual-or-entity-with-signficant-control   2016-04-07

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

  see
  https://goo.gl/qRmvF8
  https://communities.sas.com/t5/General-SAS-Programming/Parsing-json-data/m-p/399736?attachment-id=12541

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

%utl_submit_wps64(resolve('
options set=R_HOME "C:/Program Files/R/R-3.4.0";
libname wrk "%sysfunc(pathname(work))";
proc r;
submit;
library("rjson");
jsn <- as.data.frame(fromJSON(paste(readLines("d:/json/psc5.json"), collapse="")));
jsnxpo<-cbind(names(jsn),t(jsn));
endsubmit;
import r=jsnxpo data=wrk.simpler;
run;quit;
'));

/* output from R
Up to 40 obs from simpler total obs=679

  V1                    V2

  company_number        10869580
  data.etag             f327a09d5a3a08af72b03211f3a2e148814d75dd
  data.kind             persons-with-significant-control-statement
  data.self             /company/10869580/persons-with-significant-control-statements/JZsKO5aylMYjxLssqF12Cyy0eFg
  data.notified_on      2017-07-17
  data.statement        no-individual-or-entity-with-signficant-control

  company_number.1      10869582
  data.etag.1           83f75b47516bb1c7bac875c7f97134cb51711f2d
  data.kind.1           persons-with-significant-control-statement
  data.self.1           /company/10869582/persons-with-significant-control-statements/5xQ7ZCMaLDHOX6G5PG1b9vOZd34
  data.notified_on.1    2017-07-17
  data.statement.1      no-individual-or-entity-with-signficant-control
...
*/

*                _
 _ __   ___  ___| |_   ___  __ _ ___
| '_ \ / _ \/ __| __| / __|/ _` / __|
| |_) | (_) \__ \ |_  \__ \ (_| \__ \
| .__/ \___/|___/\__| |___/\__,_|___/
|_|
;


data addgrp/view=addgrp;;
   retain grp 0;
   set simpler;
   if index(v1,'company_number')>0 then grp=grp+1;
   v1=compress(v1,'.','dd');
run;quit;

proc transpose data=addgrp out=want(drop=grp _name_);
by grp;
var v2;
id v1;
run;quit;

* optimize variable lengths;
%utl_optlen(inp=want,out=want)


