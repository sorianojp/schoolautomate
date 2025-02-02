<%@ page language="java" import="utility.*,java.util.Vector,hr.HRApplNew"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">
function viewInfo(){
	document.appl_profile.page_action.value = "3";
}

function AddRecord(){
	document.appl_profile.page_action.value="1";
	document.appl_profile.hide_save.src = "../../../images/blank.gif";
	document.appl_profile.submit();
}

function EditRecord(){

	document.appl_profile.page_action.value="2";
	document.appl_profile.submit();
}
function DeleteRecord(){
	if(!confirm('Are you sure you want to delete applicant information premanently from directory.'))
		return;
	
	document.appl_profile.page_action.value="0";
	document.appl_profile.submit();
}
function ReloadPage()
{
	document.appl_profile.submit();
}
function CancelRecord(index)
{
	location = "./new_applicant.jsp";
}

function OpenSearch() {
	var pgLoc = "./applicant_search_name.jsp?opner_info=appl_profile.appl_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function focusID() {
	if(document.appl_profile.appl_id)
		document.appl_profile.appl_id.focus();
}
</script>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;


//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-APPLICANTS DIRECTORY-Profile","new_applicant.jsp");

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","APPLICANTS DIRECTORY",request.getRemoteAddr(),
														"new_applicant.jsp");
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

Vector vRetResult = null;

boolean bolEdit  = false;//if bolEdit = true; information filled up is to edit.
boolean bolNewApplicantID = false;//only if it is created for first time.

String strInfoIndex = null;//this is applicant Index.

HRApplNew hrApplNew = new HRApplNew();

int iAction = -1;

iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"3"));
if (iAction != -1)
	vRetResult = hrApplNew.operateOnApplication(dbOP,request,iAction);
	switch(iAction){
		case 0:{ // delete record
			if (vRetResult != null)
				strErrMsg = " New Applicant  record removed successfully.";
			else
				strErrMsg = hrApplNew.getErrMsg();

			break;
		}
		case 1:{ // add Record
			if (vRetResult != null) {
				strErrMsg = " New Applicant added successfully.";
				bolNewApplicantID = true;
			}
			else
				strErrMsg = hrApplNew.getErrMsg();
			break;
		}
		case 2:{ //  edit record
			if (vRetResult != null)
				strErrMsg = " New Applicant record edited successfully.";
			else
				strErrMsg = hrApplNew.getErrMsg();
			break;
		}
	} //end switch
if(vRetResult != null && vRetResult.size() > 0) {
	strInfoIndex = (String)vRetResult.elementAt(10);
	bolEdit = true;
}

%>
<body bgcolor="#663300" class="bgDynamic" onLoad="focusID();">

<form action="./new_applicant.jsp" method="post" name="appl_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          NEW APPLICANT'S ENTRY PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#FFFFFF">&nbsp;&nbsp;
	  <font size="3" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <% if(!WI.fillTextValue("create").equals("1")){%>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="34%"><strong>APPLICANT ID :</strong>
          <input type="text" name="appl_id" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	  	onBlur="style.backgroundColor='white'" size="16" value="<%=WI.fillTextValue("appl_id")%>">      </td>
      <td width="6%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="57%"><input name="image" type="image" onClick="viewInfo();" src="../../../images/refresh.gif"></td>
    </tr>
    <%} %>
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <%
if(bolNewApplicantID) {//show applicant's generated ID.%>
    <%}//only if applicant is generated for the first time.%>
  </table>

<%//do not show anything , if ID is not entered.. 
if(bolEdit || WI.fillTextValue("create").equals("1")) {%>
	  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr valign="bottom"> 
		  <td width="6%" height="18">&nbsp;</td>
		  <td width="31%"><strong>First name</strong></td>
		  <td width="30%"><strong>Middle name</strong></td>
		  <td width="27%"><strong>Last name</strong></td>
		  <td width="6%">&nbsp;</td>
		</tr>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td> <%
	if(bolEdit)
		strTemp = (String)vRetResult.elementAt(1);
	else
		strTemp = WI.fillTextValue("fname");
	%> <input type="text" name="fname" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="18" value="<%=strTemp%>"></td>
		  <td> <%
	if(bolEdit)
		strTemp = WI.getStrValue(vRetResult.elementAt(2));
	else
		strTemp = WI.fillTextValue("mname");
	%> <input name="mname" type="text" class="textbox" id="mname"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="18" value="<%=strTemp%>"></td>
		  <td> <%
	if(bolEdit)
		strTemp = (String)vRetResult.elementAt(3);
	else
		strTemp = WI.fillTextValue("lname");
	%> <input name="lname" type="text" class="textbox" id="lname"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="18" value="<%=strTemp%>"></td>
		  <td>&nbsp;</td>
		</tr>
		<%
	if(bolNewApplicantID) {//show applicant's generated ID.%>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td colspan="3">&nbsp;</td>
		  <td>&nbsp;</td>
		</tr>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td colspan="3" align="right"><font size="3"><strong>Applicant's Reference 
			ID: <font color="blue"><%=(String)vRetResult.elementAt(0)%></font></strong></font></td>
		  <td>&nbsp;</td>
		</tr>
		<%}//only if applicant is generated for the first time.%>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td colspan="3" valign="bottom"><strong>Contact No.</strong></td>
		  <td>&nbsp;</td>
		</tr>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td colspan="3"> <%
	if(bolEdit)
		strTemp = WI.getStrValue(vRetResult.elementAt(4));
	else
		strTemp = WI.fillTextValue("tel_no");
	%> <input name="tel_no" type="text" size="32" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>">      </td>
		  <td>&nbsp;</td>
		</tr>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td colspan="3" valign="bottom"><strong>Email Address</strong></td>
		  <td>&nbsp;</td>
		</tr>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td colspan="3"> <%
	if(bolEdit)
		strTemp = WI.getStrValue(vRetResult.elementAt(5));
	else
		strTemp = WI.fillTextValue("email");
	%> <input name="email" type="text" class="textbox" id="email"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" value="<%=strTemp%>"></td>
		  <td>&nbsp;</td>
		</tr>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td colspan="3" valign="bottom"><strong>Position Applying for </strong></td>
		  <td>&nbsp;</td>
		</tr>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td colspan="3"> <%
	if(bolEdit)
		strTemp = (String)vRetResult.elementAt(6);
	else
		strTemp = WI.fillTextValue("emp_type");
	%> <select name="emp_type" >
			  <option value="0">Select Position </option>
			  <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", strTemp, false)%> </select> </td>
		  <td>&nbsp;</td>
		</tr>
		<tr> 
		  <td height="24">&nbsp;</td>
		  <td colspan="3" valign="bottom"><strong>Years/Months of Experience in Position 
			Applying for</strong></td>
		  <td>&nbsp;</td>
		</tr>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td colspan="3" valign="bottom"><strong> 
			<%
	if(bolEdit)
		strTemp = WI.getStrValue(vRetResult.elementAt(7));
	else
		strTemp = WI.fillTextValue("yrs");
	%>
			<input name="yrs" type="text" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" size="3" maxlength="2"
		  value="<%=strTemp%>">
			</strong>years <strong>&nbsp;&nbsp;&nbsp; 
			<%
	if(bolEdit)
		strTemp = WI.getStrValue(vRetResult.elementAt(8));
	else
		strTemp = WI.fillTextValue("months");
	%>
			<input name="months" type="text" class="textbox" id="months"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" size="3" maxlength="2"
		  value="<%=strTemp%>">
			</strong>months</td>
		  <td>&nbsp;</td>
		</tr>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td colspan="3" valign="bottom"><strong>Date of Application</strong></td>
		  <td>&nbsp;</td>
		</tr>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td colspan="3"> <%
	if(bolEdit)
		strTemp = (String)vRetResult.elementAt(9);
	else
		strTemp = WI.fillTextValue("doa");
	%> <input name="doa" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
			onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('appl_profile','doa','/')" size="12" maxlength="12" value="<%=strTemp%>"
			 onKeyUp="AllowOnlyIntegerExtn('appl_profile','doa','/')"> <a href="javascript:show_calendar('appl_profile.doa');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>      </td>
		  <td>&nbsp;</td>
		</tr>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td colspan="3">&nbsp;</td>
		  <td>&nbsp;</td>
		</tr>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td colspan="3"><div align="center"> 
			  <% if (iAccessLevel > 1){
			  if(WI.fillTextValue("create").equals("-1") ) {%>
				 <a href="javascript:DeleteRecord();"><img src="../../../images/delete.gif" border="0"></a> 
					<font size="1">click to delete entries</font>
			  <%}else {
				if(!bolEdit) {%>
				  <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
				  <font size="1">click to save entries</font>
				  <%}else{%>
					 <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a>
					 <font size="1">click to save changes</font>
				  <a href='javascript:CancelRecord();'><img src="../../../images/cancel.gif" border="0"></a>
				  <font size="1"> click to cancel and clear entries</font> 
				  <%}
				}
			}//iAccessLevel > 1%>
			</div></td>
		  <td>&nbsp;</td>
		</tr>
		<tr> 
		  <td height="25" colspan="5">&nbsp;</td>
		</tr>
	  </table>
<%}//do not dhow if create is not called%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="info_index" value="<%=strInfoIndex%>">
  <input type="hidden" name="page_action">
  <!-- create = 1 , to create new applicant -->
  <input type="hidden" name="create" value="<%=WI.fillTextValue("create")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>


