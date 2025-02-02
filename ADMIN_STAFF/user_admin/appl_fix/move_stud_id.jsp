<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	this.SubmitOnce('form_');		
}
function MoveInfo(strMoveID) {
	document.form_.move_id.value = strMoveID;
	this.SubmitOnce("form_");
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.form_.stud_id_fr.focus();
}
function ShowHideSYTerm() {
	if(document.form_.move_allsy.checked) {
		this.hideLayer('sy_from');
		this.hideLayer('semester');
	}
	else {
		this.showLayer('sy_from');
		this.showLayer('semester');
	}
}
</script>

<body bgcolor="#D2AE72" onLoad="FocusID();ShowHideSYTerm();">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Program fix-Move Wrong ID",
								"move_stud_id.jsp");

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
														"System Administration","Application Fix",request.getRemoteAddr(),
														"move_stud_id.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vStudIDFr = null;
Vector vStudIDTo = null;

String strSYToMove  = WI.fillTextValue("sy_from");
String strSemToMove = WI.fillTextValue("semester");
if(WI.fillTextValue("move_allsy").length() > 0 || strSYToMove.length() == 0) {
	strSYToMove  = null;
	strSemToMove = null;
}
AllProgramFix progFix = new AllProgramFix();
if(WI.fillTextValue("stud_id_fr").length() > 0 && WI.fillTextValue("stud_id_to").length() > 0) {
	if(WI.fillTextValue("move_id").length() > 0) {
		//move here. 
		if(progFix.moveIDInfo(dbOP, WI.fillTextValue("stud_id_fr"),WI.fillTextValue("stud_id_to"), 
			Integer.parseInt(WI.fillTextValue("move_id")), strSYToMove , strSemToMove )) {
			strErrMsg = "Student information moved successfully. Please verify enrollment information, grade sheet information  and account information "+
			"of student :"+WI.fillTextValue("stud_id_to");			
		}
		else
			strErrMsg = progFix.getErrMsg();
	}
	vStudIDFr = progFix.getMoveIDInfo(dbOP, WI.fillTextValue("stud_id_fr"),WI.fillTextValue("stud_id_to"));
	if(vStudIDFr == null)
		strErrMsg = progFix.getErrMsg();
	else {
		vStudIDTo = (Vector)vStudIDFr.elementAt(1);
		vStudIDFr = (Vector)vStudIDFr.elementAt(0);
	}
}


%>


<form name="form_" action="./move_stud_id.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          MOVE STUDENT INFORMATION FROM WRONG ID ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td colspan="2"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="49%"><font color="#FF6600"><strong>WRONG ID</strong></font></td>
      <td width="48%">CORRECT ID</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><input name="stud_id_fr" type="text" size="16" value="<%=WI.fillTextValue("stud_id_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td><input name="stud_id_to" type="text" size="16" value="<%=WI.fillTextValue("stud_id_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><input name="move_allsy" type="checkbox" value="checked" <%=WI.fillTextValue("move_allsy")%> onClick="ShowHideSYTerm();">Move for all SY/term 
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>	  
	  <input name="sy_from" type="text" class="textbox" id="sy_from" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=strTemp%>" size="4" maxlength="4"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"  onKeyUp="DisplaySYTo('form_','sy_from','sy_to');">
	  
	  <select name="semester" id="semester">
          <option value="1">1st</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";

if(strTemp.compareTo("2") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="2" <%=strErrMsg%>>2nd</option>
<%if(strTemp.compareTo("3") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="3"<%=strErrMsg%>>3rd</option>
<%if(strTemp.compareTo("0") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="0"<%=strErrMsg%>>Summer</option>
        </select>
	  </td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td colspan="2" align="center"><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a>
	  <font size="1"> Click to view information to be moved.</font></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="2">NOTE: After moving the Wrong ID, rename the ID to wrong 
        ID format.</td>
    </tr>
  </table>
<%
if(vStudIDFr != null && vStudIDFr.size() > 0) {
int iMoveCount = 0;//if there are more than 1 move info, i will show move all.%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
    <tr> 
      <td height="25" colspan="3" bgcolor="#3366FF" align="center" class="thinborderBOTTOM"><font color="#FFFFFF"><b> 
        ::: STUDENT RECORD INFORMATION TO BE MOVED ::: </b></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="2" align="center" bgcolor="#FFFFAF" class="thinborderBOTTOMRIGHT"><font size="1" color="#FF6600"> 
        <b>WRONG ID INFORMATION</b></font></td>
      <td width="49%" bgcolor="#FFFFAF" align="center" class="thinborderBOTTOM"><font size="1"> 
        <b>CORRECT ID INFORMATION</b></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp; Name : <%=(String)vStudIDFr.elementAt(0)%></td>
      <td class="thinborderLEFT">&nbsp; Name : <%=(String)vStudIDTo.elementAt(0)%></td>
    </tr>
    <%
if( ((String)vStudIDFr.elementAt(3)).compareTo("1") == 0) {++iMoveCount;%>
    <tr> 
      <td width="35%" height="25">&nbsp; Ledger Information</td>
      <td width="16%">&nbsp; <a href="javascript:MoveInfo(1);">Move</a></td>
      <td class="thinborderLEFT">&nbsp;</td>
    </tr>
    <%}
if( ((String)vStudIDFr.elementAt(2)).compareTo("1") == 0 || 
		((String)vStudIDFr.elementAt(1)).compareTo("1") == 0) {++iMoveCount;%>
    <tr> 
      <td height="25"><p>&nbsp; Grade and Enrollment Information</p></td>
      <td>&nbsp; <a href="javascript:MoveInfo(3);">Move </a></td>
      <td class="thinborderLEFT">&nbsp;</td>
    </tr>
    <%}
if( iMoveCount > 1) {%>
    <tr> 
      <td height="25">&nbsp; MOVE ALL</td>
      <td>&nbsp; <a href="javascript:MoveInfo(0);">Move all</a></td>
      <td class="thinborderLEFT">&nbsp;</td>
    </tr>
    <%}%>
  </table>
<%}//only if student info exists.
%>

<table width="100%" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
</table>
<input type="hidden" name="move_id">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
