<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.chngsubject.submit();
}
function AddSubject()
{
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
/**
function LoadPopup(secName,sectionIndex, strCurIndex) //curriculum index is different for all courses.
{
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
//alert(subSecList);
	var loadPg = "../advising/subject_schedule.jsp?form_name=chngsubject&cur_index="+strCurIndex+"&sec_name="+secName+"&sec_index_name="+sectionIndex+
		"&syf="+document.chngsubject.sy_from.value+"&syt="+document.chngsubject.sy_to.value+"&semester="+document.chngsubject.semester.value+
		"&sec_index_list="+subSecList;
	//var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,screenX=200,screenY=300,scrollbars=yes,,toolbar=yes,location=yes,directories=yes,status=no,menubar=yes');
	var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,screenX=200,screenY=300,scrollbars=yes,,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
**/
function LoadPopup(secName,sectionIndex, strCurIndex, strSubIndex) //curriculum index is different for all courses.
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
		"&syf="+document.chngsubject.sy_from.value+"&syt="+document.chngsubject.sy_to.value+"&semester="+document.chngsubject.semester[document.chngsubject.semester.selectedIndex].value+
		"&sec_index_list="+subSecList+"&course_index="+document.chngsubject.ci.value+
		"&major_index="+document.chngsubject.mi.value+"&degree_type="+document.chngsubject.degree_type.value;

	//var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,screenX=200,screenY=300,scrollbars=yes,,toolbar=yes,location=yes,directories=yes,status=no,menubar=yes');
	var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,top=10,left=10,scrollbars=yes,,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.chngsubject.stud_id.focus();
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,enrollment.EnrlAddDropSubject,enrollment.Advising,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
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

//end of authenticaion code.

String strMaxAllowedLoad = "0"; // this is the first field of the vAdvisingList
String strOverLoadDetail = null;//Overload detail if there is any.

Vector vEnrolledList = new Vector();
Vector vStudInfo = new Vector();
Vector vAdviseList = new Vector();

Advising advising = new Advising();
EnrlAddDropSubject enrlAddDropSub = new EnrlAddDropSubject();

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
			if(enrlAddDropSub.addSubject(dbOP,request))
				strErrMsg = "Subject/s added successfully.";
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
                                astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
		if(vEnrolledList ==null)
		{
			//bolFatalErr = true;
			strErrMsg = enrlAddDropSub.getErrMsg();
			//This happens only if student has drop all.
			vEnrolledList = new Vector();vEnrolledList.addElement("0");
		}
		//else
		{
			vAdviseList = advising.getAdvisingListForOLD(dbOP,strStudID,(String)vStudInfo.elementAt(5),(String)vStudInfo.elementAt(6),true,
						request.getParameter("sy_from"),request.getParameter("sy_to"), (String)vStudInfo.elementAt(7),
						(String)vStudInfo.elementAt(8),(String)vStudInfo.elementAt(4),request.getParameter("semester"));
			if(vAdviseList ==null)
				strErrMsg = advising.getErrMsg();
		}
	}
}
if(vStudInfo != null && vStudInfo.size() > 0)
{
	strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",
                                       (String)vStudInfo.elementAt(5), "degree_type",
                                       " and is_valid=1 and is_del=0");

	if(strDegreeType == null)
		strErrMsg = "Error in getting course degree type.";
	else
	{
		if(strDegreeType.compareTo("1") == 0)
		{
			dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./add_subject_masteral.jsp?stud_id="+strStudID+"&sy_from="+WI.fillTextValue("sy_from")+
			"&sy_to="+WI.fillTextValue("sy_to")+"&semester="+WI.fillTextValue("semester")));

			return;
		}
		else if(strDegreeType.compareTo("2") == 0)
		{
			dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./add_subject_medicine.jsp?stud_id="+strStudID+"&sy_from="+WI.fillTextValue("sy_from")+
			"&sy_to="+WI.fillTextValue("sy_to")+"&semester="+WI.fillTextValue("semester")));

			return;
		}
	}
}

%>

<form action="./change_subject_add.jsp" method="post" name="chngsubject">
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
      <td width="26%" height="25"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
      <td width="53%" height="25"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
      </td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%" height="25">School Year/Term </td>
      <td height="25" colspan="2">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp;&nbsp;&nbsp;&nbsp; <select name="semester" onChange="ReloadPage();">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select>
      </td>
    </tr>
  </table>
<% if(vStudInfo != null && vStudInfo.size() > 0 && !bolFatalErr){
%>
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
<%
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
<input type="text" name="sub_load" readonly="yes" size="5" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;" value="<%=(String)vEnrolledList.elementAt(0)%>"></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="16%" height="27" align="center"><font size="1"><strong>SUBJECT
        CODE</strong></font></td>
      <td width="26%" align="center"><font size="1"><strong>SUBJECT NAME</strong></font></td>
      <td width="4%" align="center"><font size="1"><strong>LEC. UNITS</strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>LAB. UNITS</strong></font></td>
      <td width="6%" align="center"><font size="1"><strong> UNITS TAKEN</strong></font></td>
      <td width="10%" align="center"><font size="1"><strong>SECTION</strong></font></td>
      <td width="6%" align="center"><font size="1"><strong>ROOM #</strong></font></td>
      <td width="18%" align="center"><font size="1"><strong>SCHEDULE</strong></font></td>
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
      <td><%=(String)vEnrolledList.elementAt(i+11)%></td>
      <td><%=(String)vEnrolledList.elementAt(i+12)%></td>
      <td><%=(String)vEnrolledList.elementAt(i+13)%></td>
      <td><%=(String)vEnrolledList.elementAt(i+7)%></td>
      <td><%=(String)vEnrolledList.elementAt(i+8)%></td>
      <td><%=(String)vEnrolledList.elementAt(i+6)%>
	  <!-- all the hidden fileds are here. -->
	  <input type="hidden" name="cur_index<%=j%>" value="<%=(String)vEnrolledList.elementAt(i+1)%>">
	  <input type="hidden" name="checkbox<%=j%>" value="checkbox"><!-- for checking conflict ;-) just a simple work aroundie -->
	  <input type="hidden" name="sec_index<%=j%>" value="<%=(String)vEnrolledList.elementAt(i+5)%>">
</td>
    </tr>
    <%
i = i+13;
}%>
  </table>
<%
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
      <td width="7%" height="25" align="center"><strong><font size="1">YEAR</font></strong></td>
      <td width="7%" height="25" align="center"><strong><font size="1">TERM</font></strong></td>
      <td width="12%" height="25" align="center"><strong><font size="1">SUBJECT
        CODE</font></strong></td>
      <td width="23%" align="center"><strong><font size="1">SUBJECT NAME</font></strong></td>
      <td width="10%" align="center"><strong><font size="1">LEC/LAB UNITS</font></strong></td>
      <td width="9%" align="center"><strong><font size="1">TOTAL .UNITS</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">UNITS TO TAKE</font></strong></td>
      <td width="12%" align="center"><strong><font size="1">SECTION</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">SELECT</font></strong></td>
      <td width="8%" align="center"><strong><font size="1">ASSIGN SECTION</font></strong></td>
    </tr>
    <% int iTemp = 0;
for(int i = 0 ; i< vAdviseList.size() ; ++i,++j,++iMaxDisplayed)
{
%>
    <tr>
      <td height="25" align="center">
        <!-- all the hidden fileds are here. -->
        <input type="hidden" name="year_level<%=j%>" value="<%=(String)vAdviseList.elementAt(i+1)%>">
        <input type="hidden" name="sem<%=j%>" value="<%=(String)vAdviseList.elementAt(i+2)%>">
        <input type="hidden" name="sub_code<%=j%>" value="<%=(String)vAdviseList.elementAt(i+6)%>">
        <input type="hidden" name="sub_name<%=j%>" value="<%=(String)vAdviseList.elementAt(i+7)%>">
        <input type="hidden" name="lab_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+4)%>">
        <input type="hidden" name="lec_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+3)%>">
        <input type="hidden" name="total_unit<%=j%>" value="<%=(String)vAdviseList.elementAt(i+5)%>">
        <input type="hidden" name="cur_index<%=j%>" value="<%=(String)vAdviseList.elementAt(i)%>">
        <%=(String)vAdviseList.elementAt(i+1)%></td>
      <td align="center"><%=(String)vAdviseList.elementAt(i+2)%></td>
      <td><%=(String)vAdviseList.elementAt(i+6)%>
<%if(((String)vAdviseList.elementAt(i+6)).indexOf("NSTP") != -1){%>
        <select name="nstp_val<%=j%>" style="font-weight:bold;">
<%=dbOP.loadCombo("distinct NSTP_VAL","NSTP_VAL"," from NSTP_VALUES order by NSTP_VALUES.NSTP_VAL asc", WI.fillTextValue("nstp_val"), false)%>
        </select>
        <%}//only if subject is NSTP %>
      </td>
      <td><%=(String)vAdviseList.elementAt(i+7)%></td>
      <td align="center"><%=(String)vAdviseList.elementAt(i+3)%>/<%=(String)vAdviseList.elementAt(i+4)%></td>
      <td align="center"><%=(String)vAdviseList.elementAt(i+5)%></td>
      <td align="center"><input type="text" value="<%=Float.parseFloat((String)vAdviseList.elementAt(i+5))-Float.parseFloat((String)vAdviseList.elementAt(i+8))%>" name="ut<%=j%>" size="4" readonly="yes" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;"></td>
      <td> <input type="text" name="sec<%=j%>" size="12" readonly="yes" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;">
        <input type="hidden" name="sec_index<%=j%>"> </td>
      <td align="center"> <input type="checkbox" name="checkbox<%=j%>"
	  value="<%=Float.parseFloat((String)vAdviseList.elementAt(i+5))-Float.parseFloat((String)vAdviseList.elementAt(i+8))%>"
	  onClick='AddLoad("<%=j%>","<%=Float.parseFloat((String)vAdviseList.elementAt(i+5))-Float.parseFloat((String)vAdviseList.elementAt(i+8))%>")'>
      </td>
      <td align="center"><a href='javascript:LoadPopup("sec<%=j%>","sec_index<%=j%>","<%=(String)vAdviseList.elementAt(i)%>","<%=(String)vAdviseList.elementAt(i+9)%>");'><img src="../../../images/schedule.gif" width="55" height="30" border="0"></a></td>
    </tr>
    <% i = i+9;}%>
  </table>
<table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr><tr>
      <td height="25" align="center"><a href="javascript:AddSubject();">
	  <img src="../../../images/save.gif" border="0" name="hide_save"></a>
	  <font size="1">Click to save added subjects</font></td>
    </tr>
</table>
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
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
