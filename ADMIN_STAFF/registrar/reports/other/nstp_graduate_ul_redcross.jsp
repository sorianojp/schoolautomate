<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript">
function PrintPg() {
}

function UpdateSpecialized(strInputFieldName, strUserIndex){
	var varSLNo = prompt("Please enter new Specialization : ","");
	if(varSLNo == null || varSLNo == 0)
		return;
	this.dynamicUpdate(strInputFieldName,varSLNo,strUserIndex,"1");
}


function UpdateSLNumber(strInputFieldName, strUserIndex) {
	var varSLNo = prompt("Please enter new SL Number : ","");
	if(varSLNo == null || varSLNo == 0)
		return;
	this.dynamicUpdate(strInputFieldName,varSLNo,strUserIndex,"0");
}
function dynamicUpdate(strInputFieldName, strInputVal, strUserIndex,strSpecialized) {
		var objCOA=document.getElementById(strInputFieldName);

		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result found
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=201&sl_no="+
			escape(strInputVal)+"&user_index="+strUserIndex+"&spl="+strSpecialized;
		this.processRequest(strURL);
}
function PrintPg() {
	if(!confirm("Click OK to print this page"))
		return;

	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	
	window.print();//called to remove rows, make bk white and call print.
}
</script>
<body >
<form name="form_" action="./nstp_graduate_ul_redcross.jsp" method="post">
<%@ page language="java" import="utility.*,enrollment.ReportRegistrar,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	boolean bolShowChed = WI.fillTextValue("ched").equals("1");
	try	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

Vector vRetResult = null;
ReportRegistrar rR = new ReportRegistrar();

if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = rR.nstpGraduate(dbOP, request);
	if(vRetResult == null)
		strErrMsg = rR.getErrMsg();
}
boolean bolHideSpecializedCol = WI.fillTextValue("hide_spcol").equals("checked");
int iIndexOf = 0;

if(strErrMsg != null){%>
<table width="100%" border="0" >
    <tr>
      <td width="100%" style="font-size:14px; font-weight:bold; color:#FF0000"><div align="center"><%=strErrMsg%></div></td>
    </tr>
</table>
<%}

String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester","5th Semester"};
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr>
      <td width="3%"></td>
      <td width="13%">SY/Term</td>
      <td width="61%">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>
	  <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
if(strTemp == null)
	strTemp = "";
%>
        <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
       &nbsp; - &nbsp;
	   <select name="semester" onChange="ReloadPage();">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select>
	   &nbsp;&nbsp;&nbsp;
	   <input name="Submit" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" value="Proceed">
	   <select name="no_of_stud" style="font-size:9px">
<%
int iDefVal = Integer.parseInt(WI.getStrValue(WI.fillTextValue("no_of_stud"), "15"));
for(int i = 15; i < 50; ++i){
	if(i == iDefVal)
		strTemp = " selected";
	else
		strTemp = "";
%>
         <option value="<%=i%>"<%=strTemp%>><%=i%></option>
<%}%>
       </select></td>
	  <td width="23%"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a> <font size="1">Print Report</font></td>
    </tr>
    <tr>
        <td></td>
        <td height="25">Date</td>
        <td>
		<input name="date_" type="text" size="10" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_');" title="Click to select date" 
			onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../../images/calendar_new.gif" border="0"></a>		</td>
        <td>&nbsp;</td>
    </tr>
    <tr>
        <td></td>
        <td height="25">Venue</td>
        <td><textarea name="venue_" rows="2" cols="40"><%=WI.fillTextValue("venue_")%></textarea></td>
        <td>&nbsp;</td>
    </tr>
    <tr>
        <td></td>
        <td height="25">Trainer/s</td>
        <td><textarea name="trainer_" rows="2" cols="40"><%=WI.fillTextValue("trainer_")%></textarea>
		<font size="1">Please use comma( , ) to separate names</font>
		</td>
        <td>&nbsp;</td>
    </tr>
    <tr>
        <td></td>
        <td height="25">NSTP Coordinator</td>
        <td>
		<input name="nstp_coordinator" type="text" size="30" value="<%=WI.fillTextValue("nstp_coordinator")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
		</td>
        <td>&nbsp;</td>
    </tr>
 </table>
<%
String strCourseCode = null;
String strSpecializedDim = null;
Vector vStudCourseInfo   = rR.getInternshipInfo();//i save course and specialized_dim there.. 

if(vRetResult != null && vRetResult.size() > 0) {
boolean bolShowPageBreak = false;

int iNoOfStudPerPage = Integer.parseInt(WI.fillTextValue("no_of_stud"));
int iStudPrinted = 0;
int iTotalStud = vRetResult.size()/12;
int iStudCount = 1;
int iTotalPageCount = iTotalStud/iNoOfStudPerPage;
if(iTotalStud %iNoOfStudPerPage > 0)
	++iTotalPageCount;
int iPageCount = 1;
String strDispPageNo = null;


Vector vEMAIL = new Vector();
strTemp = " select id_number , EMAIL, CONTACT_MOB_NO "+
	" from STUD_CURRICULUM_HIST  "+
	" join INFO_PERSONAL on (INFO_PERSONAL.USER_INDEX = STUD_CURRICULUM_HIST.USER_INDEX) "+
	" join user_table on (user_table.user_index = stud_curriculum_hist.user_index)"+
	" where STUD_CURRICULUM_HIST.IS_VALID= 1 and SY_FROM ="+WI.fillTextValue("sy_from")+" and SEMESTER = "+WI.fillTextValue("semester")+
	" and COURSE_INDEX > 0 and EMAIL is not null ";
java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
while(rs.next()){
	vEMAIL.addElement(rs.getString(1));
	vEMAIL.addElement(rs.getString(2));
	vEMAIL.addElement(rs.getString(3));
}rs.close();



for(int i=0; i<vRetResult.size();){ // start of the biggest for loop
strDispPageNo = Integer.toString(iPageCount)+" of "+Integer.toString(iTotalPageCount);
++iPageCount;
iStudPrinted = 0;


%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="100%"><div align="center">
	  	  COMMISSION ON HIGHER EDUCATION REGION I <br>
NATIONAL SERVICE TRAINING PROGRAM<br>
CIVIC WELFARE TRAINING SERVICE<br>
<br>

<%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
		  <br><br>&nbsp;
      </div></td>
    </tr>
    <tr>
      <td height="30"><div align="center">
        <strong>PHILIPPINE RED CROSS<br>BASIC LEADERSHIP AND LIFE SUPPORT TRAINING<br></strong>
		DATE : <u><%=WI.fillTextValue("date_")%></u> &nbsp; VENUE : <u><%=WI.fillTextValue("venue_")%></u>
		</div></td>
    </tr>
</table>

<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr >
    <td height="18" valign="top">&nbsp;</td>
    <td height="18" valign="top">&nbsp;</td>
  </tr>
  <tr >
    <td height="20"  colspan="2">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC" class="thinborder">

    <tr>
      <!--
      <td width="10%" height="27" align="center" class="thinborder"><strong>Serial Number </strong></td>
-->
      <td height="22" width="25%" align="center" class="thinborder"><strong>Name</strong></td>
      <td width="7%" align="center" class="thinborder"><strong>Gender</strong></td>
      <td width="13%" align="center" class="thinborder"><strong>Course</strong></td>
    <td width="12%" align="center" class="thinborder"><strong>Birth Date </strong></td>
    <td width="4%" align="center" class="thinborder"><strong>Age</strong></td>
    <td width="27%" align="center" class="thinborder" style="font-size:11px; font-weight:bold">Address</td>
    <td width="12%" align="center" class="thinborder" style="font-size:11px; font-weight:bold">Contact #</td>


    <td width="12%" align="center" class="thinborder" style="font-size:11px; font-weight:bold">Email Address</td>
    </tr>
  <%
for(;i<vRetResult.size();){//System.out.println("i : "+i);
if(iStudPrinted++ == iNoOfStudPerPage) {
	bolShowPageBreak = true;
	break;
}
else {
	bolShowPageBreak = false;
}

strCourseCode = null;
strSpecializedDim = null;

iIndexOf = vStudCourseInfo.indexOf(vRetResult.elementAt(i+1));
if(iIndexOf > -1) {
	strCourseCode     = (String)vStudCourseInfo.elementAt(iIndexOf + 1);
	strSpecializedDim = (String)vStudCourseInfo.elementAt(iIndexOf + 2);
	
	vStudCourseInfo.remove(iIndexOf);vStudCourseInfo.remove(iIndexOf);vStudCourseInfo.remove(iIndexOf);
}
%>
  <tr>
    <!--
    <td height="25" align="center" class="thinborder"><label id="sl_no_<%=iStudCount - 1%>" onClick="UpdateSLNumber('sl_no_<%=iStudCount - 1%>','<%=vRetResult.elementAt(i + 8)%>')"><%=WI.getStrValue((String)vRetResult.elementAt(i)," &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")%></label></td>
-->
    <td height="18" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
    <td class="thinborder" align="center"><%=(String)vRetResult.elementAt(i+5)%></td>
    <td class="thinborder" align="center"><%=WI.getStrValue(strCourseCode)%></td>
    <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3), "&nbsp;")%></td>
    <td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+4), "&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+6), "&nbsp;")%></td>
	<%
	strErrMsg = "&nbsp;";
	strTemp = "&nbsp;";
	iIndexOf = vEMAIL.indexOf((String)vRetResult.elementAt(i+1));
	if(iIndexOf > -1){
		strTemp = (String)vEMAIL.elementAt(iIndexOf + 1);
		strErrMsg = (String)vEMAIL.elementAt(iIndexOf + 2);
	}
		
	%>
    <td class="thinborder" align="center"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    
  </tr>
  <%
i = i+12;
}%>
</table>

<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="75%" height="40" valign="top">&nbsp;</td>
    <td width="24%" valign="top"><div align="right">page <strong><%=strDispPageNo%></strong></div></td>
  </tr>
  <tr>
    <td height="18" colspan="2" valign="top">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<tr align="center" valign="bottom">
				<td width="12%">Prepared by:</td>
				<td width="25%" class="thinborderBOTTOM">&nbsp;<%=WI.fillTextValue("nstp_coordinator").toUpperCase()%></td>
				<td width="1%"></td>
				<td width="6%">&nbsp;</td>
				<%
				strTemp = null;
				Vector vTemp = CommonUtil.convertCSVToVector(WI.fillTextValue("trainer_"));
				if(vTemp != null && vTemp.size() > 0){
					for(int x = 0; x < vTemp.size(); ++x){
						if(strTemp == null)
							strTemp = (String)vTemp.elementAt(x);
						else
							strTemp += "<br>" + (String)vTemp.elementAt(x);
					}
				}	
				%>
				<td width="20%" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				<td width="1%"></td>
				<td width="12%">Approved by:</td>
				<td width="22%" class="thinborderBOTTOM">&nbsp;<%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"Director/NSTP Coordinator",7)).toUpperCase()%></td>
			</tr>
			<tr align="center">
			  <td>&nbsp;</td>
			  <td>ULES IN-HOUSE COORDINATO</td>
			  <td></td>
			  <td>&nbsp;</td>
			  <td>Name of Trainer/s</td>
			  <td></td>
			  <td>&nbsp;</td>
			  <td>NSTP Coordinator</td>
		  </tr>
		</table>	</td>
    </tr>
</table>
<!-- introduce page break here -->
<% if(bolShowPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//do not print for last page.

 }//end of for loop..

}//end of if(vRetResult != null . %>


<input type="hidden" value="<%=WI.fillTextValue("ched")%>" name="ched">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
