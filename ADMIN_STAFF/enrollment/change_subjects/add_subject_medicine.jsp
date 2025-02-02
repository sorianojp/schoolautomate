<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
.messageBox {
		height: 250px; width:auto; overflow: auto; border: inset black 1px;
}

.nav {
     /**color: #000000;**/
     /**background-color: #FFFFFF;**/
	 font-weight:normal;
}
.nav-highlight {
     /**color: #0000FF;**/
     /**background-color: #FAFCDD;**/
     background-color:#BCDEDB;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}
function ReloadPage()
{
	document.chngsubject.submit();
}
function AddSubject()
{
	if(document.chngsubject.reason) {
		//must enter reason.. 
		var strReason = document.chngsubject.reason.value;
		if(strReason.length < 5) {
			alert("Please encode a valid reason");
			return;
		}	
	}
	document.chngsubject.addSubject.value="1";
	document.chngsubject.hide_save.src = "../../../images/blank.gif";
	ReloadPage();
}
function AddLoad(index,subLoad)
{
	//if there is no section schedule yet - do not let user select.
	if(eval('document.chngsubject.sec_index'+index+'.value.length') ==0)
	{
		alert("Please schedule first before selecting a subject.");
		eval("document.chngsubject.checkbox"+index+".checked=false");
		return;
	}

	if( eval("document.chngsubject.checkbox"+index+".checked") )
	{
		document.chngsubject.sub_load.value = eval(document.chngsubject.sub_load.value) + eval(subLoad);
		if( eval(document.chngsubject.sub_load.value) > eval(document.chngsubject.maxAllowedLoad.value))
		{
			alert("Student can't take more than allowed load <"+document.chngsubject.maxAllowedLoad.value+">.Please re-adjust load.");
			document.chngsubject.sub_load.value = eval(document.chngsubject.sub_load.value) - eval(subLoad);
			eval("document.chngsubject.checkbox"+index+".checked=false");
		}
	}
	else //subtract.
		document.chngsubject.sub_load.value = eval(document.chngsubject.sub_load.value) - eval(subLoad);


	if( eval(document.chngsubject.sub_load.value) < 0)
		document.chngsubject.sub_load.value = 0;

}
//set NO_CONFLICT parameter
function SetIsNoConflict(strIndex) {
	if( eval('document.chngsubject.no_conflict'+strIndex+'.checked') )
		eval('document.chngsubject.NO_CONFLICT'+strIndex+'.value=1');
	else
		eval('document.chngsubject.NO_CONFLICT'+strIndex+'.value=0');
}
function LoadPopup(secName, sectionIndex, strCurIndex, strSubIndex, strIndex) //curriculum index is different for all courses.
{
//this will check conflict with the schedule of other subjects taken. pass user id, all the sub_section_index,
//if check box is not checked - it is considered as not selected.
	var subSecList = "";
	var i = eval(document.chngsubject.maxDisplay.value)-eval(document.chngsubject.addSubCount.value);
	for(; i< document.chngsubject.maxDisplay.value; ++i)
	{
		if( eval('document.chngsubject.checkbox'+i+'.checked') )
		{//alert(eval('document.chngsubject.sec_index'+i+'.value'));
			if(subSecList.length ==0)
				subSecList =eval('document.chngsubject.sec_index'+i+'.value');
			else
				subSecList =subSecList+","+eval('document.chngsubject.sec_index'+i+'.value');
		}
	}

	if(subSecList.length == 0) subSecList = document.chngsubject.sub_sec_csv.value;
	else
		subSecList +=","+document.chngsubject.sub_sec_csv.value;

	var loadPg = "../advising/subject_schedule.jsp?form_name=chngsubject&cur_index="+strCurIndex+
		"&sub_index="+strSubIndex+"&sec_name="+secName+"&sec_index_name="+sectionIndex+
		"&syf="+document.chngsubject.sy_from.value+"&syt="+document.chngsubject.sy_to.value+"&semester="+document.chngsubject.semester.value+
		"&sec_index_list="+subSecList+"&course_index="+document.chngsubject.ci.value+
		"&major_index="+document.chngsubject.mi.value+"&degree_type="+
		document.chngsubject.degree_type.value+"&NO_CONFLICT="+
		eval('document.chngsubject.NO_CONFLICT'+strIndex+'.value')+"&line_number="+strIndex;

	//var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,screenX=200,screenY=300,scrollbars=yes,,toolbar=yes,location=yes,directories=yes,status=no,menubar=yes');
	var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,top=10,left=10,scrollbars=yes,,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateAddDropCount() {
	return;
	var obj = document.chngsubject.no_of_adddrop;
	if(!obj)
		return;
	if(document.chngsubject.no_of_adddrop_edited.value != '')
		return;
	
	var iCount = 0;
	for(var i = 0; i< document.chngsubject.maxDisplay.value; ++i) {
		if( eval('document.chngsubject.checkbox'+i+'.checked'))
			++iCount;
	}
	if(iCount > 0) 
		obj.value = iCount;

}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.EnrlAddDropSubject,enrollment.Advising,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String strStudID = WI.fillTextValue("stud_id");
	String strSubSecCSV = null;//this is the subject section already enrolled in CSV to check the conflict ;-)
	int iMaxDisplayed = 0;
	boolean bolFatalErr = false;

	int j=0; //this is the max display variable.
	String[] astrSchYrInfo = {WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester")};
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

	String strDegreeType = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-CHANGE OF SUBJECTS","change_subject_add.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","CHANGE OF SUBJECTS",request.getRemoteAddr(),
														"change_subject_add.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//I have to give an option to set do not check conflict incase user is super user.
boolean bolIsSuperUser = false;//comUtil.IsSuperUser(dbOP,(String)request.getSession(false).getAttribute("userId"));
//end of authenticaion code.

String strMaxAllowedLoad = "0"; // this is the first field of the vAdvisingList
String strOverLoadDetail = null;//Overload detail if there is any.

Vector vEnrolledList = new Vector();
Vector vStudInfo = new Vector();
Vector vAdviseList = new Vector();

Advising advising = new Advising();
EnrlAddDropSubject enrlAddDropSub = new EnrlAddDropSubject();
enrollment.FAFeeMaintenance FFM = new enrollment.FAFeeMaintenance();


if(astrSchYrInfo == null)//db error
{
	strErrMsg = dbOP.getErrMsg();
	bolFatalErr = true;
}
if(!bolFatalErr && strStudID.length() > 0)
{
	vStudInfo = enrlAddDropSub.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),strStudID,
                                    astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
	if(vStudInfo == null)
	{
		bolFatalErr = true;
		strErrMsg = enrlAddDropSub.getErrMsg();
	}
	if(!bolFatalErr)
	{
		Vector vMaxLoadDetail = advising.getMaxAllowedUnit(dbOP,strStudID,(String)vStudInfo.elementAt(5),(String)vStudInfo.elementAt(6),
			astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2],(String)vStudInfo.elementAt(7),
			(String)vStudInfo.elementAt(8));
		if(vMaxLoadDetail == null)
		{
			bolFatalErr = true;
			strErrMsg = advising.getErrMsg();
		}
		else
		{
			strMaxAllowedLoad = (String)vMaxLoadDetail.elementAt(0);
			if(vMaxLoadDetail.size() > 1)
				strOverLoadDetail = "Maximum load in curriculum for this sem "+(String)vMaxLoadDetail.elementAt(1)+
				" overloaded load "+(String)vMaxLoadDetail.elementAt(0)+" (approved on :"+(String)vMaxLoadDetail.elementAt(2)+")";
		}
	}
	//Withdraw subject if it is trigged.
	if(!bolFatalErr && WI.fillTextValue("addSubject").compareTo("1") ==0)
	{
		if(advising.checkScheduleBeforeSave(dbOP,request) != null)
		{
			//add the selected subjects here.
			if(enrlAddDropSub.addSubject(dbOP,request)) {
				dbOP.forceAutoCommitToTrue();
				if(WI.fillTextValue("no_charge").equals("1"))
					strErrMsg = "Subject/s added successfully.";
				else {
					if(!FFM.chargeAddDropFeeApplicable(dbOP, (String)vStudInfo.elementAt(0),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
						WI.fillTextValue("semester"), (String)vStudInfo.elementAt(4), (String)request.getSession(false).getAttribute("userIndex"), true, request)) {
						strErrMsg = "Subjects Added Successfully. But Add Charge Failed to post to ledger. Please manually post.";
					}
					else
						strErrMsg = "Subject/s added successfully.";
				}
//				strErrMsg = "Subject/s added successfully.";
			}
			else
			{
				strErrMsg = enrlAddDropSub.getErrMsg();
				bolFatalErr = true;
			}
		}
		else
		{
			bolFatalErr = true;
			strErrMsg =advising.getErrMsg();
		}
	}
	if(!bolFatalErr) // show enrolled list
	{
		vEnrolledList = enrlAddDropSub.getEnrolledList(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(9),
                                astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2],false,true);
		if(vEnrolledList ==null)
			strErrMsg = enrlAddDropSub.getErrMsg();
		vAdviseList = advising.getAdvisingListForOLDCOM(dbOP,strStudID,(String)vStudInfo.elementAt(5),(String)vStudInfo.elementAt(6),true,
					request.getParameter("sy_from"),request.getParameter("sy_to"), (String)vStudInfo.elementAt(7),
					(String)vStudInfo.elementAt(8),(String)vStudInfo.elementAt(4),request.getParameter("semester"));
		if(vAdviseList ==null)
			strErrMsg = advising.getErrMsg();

	}
}
if(vStudInfo != null && vStudInfo.size() > 0)
{
	strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",
                                       (String)vStudInfo.elementAt(5), "degree_type",
                                       " and is_valid=1 and is_del=0");

	if(strDegreeType == null)
		strErrMsg = "Error in getting course degree type.";
}


String strReadOnlyUnitToTake = "";
if(strSchCode.startsWith("UB"))
	strReadOnlyUnitToTake = " readonly='yes'";

String strInfo5 = (String)request.getSession(false).getAttribute("info5");
boolean bolReasonRequired = false;
if(strSchCode.startsWith("UPH") && strInfo5 != null)
	bolReasonRequired = true;
%>

<form action="./add_subject_medicine.jsp" method="post" name="chngsubject">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" >
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>:::: CHANGE
          OF SUBJECTS - ADD ::::</strong></font></strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%" height="25">Enter Student ID </td>
      <td width="26%" height="25"><b><%=WI.fillTextValue("stud_id")%></b> <input type="hidden" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>">
      </td>
      <td width="53%" height="25"><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a>
        click to refresh the page.</td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%" height="25">School Year/Term </td>
      <td height="25" colspan="2"> <b><%=WI.fillTextValue("sy_from")%></b> - <b><%=WI.fillTextValue("sy_to")%></b>
        &nbsp;&nbsp;&nbsp;&nbsp; <strong><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%></strong>
        <input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
        <input type="hidden" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>">
        <input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">
      </td>
    </tr>
  </table>
<% if(vStudInfo != null && vStudInfo.size() > 0 && !bolFatalErr){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td colspan="5" height="25"><hr size="1"></td>
    </tr>
    <tr >
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%" height="25">Student name </td>
      <td width="40%"> <strong><%=(String)vStudInfo.elementAt(1)%></strong>
	        <input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>">
	  </td>
      <td width="14%">Date approved </td>
      <td width="25%"><input name="apv_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("apv_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('chngsubject.apv_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Course/Major</td>
      <td height="25" colspan="3"><strong><%=(String)vStudInfo.elementAt(2)%>
        <%
		if(vStudInfo.elementAt(3) != null){%>
        / <%=(String)vStudInfo.elementAt(3)%>
        <%}%>
        </strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Year level</td>
      <td height="25" colspan="3"><strong><%=(String)vStudInfo.elementAt(4)%></strong>
	  <input type="hidden" name="year_level" value="<%=(String)vStudInfo.elementAt(4)%>"></td>
    </tr>
    <tr >
      <td height="25" colspan="5" bgcolor="#B9B292"><div align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">SUBJECTS
          ENROLLED</font></div></td>
    </tr>
<%if(strSchCode.startsWith("UC")){
strTemp = FFM.getAddDropFeeRef(dbOP, WI.fillTextValue("sy_from"), true);
if(strTemp != null) {
strTemp = "select amount from fa_oth_sch_fee where othsch_fee_index = "+strTemp;
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp != null)
	strTemp = CommonUtil.formatFloat(strTemp, true);
%>
    <tr>
      <td  height="25">&nbsp;</td>
      <td colspan="4" height="25" style="font-size:16px; font-weight:bold; color:#0000FF">Number of  Charge(s):
	    <input type="text" name="no_of_adddrop" size="3" value="1" <%if(!bolIsSuperUser && false){%>readonly="yes"<%}%> maxlength="2" style="font-weight:bold;font-size:18px; color:#0000FF;font-family:Verdana, Arial, Helvetica, sans-serif;" onKeyUp="document.chngsubject.no_of_adddrop_edited.value='1'">
	  x <%=strTemp%>
	  </td>
    </tr>
<%}
}
if(strOverLoadDetail != null){%>
    <tr>
      <td  height="25">&nbsp;</td>
      <td colspan="4" height="25"><font size="1">Overload detail : <%=strOverLoadDetail%></font></td>
    </tr>
<%}%>

    <tr >
      <td height="25">&nbsp;</td>
      <td  colspan="2" height="25">Maximum units the student can take : <strong><%=strMaxAllowedLoad%></strong></td>
      <td  colspan="2" height="25">Total student load :
<%
if(vEnrolledList != null && vEnrolledList.size() > 0)
	strTemp = (String)vEnrolledList.elementAt(0);
else
	strTemp = "0";
%>

<input type="text" name="sub_load" readonly="yes" size="5" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;" value="<%=strTemp%>"></td>
    </tr>
  </table>
<%if(vEnrolledList != null && vEnrolledList.size() > 0) {%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="19%" height="27" align="center"><font size="1"><strong>SUBJECT
        CODE</strong></font></td>
      <td width="33%" align="center"><font size="1"><strong>SUBJECT TITLE </strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>TOTAL UNITS</strong></font></td>
      <td width="13%" align="center"><font size="1"><strong>
	  <% if(!strSchCode.startsWith("CPU")){%>
	  SECTION <%}else{%> STUB CODE<%}%></strong></font></td>
      <td width="9%" align="center"><font size="1"><strong>SEC / ROOM #</strong></font></td>
      <td width="21%" align="center"><font size="1"><strong>SCHEDULE</strong></font></td>
    </tr>
    <%
 for(int i=1;i<vEnrolledList.size();++i,++j){
 if(strSubSecCSV == null)
 	strSubSecCSV = (String)vEnrolledList.elementAt(i+5);
 else
 	strSubSecCSV += ","+(String)vEnrolledList.elementAt(i+5);
 %>
    <tr>
      <td height="25"><%=(String)vEnrolledList.elementAt(i+3)%></td>
      <td><%=(String)vEnrolledList.elementAt(i+4)%></td>
      <td><%=(String)vEnrolledList.elementAt(i+13)%></td>
      <td>
	 <% if (strSchCode.startsWith("CPU")) {%>
	  <%=WI.getStrValue(vEnrolledList.elementAt(i+5),"N/A")%>
	 <%}else{%>
  	  <%=WI.getStrValue(vEnrolledList.elementAt(i+7),"N/A")%>
	  <%}%>
	  </td>
	  <% strTemp = (String) vEnrolledList.elementAt(i+8);
	  	if (strTemp != null && strTemp.indexOf("null") != -1) {
			strTemp = ConversionTable.replaceString(strTemp,"null", "TBA");
		}%>
      <td><%=WI.getStrValue(strTemp,"TBA")%></td>
      <td><%=WI.getStrValue(vEnrolledList.elementAt(i+6),"N/A")%>
	  <!-- all the hidden fileds are here. -->
	  <input type="hidden" name="cur_index<%=j%>" value="<%=(String)vEnrolledList.elementAt(i+1)%>">
	  <input type="hidden" name="checkbox<%=j%>" value="checkbox"><!-- for checking conflict ;-) just a simple work around -->
	  <input type="hidden" name="sec_index<%=j%>" value="<%=(String)vEnrolledList.elementAt(i+5)%>">
	  <input type="hidden" name="is_lab_only<%=j%>" value="<%=(String)vEnrolledList.elementAt(i+14)%>">
	 <% if (strSchCode.startsWith("CPU")) {%>
	  <input type="hidden" name="by_pass<%=j%>" value="1">
	  <%}%>
      </td>
    </tr>
    <%
i = i+14;
}%>
  </table>
<%}
if(vAdviseList != null && vAdviseList.size() > 0){%>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="18">&nbsp;</td>
    </tr>
	    <tr >
      <td height="25" bgcolor="#B9B292"><div align="center">SUBJECTS LIST ALLOWED
          TO ADD </div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="5%" height="25" align="center"><strong><font size="1">YEAR</font></strong></td>
      <td width="5%" height="25" align="center"><strong><font size="1">TERM</font></strong></td>
      <td width="12%" height="25" align="center"><strong><font size="1">SUBJECT
        CODE</font></strong></td>
      <td width="23%" align="center"><strong><font size="1">SUBJECT TITLE </font></strong></td>
      <td width="5%" align="center"><strong><font size="1">TOTAL UNITS</font></strong></td>
      <td width="5%" align="center"><strong><font size="1">UNITS TO TAKE</font></strong></td>
      <td width="12%" align="center"><strong><font size="1">SECTION</font></strong></td>
      <td width="20%" align="center"><strong><font size="1">SCHEDULE</font></strong></td>
      <td width="5%" align="center"><strong><font size="1">SELECT ALL</font></strong>
        <br> <input type="checkbox" name="selAll" value="0" onClick="checkAll();"></td>
<%if(bolIsSuperUser){%>
      <td width="5%" align="center"><font size="1"><b>NO CONFLICT</b></font></td>
<%}%>
      <td width="5%" align="center"><strong><font size="1">ASSIGN SECTION</font></strong></td>
    </tr>
    <% int iTemp = 0;
//vAutoAdvisedList[1] is having the advised list = [0]=sub section index,[1]=section,[2]=sub_code
for(int i = 0 ; i< vAdviseList.size() ; ++i,++j,++iMaxDisplayed)
{
%>
    <tr onDblClick='LoadPopup("sec<%=j%>","sec_index<%=j%>","<%=(String)vAdviseList.elementAt(i)%>","<%=(String)vAdviseList.elementAt(i+9)%>","<%=j%>");'
	 class="nav" id="msg<%=j%>" onMouseOver="navRollOver('msg<%=j%>', 'on')" onMouseOut="navRollOver('msg<%=j%>', 'off')">
      <td height="20" align="center">
        <!-- all the hidden fileds are here. -->
        <input type="hidden" name="sub_code<%=j%>" value="<%=(String)vAdviseList.elementAt(i+6)%>">
        <input type="hidden" name="sub_name<%=j%>" value="<%=(String)vAdviseList.elementAt(i+7)%>">
        <input type="hidden" name="lab_unit<%=j%>" value="">
        <input type="hidden" name="lec_unit<%=j%>" value="">
        <input type="hidden" name="total_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+5)%>">
        <input type="hidden" name="cur_index<%=j%>" value="<%=(String)vAdviseList.elementAt(i)%>">
        <%=WI.getStrValue(vAdviseList.elementAt(i+1),"&nbsp;")%></td>
      <td align="center"><%=WI.getStrValue(vAdviseList.elementAt(i+2),"&nbsp;")%></td>
      <td><%=(String)vAdviseList.elementAt(i+6)%> </td>
      <td><%=(String)vAdviseList.elementAt(i+7)%></td>
      <td align="center"><%=(String)vAdviseList.elementAt(i+5)%></td>
      <td align="center">
	  <input type="text" value="<%=Float.parseFloat((String)vAdviseList.elementAt(i+5))-Float.parseFloat((String)vAdviseList.elementAt(i+8))%>"
	  		name="ut<%=j%>" size="4" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;" <%=strReadOnlyUnitToTake%>></td>
      <td> <input type="text" name="sec<%=j%>" size="12" readonly="yes" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;">
        <input type="hidden" name="sec_index<%=j%>"> </td>
      <td><label id="_<%=j%>" style="font-size:11px;">&nbsp;</label></td>
      <td align="center"> <input type="checkbox" name="checkbox<%=j%>"
	  value="<%=Float.parseFloat((String)vAdviseList.elementAt(i+5))-Float.parseFloat((String)vAdviseList.elementAt(i+8))%>"
	  onClick='AddLoad("<%=j%>","<%=Float.parseFloat((String)vAdviseList.elementAt(i+5))-Float.parseFloat((String)vAdviseList.elementAt(i+8))%>")'>      </td>
<%if(bolIsSuperUser){%>
      <td align="center">
	  <input type="checkbox" value="1" name="no_conflict<%=j%>" onClick="SetIsNoConflict(<%=j%>);"></td>
<%}%>
<input type="hidden" name="NO_CONFLICT<%=j%>" value="0">
      <td align="center"><a href='javascript:LoadPopup("sec<%=j%>","sec_index<%=j%>","<%=(String)vAdviseList.elementAt(i)%>","<%=(String)vAdviseList.elementAt(i+9)%>","<%=j%>");'><img src="../../../images/schedule.gif" width="40" height="20" border="0"></a></td>
    </tr>
    <% i = i+9;}%>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td colspan="2" valign="top">&nbsp;</td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="20%" valign="top"><%if(bolReasonRequired){%>Reason for dropping: <%}%></td>
      <td width="40%" valign="top"><%if(bolReasonRequired){%><textarea name="reason" cols="40" rows="3" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("reason")%></textarea><%}%></td>
      <td width="36%" valign="bottom">
	 <a href="javascript:AddSubject();">
	  <img src="../../../images/save.gif" border="0" name="hide_save" onClick="UpdateAddDropCount();"></a>
	  <font size="1">Click to save added subjects</font>
	  </td>
    </tr>
  </table>
<!--
<table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr><tr>
      <td height="25" align="center"><a href="javascript:AddSubject();">
	  <img src="../../../images/save.gif" border="0" name="hide_save" onClick="UpdateAddDropCount();"></a>
	  <font size="1">Click to save added subjects</font></td>
    </tr>
</table>
-->
<input type="hidden" name="ci" value="<%=(String)vStudInfo.elementAt(5)%>">
<input type="hidden" name="mi" value="<%=WI.getStrValue(vStudInfo.elementAt(6))%>">

<%
	}//if vAdviseLIst is not null.
}//only if student information is not null
%>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="addSubject" value="0">
<input type="hidden" name="maxAllowedLoad" value="<%=strMaxAllowedLoad%>">
<input type="hidden" name="sub_sec_csv" value="<%=strSubSecCSV%>">
<input type="hidden" name="maxDisplay" value="<%=j%>">
<input type="hidden" name="addSubCount" value="<%=iMaxDisplayed%>">
<input type="hidden" name="degree_type" value="<%=strDegreeType%>">

<input type="hidden" name="no_charge" value="<%=WI.fillTextValue("no_charge")%>">
<input type="hidden" name="no_of_adddrop_edited" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
