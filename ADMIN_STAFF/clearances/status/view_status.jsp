<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
<!--
function ReloadPage()
{
	document.form_.ctype.value=document.form_.type_index[document.form_.type_index.selectedIndex].text;
	this.SubmitOnce('form_');
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
-->
</script>
<%@ page language="java" import="utility.*,clearance.ClearanceMain, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = new Vector();
	
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTRCol = "";
	String [] astrPosted = {"No", "Yes"};	
	int iSearchResult =0;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Clearances-Clearance Status-View Status","view_status.jsp");
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
														"Clearances","Clearance Status",request.getRemoteAddr(),
														"view_status.jsp");
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
	ClearanceMain clrMain = new ClearanceMain();
		
		if(WI.fillTextValue("showresult").length() > 0 && WI.fillTextValue("sy_from").length()>0 && WI.fillTextValue("sy_to").length()>0 && WI.fillTextValue("semester").length()>0) {
			vRetResult = clrMain.viewStatus(dbOP, request);
			if(vRetResult == null)// && WI.fillTextValue("sy_from").length()>0 && WI.fillTextValue("sy_to").length()>0 && WI.fillTextValue("semester").length()>0)
				strErrMsg = clrMain.getErrMsg();
			else	
				iSearchResult = clrMain.getSearchCount();
		}
%>

<body bgcolor="#D2AE72">
<form name="form_" method="post" action = "view_status.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        CLEARANCES- VIEW STATUS PAGE ::::</strong></font></div></td>
    </tr>
</table>  
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="25" colspan="4"><%=WI.getStrValue(strErrMsg)%></td>
  </tr>
  <tr> 
    <td width="2%" height="25">&nbsp;</td>
    <td>School Year / Term</td>
    <td colspan="2"> 
<% strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0 && request.getParameter("sy_from") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); 
%> 
	
	<input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
      to 
      <%  strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0 && request.getParameter("sy_from") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %> <input name="sy_to" type="text" size="4" maxlength="4" 
		  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
      / 
      <select name="semester">
      <%
		strTemp = WI.fillTextValue("semester");
	if(strTemp.length() ==0 )
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	if(strTemp.compareTo("0") ==0){%>
        <option value="0" selected>Summer</option>
        <%}else{%>
        <option value="0">Summer</option>
        <%}if(strTemp.compareTo("1") ==0){%>
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
      </select> &nbsp;&nbsp;&nbsp;&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td>Clearance Type</td>
    <td colspan="2"> <%strTemp2 = WI.fillTextValue("type_index");%> <select name="type_index" onChange="ReloadPage();">
        <option value="">Select Clearance Type</option>
        <%=dbOP.loadCombo("CLE_CTYPE_INDEX","CLEARANCE_TYPE"," FROM CLE_TYPE WHERE IS_VALID = 1 AND IS_DEL = 0", strTemp2, false)%> </select> </td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td>Specific Student ID</td>
    <td width="24%"><input name="stud_id" type="text"  value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
    </td>
    <td width="55%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a><font size="1">click 
      to search Student ID</font></td>
  </tr>
  <tr>
    <td height="40">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0" onClick="document.form_.showresult.value='1'"></a></td>
    <td>&nbsp;</td>
  </tr>
</table>
<%if (vRetResult!=null && vRetResult.size()>0){%>
<table  bgcolor="#FFFFFF" width="100%" cellspacing="0" cellpadding="0" border="0">
	<tr> 
		<td height="25" colspan="5" bgcolor="#B9B292" class="thinborder">
			<div align="center">CLEARANCE STATUS FOR <%=WI.getStrValue(request.getParameter("ctype"))%></div>
		</td>
	</tr>
	<tr>
		<td colspan="5" height="25" class="thinborder">
			<div align="right">
				<%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/clrMain.defSearchSize;
		if(iSearchResult % clrMain.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>Jump
				To page: 
				<select name="jumpto" onChange="ReloadPage();">
					<%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
					<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
					<%}else{%>
					<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
					<%	}
			}
			%>
				</select>
				<%} else {%>&nbsp;<%}%>
			</div>
		</td>		
	</tr>
	<tr> 
		<td width="30%" height="25" class="thinborder">
			<div align="center"><font size="1"><strong>STUDENT </strong></font></div>
		</td>
		<td width="20%" class="thinborder">
					<div align="center"><font size="1"><strong>ACTION TAKEN / <br>POSTING STATUS</strong></font></div>
		</td>
		<td width="20%" class="thinborder">
			<div align="center"><font size="1"><strong>DUE/AMOUNT</strong></font></div>
		</td>
		<td width="20%" class="thinborder">
			<div align="center"><font size="1"><strong>REQUIREMENT</strong></font></div>
		</td>
	</tr>
	<%for (int i = 0; i<vRetResult.size();i+=18){%>
	<%if (((String)vRetResult.elementAt(i+12)).compareTo("0")==0)
		strTRCol = " bgcolor='#FFDDDD'";
	else
		strTRCol = " bgcolor='#FFFFFF'";%>
	<tr<%=strTRCol%>>
		
		<td height="25" class="thinborder"><font size="1">
			<%if (i>0 && ((String)vRetResult.elementAt(i)).compareTo((String)vRetResult.elementAt(i-18))==0){%>
			&nbsp; 
			<%}else{%><strong>ID Number:&nbsp;</strong>
			<%=(String)vRetResult.elementAt(i)%><br><strong>Name:</strong>&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+1),(String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),7)%>
			<%}%>
			</font></td>
	
		<td class="thinborder"><font size="1">
		<strong>Posted by:</strong> <br><%=(String)vRetResult.elementAt(i+16)%>-<%=WI.getStrValue((String)vRetResult.elementAt(i+17),"&nbsp;")%><br>
		<strong>Action Taken:</strong> <%=WI.getStrValue((String)vRetResult.elementAt(i+6),"","","NONE")%><br>
		<strong>Posted to Ledger:</strong> <%=astrPosted[Integer.parseInt((String)vRetResult.elementAt(i+10))]%>
		</font></td>
		<td class="thinborder"><font size="1">
			<strong>Amount:</strong> <%=WI.getStrValue((String)vRetResult.elementAt(i+7),"","","NONE")%><br>
			<strong>Quantity:</strong> <%=WI.getStrValue((String)vRetResult.elementAt(i+8),"","","NONE")%><%=WI.getStrValue((String)vRetResult.elementAt(i+9),"&nbsp;","","&nbsp;")%></font></td>
		<td class="thinborder"><font size="1">
		<strong>Requirement:</strong> <%=WI.getStrValue((String)vRetResult.elementAt(i+14),"","","NONE")%><br>
		<strong>Remarks:</strong> <%=WI.getStrValue((String)vRetResult.elementAt(i+15),"","","NONE")%><br>
		</font></td>
	</tr>
	<%}%>
</table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="print_page">
<input type="hidden" name="ctype">
<input type="hidden" name="showresult" value="<%=WI.fillTextValue("showresult")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>