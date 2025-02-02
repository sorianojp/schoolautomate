<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.nav {
     color: #000000;
	 font-weight:normal;
}
.nav-highlight {
     color: #0000FF;
     background-color:#BCDEDB;
}

</style>

</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript">

function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}

function checkAllSaveItems() {
	var maxDisp = document.form_.item_count.value;
	var bolIsSelAll = document.form_.selAllSaveItems.checked;
	for(var i =1; i<= maxDisp; ++i)
		eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
}

function ViewAll(){
	document.form_.page_action.value = "";
	document.form_.submit();
}

function PageAction(strAction){
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;		


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-other sch fee","fm_other_sch_fee_vatable.jsp");
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
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"fm_other_sch_fee_vatable.jsp");
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
String strSYFrom = WI.fillTextValue("sy_from");


strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0 && strSYFrom.length() > 0){
	int iMaxItem = Integer.parseInt(WI.getStrValue(WI.fillTextValue("item_count"),"0"));
	if(iMaxItem == 0)
		strErrMsg = "No list of fees found.";
	else{
		int iTemp = 0;
		for (int i = 1; i <= iMaxItem; i++) {
			if (WI.fillTextValue("save_" + i).length() > 0) {
				++iTemp;
				break; //if even one entry is checked, proceed
			}
		}
		if (iTemp == 0) 
			strErrMsg = "Please select atleast 1 fees to save.";			
		else{
			
			strTemp = "update fa_oth_sch_fee set is_vatable = 0 where is_del=0 and is_valid=1 and year_level=0 and "+
				" sy_index=(select sy_index from FA_SCHYR where sy_from="+strSYFrom+")";
			dbOP.executeUpdateWithTrans(strTemp, null, null, false);
			
			strTemp = "update fa_oth_sch_fee set is_vatable = 1 where is_valid =1 and othsch_fee_index = ?";
			java.sql.PreparedStatement pstmtUpdate = dbOP.getPreparedStatement(strTemp);
			
			for (int i = 1; i <= iMaxItem; i++) {
				if (WI.fillTextValue("save_" + i).length() == 0) 
					continue;
					
				pstmtUpdate.setString(1, WI.fillTextValue("save_" + i));
				pstmtUpdate.executeUpdate();
			}
		}
	}
}


Vector vRetResult = new Vector();

if(strSYFrom.length() > 0){
	strTemp = 
		" select othsch_fee_index, fee_name, is_vatable "+
		" from FA_OTH_SCH_FEE where is_del=0 and is_valid=1 and year_level=0 and "+
		" sy_index=(select sy_index from FA_SCHYR where sy_from="+strSYFrom+") order by FEE_NAME asc";
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next()){
		vRetResult.addElement(rs.getString(1));
		vRetResult.addElement(rs.getString(2));
		vRetResult.addElement(rs.getString(3));
	}rs.close();
	
	if(vRetResult == null)
		strErrMsg = "No other school fees created.";
}

%>


<form name="form_" action="./fm_other_sch_fee_vatable.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr bgcolor="#A49A6A">
		<td height="25"><div align="center"><font color="#FFFFFF"><strong>::::OTHER SCHOOL FEES MAINTENANCE PAGE ::::</strong></font></div></td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">   
    <tr> 
      <td height="22">&nbsp;</td>
      <td height="22" colspan="2"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td width="3%" height="22">&nbsp;</td>
      <td width="13%">School year</td>
      <td width="84%"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> </td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href='javascript:ViewAll();'><img src="../../../images/view.gif" border="0"></a> 
        <font size="1">View Other School Fee detail.</font> </td>
    </tr>
    
  </table>

<%
if(vRetResult != null && vRetResult.size() > 0){
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF"> 
	<tr>
	    <td width="7%" class="thinborder" align="center"><strong>COUNT</strong></td>
		<td width="84%" class="thinborder"><strong>FEE NAME</strong></td>
		<td width="9%" align="center" class="thinborder"><strong>SELECT ALL<br>
				<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();">
		</strong></td>
	</tr>
	<%
	int iCount = 0;
	for(int i = 0; i < vRetResult.size(); i+=3){
	%>
	<tr class="nav" id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on')" onMouseOut="navRollOver('msg<%=i%>', 'off')">
		<td class="thinborder" height="22"><%=++iCount%>.</td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+1),"&nbsp;")%></td>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i+2),"0");
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg =  "";
		%>
		<td class="thinborder" align="center">
			<input type="checkbox" name="save_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" tabindex="-1" <%=strErrMsg%>>
		</td>
	</tr>
	<%}%>
	
	<input type="hidden" name="item_count" value="<%=iCount%>">
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td align="center">
		<a href="javascript:PageAction('1');"><img src="../../../images/save.gif" border="0"></a>
		<font size="1">Click to save vatable fees</font>
	</td></tr>
</table>
<%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
<tr bgcolor="#FFFFFF"><td height="22" colspan="9">&nbsp;</td></tr>
<tr bgcolor="#A49A6A"><td height="22" colspan="9">&nbsp;</td></tr>
 
<input type="hidden" name="page_action">
</table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
