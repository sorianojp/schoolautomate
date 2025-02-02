<%@ page language="java" import="utility.*,java.util.Vector,ClassMgmt.CMAssignment" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
//add security here.

	if (WI.fillTextValue("print_page").compareTo("1") == 0){ %>
<jsp:forward page="cm_assignment_dtl_print.jsp" />
<% return;	}
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-CLASS MANAGEMENT-Assignments/Homeworks","cm_assignment_details.jsp");
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
														"Faculty/Acad. Admin","CLASS MANAGEMENT",request.getRemoteAddr(), 
														"cm_assignment_details.jsp");	
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
	String strEmployeeID = (String)request.getSession(false).getAttribute("userId");
	String strEmployeeIndex = dbOP.mapUIDToUIndex(strEmployeeID);
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	Vector vRetResult = null;
	Vector vAssignInfo = null;
	Vector vEditInfo = null;
	String strPageAction = WI.fillTextValue("page_action");
	String strSubSecIndex = WI.fillTextValue("sub_sec_index");
	String strAssignIndex = WI.fillTextValue("info_index");
	String[] astrSem= {"SUMMER", "1ST SEMESTER", "2ND SEMESTER","3RD SEMESTER","4TH SEMESTER"};

CMAssignment cm = new CMAssignment();

if (strSubSecIndex != null && strSubSecIndex.length() > 0){
	vAssignInfo = cm.operateOnAssignment(dbOP,request,3, strSubSecIndex);
	if(vAssignInfo == null)
		strErrMsg = cm.getErrMsg();
}

if (strPageAction.compareTo("0")==0) {
	vRetResult = cm.operateOnAssignmentDetail(dbOP,request,0, strAssignIndex);
	if (vRetResult != null)
		strErrMsg = " Question successfully removed";
	else
		strErrMsg = cm.getErrMsg();
}else if (strPageAction.compareTo("1") == 0){
	vRetResult = cm.operateOnAssignmentDetail(dbOP,request,1, strAssignIndex);
	if (vRetResult != null)
		strErrMsg = " Question successfully added";
	else
		strErrMsg = cm.getErrMsg();
}else if (strPageAction.compareTo("2") == 0){
	vRetResult = cm.operateOnAssignmentDetail(dbOP,request,2, strAssignIndex);
	if (vRetResult != null){
		strErrMsg = " Question successfully edited";
		strPrepareToEdit = "";
	}else
		strErrMsg = cm.getErrMsg();
}

if (strPrepareToEdit.compareTo("1") == 0){
	vEditInfo = cm.operateOnAssignmentDetail(dbOP,request,3, strAssignIndex);
	if (vEditInfo == null)
		strErrMsg = cm.getErrMsg();
}

if (strAssignIndex.length() > 0){
	vRetResult = cm.operateOnAssignmentDetail(dbOP,request,4, strAssignIndex);
	if (vRetResult == null && cm.getErrMsg() != null){
		strErrMsg = cm.getErrMsg();
	}
}

%>
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

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>

</head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
<!--
function ReloadPage(){
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function ReloadSection(){
	document.form_.subject.value="";
	ReloadPage();
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.print_page.value = "";
	document.form_.prepareToEdit.value ="";
	this.SubmitOnce("form_");
}

function EditRecord(){
	document.form_.page_action.value = "2";
	document.form_.print_page.value = "";
	document.form_.prepareToEdit.value ="";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.prepareToEdit.value ="";
	document.form_.page_action.value = "0";
	document.form_.print_page.value = "";
	document.form_.info_index2.value = strInfoIndex;
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex){
	document.form_.page_action.value ="";
	document.form_.info_index2.value = strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	document.form_.print_page.value ="";
	this.SubmitOnce("form_");
}
function CancelRecord(){
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value ="";

	document.form_.detail_name.value = "";
	document.form_.order.value = "";
	
	this.ReloadPage();		
}

function PrintPg(){
	document.form_.print_page.value = "1";
	this.SubmitOnce("form_");
}

function goBack(){
	location = "./cm_assignment.jsp?section_name="+escape(document.form_.section_name.value)+
	"&subject="+document.form_.subject.value+"&sy_from="+document.form_.sy_from.value+
	"&offering_sem="+document.form_.offering_sem.value+"&sy_to="+document.form_.sy_to.value;
}

-->
</script>

<body bgcolor="#93B5BB">
<form name="form_" method="post" action="./cm_assignment_detail.jsp">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#6A99A2"> 
      <td height="25"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          CLASS ASSIGNMENT MAINTENANCE PAGE::::</strong></font></div></td>
    </tr>
    <tr> 
      <td width="65%" height="25">&nbsp;&nbsp;<strong> <a href="javascript:goBack();"><img src="../../images/go_back.gif" alt="Click to go back to previous page" width="50" height="27" border="0"></a> 
        </strong><font size="1">&nbsp;</font><strong><font size="2" color="#FF0000"> 
        <%=WI.getStrValue(strErrMsg,"MESSAGE: ","","")%></font></strong></td>

    </tr>
  </table>
<% if (vAssignInfo != null){ %>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="3%" align="center">&nbsp;</td>
      <td width="12%" align="center"><div align="left">Subject </div></td>
      <td width="42%" ><strong><%=dbOP.mapOneToOther("subject","is_del","0","sub_code"," and sub_index = " + WI.fillTextValue("subject"))%></strong></td>
      <td width="12%" >Section</td>
      <td width="31%" ><strong><%=WI.fillTextValue("section_name")%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td align="center">&nbsp;</td>
      <td>Assignment </td>
      <td><strong><%=(String)vAssignInfo.elementAt(2)%></strong></td>
      <td>SY:: Term</td>
      <td><strong><%=WI.fillTextValue("sy_from") +" - " + WI.fillTextValue("sy_to") + " :: " + astrSem[Integer.parseInt(WI.fillTextValue("offering_sem"))] %></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td align="center">&nbsp;</td>
      <td>Date Given</td>
      <td><strong><%=(String)vAssignInfo.elementAt(3)%></strong></td>
      <td>Last Date of Submission</td>
      <td><strong><font color="#0000EE"><%=(String)vAssignInfo.elementAt(4)%></font></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td align="center">&nbsp;</td>
      <td>Instr. Note </td>
      <td colspan="3"><strong><%=WI.getStrValue((String)vAssignInfo.elementAt(6))%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td align="center">&nbsp;</td>
      <td>Stud. Notes </td>
      <td colspan="3"><strong><%=WI.getStrValue((String)vAssignInfo.elementAt(7))%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td align="center">&nbsp;</td>
      <td>References</td>
      <td colspan="3"><strong><%=WI.getStrValue((String)vAssignInfo.elementAt(5))%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td colspan="5" align="center"><hr size="1" noshade></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="3%" height="25" align="center">&nbsp;</td>
      <td width="18%" height="25"><strong>Order No.</strong></td>
      <td width="79%" height="25"> 
        <%
if(vEditInfo!= null) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(1));
else 
	strTemp = WI.fillTextValue("order");
%> <input name="order" type="text" class="textbox" id="order" onFocus="style.backgroundColor='#D3EBFF'" 
	onblur="style.backgroundColor='white'" value="<%=strTemp%>" size="3" maxlength="3"
    onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" align="center">&nbsp;</td>
      <td height="25" align="center"><div align="left"><strong>Question</strong></div></td>
      <td height="25" align="center"><div align="left"> 
          <%
if(vEditInfo!= null) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(2));
else 
	strTemp = WI.fillTextValue("detail_name");
%>
          <textarea name="detail_name" cols="48" rows="2"   class="textbox" id="detail_name" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="return isMaxLen(this)" maxlength="256" ><%=strTemp%></textarea>
        </div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3" align="center"> <%
 	strTemp = strPrepareToEdit;
    if(WI.getStrValue(strTemp,"0").compareTo("0") == 0) {
		if (iAccessLevel > 1){
%> <a href="javascript:AddRecord()"><img border="0" src="../../images/add.gif" width="42" height="32"></a> 
        <font size="1">click to add record</font> <%     }
  }else{ %> <a href="javascript:EditRecord()"><img src="../../images/edit.gif" width="40" height="26" border="0"></a> 
        <font size="1">click to save changes </font><a href='javascript:CancelRecord();'><img src="../../images/cancel.gif" width="51" height="26" border="0"></a> 
        <font size="1">click to cancel or go previous</font> <%}%> </td>
    </tr>
<%
Vector vSharedBy = null;
if(vAssignInfo != null && vAssignInfo.size() > 0)
	vSharedBy = cm.getListOfSharedAssignment(dbOP, (String)vAssignInfo.elementAt(8), (String)vAssignInfo.elementAt(0));
if(vSharedBy != null) {//it is shared by other assignment.
%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3">This assignment is shared by assignment listed below. Editing or deleting any question below will affect the sharing assignment 
	  <div align="center"><table width="75%" cellpadding="0" cellspacing="0" class="thinborder">
	  	<tr bgcolor="#CCCCCC">
			<td class="thinborder">Assignment Name</td>
			<td class="thinborder">Subject</td>
			<td class="thinborder">Target section</td>
		</tr>
		<%for(int i =0; i < vSharedBy.size(); i += 4) {
			if(vSharedBy.elementAt(i + 3).equals("1"))
				strTemp = " style='color=#FF00FF; font-weight=bold;'";
			else	
				strTemp = "";%>	  	
			<tr bgcolor="#EEEEEE"<%=strTemp%>>
			  <td class="thinborder">&nbsp;<%=(String)vSharedBy.elementAt(i + 2)%></td>
			  <td class="thinborder">&nbsp;<%=(String)vSharedBy.elementAt(i + 1)%></td>
			  <td class="thinborder">&nbsp;<%=(String)vSharedBy.elementAt(i)%></td>
			</tr>
		<%}%>
	  </table>	  
	  </div>
	  </td>
    </tr>
<%}%>
  </table>
<% if (vRetResult != null){%>
  <table width="100%" border="1" cellpadding="2" cellspacing="0">
    <tr bgcolor="#EBF5F5"> 
      <td height="25" colspan="4"><div align="center"><strong>LIST OF QUESTIONS 
          FOR <%=((String)vAssignInfo.elementAt(2)).toUpperCase()%></strong></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="7%" height="25"><div align="center"><font size="1"><strong>NO. 
          </strong></font></div></td>
      <td width="76%"><div align="center"><font size="1"><strong>QUESTION</strong></font></div></td>
      <td colspan="2"><div align="center"><strong>OPTIONS</strong></div></td>
    </tr>
    <% for (int i = 0; i < vRetResult.size(); i+=3) {%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td><%=(String)vRetResult.elementAt(i+2)%></td>
      <td width="7%"><a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../images/edit.gif"  border="0" ></a></td>
      <td width="10%"><a href="javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../images/delete.gif"  border="0"></a></td>
    </tr>
    <%} // end of for loop%>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td colspan="6">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="6"> <div align="center"><a href="javascript:PrintPg();"><img src="../../images/print.gif"  border="0"></a><font size="1">click 
          to print assignment</font></div></td>
    </tr>
  </table>
<%}// vRetREsult != null 
} // vAssignInfo != null%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#6A99A2"> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
<input type="hidden" name="print_page">
<input type="hidden" name="subject" value="<%=WI.fillTextValue("subject")%>">
<input type="hidden" name="section_name" value="<%=WI.fillTextValue("section_name")%>">
<input type="hidden" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>">
<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name="offering_sem" value="<%=WI.fillTextValue("offering_sem")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="info_index2" value="<%=WI.fillTextValue("info_index2")%>">
<input type="hidden" name="sub_sec_index" value="<%=strSubSecIndex%>">

</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>