<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">	
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
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
	TABLE.thinborderALL{
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
	TD.thinborderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
</head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage(){
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function CancelEdit(){
	location = "./stud_acad.jsp?stud_id="+ document.form_.stud_id.value;
}

function PageAction(strAction, strInfoIndex){
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value = "";
}

function EditRecord(){
	document.form_.page_action.value = "2";
	document.form_.print_page.value = "";
}

function PrepareToEdit(strInfoIndex){
	document.form_.prepareToEdit.value ="1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce('form_');
}

function viewList(table,indexname,colname,labelname){ 
	var loadPg = "../../ADMIN_STAFF/HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname+
	"&opner_form_name=form_";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();	
}
-->
</script>

<%@ page language="java" import="utility.*,java.util.Vector,enrollment.OfflineAdmission,ClassMgmt.CMStudPerformance" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	boolean bolProceed = true;
//add security here.


	boolean bolIsStudent = WI.fillTextValue("is_student").equals("1");

try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-Students Performance-Academic Achievements","stud_acad.jsp");
}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.


CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Faculty/Acad. Admin","ALL",request.getRemoteAddr(), 
														"stud_acad.jsp");	

if (bolIsStudent)
	iAccessLevel = 1;

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	OfflineAdmission offlineAdm = new OfflineAdmission();
	Vector vStudBasicInfo = null;
	Vector vRetResult = null;
	Vector vEditInfo = null;
	String strSchCode = WI.getStrValue(dbOP.getSchoolIndex());
	

	CMStudPerformance cm = new CMStudPerformance();
	String strPageAction = WI.fillTextValue("page_action");
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	String[] astrConvSem = {", Summer", ", 1st Semester",", 2nd Semester",",3rd Semester", ", 4th Semester"};

	String strStudID = WI.fillTextValue("stud_id");
	if (strStudID.length() ==0 && bolIsStudent){
		strStudID = (String)request.getSession(false).getAttribute("userId");
	}

	
	if (strStudID.length() > 0){
		vStudBasicInfo = offlineAdm.getStudentBasicInfo(dbOP, strStudID);
		if (vStudBasicInfo == null)
			strErrMsg = offlineAdm.getErrMsg();
		
		if (WI.fillTextValue("stud_id").length() > 0) { 
			if (strPageAction.compareTo("0") == 0){
				vRetResult = cm.operateOnAcadAchievement(dbOP,request,0);
				if (vRetResult != null)
					strErrMsg = " Achievement removed successfully";
				else
					strErrMsg = cm.getErrMsg();
			}else if (strPageAction.compareTo("1") == 0){
				vRetResult = cm.operateOnAcadAchievement(dbOP,request,1);
				if (vRetResult != null)
					strErrMsg = " Achievement added successfully";
				else
					strErrMsg = cm.getErrMsg();
			}else if (strPageAction.compareTo("2") == 0){
				vRetResult = cm.operateOnAcadAchievement(dbOP,request,2);
				if (vRetResult != null){
					strErrMsg = " Achievement edited successfully";
					strPrepareToEdit ="";
				}else
					strErrMsg = cm.getErrMsg();
			}
		
			vRetResult =  cm.operateOnAcadAchievement(dbOP,request,4);
			if (vRetResult == null)
				strErrMsg = cm.getErrMsg();
		}
	}
if (strPrepareToEdit.length() > 0){
	vEditInfo = cm.operateOnAcadAchievement(dbOP,request,3);
	if (vEditInfo == null)
		strErrMsg = cm.getErrMsg();
}

	//check if elem student.
	if(vStudBasicInfo != null && vStudBasicInfo.size() > 0 && vStudBasicInfo.elementAt(7) == null) {//basic
		dbOP.cleanUP();
		
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">Not Available for Grade School Student</font></p>
		<%
		return;
	}
	
%>
<body bgcolor="#93B5BB">
<form action="./stud_acad.jsp" method="post" name="form_" id="form_" onSubmit="SubmitOnceButton(this);">
<% if (bolIsStudent) { %>
<input name="stud_id" type="hidden" value="<%=strStudID%>"> 
<%}%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#6A99A2">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          STUDENT ACADEMIC ACHIEVEMENT MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4">&nbsp;<%=WI.getStrValue(strErrMsg, "<font size=\"3\" color=\"#FF0000\">","</font>","")%></td>
    </tr>
<% if (!bolIsStudent) {%>
    <tr bgcolor="#FFFFFF">
      <td width="15%" height="25">&nbsp;<font face="Verdana, Arial, Helvetica, sans-serif">STUDENT 
        ID </font> </td>

      <td width="21%"><input name="stud_id" type="text" class="textbox" 
	                    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
						 value="<%=WI.fillTextValue("stud_id")%>" size="15" maxlength="15"> 
        &nbsp;&nbsp;</td>
      <td width="13%"><a href="javascript:OpenSearch();"><img src="../../images/search.gif" border="0"></a></td>
      <td width="51%">
	    <input type="submit" name="1" value=" Reload " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='';document.form_.print_page.value=''">
      </td>
    </tr>
<%}%>
  </table>
<% if (vStudBasicInfo != null) {%>

  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4"><hr size="1"> </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3"><font face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp; 
        </strong>STUDENT NAME</font> :<strong> <%=WI.formatName((String)vStudBasicInfo.elementAt(0),(String)vStudBasicInfo.elementAt(1),(String)vStudBasicInfo.elementAt(2),4)%></strong></td>
      <td width="55%">COURSE : <strong><%=(String)vStudBasicInfo.elementAt(7)%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3"><font face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp; 
        </strong></font>YEAR LEVEL : <strong><%=(String)vStudBasicInfo.elementAt(14)%></strong></td>
      <td>MAJOR : <strong><%=WI.getStrValue((String)vStudBasicInfo.elementAt(8),"&nbsp")%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4">&nbsp;	  
	    <% if (bolIsStudent) {%> <div align="center">
	      <a href="javascript:ReloadPage()"><img src="../../images/refresh.gif" border="0"> </a>
		  </div> <%}%> </td>
    </tr>
  </table>
<% if (!bolIsStudent) {%>  
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="2" cellspacing="0">
    <tr>
      <td height="25" colspan="3"><hr size="1" noshade></td>
    </tr>
    <tr>
      <td><strong>NAME OF ACHIEVEMENT :</strong></td>
<% 	
if (vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(2);
else 
	strTemp= WI.fillTextValue("acad_index");
%>
      <td colspan="2"><select name="acad_index">
		 <option value="">Select Achievement</option>
		 <%=dbOP.loadCombo("distinct PRE_ACAD_INDEX","PRE_ACAD_NAME", " from CM_PRELOAD_ACAD_ACH",strTemp,false)%>
        </select>
        <a href="javascript:viewList('CM_PRELOAD_ACAD_ACH','PRE_ACAD_INDEX','PRE_ACAD_NAME','ACHIEVEMENT');"><img src="../../images/update.gif" width="60" height="26" border="0"></a> 
        <font size="1">click to update list of achievements</font></td>
    </tr>
	
<%
		if (vEditInfo!= null)
			strTemp = WI.getStrValue((String)vEditInfo.elementAt(4));
		else{
		strTemp  = WI.fillTextValue("sy_from");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");}
%>
    <tr>
      <td height="27"><strong>SCHOOL YEAR / TERM :</strong></td>
      <td width="16%"> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>- 
<%
	if (vEditInfo!= null)
		strTemp = WI.getStrValue((String)vEditInfo.elementAt(5));
	else{
	strTemp  = WI.fillTextValue("sy_to");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	}
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"></td>
      <td width="60%">
<%
	if (vEditInfo!= null)
		strTemp = WI.getStrValue((String)vEditInfo.elementAt(6));
	else{		
	strTemp  = WI.fillTextValue("semester");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	}
%>
       <select name="semester" id="semester">
          <option value="1">1st</option>
          <% if (strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}
		  if (strSchCode.startsWith("CPU")) { 
		  	if (strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if (strTemp.compareTo("4") == 0){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}
		  } // 
		  
		  if (strTemp.compareTo("0") == 0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select>
        </td>
    </tr>
    <tr>
      <td width="24%"><strong>DATE OF AWARDING :</strong></td>
      <td colspan="2"><p> 
<%
	if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(7));
	else strTemp= WI.fillTextValue("date_award");
%>
          <input name="date_award" type="text" class="textbox" id="date_award" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"  size="12" maxlength="12" readonly>
          &nbsp;<a href="javascript:show_calendar('form_.date_award');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		  <img src="../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
          <font size="1"> </font></p></td>
    </tr>
    <tr>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="3"> <div align="center">
<% if (iAccessLevel > 1){ 
	if(vEditInfo  == null){%>
<input type="submit" name="122" value=" Save Information " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('1', '');">
&nbsp;&nbsp;
<%}else{%>
		<input type="submit" name="12" value=" Edit Information " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="EditRecord();">
	  <a href='javascript:CancelEdit();'><img src="../../images/cancel.gif" border="0"></a>
	  <font size="1">click to cancel or go previous</font>
<%}}%>		  
		  </div></td>
    </tr>

    <tr>
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
<%}
 if (vRetResult != null) {%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#BDD5DF"> 
      <td height="25" colspan="4"><div align="center"><strong>LIST OF ACADEMIC 
          AWARDS RECEIVED</strong></div></td>
    </tr>
    <tr> 
      <td height="25"><strong>NAME OF AWARD ( SY, TERM)</strong></td>
      <td><strong>DATE AWARDED</strong></td>
      <td><strong>EDIT</strong></td>
      <td><strong>DELETE</strong></td>
    </tr>
<% for (int i = 0 ; i< vRetResult.size(); i+=8){%>
    <tr> 
      <td width="54%" height="25"><%=(String)vRetResult.elementAt(i+3)%> (<%=WI.getStrValue((String)vRetResult.elementAt(i+4),"","","") + 
	  WI.getStrValue((String)vRetResult.elementAt(i+5)," - ","","") +  
	  astrConvSem[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+6),"","","0"))]%>)</td>
      <td width="26%"><%=(String)vRetResult.elementAt(i+7)%></td>
      <td width="8%"><% if (iAccessLevel > 1){%> 
	  	<input type="submit" name="13" value=" Edit " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')">
      <%}else{%>N/A<%}%></td>
      <td width="12%"> <% if (iAccessLevel == 2){ %> 
	 	 <input type="submit" name="13" value=" Delete " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('0','<%=(String)vRetResult.elementAt(i)%>')">
      <%}else{%>N/A<%}%> </td>
    </tr>
<%} // end fro lopp%>
  </table>
<%}
} // end vStudBasicInfo != null%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
  <tr bgcolor="#FFFFFF">
      <td height="25">
  </tr>
  <tr bgcolor="#6A99A2">
    <td height="25">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="opner_form_name" value="form_">
<input type="hidden" name="page_action">
<input type="hidden" name="print_page">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="is_student" value="<%=WI.fillTextValue("is_student")%>">
</form>
</body>
</html>

