<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="javascript">	
	function PageAction(strAction, strInfoIndex) {		
		document.form_.page_action.value = strAction;
		if(strAction == '0') {
			if(!confirm("Are you sure you want to delete this record?"))
				return;
				
			document.form_.page_action.value ='0';								
			document.form_.info_index.value = strInfoIndex;
		}
		document.form_.submit();
	}
//// - all about ajax.. 
function ajaxLoadRoom(objSchRef, strSelName, strLabelID) {
	var objCOAInput;
	objCOAInput = document.getElementById(strLabelID);
			
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=218&sch_ref="+objSchRef[objSchRef.selectedIndex].value+"&sel_name="+strSelName+
				"&sy_from="+document.form_.sy_from.value+"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value+
				"&pmt_schedule="+document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].value;

	this.processRequest(strURL);
}
function ajaxUpdateSched(objSchRef, objRoomRef, strLabelID, strInfoIndex)	{
	var objCOAInput;
	objCOAInput = document.getElementById(strLabelID);
	
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=218&update_=1&info_index="+strInfoIndex+"&new_room="+objRoomRef[objRoomRef.selectedIndex].value+
				"&new_sch="+objSchRef[objSchRef.selectedIndex].value+
				"&sy_from="+document.form_.sy_from.value+"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value+
				"&pmt_schedule="+document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].value;

	this.processRequest(strURL);
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector, enrollment.EACExamSchedule" %>
<%
	DBOperation dbOP  = null;
	WebInterface WI   = new WebInterface(request);
	Vector vRetResult = null;
	String strErrMsg  = null;
	String strTemp    = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		//may be called from registrar.
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
		return;
	}
	try
	{
		dbOP = new DBOperation();
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
	

EACExamSchedule EES = new EACExamSchedule();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(EES.operateOnManualSched(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = EES.getErrMsg();
	else	
		strErrMsg = "Operate Processed successfully.";
}
if(WI.fillTextValue("sy_from").length() > 0)
	vRetResult = EES.operateOnManualSched(dbOP, request, 4);



String strSYFrom = WI.fillTextValue("sy_from");
if(strSYFrom.length() == 0) 
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
String strSemester = WI.fillTextValue("semester");
if(strSemester.length() == 0) 
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");


Vector vSchedInfo = null;

String strRoomsNotAssigned = null;

if(WI.fillTextValue("pmt_schedule").length() > 0) {
	vSchedInfo = EES.getSchedulesCreated(dbOP, request, strSYFrom, strSemester);
			
			//get how many rooms not assigned..
			String strSQLQuery = "select count(*) from EAC_EXAM_ASSIGNMENT where is_valid = 1 and SY_FROM = "+WI.fillTextValue("sy_from")+" and SEMESTER = "+WI.fillTextValue("semester")+ 
								" and PMT_SCH_INDEX = "+WI.fillTextValue("pmt_schedule")+" and ROOM_REF is null and is_valid = 1";
			strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
			if(strSQLQuery != null && !strSQLQuery.equals("0")) 
				strRoomsNotAssigned = "ROOMs not assigned : "+strSQLQuery;
			else
				strRoomsNotAssigned= "All rooms assigned. No Error found.";
}
if(vSchedInfo == null)
	vSchedInfo = new Vector();





%>
<body>
<form name="form_" method="post" action="manual_sched.jsp">
  <table border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2">
	  <jsp:include page="./inc.jsp?pgIndex=6"></jsp:include>
	  </td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center"><font color="#FFFFFF" size="2"><strong>:::: MANUAL SCHEDULE MAIN PAGE ::::</strong></font></td>
    </tr>    
		<tr bgcolor="#FFFFFF">
      <td height="25" style="font-weight:bold; font-size:16px; color:#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
    </tr>	
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
	<tr>
	  <td width="2%" height="25">&nbsp;</td>
	  <td width="17%" >SY From/Term </td>
	  <td width="81%" >
			<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("oth_miscfee","sy_from","sy_to")'>
	  - 
 <select name="semester">
   <option value="0">Summer</option>
<%
if(strSemester.compareTo("1") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="1"<%=strErrMsg%>>1st Sem</option>
<%
if(strSemester.compareTo("2") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="2"<%=strErrMsg%>>2nd Sem</option>
<%
if(strSemester.compareTo("3") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="3"<%=strErrMsg%>>3rd Sem</option>
        </select>		</td>
	</tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td >Exam Name  </td>
	  <td ><select name="pmt_schedule" >
         <%=dbOP.loadCombo("pmt_sch_index","exam_name"," from fa_pmt_schedule where is_valid=1 order by exam_period_order", WI.fillTextValue("pmt_schedule"), false)%>
     </select></td>
	</tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td colspan="2" >
<%
strTemp = WI.fillTextValue("show_con");
if(strTemp.length() == 0 || strTemp.equals("0"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="show_con" value="0" <%=strErrMsg%>> Show With Room
<%
if(strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="show_con" value="1" <%=strErrMsg%>> Show Without Room
	  
	  <font style="color:#FF0000; font-weight:bold"><%=WI.getStrValue(strRoomsNotAssigned, "(", ")","")%></font>
	  </td>
    </tr>
		
	<tr>
	  <td >&nbsp;</td>
	  <td >&nbsp;</td>
	  <td >
      	<input type="button" name="chk_" value=" List Schedule " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="document.form_.submit();" />      </td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" align="center" class="thinborderNONE"><strong>List of Schedules Created </strong></td>
    </tr>    
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td width="4%" class="thinborder" height="22">Count#</td>
		<td width="20%" class="thinborder">Exam Date-Time</td>
		<td width="8%" class="thinborder">Subject</td>
		<td width="8%" class="thinborder">Section</td>
		<td width="5%" class="thinborder">Control # </td>
		<td width="5%" class="thinborder">Room</td>
		<td width="8%" class="thinborder">Location</td>
		<td width="5%" class="thinborder">Floor</td>
		<td width="5%" class="thinborder">Max Capacity</td>
		<td width="5%" class="thinborder">#Enrolled</td>
	    <td width="5%" class="thinborder">Delete</td>
		<td width="10%" class="thinborder">New Sched</td>
		<td width="5%" class="thinborder">New Room</td>
		<td width="5%" class="thinborder">Update</td>
	</tr>
<%
int iCount = 1;
String strSchIndex = null; 
for(int i =0; i < vRetResult.size(); i += 17){%>
	<tr>
	  <td class="thinborder" height="22"><%=iCount++%>. </td>
	  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%> <%=(String)vRetResult.elementAt(i + 2)%> - <%=(String)vRetResult.elementAt(i + 3)%></td>
	  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
	  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
	  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 16)%></td>
	  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%></td>
	  <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 10), "&nbsp;")%></td>
	  <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 8), "&nbsp;")%></td>
	  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 11)%></td>
	  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 13)%></td>
      <td class="thinborder">
	  	<input type="button" name="del_" value="Delete" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>');document.form_.focus_index.value=<%=i-16%>" />	  </td>
	  <td class="thinborder">
<%
strSchIndex = WI.getStrValue((String)vRetResult.elementAt(i + 14));
%>
	  <select name="new_sched<%=iCount%>" style="font-size:9px;" onChange="ajaxLoadRoom(document.form_.new_sched<%=iCount%>,'new_room_<%=iCount%>', '_<%=iCount%>')">
<%
for(int p =0; p < vSchedInfo.size(); p += 2) {
	if(WI.getStrValue(strSchIndex).equals(vSchedInfo.elementAt(p)))
		strErrMsg = " selected";
	else
		strErrMsg = "";
	%>
		<option value="<%=vSchedInfo.elementAt(p)%>"<%=strErrMsg%>><%=vSchedInfo.elementAt(p + 1)%></option>
<%}%>	  
	  </select>
	  </td>
	  <td class="thinborder">
	  <label id="_<%=iCount%>">
		  <%=EES.ajaxLoadRoom(dbOP, request, strSchIndex,"new_room_"+iCount)%>
	  </label>
	  </td>
	  <td class="thinborder">
	  	<input type="button" name="update_" value="Update" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="ajaxUpdateSched(document.form_.new_sched<%=iCount%>,document.form_.new_room_<%=iCount%>, '_x<%=iCount%>','<%=vRetResult.elementAt(i)%>')" />
		<label id="_x<%=iCount%>" style="font-weight:bold; font-size:9px; color:#FF0000"></label></td>
	  </td>
	</tr>
<%}%>
  </table>
<%}%>

	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
	<input type="hidden" name="new_sched">
	<input type="hidden" name="new_room">
	<input type="hidden" name="focus_index">
</form>
</body>
</html>

<%
if(dbOP!=null)
	dbOP.cleanUP();
%>

