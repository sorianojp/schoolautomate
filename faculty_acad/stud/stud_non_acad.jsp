<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function CancelEdit(){
	location = "./stud_non_acad.jsp?stud_id="+ document.form_.stud_id.value;
}

function ReloadPage(){
	this.SubmitOnce('form_');
}


function PageAction(strAction, strInfoIndex) {
	document.form_.print_page.value="";
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
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
int iAccessLevel = 0;
if (bolIsStudent)
	iAccessLevel = 1;
else {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Faculty/Acad. Admin","ALL",request.getRemoteAddr(), 
															"stud_non_acad.jsp");
															
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
}

//end of authenticaion code.
	OfflineAdmission offlineAdm = new OfflineAdmission();
	Vector vStudBasicInfo = null;
	Vector vRetResult = null;
	Vector vEditInfo = null;
	CMStudPerformance cm = new CMStudPerformance();
	String strPageAction = WI.fillTextValue("page_action");
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	String[] astrConvSem = {", Summer", ", 1st Semester",", 2nd Semester",",3rd Semester", ", 4th Semester"};

	String strStudID = null;
	if(bolIsStudent) {
		strStudID = (String)request.getSession(false).getAttribute("userId");
		request.setAttribute("LoggedInStudIndex",request.getSession(false).getAttribute("userIndex"));
	}
	else
		strStudID = WI.fillTextValue("stud_id");
	if(strStudID == null)
		strStudID = "";
	
	if (strStudID.length() > 0){
		vStudBasicInfo = offlineAdm.getStudentBasicInfo(dbOP, strStudID);
		if (vStudBasicInfo == null)
			strErrMsg = offlineAdm.getErrMsg();
	}
	if(vStudBasicInfo != null && strStudID.length() > 0) { 	
		if (strPageAction.compareTo("0") == 0){
			vRetResult = cm.operateOnNonAcadAchievement(dbOP,request,0);
			if (vRetResult != null)
				strErrMsg = " Achievement removed successfully";
			else
				strErrMsg = cm.getErrMsg();
		}else if (strPageAction.compareTo("1") == 0){
			vRetResult = cm.operateOnNonAcadAchievement(dbOP,request,1);
			if (vRetResult != null)
				strErrMsg = " Achievement added successfully";
			else
				strErrMsg = cm.getErrMsg();
		}else if (strPageAction.compareTo("2") == 0){
			vRetResult = cm.operateOnNonAcadAchievement(dbOP,request,2);
			if (vRetResult != null){
				strErrMsg = " Achievement edited successfully";
				strPrepareToEdit ="";
			}else
				strErrMsg = cm.getErrMsg();
		}
		vRetResult =  cm.operateOnNonAcadAchievement(dbOP,request,4);
		if (vRetResult == null)
			strErrMsg = cm.getErrMsg();
	}
	
if (strPrepareToEdit.equals("1")){
	vEditInfo = cm.operateOnNonAcadAchievement(dbOP,request,3);
	if (vEditInfo == null)
		strErrMsg = cm.getErrMsg();
}

	if(bolIsStudent)
		request.removeAttribute("LoggedInStudIndex");

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
<form name="form_" method="post" action="./stud_non_acad.jsp" onSubmit="SubmitOnceButton(this);">
<% if (bolIsStudent) { %>
<input name="stud_id" type="hidden" value="<%=strStudID%>"> 
<%}%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#6A99A2"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: 
          STUDENT NON-ACADEMIC ACHIEVEMENT MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4">&nbsp;<%=WI.getStrValue(strErrMsg, "<font size=\"3\" color=\"#FF0000\">","</font>","")%></td>
    </tr>
<% if (!bolIsStudent) {%>	
    <tr bgcolor="#FFFFFF"> 
      <td width="15%" height="25">&nbsp;STUDENT ID</td>
      <td width="22%"><input name="stud_id" type="text" class="textbox" 
	                    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
						 value="<%=WI.fillTextValue("stud_id")%>" size="15" maxlength="15"> 
        &nbsp;&nbsp;</td>
      <td width="12%"><a href="javascript:OpenSearch();"><img src="../../images/search.gif" border="0"></a></td>
      <td width="51%"><input type="submit" name="1" value=" Reload " style="font-size:11px; height:28px;border: 1px solid #FF0000;"></td>
    </tr>
<%}%>
  </table>
<% if (vStudBasicInfo != null) {%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4"><hr size="1"> </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3">&nbsp; 
        Student Name :<strong> <%=WI.formatName((String)vStudBasicInfo.elementAt(0),(String)vStudBasicInfo.elementAt(1),(String)vStudBasicInfo.elementAt(2),4)%></strong></td>
      <td width="55%">Course : <strong><%=(String)vStudBasicInfo.elementAt(7)%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3">&nbsp; 
        Year Level : <strong><%=(String)vStudBasicInfo.elementAt(14)%></strong></td>
      <td>Major  : <strong><%=WI.getStrValue((String)vStudBasicInfo.elementAt(8),"&nbsp")%></strong></td>
    </tr>
<!--
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4"><div align="center">&nbsp;
	    <% if (bolIsStudent) {%> 
	      <a href="javascript:ReloadPage()"><img src="../../images/refresh.gif" border="0"> </a>
          <%}%> 
      </div></td>
   </tr>
-->
  </table>
<% if (!bolIsStudent) {%>	
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="2" cellspacing="0">
    <tr> 
      <td style="font-weight:bold; font-size:10px;">Achievement Name</td>
      <td>
<%
	if (vEditInfo != null) 
		strTemp = WI.getStrValue((String)vEditInfo.elementAt(2));
	else 
		strTemp= WI.fillTextValue("PRE_NON_ACAD_INDEX");
%>
	  <select name="PRE_NON_ACAD_INDEX">
<%=dbOP.loadCombo("distinct PRE_NON_ACAD_INDEX","PRE_NON_ACAD_NAME", " from CM_PRELOAD_NON_ACAD_ACH",strTemp,false)%>
       </select>
        <a href="javascript:viewList('CM_PRELOAD_NON_ACAD_ACH','PRE_NON_ACAD_INDEX','PRE_NON_ACAD_NAME','ACHIEVEMENT');">
		<img src="../../images/update.gif" width="60" height="26" border="0"></a> 
        <font size="1">Update list of achievements</font></td>
    </tr>
    <tr> 
      <td height="27" style="font-weight:bold; font-size:10px;">Awarding Organization</td>
      <td> 
<%
	if (vEditInfo != null) 
		strTemp = WI.getStrValue((String)vEditInfo.elementAt(4));
	else 
		strTemp= WI.fillTextValue("pre_org_index");
%>
        <select name="pre_org_index">
<%=dbOP.loadCombo("PRE_ORG_INDEX","PRE_ORG_NAME", " from CM_PRELOAD_ORG order by PRE_ORG_NAME",strTemp,false)%>
        </select>
        <a href="javascript:viewList('CM_PRELOAD_ORG','PRE_ORG_INDEX','PRE_ORG_NAME','ORGANIZATIONS');">
			<img src="../../images/update.gif" width="60" height="26" border="0"></a>
		<font size="1">Update list of awarding organizations/institution</font></td>
    </tr>
    <tr> 
      <td width="17%" style="font-weight:bold; font-size:10px;">Award Date</td>
      <td width="83%"> 
<%
	if (vEditInfo != null) 
		strTemp = WI.getStrValue((String)vEditInfo.elementAt(6));
	else 
		strTemp= WI.fillTextValue("date_award");
%>
          <input name="date_award" type="text" class="textbox" id="date_award" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"  size="12" maxlength="12" readonly>
          &nbsp;<a href="javascript:show_calendar('form_.date_award');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="2">  <div align="center">
<% if (iAccessLevel > 1){ 
	if(vEditInfo  == null){%>
		<input type="submit" name="122" value=" Save Information " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('1', '');">
<%}else{%>
	  <input type="submit" name="12" value=" Edit Information " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('2','');">
	  &nbsp;&nbsp;&nbsp;
	  <a href='javascript:CancelEdit();'><img src="../../images/cancel.gif" width="51" height="26" border="0"></a>
	  <font size="1">click to cancel or go previous</font>
<%}}%>		  
		  </div></td>
    </tr>
    <tr> 
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<% }

if(vRetResult != null && vRetResult.size() > 0){%>  
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#BDD5DF"> 
      <td height="25" colspan="5" class="thinborder"><div align="center"><strong>LIST OF NON-ACADEMIC 
          AWARDS RECEIVED</strong></div></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"> <div align="center"><strong>ACHIEVEMENT NAME </strong></div></td>
      <td class="thinborder"><div align="center"><strong>AWARDING ORGANIZATION</strong></div></td>
      <td class="thinborder"><div align="center"><strong>DATE AWARDED</strong></div></td>
      <td class="thinborder"><div align="center"><strong>EDIT</strong></div></td>
      <td class="thinborder"><div align="center"><strong>DELETE</strong></div></td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 7) {%>
    <tr> 
      <td width="32%" height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td width="37%" class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td width="21%" class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%> </td>
      <td width="10%" class="thinborder"> 
	  <% if (iAccessLevel > 1){%> 
	  	<input type="submit" name="13" value=" Edit " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')">
      <%}else{%>N/A<%}%></td>
      <td width="10%" class="thinborder"> <% if (iAccessLevel == 2){ %> 
      <input type="submit" name="132" value=" Delete " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('0','<%=(String)vRetResult.elementAt(i)%>')">
      <%}else{%>N/A<%}%> </td>
    </tr>
<%}%>
  </table>
<%}
}//show only if student information is not null. %>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
  <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
  </tr>
  <tr bgcolor="#6A99A2">
    <td height="25">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="print_page">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="is_student" value="<%=WI.fillTextValue("is_student")%>">
</form>
</body>
</html>

