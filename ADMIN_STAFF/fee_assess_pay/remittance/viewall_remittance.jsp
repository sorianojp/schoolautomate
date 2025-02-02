<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%@ page language="java" import="utility.*,enrollment.FARemittance ,search.SearchStudent,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strORNumber = null;

//add security here.

	if (WI.fillTextValue("view_detail").length() > 0){%>
		<jsp:forward page="./viewall_remittance_print.jsp" />		
<%	return;}
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REMITTANCE-Receive Remittance","receive_remittance.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<body bgcolor="#D2AE72"><p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","REMITTANCE",request.getRemoteAddr(),
														"receive_remittance.jsp");
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
String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"=",">","<"};


Vector vRetResult = null;
FARemittance faR = new FARemittance(request);
SearchStudent searchStud = new SearchStudent(request);

vRetResult = faR.viewAllRemittances(dbOP);

if (vRetResult == null){
	strErrMsg = faR.getErrMsg();
}

int iCtr = 0;
%>


<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">

function ReloadPage(){
	document.form_.result_show.value ="";
	document.form_.view_detail.value ="";
	this.SubmitOnce("form_");
}

function ShowResult(){
	document.form_.result_show.value ="1";
	document.form_.view_detail.value ="";
	this.SubmitOnce("form_");
}

function ClearDates(){
	document.form_.date_from.value = "";
	document.form_.date_to.value = "";
}

function ShowDetail(strInfoIndex){
	document.form_.type_.value = strInfoIndex;
	document.form_.view_detail.value ="1";
	this.SubmitOnce("form_");
}

function ShowAll(){
	document.form_.view_detail.value ="1";
	document.form_.type_.value = "";
	this.SubmitOnce("form_");
}

function PrintPg(){

	var strInfo = "<div align=\"center\"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> </div>";
	document.bgColor = "#FFFFFF";
	document.getElementById('myTable1').deleteRow(0);
	document.getElementById('myTable1').deleteRow(0);
		
	for (i =0; i < 12; ++i){
		document.getElementById('myADTable').deleteRow(0);
	}
	this.insRow(0, 1, strInfo);
	
	
	document.getElementById('myTable3').deleteRow(0);
	document.getElementById('myTable4').deleteRow(0);
	
	var iCount = eval(document.form_.cntr_display.value);
	for (i=0 ; i < iCount; ++i){
		eval('document.form_.view'+i+'.src = \"../../../images/blank.gif\"');
	}
}
</script>
</head>
<body bgcolor="#D2AE72">
<form name="form_" method="post" action="./viewall_remittance.jsp">
  <table width="100%" border="0" id="myTable1" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" ><strong>:::: 
          REMITTANCE SEARCH PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" id="myADTable" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom">Date of Remittance</td>
      <td height="25"><font size="1">From 
        <input name="date_from" type="text"  class="textbox" value="<%=WI.fillTextValue("date_from")%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="12" readonly="true">
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to 
        <input name="date_to" type="text" size="12"  class="textbox" value="<%=WI.fillTextValue("date_to")%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="true">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:ClearDates()"><img src="../../../images/clear.gif" width="55" height="19" border="0"></a> 
        click to clear dates</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom">Type of Remittance :</td>
      <td height="25"><strong> 
        <select name="preload_remit_index" id="select3" onChange="ReloadPage()">
          <option value="">Select a type</option>
          <%=dbOP.loadCombo("preload_remit_index","preload_remit_name"," from preload_remittance order by preload_remit_name", request.getParameter("preload_remit_index"), false)%> 
        </select>
        </strong></td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="20%" height="25" valign="bottom">Account Name : </td>
      <td height="25"><strong> 
        <% strTemp= "";
		if (WI.fillTextValue("preload_remit_index").length() > 0) {
	 	  	strTemp = " and preload_remit_index = " + WI.fillTextValue("preload_remit_index"); }%>
        <select name="type" id="select2" onChange="ReloadPage()">
          <option value="">Select a type</option>
          <%=dbOP.loadCombo("REMIT_TYPE_INDEX","TYPE_NAME"," from FA_REMIT_TYPE where IS_VALID=1 " + strTemp +" order by TYPE_NAME asc ", WI.fillTextValue("type"), false)%> 
        </select>
        </strong> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom">College : </td>
      <td height="25"><strong> 
        <select name="c_index" id="office" onChange="ReloadPage();">
          <option value="">Select a College</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc ", WI.fillTextValue("c_index"), false)%> 
        </select>
        </strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom">Department / Office : </td>
      <td height="25"><strong> 
        <select name="d_index" id="select" onChange="ReloadPage();">
          <% if (WI.fillTextValue("c_index").length() != 0) {%>
          <option value="">Select a Department</option>
          <%=dbOP.loadCombo("d_index","d_name"," from department where IS_DEL=0 and c_index = " + WI.fillTextValue("c_index") + " order by d_name asc", WI.fillTextValue("d_index"), false)%> 
          <%}else{%>
          <option value="">Select a Office</option>
          <%=dbOP.loadCombo("d_index","d_name"," from department where IS_DEL=0 and c_index is null order by d_name asc", WI.fillTextValue("d_index"), false)%> 
          <%}%>
        </select>
        </strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom">Amount Remitted :</td>
      <td height="25"><strong> 
        <select name="amount_con">
          <%=searchStud.constructGenericDropList(WI.fillTextValue("amount_con"),astrDropListGT,astrDropListValGT)%> 
        </select>
        <input name="amount" type="text" size="10" value="<%=WI.fillTextValue("amount")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
        </strong> </td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%" height="25" valign="bottom">Remitted by :</td>
      <td height="25"><strong> 
        <select name="remit_by_con">
          <%=searchStud.constructGenericDropList(WI.fillTextValue("remit_by_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select>
        <input name="remit_by" type="text" size="24" value="<%=WI.fillTextValue("remit_by")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom">Description : </td>
      <td height="25"><strong> 
        <select name="desc_con">
          <%=searchStud.constructGenericDropList(WI.fillTextValue("desc_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select>
        <input name="description" type="text" size="32" maxlength="64" value="<%=WI.fillTextValue("description")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </strong></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td>Teller : </td>
      <td><strong> 
        <% strTemp = " from fa_remittance join user_table on (fa_remittance.received_by = user_table.user_index) where " +
	  	  " user_table.is_valid = 1 and user_table.is_del = 0 "; %>
        <select name="cashier">
          <option value="">ANY</option>
          <%=dbOP.loadCombo("distinct received_by","id_number", strTemp, WI.fillTextValue("cashier"), false)%> 
        </select>
        </strong></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td colspan="2">Include in detail result: 
        <% strTemp = ""; if (WI.fillTextValue("_description").length() > 0) strTemp = "checked"; %> <input name="_description" type="checkbox" id="_description" value="1"<%=strTemp%>>
        Description 
        <% strTemp = ""; if (WI.fillTextValue("_teller").length() > 0) strTemp = "checked"; %> <input name="_teller" type="checkbox" id="_teller" value="1" <%=strTemp%>>
        Teller &nbsp;&nbsp; <% strTemp = ""; if (WI.fillTextValue("_date").length() > 0) strTemp = "checked"; %> <input name="_date" type="checkbox" id="_date" value="1" <%=strTemp%>>
        Date &nbsp; <% strTemp = ""; if (WI.fillTextValue("_date").length() > 0) strTemp = "checked"; %> <input name="_office" type="checkbox" id="_office" value="1" <%=strTemp%>>
        College / Office&nbsp;</td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td colspan="2"><strong> </strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26" colspan="2"><a href="javascript:ShowResult()"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr> 
      <td colspan="3" height="25">&nbsp;</td>
    </tr>
  </table>
  <% if(vRetResult != null && vRetResult.size() > 0 && WI.fillTextValue("result_show").length() > 0){%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable3" bgcolor="#FFFFFF">
    <tr> 
      <td width="54%" height="25"><strong><font color="#0000FF">&nbsp;&nbsp;<a href="javascript:ShowAll()">View 
        ALL Detail</a></font></strong></td>
      <td width="46%" align="right">&nbsp;<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border=0></a><font size="1"> 
        click to print&nbsp;&nbsp;<strong><font color="#FFFFFF"> </font></strong></font></td>
    </tr>
    <tr bgcolor="#CCCCCC"> 
      <td height="25" colspan="2" class="thinborderALL"><div align="center"><strong><font color="#000000">LIST 
          OF REMITTANCES</font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center"> 
      <td width="26%" height="25" class="thinborder"><strong>TYPE OF REMITTANCE</strong></td>
      <td width="34%" class="thinborder"><strong>ACCOUNT NAME</strong></td>
      <td width="33%" class="thinborder"><strong>AMOUNT</strong></td>
      <td width="7%" class="thinborder">&nbsp;</td>
    </tr>
    <% 
		for (int i = 0 ; i < vRetResult.size(); i+=5, ++iCtr) {
	%>
    <tr align="center"> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder">&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+2),true)%></td>
      <td class="thinborder">&nbsp;<a href="javascript:ShowDetail(<%=(String)vRetResult.elementAt(i+1)%>)"><img border=0 src="../../../images/view.gif" id="view<%=iCtr%>"></a></td>
    </tr>
    <%}//end for loop%>
  </table>
 <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable4" bgcolor="#FFFFFF">
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table><input type="hidden" name="result_show">
<input type="hidden" name="view_detail">
<input type="hidden" name="type_">
<input type="hidden" name="cntr_display" value="<%=iCtr%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
