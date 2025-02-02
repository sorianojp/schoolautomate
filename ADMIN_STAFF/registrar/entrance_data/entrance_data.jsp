<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
<style type="text/css">
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TABLE.thinborderall {
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-size: 11px;
    }
</style>

</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction) {
	document.form_ed_.page_action.value =strAction;
	if(strAction == 1)
		document.form_ed_.hide_save.src = "../../../images/blank.gif";
	document.form_ed_.submit();
}
function ReloadPage() {
	document.form_ed_.page_action.value = "";
	document.form_ed_.submit();
}
function CancelRecord(strEmpID){
	location = "./entrance_data.jsp";
}

function FocusID() {
	document.form_ed_.stud_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_ed_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateSchoolList()
{
	//pop up here.
	var pgLoc = "../../registrar/sub_creditation/schools_accredited.jsp?parent_wnd=form_ed_";
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function CloseWindow(){	
	eval("window.opener.document."+document.form_ed_.parent_wnd.value+".submit()");
	window.opener.focus();
	self.close();
}

function UpdateReqDocs(){
	var pgLoc = "../admission_requirements/stud_admission_req.jsp?parent_wnd=form_ed_&stud_id="+document.form_ed_.stud_id.value;
	var win=window.open(pgLoc,"ReqWindow",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_ed_.stud_id.value;
		if(strCompleteName.length < 3) {
			document.getElementById("coa_info").innerHTML = "";
			return;
		}
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_ed_.stud_id.value = strID;
	document.form_ed_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_ed_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,enrollment.EntranceNGraduationData,enrollment.CourseRequirement,java.util.Vector"%>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	Vector vStudInfo = null;
	boolean bolShowEditInfo = false;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-ENTRANCE DATA","entrance_data.jsp");
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
														"Registrar Management","ENTRANCE DATA",request.getRemoteAddr(),
														"entrance_data.jsp");
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

boolean bolIsWNU = false;
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
EntranceNGraduationData entranceData = new EntranceNGraduationData();
CourseRequirement cRequirement = new CourseRequirement();
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if (strSchCode == null) 
	strSchCode = "";
	

bolIsWNU = strSchCode.startsWith("WNU");
if(strSchCode.equals("WNU"))
	strSchCode = "AUF";
	
boolean bolIsUB = strSchCode.startsWith("WNU");

Vector vRetResult = null;
Vector vPendingRequirement = null;
Vector vCompliedRequirement = null;
Vector vFirstEnrl = null;

if(WI.fillTextValue("stud_id").length() > 0) {
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null || vStudInfo.size() ==0)
		strErrMsg = offlineAdm.getErrMsg();
}
if(vStudInfo != null && vStudInfo.size() > 0) {
	
	vFirstEnrl = cRequirement.getFirstEnrollment(dbOP,request.getParameter("stud_id"),(String)vStudInfo.elementAt(7),
													(String)vStudInfo.elementAt(8));
													
	if (vFirstEnrl != null) {

 // DBOperation dbOP, String strStudIndex,String strSYFrom,String strSYTo,String strSemester, boolean bolIsTempStud, bolean bolGetPendingList, boolean bolGetCompliedList

	vRetResult = cRequirement.getStudentPendingCompliedList(dbOP,(String)vStudInfo.elementAt(12),
											(String)vFirstEnrl.elementAt(0),(String)vFirstEnrl.elementAt(1),
											(String)vFirstEnrl.elementAt(2),false,true,true);
										
		if(vRetResult == null && strErrMsg == null)
			strErrMsg = cRequirement.getErrMsg();
		else {
			vPendingRequirement = (Vector)vRetResult.elementAt(0);
			vCompliedRequirement = (Vector)vRetResult.elementAt(1);
		}
	  }else strErrMsg = cRequirement.getErrMsg();

		
	int iAction = Integer.parseInt(WI.getStrValue(WI.fillTextValue("page_action"),"4"));//default = 4, view all.
	vRetResult = entranceData.operateOnEntranceData(dbOP, request,iAction);

	

	if(vRetResult == null || vRetResult.size() ==0) {
		strErrMsg = entranceData.getErrMsg();
		vRetResult = entranceData.operateOnEntranceData(dbOP, request,4);
	}
	else {
		if(iAction == 1) {
			strErrMsg = "Entrance Data saved successfully.";
		}
		else if(iAction == 2) {
			strErrMsg = "Entrance Data information changed successfully.";
		}
	}
}


strTemp = WI.getStrValue(WI.fillTextValue("new_id_entered"),"0");

if(vRetResult != null && vRetResult.size() > 0 && strTemp.equals(WI.fillTextValue("stud_id")))
	bolShowEditInfo = true;

String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};

//if entrance data is not found. get information from GSPIS
Vector vTemp = null;
if( vStudInfo != null && vStudInfo.size() > 0 && (vRetResult == null || vRetResult.size() == 0) )
	vTemp = entranceData.getEduFrGSPIS(dbOP, (String)vStudInfo.elementAt(12));
%>

<form name="form_ed_" action="./entrance_data.jsp" method="post">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="6" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          ENTRANCE DATA PAGE ::::</strong></font></div></td>
    </tr>
<%
if(WI.fillTextValue("parent_wnd").length() > 0){%>
   <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="5" ><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" border="0"></a>
        <font size="1"><strong>Click to close window</strong></font></td>
    </tr>
<%}%>
    <tr>
      <td width="4%" height="25" >&nbsp;</td>
      <td height="25" colspan="5" ><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr valign="top">
      <td width="4%" height="25" >&nbsp;</td>
      <td width="15%" height="25" >Student ID :</td>
      <td width="20%" > <input name="stud_id" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=WI.fillTextValue("stud_id")%>" onKeyUp="AjaxMapName('1');"></td>
      <td width="7%" >&nbsp; <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="11%" ><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td width="43%" ><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr>
      <td colspan="6" height="25" ><hr size="1"></td>
    </tr>
    <% if(vStudInfo != null && vStudInfo.size() > 0){//outer loops%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="5" >Student name : <strong> 
	  <%=WebInterface.formatName((String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(1),
	  	(String)vStudInfo.elementAt(2),5)%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="5" height="25" >Year : <strong><%=WI.getStrValue(vStudInfo.elementAt(14),"N/A")%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="5" height="25" >Course /Major: <strong><%=(String)vStudInfo.elementAt(7)%>
        <%
	  if(vStudInfo.elementAt(8) != null){%>
        / <%=WI.getStrValue(vStudInfo.elementAt(8))%>
        <%}%>
        </strong></td>
    </tr>
    <tr>
      <td colspan="6" height="25" ><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25" >&nbsp;</td>
      <td height="25" colspan="4" ><u><strong>Educational Data</strong></u></td>
    </tr>
<%if(!strSchCode.startsWith("UC")){%>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="11%" height="25" >Elementary</td>
      <td width="11%" height="25" > <a href="javascript:UpdateSchoolList();"><img src="../../../images/update.gif" border="0"></a></td>
      <td width="72%" >&nbsp; <%if (strSchCode.startsWith("AUF") || strSchCode.startsWith("DBTC") || true) {%> 
<%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(19);
else
	strTemp = WI.fillTextValue("int_sy_from");

if(request.getParameter("int_sy_from") == null && vTemp != null && vTemp.size() > 0 && vTemp.elementAt(6) != null)
	strTemp = Integer.toString(Integer.parseInt((String)vTemp.elementAt(6)) - 1);


%> Year Graduated :
	  				<input name="int_sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_ed_","int_sy_from","int_sy_to")'> 
	  				-  
<%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(20);
else
	strTemp = WI.fillTextValue("int_sy_to");
	
if(request.getParameter("int_sy_to") == null && vTemp != null && vTemp.size() > 0 && vTemp.elementAt(6) != null)
	strTemp = (String)vTemp.elementAt(6);

%>		            <input name="int_sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
                    <%}%>

	  </td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="3" ><select name="elem_sch_index">
          <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(2);
else
	strTemp = WI.fillTextValue("elem_sch_index");
if(request.getParameter("elem_sch_index") == null && vTemp != null && vTemp.size() > 0 && vTemp.elementAt(1) != null)
	strTemp = (String)vTemp.elementAt(1);

%>
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",strTemp,false)%> </select></td>
    </tr>
<%}//do not show elementary to UC.. 
if(true){//for UC, show Primary and intermediate.-- show for all%>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="11%" height="25" >Primary</td>
      <td width="11%" height="25" > <a href="javascript:UpdateSchoolList();"><img src="../../../images/update.gif" border="0"></a></td>
      <td width="72%" >&nbsp;
        Year Graduated :
<%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(17);
else
	strTemp = WI.fillTextValue("primary_sy_from");

%> <input name="primary_sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_ed_","primary_sy_from","primary_sy_to")'>
	  				-  
<%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(18);
else
	strTemp = WI.fillTextValue("primary_sy_to");

%> <input name="primary_sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="3" >
<select name="primary_sch_index">
          <option value="">N/A</option>
          <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(13);
else
	strTemp = WI.fillTextValue("primary_sch_index");
%>
          <%//=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_CODE+'('+SUBSTRING(SCH_NAME,1,4)+' ...)'"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_CODE",strTemp,false)%>
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",strTemp,false)%> 
        </select>	  </td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="11%" height="25" >Intermediate</td>
      <td width="11%" height="25" > <a href="javascript:UpdateSchoolList();"><img src="../../../images/update.gif" border="0"></a></td>
      <td width="72%" >&nbsp;
        Year Graduated :
<%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(19);
else
	strTemp = WI.fillTextValue("int_sy_from");

if(request.getParameter("int_sy_from") == null && vTemp != null && vTemp.size() > 0 && vTemp.elementAt(6) != null)
	strTemp = Integer.toString(Integer.parseInt((String)vTemp.elementAt(6)) - 1);

%> <input name="int_sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_ed_","int_sy_from","int_sy_to")'>	  				 
	  				-  
<%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(20);
else
	strTemp = WI.fillTextValue("int_sy_to");

if(request.getParameter("int_sy_to") == null && vTemp != null && vTemp.size() > 0 && vTemp.elementAt(6) != null)
	strTemp = (String)vTemp.elementAt(6);

%> <input name="int_sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="3" >
<select name="int_sch_index">
          <option value="">N/A</option>
          <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(15);
else
	strTemp = WI.fillTextValue("int_sch_index");
%>
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",strTemp,false)%> </select>	  </td>
    </tr>





<%}//show for UC only. -- Intermediate and Primary.. %>

    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >Secondary</td>
      <td height="25" > <a href="javascript:UpdateSchoolList();"><img src="../../../images/update.gif" border="0"></a></td>
      <td height="25" ><%if (strSchCode.startsWith("AUF") || strSchCode.startsWith("DBTC") || strSchCode.startsWith("UB") || strSchCode.startsWith("UC") || true) {%> 
<%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(21);
else
	strTemp = WI.fillTextValue("sec_sy_from");

if(request.getParameter("sec_sy_from") == null && vTemp != null && vTemp.size() > 0 && vTemp.elementAt(7) != null)
	strTemp = Integer.toString(Integer.parseInt((String)vTemp.elementAt(7)) - 1);

%> Year Graduated :
        <input name="sec_sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_ed_","sec_sy_from","sec_sy_to")'> 
        -  
<%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(22);
else
	strTemp = WI.fillTextValue("sec_sy_to");

if(request.getParameter("sec_sy_to") == null && vTemp != null && vTemp.size() > 0 && vTemp.elementAt(7) != null)
	strTemp = (String)vTemp.elementAt(7);

%>         <input name="sec_sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
	  
	  
	  <%if(strSchCode.startsWith("UB") || strSchCode.startsWith("SPC")){
	  	if(bolShowEditInfo)
			strTemp = (String)vRetResult.elementAt(40);
		else
			strTemp = WI.fillTextValue("level_attended");
	  %>
	  <br>
	  <%if(strSchCode.startsWith("UB")){%>
		  Year Attended &nbsp; :
		  <input name="level_attended" type="text" size="15" maxlength="64" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  <%}%>
	  &nbsp; Section : 
	  <%
	  if(bolShowEditInfo)
		strTemp = (String)vRetResult.elementAt(41);
	else
		strTemp = WI.fillTextValue("level_section");
	  %>
	  <input name="level_section" type="text" size="15" maxlength="64" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  <%}
	  }%>
					
					
		</td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="3" ><select name="sec_sch_index">
          <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(4);
else
	strTemp = WI.fillTextValue("sec_sch_index");
if(request.getParameter("sec_sch_index") == null && vTemp != null && vTemp.size() > 0 && vTemp.elementAt(3) != null)
	strTemp = (String)vTemp.elementAt(3);
%>
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",strTemp,false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >College</td>
      <td height="25" colspan="2" > <a href="javascript:UpdateSchoolList();"><img src="../../../images/update.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="3" ><select name="college_index">
          <option value="">N/A</option>
<%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(6);
else
	strTemp = WI.fillTextValue("college_index");
if(request.getParameter("college_index") == null && vTemp != null && vTemp.size() > 0 && vTemp.elementAt(5) != null)
	strTemp = (String)vTemp.elementAt(5);
%>
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",strTemp,false)%> 
        </select></td>
    </tr>
<% if (strSchCode.startsWith("AUF")){%>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="3" > Year Last Attended :
 <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(24);
else
	strTemp = WI.fillTextValue("last_sy_attended");
%>	  
	   
      <input name="last_sy_attended" type="text"  size="6" maxlength="12" 
	  value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">      </td>
    </tr>
<%}%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="18" >&nbsp;</td>
      <td height="18" colspan="3" >&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="3" ><u><strong>Entrance Data</strong></u></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >Admission Date</td>
      <td > <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(23);
else
	strTemp = WI.fillTextValue("admission_date");
%> <input name="admission_date" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=WI.getStrValue(strTemp)%>" size="32" maxlength="32"></td>
    </tr>
    <tr> 
      <td width="3%" height="25" >&nbsp;</td>
      <td width="1%" height="25" >&nbsp;</td>
      <td width="15%" height="25" >Documents Presented</td>
      <td width="81%" > <br> <%
   if((vPendingRequirement != null && vPendingRequirement.size() > 0) ||
   		(vCompliedRequirement != null && vCompliedRequirement.size() > 0)  ){%> <table width="75%" border="0" align="left" cellpadding="0" cellspacing="0" class="thinborder">
          <% if (vCompliedRequirement != null && vCompliedRequirement.size() > 0) {%>
          <tr bgcolor="#F4F7FF"> 
            <td width="64%" class="thinborder">&nbsp;&nbsp;<strong>PASSED </strong></td>
            <td width="36%" class="thinborderBottom"><strong>&nbsp;&nbsp;DATE 
              PASSED</strong></td>
          </tr>
          <% for(int i = 0 ; i< vCompliedRequirement.size(); i +=3){%>
          <tr> 
            <td class="thinborder">&nbsp;<%=(String)vCompliedRequirement.elementAt(i+1)%></td>
            <td class="thinborderBottom">&nbsp;&nbsp;<%=(String)vCompliedRequirement.elementAt(i+2)%></td>
          </tr>
          <%} //end for loop
}//end if vCompliedRequirement.size > 0
if (vPendingRequirement != null && vPendingRequirement.size() > 0) {%>
          <tr> 
            <td colspan="2" bgcolor="#FDEEF2" class="thinborder"><div align="center">&nbsp;<strong>REQUIRED 
                ITEMS</strong></div></td>
          </tr>
          <% for (int i = 0; i < vPendingRequirement.size(); i+=5) {%>
          <tr> 
            <td colspan="2" class="thinborder">&nbsp;<%=(String)vPendingRequirement.elementAt(i+1)%></td>
          </tr>
          <%} //end for loop
}//end if vPendingRequirement.size > 0%>
        </table>
        <br> <a href="javascript:UpdateReqDocs();"><img src="../../../images/update.gif" border="0"></a> 
        <%} // if pass or uncomplied requirementes exist 
		else{%> <strong><font color="#FF0000">Please set the requirements 
        for the course and school year of entry </font></strong> <%}%> </td>
    </tr>
    <% if (vStudInfo!= null && ((String)vStudInfo.elementAt(15)).equals("2")){%>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" valign="middle" >&nbsp;</td>
      <td height="25" >C.E.A. No.</td>
      <td height="25" > <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(9);
else
	strTemp = WI.fillTextValue("cea_no");
%> <input name="cea_no" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=strTemp%>" size="24"> </td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" valign="middle" >&nbsp;</td>
      <td height="25" >C.E.A. No. Date</td>
      <td height="25" > <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(10);
else
	strTemp = WI.fillTextValue("cea_no");
%> <input name="cea_issue_date" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=strTemp%>" size="32"> <font size="1">&nbsp; </font></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" valign="middle" >&nbsp;</td>
      <td height="25" >Pre-Med. Course</td>
      <td height="25" > <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(11);
else
	strTemp = WI.fillTextValue("pre_med_course");
%> <input name="pre_med_course" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=strTemp%>" size="50"> <font size="1">&nbsp; </font></td>
    </tr>
    <%}// %>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" valign="middle" >&nbsp; </td>
      <td height="25" > Remarks :</td>
      <td height="25" > <br> <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(12);
else
	strTemp = WI.fillTextValue("remarks");
%> <textarea name="remarks" cols="50" rows="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onblur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea> 
        <br>
        (Only for the latest course graduated Entrance Data Remarks)</td>
    </tr>
  </table>
<% if (!strSchCode.startsWith("AUF") && !strSchCode.startsWith("DBTC") && !strSchCode.startsWith("UC") && false) {%> 
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#97ABC1"> 
      <td height="25" colspan="6" align="center"><font color="#FFFFFF"><strong>FORM 
        17 DATA</strong></font></td>
    </tr>
<!--
Note : Primary + Intermediate = elementary
secondary : highschool
-->   <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" ><strong>SCHOOL</strong></td>
      <td height="25" colspan="2" ><div align="center"><strong>YEAR RANGE</strong></div></td>
      <td width="58%" ><strong>SCHOOL NAME</strong></td>
    </tr>
    <tr> 
      <td width="4%" height="25" >&nbsp;</td>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="11%" height="25" >Primary</td>
      <td width="12%" height="25" > <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(17);
else
	strTemp = WI.fillTextValue("primary_sy_from");

%> <input name="primary_sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_ed_","primary_sy_from","primary_sy_to")'></td>
      <td width="13%" > <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(18);
else
	strTemp = WI.fillTextValue("primary_sy_to");

%> <input name="primary_sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td height="25" > <a href="javascript:UpdateSchoolList();"><img src="../../../images/update.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="4" ><select name="primary_sch_index">
          <option value="">N/A</option>
          <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(13);
else
	strTemp = WI.fillTextValue("primary_sch_index");
%>
          <%//=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_CODE+'('+SUBSTRING(SCH_NAME,1,4)+' ...)'"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_CODE",strTemp,false)%>
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",strTemp,false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >Intermediate</td>
      <td height="25" > <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(19);
else
	strTemp = WI.fillTextValue("int_sy_from");

if(request.getParameter("int_sy_from") == null && vTemp != null && vTemp.size() > 0 && vTemp.elementAt(6) != null)
	strTemp = Integer.toString(Integer.parseInt((String)vTemp.elementAt(6)) - 1);

%> <input name="int_sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_ed_","int_sy_from","int_sy_to")'></td>
      <td height="25" > <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(20);
else
	strTemp = WI.fillTextValue("int_sy_to");

if(request.getParameter("int_sy_to") == null && vTemp != null && vTemp.size() > 0 && vTemp.elementAt(6) != null)
	strTemp = (String)vTemp.elementAt(6);

%> <input name="int_sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td height="25" > <a href="javascript:UpdateSchoolList();"><img src="../../../images/update.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="4" ><select name="int_sch_index">
          <option value="">N/A</option>
          <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(15);
else
	strTemp = WI.fillTextValue("int_sch_index");
%>
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",strTemp,false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >Secondary</td>
      <td height="25" > 
<%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(21);
else
	strTemp = WI.fillTextValue("sec_sy_from");

if(request.getParameter("sec_sy_from") == null && vTemp != null && vTemp.size() > 0 && vTemp.elementAt(7) != null)
	strTemp = Integer.toString(Integer.parseInt((String)vTemp.elementAt(7)) - 1);

%> <input name="sec_sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_ed_","sec_sy_from","sec_sy_to")'></td>
      <td height="25" > <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(22);
else
	strTemp = WI.fillTextValue("sec_sy_to");

if(request.getParameter("sec_sy_to") == null && vTemp != null && vTemp.size() > 0 && vTemp.elementAt(7) != null)
	strTemp = (String)vTemp.elementAt(7);

%> <input name="sec_sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td height="25" >&nbsp;</td>
    </tr>
<%if(bolIsWNU) {%>
    <tr>
      <td colspan="6" ><hr size="1" color="#0000FF"></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="2" >Collegiate Course: </td>
      <td height="25" >
<%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(38);
else
	strTemp = WI.fillTextValue("wnu_course");
%>
	  <input name="wnu_course" size="12" type="text" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td height="25" >Collegiate Completion SY From : 
<%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(39);
else
	strTemp = WI.fillTextValue("wnu_course_sy");
%>
      <input name="wnu_course_sy" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="2" >Masteral Concentration: </td>
      <td height="25" colspan="2" >
<%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(37);
else
	strTemp = WI.fillTextValue("wnu_concentration");
%>
	  <input name="wnu_concentration" size="32" type="text" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
    </tr>
<%}%>
  </table>
<%} // do not show Form 17 data for AUF%> 
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="3" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td width="6%" height="25">&nbsp;</td>
      <td><div align="center"><font size="1">
          <% if (iAccessLevel > 1){
	if(vRetResult == null || vRetResult.size() == 0) {%>
          <a href="javascript:PageAction(1);"><img src="../../../images/save.gif" border="0" name="hide_save"></a>
          click to save entries
          <%}else{%>
          <a href='javascript:CancelRecord()'><img src="../../../images/cancel.gif" border="0"></a>
		  click to cancel and clear entries
		  <a href="javascript:PageAction(2);"><img src="../../../images/edit.gif" border="0"></a>
          click to save changes
          <%}
		}%></font>
        </div></td>
      <td width="17%">&nbsp;</td>
    </tr>
  </table>
<%}//end if vStudInfo is not null%>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="3" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="new_id_entered" value="<%=WI.fillTextValue("stud_id")%>">
<input type="hidden" name="parent_wnd" value="<%=WI.fillTextValue("parent_wnd")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
