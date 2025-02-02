<%@ page language="java" import="utility.*,java.util.Vector,ClassMgmt.CMLessonPlan" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-CLASS MANAGEMENT-Assignments/Homeworks","cm_assignment.jsp");
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
														"cm_assignment.jsp");	
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
CMLessonPlan cm = new CMLessonPlan();
Vector vRetResult = null;
Vector vEditInfo = null;
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strPageAction = WI.fillTextValue("page_action");


if (strPageAction.compareTo("0") == 0){
	vRetResult = cm.operateOnLPSub(dbOP,request,0);
	if (vRetResult != null)
		strErrMsg = " Sub Description removed successfully";
	else
		strErrMsg = cm.getErrMsg();
}else if (strPageAction.compareTo("1") == 0){
	vRetResult = cm.operateOnLPSub(dbOP,request,1);
	if (vRetResult != null)
		strErrMsg = " Sub Description added successfully";
	else
		strErrMsg = cm.getErrMsg();
}else if (strPageAction.compareTo("2") == 0){
	vRetResult = cm.operateOnLPSub(dbOP,request,2);
	if (vRetResult != null){
		strErrMsg = " Sub Description edited successfully";
		strPrepareToEdit ="";
	}else
		strErrMsg = cm.getErrMsg();
}

if (strPrepareToEdit.compareTo("1") == 0){
	vEditInfo = cm.operateOnLPSub(dbOP,request,3,true);
	if (vEditInfo == null && cm.getErrMsg() != null){
		strErrMsg = cm.getErrMsg();
	}
}

vRetResult = cm.operateOnLPSub(dbOP,request,4,true);
	if (vRetResult == null && strErrMsg == null){
		strErrMsg = cm.getErrMsg();
	}

%>
<html>
<head>
<title>Lesson Plan Headers</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
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
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex){
	document.form_.page_action.value ="";
	document.form_.info_index.value = strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	document.form_.print_page.value ="";
	this.SubmitOnce("form_");
}
function CancelRecord(){
	location = "./lp_sub.jsp?header=" + document.form_.header.value+"&header_name="+
	escape(document.form_.header_name.value);
}

function PrintPg(){
	document.form_.print_page.value = "1";
	document.form_.sem_label.value = document.form_.offering_sem[document.form_.offering_sem.selectedIndex].text;
	document.form_.subj_label.value = document.form_.subject[document.form_.subject.selectedIndex].text;
	this.SubmitOnce("form_");
}

function UpdateRecord(strInfoIndex,strHeaderName){
	location = "./lp_sub.jsp?header=" + strInfoIndex+"&header_name="+escape(strHeaderName);
}

function  ShowHideDetail() {
	//strShow = 1 , show the table rows. else hide the table rows.
	var strShow = 0;
	if(document.form_.show_drop.checked)
		this.showLayer('tr_1');
	else
		this.hideLayer('tr_1');
}

-->
</script>

<body bgcolor="#93B5BB">
<form name="form_" method="post" action="./lp_sub.jsp">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#6A99A2"> 
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          LESSON PLAN SUB DESCRIPTION PAGE::::</strong></font></div></td>
    </tr>
    <tr> 
      <td width="72%" height="25">&nbsp;&nbsp;<strong><font size="2" color="#FF0000"> <%=WI.getStrValue(strErrMsg,"MESSAGE: ","","")%></font></strong></td>
      <td width="28%" height="25"><a href="lp_header.jsp"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a>click 
        to return to headers</td>
    </tr>
  </table>
    <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><strong>Header</strong></td>
      <td height="25" nFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <strong><%=WI.fillTextValue("header_name")%></strong> 
        <input name="header_name" type="hidden" value="<%=WI.fillTextValue("header_name")%>">
	 <input name="header" type="hidden" value="<%=WI.fillTextValue("header")%>">
	 </td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="21%" height="25"><div align="left"><strong>Order No.</strong></div></td>
      <td width="76%" height="25" nFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <%if(vEditInfo!= null) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(5));
 else 
	strTemp = WI.fillTextValue("order_no");%> <input name="order_no" type="text"   class="textbox" id="order_no"   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 	onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	value="<%=strTemp%>" size="3" maxlength="2"> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><strong>Sub Description </strong></td>
      <td height="25" > <%if(vEditInfo!= null) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(4));
 else 
	strTemp = WI.fillTextValue("sub_header");%> 
        <input name="sub_header" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  value="<%=strTemp%>" size="48" maxlength="64">
      </td>
    </tr>
    <tr> 
      <td height="25" colspan="3" align="center">
<% 	if (iAccessLevel > 1){
	  if(vEditInfo == null) { %> 
	  <a href="javascript:AddRecord()"><img border="0" src="../../../images/add.gif" width="42" height="32"></a> 
        <font size="1">click to add record</font> <%     
  }else{ %> <a href="javascript:EditRecord()"><img src="../../../images/edit.gif" width="40" height="26" border="0"></a> 
        <font size="1">click to save changes </font><a href='javascript:CancelRecord();'><img src="../../../images/cancel.gif" width="51" height="26" border="0"></a> 
        <font size="1">click to cancel edit</font> <%}}%> </td>
    </tr>
    <tr> 
      <td height="25" colspan="3" align="center"><div align="right"></div></td>
    </tr>
  </table>
<%if (vRetResult != null && vRetResult.elementAt(3) != null){%>
  <table width="100%" border="1" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#EBF5F5"> 
      <td height="25" colspan="4"><div align="center"><strong>LIST OF SUB DESCRIPTIONS 
          </strong></div></td>
    </tr>
    <tr> 
      <td width="18%" height="25"><div align="center"><font size="1"><strong>ORDER 
          NO </strong></font></div></td>
      <td width="58%"><div align="center"><font size="1"><strong>SUB DESCRIPTION 
          NAME</strong></font></div></td>
      <td colspan="2"><div align="center"><strong><font size="1">OPTIONS</font></strong></div></td>
    </tr>
    <% for (int i = 0; i < vRetResult.size(); i+=6) {%>
    <tr> 
      <td height="34" align="center"><%=(String)vRetResult.elementAt(i+5)%></td>
      <td><%=(String)vRetResult.elementAt(i+4)%></td>
      <td width="5%"><a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i+3)%>)"><img src="../../../images/edit.gif"  border="0" ></a></td>
      <td width="8%"><a href="javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i+3)%>)"><img src="../../../images/delete.gif"  border="0"></a></td>
    </tr>
    <%} // end of for loop%>
  </table>
<%}// vRetREsult != null%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#6A99A2"> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
<input type="hidden" name="print_page">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>